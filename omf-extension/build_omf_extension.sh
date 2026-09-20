#!/usr/bin/env bash
# Packaging script for Apple iOS Emoji OMF Extension
# Author: Fuzail Mansuri (@fuzailmansuri)

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$DIR/.." && pwd)"
OUT="$DIR/IosEmoji-OMF.zip"
SRC_FONT="$ROOT/prebuilt/IosEmoji.ttf"

if [ ! -f "$SRC_FONT" ]; then
    echo "Error: Font file not found in $ROOT/prebuilt/!"
    exit 1
fi

TMP_DIR="$(mktemp -d)"
cp "$DIR/50_ios_emoji.sh" "$TMP_DIR/50_ios_emoji.sh"
cp "$SRC_FONT" "$TMP_DIR/IosEmoji.ttf"

cd "$TMP_DIR"
zip -9 -r "$OUT" 50_ios_emoji.sh IosEmoji.ttf

rm -rf "$TMP_DIR"
echo "Successfully built OMF extension package: $OUT"
