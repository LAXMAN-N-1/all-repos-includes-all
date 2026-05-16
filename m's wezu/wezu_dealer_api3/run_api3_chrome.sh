#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

flutter pub get
flutter run -d chrome --web-port "${WEB_PORT:-5180}"
