# ╭──────────────────────────────────────────────────────────╮
# │ Apple iOS Emoji - Oh My Font (OMF) Extension             │
# │ Author: Fuzail Mansuri (@fuzailmansuri)                  │
# │ https://github.com/fuzailmansuri/emoji-fonts             │
# ╰──────────────────────────────────────────────────────────╯

(
    # Check config: support EMOJI, EMOJ, or auto-activate if font exists in /sdcard/OhMyFont
    CFG_EMOJI="$(valof EMOJI 2>/dev/null)"
    [ -z "$CFG_EMOJI" ] && CFG_EMOJI="$(valof EMOJ 2>/dev/null)"
    [ "$CFG_EMOJI" = "false" ] && return

    ui_print '+ Apple iOS Emoji Extension'
    ui_print '  Author: Fuzail Mansuri'

    EMOJI_PRIMARY="IosEmoji.ttf"
    EMOJI_ALT="AppleColorEmoji.ttf"
    SRC_EMOJI=""

    # 1. Locate the iOS emoji font source
    for loc in "$OMFDIR/$EMOJI_PRIMARY" \
               "$OMFDIR/$EMOJI_ALT" \
               "$OMFDIR/Emoji.ttf" \
               "$FONTS/$EMOJI_PRIMARY" \
               "$FONTS/$EMOJI_ALT" \
               "$FONTS/Emoji.ttf"; do
        if [ -f "$loc" ]; then
            SRC_EMOJI="$loc"
            break
        fi
    done

    # If not found directly, discover any *emoji*.[ot]tf in OMFDIR
    if [ -z "$SRC_EMOJI" ]; then
        SRC_EMOJI="$(find "$OMFDIR" -maxdepth 1 -type f -iname '*emoji*.[ot]tf' 2>/dev/null | head -n 1)"
    fi

    # Handle compressed .xz archive if present
    case "$SRC_EMOJI" in
        *.xz)
            ui_print '  Extracting iOS emoji archive...'
            tar xJf "$SRC_EMOJI" -C "$FONTS" 2>/dev/null || xz -dc "$SRC_EMOJI" > "$FONTS/$EMOJI_PRIMARY"
            SRC_EMOJI="$FONTS/$EMOJI_PRIMARY"
            ;;
    esac

    # Remote fallback download if font is missing during flash
    if [ ! -f "$SRC_EMOJI" ]; then
        ui_print '  Fetching iOS emoji font...'
        curl -sL "https://raw.githubusercontent.com/fuzailmansuri/emoji-fonts/main/prebuilt/IosEmoji.ttf" \
             -o "$FONTS/$EMOJI_PRIMARY" 2>/dev/null || \
        wget -qO "$FONTS/$EMOJI_PRIMARY" "https://raw.githubusercontent.com/fuzailmansuri/emoji-fonts/main/prebuilt/IosEmoji.ttf" 2>/dev/null
        if [ -f "$FONTS/$EMOJI_PRIMARY" ]; then
            SRC_EMOJI="$FONTS/$EMOJI_PRIMARY"
        fi
    fi

    [ -f "$SRC_EMOJI" ] || {
        ui_print '! iOS Emoji font file not found!'
        abort '! Please place IosEmoji.ttf in /sdcard/OhMyFont and reflash.'
    }

    # 2. Deploy to all system emoji font targets
    # Android 10-12: NotoColorEmoji.ttf
    # Android 13-16: NotoColorEmoji.ttf AND NotoColorEmojiFlags.ttf (or NotoColorEmoji-Legacy.ttf)
    # Samsung OneUI: SamsungColorEmoji.ttf
    TARGET_LIST="NotoColorEmoji.ttf NotoColorEmojiFlags.ttf NotoColorEmoji-Legacy.ttf SamsungColorEmoji.ttf"

    # Also query the real system font mirror on the device
    if [ -d "$ORISYSFONT" ]; then
        SYS_MATCHES="$(find "$ORISYSFONT" -maxdepth 1 -type f -iname '*emoji*.[ot]t[fc]' -exec basename {} + 2>/dev/null)"
        TARGET_LIST="$(echo "$TARGET_LIST $SYS_MATCHES" | tr ' ' '\n' | sort -u)"
    fi

    ui_print '  Injecting iOS emoji into system typefaces...'
    for target_font in $TARGET_LIST; do
        cp -f "$SRC_EMOJI" "$SYSFONT/$target_font"
        chmod 644 "$SYSFONT/$target_font"
    done

    # Maintain native OMF reference
    cp -f "$SRC_EMOJI" "$SYSFONT/Emoji.ttf"
    chmod 644 "$SYSFONT/Emoji.ttf"
    cp -f "$SRC_EMOJI" "$FONTS/Emoji.ttf" 2>/dev/null

    # 3. Purge Android 12-16 /data/fonts cache immediately
    [ -d /data/fonts ] && rm -rf /data/fonts

    # 4. Persistent post-fs-data hook
    # Wipes /data/fonts on every boot before system_server / FontManagerService initializes
    mkdir -p "$OMFDIR/post-fs-data.d"
    cat << 'EOF' > "$OMFDIR/post-fs-data.d/00_ios_emoji_datafonts_purge.sh"
#!/system/bin/sh
# Apple iOS Emoji - Suppress /data/fonts override
# Author: Fuzail Mansuri (@fuzailmansuri)
[ -d /data/fonts ] && rm -rf /data/fonts
EOF
    chmod +x "$OMFDIR/post-fs-data.d/00_ios_emoji_datafonts_purge.sh"

    # 5. Persistent service hook
    # Cleans runtime caches, disables GMS font provider, replaces in-app emojis
    mkdir -p "$OMFDIR/service.d"
    cat << 'EOF' > "$OMFDIR/service.d/99_ios_emoji_service.sh"
#!/system/bin/sh
# Apple iOS Emoji - Late-Boot Runtime Cleanup & GMS Neutralization
# Author: Fuzail Mansuri (@fuzailmansuri)

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# Re-check and clear /data/fonts if recreated during boot
[ -d /data/fonts ] && rm -rf /data/fonts

# Disable GMS Font Provider to prevent EmojiCompat from re-downloading Google Noto Emoji
pm disable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider 2>/dev/null
pm disable com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService 2>/dev/null
rm -rf /data/user/0/com.google.android.gms/files/fonts/opentype/*emoji* 2>/dev/null
rm -rf /data/user_de/0/com.google.android.gms/files/fonts/opentype/*emoji* 2>/dev/null

# Clear Gboard emoji bitmap caches so newly installed iOS emojis render immediately
for gb in /data/data/com.google.android.inputmethod.latin \
          /data/user_de/0/com.google.android.inputmethod.latin; do
    if [ -d "$gb" ]; then
        find "$gb" -type d -name "*cache*" -exec rm -rf {} + 2>/dev/null
    fi
done
am force-stop com.google.android.inputmethod.latin 2>/dev/null

# Scan and replace in-app downloaded emoji fonts (WhatsApp, Messenger, Facebook, Instagram, Telegram)
find /data/data /data/user/0 -type f -iname "*emoji*.[ot]tf" 2>/dev/null | while IFS= read -r app_font; do
    cp -f /system/fonts/NotoColorEmoji.ttf "$app_font" 2>/dev/null
done
EOF
    chmod +x "$OMFDIR/service.d/99_ios_emoji_service.sh"

    # 6. Notify OMF environment
    EMOJ=true
    ver ios-emoji
)
