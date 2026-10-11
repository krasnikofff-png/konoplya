#!/usr/bin/env bash
# Ставит Godot (без редактора не обойтись: он же запускает тесты) в облачное окружение разработки.
# На своём компьютере Godot ставится вручную — см. README.md.
set -euo pipefail
VERSION="4.7.2"
BIN="/opt/godot/Godot_v${VERSION}-stable_linux.x86_64"
if command -v godot >/dev/null 2>&1 && godot --headless --version 2>/dev/null | grep -q "^${VERSION}"; then
	exit 0
fi
mkdir -p /opt/godot
cd /opt/godot
curl -sSL -o godot.zip "https://github.com/godotengine/godot/releases/download/${VERSION}-stable/Godot_v${VERSION}-stable_linux.x86_64.zip"
unzip -oq godot.zip
rm godot.zip
ln -sf "$BIN" /usr/local/bin/godot
godot --headless --version
