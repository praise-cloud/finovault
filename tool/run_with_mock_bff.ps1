# Starts the Finovault reference mock BFF, then runs the Flutter app pointed
# at it over real HTTP. The BFF is stopped when the app exits.
#
# Usage:  .\tool\run_with_mock_bff.ps1
$ErrorActionPreference = 'Stop'
$port = 8080

Write-Host "Starting Finovault mock BFF on port $port..."
$bff = Start-Process -NoNewWindow -PassThru -FilePath 'dart' `
  -ArgumentList 'run', 'tool/mock_bff/server.dart', '--port', $port

$env:API_BASE_URL = "http://localhost:$port"
try {
  flutter run --dart-define=API_BASE_URL="http://localhost:$port"
} finally {
  if (-not $bff.HasExited) { Stop-Process -Id $bff.Id -Force }
}
