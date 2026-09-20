#!/usr/bin/env bash
# Packaging script for Standalone Apple iOS Emoji Module
# Compatible with KernelSU-Next, KernelSU, Magisk, and APatch
# Author: Fuzail Mansuri (@fuzailmansuri)

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$DIR/.." && pwd)"
OUT="$DIR/IosEmoji-Magisk.zip"
SRC_FONT="$ROOT/prebuilt/IosEmoji.ttf"

if [ ! -f "$SRC_FONT" ]; then
    echo "Error: Font file $SRC_FONT not found!"
    exit 1
fi

TMP_DIR="$(mktemp -d)"

# 1. Standard META-INF installer for KernelSU-Next / KernelSU / Magisk / APatch
mkdir -p "$TMP_DIR/META-INF/com/google/android"

cat << 'EOF' > "$TMP_DIR/META-INF/com/google/android/updater-script"
#MAGISK
EOF

cat << 'EOF' > "$TMP_DIR/META-INF/com/google/android/update-binary"
#!/sbin/sh
#################
# Universal Module Installer (Magisk / KernelSU-Next / KernelSU / APatch)
#################

umask 022
ui_print() { echo "$1"; }

OUTFD=$2
ZIPFILE=$3

mount /data 2>/dev/null

KSU_UTIL="/data/adb/ksu/util_functions.sh"
[ -f "$KSU_UTIL" ] || KSU_UTIL="/data/adb/ksu/bin/util_functions.sh"

MAGISK_UTIL="/data/adb/magisk/util_functions.sh"
APATCH_UTIL="/data/adb/ap/util_functions.sh"
[ -f "$APATCH_UTIL" ] || APATCH_UTIL="/data/adb/ap/bin/util_functions.sh"

if [ -f "$KSU_UTIL" ]; then
  . "$KSU_UTIL"
elif [ -f "$MAGISK_UTIL" ]; then
  . "$MAGISK_UTIL"
elif [ -f "$APATCH_UTIL" ]; then
  . "$APATCH_UTIL"
else
  ui_print "! Unsupported root environment: util_functions.sh not found!"
  exit 1
fi

install_module
EOF
chmod +x "$TMP_DIR/META-INF/com/google/android/update-binary"

# 2. Module metadata and control scripts
cp "$DIR/module.prop" "$TMP_DIR/module.prop"
cp "$DIR/customize.sh" "$TMP_DIR/customize.sh"
cp "$DIR/post-fs-data.sh" "$TMP_DIR/post-fs-data.sh"
cp "$DIR/service.sh" "$TMP_DIR/service.sh"

# 3. Include font payload once (customize.sh links/deploys it during flash)
cp "$SRC_FONT" "$TMP_DIR/IosEmoji.ttf"

# 4. Pack zip archive
cd "$TMP_DIR"
rm -f "$OUT"
zip -9 -r "$OUT" .

rm -rf "$TMP_DIR"
echo "Successfully built Standalone Module for KernelSU-Next/Magisk: $OUT"
