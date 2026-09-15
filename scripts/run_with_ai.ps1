<#
  Runs the MBMT Smart Bus app with the AI assistant enabled, reading the
  OpenAI key from secrets.local.json (git-ignored - never committed).
  See the "MBMT Assistant" section in README.md before using this.

  Usage:
    .\scripts\run_with_ai.ps1
    .\scripts\run_with_ai.ps1 -d chrome
    .\scripts\run_with_ai.ps1 -d windows
#>

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$secretsPath = Join-Path $root 'secrets.local.json'
$examplePath = Join-Path $root 'secrets.example.json'

if (-not (Test-Path $secretsPath)) {
    Write-Host 'Missing secrets.local.json.' -ForegroundColor Yellow
    Write-Host 'Copy secrets.example.json to secrets.local.json and fill in OPENAI_API_KEY, then re-run this script:' -ForegroundColor Yellow
    Write-Host "  Copy-Item `"$examplePath`" `"$secretsPath`"" -ForegroundColor Yellow
    exit 1
}

$secrets = Get-Content -Raw -Path $secretsPath | ConvertFrom-Json

$apiKey = $secrets.OPENAI_API_KEY
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Host 'OPENAI_API_KEY is empty in secrets.local.json. Add your key and re-run.' -ForegroundColor Yellow
    exit 1
}

$chatModel = $secrets.OPENAI_MODEL
if ([string]::IsNullOrWhiteSpace($chatModel)) { $chatModel = 'gpt-4o-mini' }

$transcribeModel = $secrets.OPENAI_TRANSCRIBE_MODEL
if ([string]::IsNullOrWhiteSpace($transcribeModel)) { $transcribeModel = 'whisper-1' }

$flutterArgs = @(
    'run',
    "--dart-define=OPENAI_API_KEY=$apiKey",
    "--dart-define=OPENAI_MODEL=$chatModel",
    "--dart-define=OPENAI_TRANSCRIBE_MODEL=$transcribeModel"
) + $args

Push-Location $root
try {
    & flutter @flutterArgs
}
finally {
    Pop-Location
}
