#!/usr/bin/env bash
# Импорт ресурсов и прогон всех тестов без окна. Код выхода 0 — все тесты прошли.
set -euo pipefail
cd "$(dirname "$0")/.."
godot --headless --import >/dev/null 2>&1 || true
godot --headless -s addons/gut/gut_cmdln.gd
