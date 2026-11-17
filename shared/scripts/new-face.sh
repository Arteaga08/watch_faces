#!/usr/bin/env bash
# Creates a new watch face module from faces/template.
# Usage: shared/scripts/new-face.sh <name> "<Nombre visible>"
#   <name>: lowercase letters/digits, used as module dir and package com.vidix.<name>
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
NAME="${1:?Usage: new-face.sh <name> \"<Nombre visible>\"}"
LABEL="${2:?Falta el nombre visible, por ejemplo \"Centinela\"}"
DEST="$ROOT/faces/$NAME"

[[ "$NAME" =~ ^[a-z][a-z0-9]*$ ]] || { echo "El nombre solo puede tener minúsculas y números, y empezar con letra." >&2; exit 1; }
[[ ! -e "$DEST" ]] || { echo "Ya existe faces/$NAME" >&2; exit 1; }

rsync -a --exclude build "$ROOT/faces/template/" "$DEST/"

sed -i '' "s/com\.vidix\.template/com.vidix.$NAME/g" "$DEST/build.gradle.kts"
sed -i '' "s|<string name=\"watch_face_name\">.*</string>|<string name=\"watch_face_name\">$LABEL</string>|" \
    "$DEST/src/main/res/values/strings.xml"

echo "include(\":faces:$NAME\")" >> "$ROOT/settings.gradle.kts"

echo "Creada faces/$NAME (com.vidix.$NAME). Compila con: ./gradlew :faces:$NAME:assembleDebug"
