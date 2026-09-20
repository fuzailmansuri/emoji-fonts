# ╭──────────────────────────────────────────────────────────╮
# │ Apple iOS Emoji - Standalone Installer                   │
# │ Compatible with Magisk, KernelSU, KernelSU-Next, APatch  │
# │ Designed to run cleanly alongside Oh My Font             │
# │ Author: Fuzail Mansuri (@fuzailmansuri)                  │
# ╰──────────────────────────────────────────────────────────╯

ui_print '********************************************'
ui_print '*             Apple iOS Emoji              *'
ui_print '*          Author: Fuzail Mansuri          *'
ui_print '********************************************'

SYSFONTS="$MODPATH/system/fonts"
mkdir -p "$SYSFONTS"

# 1. Deploy font to all system emoji filenames
EMOJI_SRC="$MODPATH/IosEmoji.ttf"
TARGETS="NotoColorEmoji.ttf NotoColorEmojiFlags.ttf NotoColorEmoji-Legacy.ttf SamsungColorEmoji.ttf"

# Discover any other system emoji fonts
ORISYSFONT="/system/fonts"
[ -d "$MAGISKTMP/mirror/system/fonts" ] && ORISYSFONT="$MAGISKTMP/mirror/system/fonts"
if [ -d "$ORISYSFONT" ]; then
    DISCOVERED="$(find "$ORISYSFONT" -maxdepth 1 -type f -iname '*emoji*.[ot]t[fc]' -exec basename {} + 2>/dev/null)"
    TARGETS="$(echo "$TARGETS $DISCOVERED" | tr ' ' '\n' | sort -u)"
fi

ui_print '- Deploying iOS emoji to system fonts...'
for target in $TARGETS; do
    cp -f "$EMOJI_SRC" "$SYSFONTS/$target"
done
rm -f "$EMOJI_SRC"

# 2. Clear Android 12-16 updateable font cache
ui_print '- Purging /data/fonts cache...'
rm -rf /data/fonts 2>/dev/null

# 3. Clear Gboard emoji bitmap caches
ui_print '- Clearing keyboard emoji cache...'
for gb in /data/data/com.google.android.inputmethod.latin \
          /data/user_de/0/com.google.android.inputmethod.latin; do
    if [ -d "$gb" ]; then
        find "$gb" -type d -name "*cache*" -exec rm -rf {} + 2>/dev/null
    fi
done
am force-stop com.google.android.inputmethod.latin 2>/dev/null

# 4. Set proper permissions
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm_recursive "$MODPATH/system/fonts" 0 0 0755 0644

ui_print '- Installation complete! Reboot to apply.'
