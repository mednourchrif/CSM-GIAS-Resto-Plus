[CmdletBinding()]
param([switch]$SkipMysqlCheck, [switch]$InstallMysql, [switch]$ProvisionDatabase, [switch]$SkipSeed, [switch]$StartAfterDeploy, [int]$Port = 8000)

$ErrorActionPreference = 'Stop'
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Please run deploy_windows.bat as Administrator.' -ForegroundColor Red
    exit 1
}
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Backend = Join-Path $Root '03_Backend'
$EnvFile = Join-Path $Backend '.env'

function Fail([string]$Message) { Write-Host "ERROR: $Message" -ForegroundColor Red; exit 1 }
function New-Secret {
    $bytes = New-Object byte[] 48
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) }
    finally { $rng.Dispose() }
    [Convert]::ToBase64String($bytes).Replace('+','-').Replace('/','_').TrimEnd('=')
}
function Ask([string]$Label, [string]$Default) {
    $value = Read-Host "$Label [$Default]"
    if ([string]::IsNullOrWhiteSpace($value)) { $Default } else { $value.Trim() }
}
function Read-Secret([string]$Label) {
    $secure = Read-Host $Label -AsSecureString
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
}

Write-Host 'CSM-GIAS Resto+ deployment (Windows, no Docker)' -ForegroundColor Cyan
$python = (Get-Command py -ErrorAction SilentlyContinue).Source
if (-not $python) { $python = (Get-Command python -ErrorAction SilentlyContinue).Source }
if (-not $python -and (Get-Command winget -ErrorAction SilentlyContinue)) {
    winget install --id Python.Python.3.13 --exact --scope machine --silent --accept-package-agreements --accept-source-agreements
    $python = (Get-Command py -ErrorAction SilentlyContinue).Source
}
if (-not $python) { Fail 'Python 3.13+ is required. Install Python and rerun.' }

$venv = Join-Path $Backend '.venv'
if (-not (Test-Path (Join-Path $venv 'Scripts\python.exe'))) { & $python -m venv $venv }
$vp = Join-Path $venv 'Scripts\python.exe'
& $vp -m pip install --upgrade pip
& $vp -m pip install -r (Join-Path $Backend 'requirements.txt')

if ($InstallMysql -and -not (Get-Command mysql -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { Fail 'winget is unavailable; install MySQL Server 8+ manually.' }
    Write-Host 'Installing Oracle MySQL Server 8.4. The installer may ask for the root password.' -ForegroundColor Yellow
    winget install --id Oracle.MySQL --exact --silent --accept-package-agreements --accept-source-agreements
    $mysqlBin = Get-ChildItem 'C:\Program Files\MySQL' -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($mysqlBin) { $env:Path = "$($mysqlBin.FullName)\bin;$env:Path" }
}
if (-not $SkipMysqlCheck -and -not (Get-Command mysql -ErrorAction SilentlyContinue)) {
    Fail 'mysql.exe is not in PATH. Install MySQL Server 8+, add its bin folder to PATH, and rerun. SQLite is not supported.'
}

$dbHost = Ask 'MySQL host' '127.0.0.1'
$dbPort = Ask 'MySQL port' '3306'
$dbUser = Ask 'MySQL application user' 'resto_user'
$dbName = Ask 'MySQL database name' 'resto_plus'
$dbPassword = Read-Secret 'MySQL application password'
$trustedHosts = Ask 'Trusted API host/IP (comma-separated)' '127.0.0.1'
$corsOrigins = Ask 'Allowed CORS origins (comma-separated)' 'http://localhost:8000'
$timezone = Ask 'Restaurant IANA timezone' 'Africa/Casablanca'
$adminEmail = Ask 'Initial administrator email' 'admin@csm-gias.tn'
$adminPassword = Read-Secret 'Initial administrator password'
$receptionEmail = Ask 'Initial receptionist email' 'reception@csm-gias.tn'
$receptionPassword = Read-Secret 'Initial receptionist password'
$tabletKey = New-Secret; $appSecret = New-Secret; $jwtSecret = New-Secret
$biometricKey = (& $vp -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())").Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($biometricKey)) { Fail 'Could not generate the biometric encryption key.' }
$quoteList = { param($value) (($value -split ',' | ForEach-Object { '"' + $_.Trim() + '"' }) -join ',') }

$lines = @(
    'APP_NAME="CSM-GIAS Resto+"','APP_VERSION="1.0.0"','APP_DEBUG=false','API_DOCS_ENABLED=false',
    'APP_ENVIRONMENT=production',"APP_SECRET_KEY=$appSecret",'SERVER_HOST=0.0.0.0',"SERVER_PORT=$Port",'SERVER_WORKERS=4',
    "TRUSTED_HOSTS=[$(&$quoteList $trustedHosts)]", "DB_HOST=$dbHost", "DB_PORT=$dbPort", "DB_USER=$dbUser", "DB_PASSWORD=$dbPassword", "DB_NAME=$dbName",
    'DB_POOL_SIZE=10','DB_MAX_OVERFLOW=20','DB_ECHO_SQL=false',"JWT_SECRET_KEY=$jwtSecret",'JWT_ALGORITHM=HS256','JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30','JWT_REFRESH_TOKEN_EXPIRE_DAYS=7','BCRYPT_ROUNDS=12',
    "TABLET_API_KEY=$tabletKey",'FACE_ENGINE=disabled',"BIOMETRIC_ENCRYPTION_KEY=$biometricKey",'LOG_LEVEL=INFO','LOG_FORMAT=json','LOG_FILE_PATH=logs/app.log','LOG_ROTATION=1 day','LOG_RETENTION=30 days',
    "CORS_ORIGINS=[$(&$quoteList $corsOrigins)]", "TZ=$timezone", "SEED_ADMIN_EMAIL=$adminEmail", "SEED_ADMIN_PASSWORD=$adminPassword", "SEED_RECEPTION_EMAIL=$receptionEmail", "SEED_RECEPTION_PASSWORD=$receptionPassword"
)
Set-Content -LiteralPath $EnvFile -Value $lines -Encoding UTF8

if ($ProvisionDatabase) {
    $rootPassword = Read-Secret 'MySQL root password (used only to provision the database)'
    $env:MYSQL_PWD = $rootPassword
    $sql = "CREATE DATABASE IF NOT EXISTS ``$dbName`` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS '$dbUser'@'%' IDENTIFIED BY '$dbPassword'; ALTER USER '$dbUser'@'%' IDENTIFIED BY '$dbPassword'; GRANT ALL PRIVILEGES ON ``$dbName``.* TO '$dbUser'@'%'; FLUSH PRIVILEGES;"
    & mysql --protocol=TCP -h $dbHost -P $dbPort -u root -e $sql
    Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
    if ($LASTEXITCODE -ne 0) { Fail 'MySQL database/user provisioning failed.' }
}

Push-Location $Backend
try {
    & $vp -m alembic upgrade head
    if ($LASTEXITCODE -ne 0) { Fail 'Database migration failed.' }
    if (-not $SkipSeed) { & $vp scripts\seed.py; if ($LASTEXITCODE -ne 0) { Fail 'Database seed failed.' } }
} finally { Pop-Location }

New-NetFirewallRule -DisplayName 'CSM-GIAS Resto+ API' -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow -Profile Any -ErrorAction SilentlyContinue | Out-Null
Write-Host 'Deployment complete.' -ForegroundColor Green
Write-Host "Tablet API key: $tabletKey" -ForegroundColor Yellow
Write-Host "Start the API with: $Root\run_backend.bat" -ForegroundColor Green
if ($StartAfterDeploy) {
    Start-Process -FilePath (Join-Path $Root 'run_backend.bat') -WorkingDirectory $Root
    Write-Host 'Backend process started in a separate window.' -ForegroundColor Green
}
