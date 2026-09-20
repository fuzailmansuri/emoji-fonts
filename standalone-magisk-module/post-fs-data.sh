#!/system/bin/sh
# Apple iOS Emoji - Early Boot /data/fonts Cache Purge
# Author: Fuzail Mansuri (@fuzailmansuri)

# Prevent Android 12-16 FontManagerService from overriding /system/fonts
[ -d /data/fonts ] && rm -rf /data/fonts
