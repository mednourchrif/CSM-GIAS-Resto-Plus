$ErrorActionPreference = 'Stop'
$mobileRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$keystore = Join-Path $mobileRoot 'android\release-keystore.jks'
$properties = Join-Path $mobileRoot 'android\key.properties'
$keytool = Join-Path ${env:JAVA_HOME} 'bin\keytool.exe'
if (-not (Test-Path $keytool)) { $keytool = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe' }
if (Test-Path $keystore) { Write-Host 'Release keystore already exists.'; exit 0 }
$password = ((New-Guid).Guid + (New-Guid).Guid).Replace('-', '')
& $keytool -genkeypair -v -keystore $keystore -storepass $password -keypass $password -alias csmgias-release -keyalg RSA -keysize 4096 -validity 10000 -dname 'CN=CSM-GIAS-Resto, OU=Mobile, O=CSM-GIAS, L=Unknown, S=Unknown, C=TN'
if ($LASTEXITCODE -ne 0) { throw 'Could not generate the release keystore.' }
Set-Content -LiteralPath $properties -Value @(
    "storePassword=$password"
    "keyPassword=$password"
    'keyAlias=csmgias-release'
    'storeFile=../release-keystore.jks'
) -Encoding ASCII
Write-Host 'Generated android/release-keystore.jks and android/key.properties.' -ForegroundColor Green
Write-Host 'Back up both files securely. The key.properties and keystore are ignored by Git.' -ForegroundColor Yellow
