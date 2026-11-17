#!/usr/bin/env bash
# Builds a watch face (debug) and installs it on the connected watch via adb.
# Usage: shared/scripts/install.sh <face-name> [adb-serial]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FACE="${1:?Usage: install.sh <face-name> [adb-serial]}"
SERIAL="${2:-}"
APK="$ROOT/faces/$FACE/build/outputs/apk/debug/$FACE-debug.apk"

command -v adb >/dev/null || { echo "No encuentro adb. Instala platform-tools y agrégalo al PATH." >&2; exit 1; }

"$ROOT/shared/scripts/validate.sh" "$FACE"
(cd "$ROOT" && ./gradlew --quiet ":faces:$FACE:assembleDebug")

[[ -f "$APK" ]] || { echo "No se generó el APK en $APK" >&2; exit 1; }

ADB=(adb)
[[ -n "$SERIAL" ]] && ADB+=(-s "$SERIAL")
"${ADB[@]}" install -r "$APK"

echo "Listo. En el reloj: mantén presionada la carátula actual → desliza → elige la nueva."
