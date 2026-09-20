#!/system/bin/sh
# Apple iOS Emoji - Runtime Cache & GMS Cleanup Service
# Author: Fuzail Mansuri (@fuzailmansuri)

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# 1. Re-check /data/fonts
[ -d /data/fonts ] && rm -rf /data/fonts

# 2. Neutralize GMS Font Provider (blocks dynamic Google Noto Emoji re-download)
pm disable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider 2>/dev/null
pm disable com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService 2>/dev/null
rm -rf /data/user/0/com.google.android.gms/files/fonts/opentype/*emoji* 2>/dev/null
rm -rf /data/user_de/0/com.google.android.gms/files/fonts/opentype/*emoji* 2>/dev/null

# 3. Purge Gboard rendered bitmap caches
for gb in /data/data/com.google.android.inputmethod.latin \
          /data/user_de/0/com.google.android.inputmethod.latin; do
    if [ -d "$gb" ]; then
        find "$gb" -type d -name "*cache*" -exec rm -rf {} + 2>/dev/null
    fi
done
am force-stop com.google.android.inputmethod.latin 2>/dev/null

# 4. Replace downloaded in-app emoji fonts (WhatsApp, Messenger, Facebook, Telegram, etc.)
find /data/data /data/user/0 -type f -iname "*emoji*.[ot]tf" 2>/dev/null | while IFS= read -r app_emoji; do
    cp -f /system/fonts/NotoColorEmoji.ttf "$app_emoji" 2>/dev/null
done
