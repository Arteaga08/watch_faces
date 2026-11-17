#!/usr/bin/env bash
# Validates a watch face XML with the official WFF validator (google/watchface).
# Usage: shared/scripts/validate.sh <face-name>
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FACE="${1:?Usage: validate.sh <face-name>}"
FACE_DIR="$ROOT/faces/$FACE"
XML="$FACE_DIR/src/main/res/raw/watchface.xml"
MANIFEST="$FACE_DIR/src/main/AndroidManifest.xml"

# Pinned commit of the official repo (bump deliberately, never track a branch).
VALIDATOR_REPO="https://github.com/google/watchface.git"
VALIDATOR_COMMIT="d1cdafa953c95d5554fc54df4bc3948befbefc4d"
TOOLS_DIR="$ROOT/shared/tools"
SRC_DIR="$TOOLS_DIR/watchface"
JAR="$SRC_DIR/third_party/wff/specification/validator/build/libs/wff-validator.jar"

[[ -f "$XML" ]] || { echo "No existe $XML" >&2; exit 1; }

# Read the WFF version declared in the manifest.
VERSION="$(sed -n 's/.*watchface.format.version"[[:space:]]*android:value="\([0-9]*\)".*/\1/p' "$MANIFEST" | head -1)"
if [[ -z "$VERSION" ]]; then
    VERSION="$(tr -d '\n' < "$MANIFEST" | sed -n 's/.*watchface\.format\.version"[[:space:]]*android:value="\([0-9]*\)".*/\1/p')"
fi
[[ -n "$VERSION" ]] || { echo "No encontré la versión de WFF en $MANIFEST" >&2; exit 1; }

if [[ ! -f "$JAR" ]]; then
    echo "Compilando el validador oficial (commit ${VALIDATOR_COMMIT:0:7}), solo la primera vez..."
    mkdir -p "$TOOLS_DIR"
    if [[ ! -d "$SRC_DIR/.git" ]]; then
        git clone --quiet "$VALIDATOR_REPO" "$SRC_DIR"
    fi
    git -C "$SRC_DIR" fetch --quiet origin "$VALIDATOR_COMMIT"
    git -C "$SRC_DIR" checkout --quiet "$VALIDATOR_COMMIT"
    (cd "$SRC_DIR/third_party/wff" && ./gradlew --quiet :specification:validator:executable-jar)
fi

echo "Validando $FACE con WFF v$VERSION..."
java -jar "$JAR" "$VERSION" "$XML"
