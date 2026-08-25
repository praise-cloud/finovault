#!/usr/bin/env bash
# Starts the Finovault reference mock BFF, then runs the Flutter app pointed
# at it over real HTTP. The BFF is stopped when the app exits.
#
# Usage:  ./tool/run_with_mock_bff.sh
set -euo pipefail
PORT=8080

echo "Starting Finovault mock BFF on port $PORT..."
dart run tool/mock_bff/server.dart --port "$PORT" &
BFF_PID=$!

export API_BASE_URL="http://localhost:$PORT"
flutter run --dart-define=API_BASE_URL="http://localhost:$PORT"

kill "$BFF_PID" 2>/dev/null || true
