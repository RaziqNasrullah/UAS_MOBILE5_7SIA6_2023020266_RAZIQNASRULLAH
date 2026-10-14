#!/usr/bin/env bash
# Membuat zip source code tanpa folder build & cache.
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="MyHealthGw_source_2023020266.zip"
rm -f "$OUT"
zip -r "$OUT" . \
  -x "build/*" "*/build/*" ".dart_tool/*" ".idea/*" "*.iml" ".gradle/*" "android/.gradle/*" \
     "android/app/.cxx/*" "android/local.properties" ".flutter-plugins*" ".git/*" "*.zip" ".vscode/*"
echo "Selesai: $OUT"
