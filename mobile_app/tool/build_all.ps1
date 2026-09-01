[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiBaseUrl,

    [string]$AndroidApiBaseUrl,

    [switch]$Production,

    [switch]$SkipTests
)

$ErrorActionPreference = 'Stop'
$productionValue = if ($Production) { 'true' } else { 'false' }
$resolvedAndroidApiBaseUrl = if ([string]::IsNullOrWhiteSpace($AndroidApiBaseUrl)) {
    $ApiBaseUrl
} else {
    $AndroidApiBaseUrl
}

if ($Production -and (
    -not $ApiBaseUrl.StartsWith('https://') -or
    -not $resolvedAndroidApiBaseUrl.StartsWith('https://')
)) {
    throw 'Production Web and Android builds require HTTPS API URLs.'
}

if ($Production -and [string]::IsNullOrWhiteSpace($env:RESTO_TABLET_API_KEY)) {
    throw 'Set RESTO_TABLET_API_KEY before creating a production Android build.'
}

function Invoke-Flutter {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)

    & flutter @Arguments
    if ($LASTEXITCODE -ne 0) {
        # Do not repeat arguments because an Android build may contain the
        # tablet credential in a dart-define.
        throw 'Flutter command failed. Review the command output above.'
    }
}

Invoke-Flutter pub get

if (-not $SkipTests) {
    Invoke-Flutter analyze
    Invoke-Flutter test
}

# Parallel Flutter builds share .dart_tool and build, so they are intentionally
# sequential. The Web bundle never receives the shared tablet credential.
Invoke-Flutter build web --release `
    "--dart-define=PRODUCTION=$productionValue" `
    "--dart-define=API_BASE_URL=$ApiBaseUrl"

$androidArguments = @(
    'build', 'apk', '--release',
    "--dart-define=PRODUCTION=$productionValue",
    "--dart-define=API_BASE_URL=$resolvedAndroidApiBaseUrl"
)

if (-not [string]::IsNullOrWhiteSpace($env:RESTO_TABLET_API_KEY)) {
    $androidArguments += "--dart-define=TABLET_API_KEY=$($env:RESTO_TABLET_API_KEY)"
}

Invoke-Flutter @androidArguments

Write-Host ''
Write-Host 'Builds completed:'
Write-Host '  Web:     build\web'
Write-Host '  Android: build\app\outputs\flutter-apk\app-release.apk'
