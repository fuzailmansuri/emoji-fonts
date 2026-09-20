# Apple iOS Emoji - Oh My Font (OMF) Extension & Standalone Magisk Module

**Author**: [Fuzail Mansuri](https://github.com/fuzailmansuri)  
**Repository**: [fuzailmansuri/emoji-fonts](https://github.com/fuzailmansuri/emoji-fonts)

---

## Overview

A robust, system-wide Apple iOS emoji replacement engine built for **Oh My Font (OMF)** and standalone **Magisk / KernelSU / APatch** environments across Android 10 through Android 16.

This implementation overcomes the failure points of typical emoji modules on modern Android:

1. **Android 12–16 `/data/fonts` SystemFontManager Override**:
   - Google Play System Updates (Mainline Apex) store updated emojis in `/data/fonts/files/` and register them in `/data/fonts/config/config.xml`.
   - Android's framework checks `/data/fonts` before `/system/fonts`. If `/data/fonts` is populated, normal `/system/fonts` replacements are ignored.
   - **Solution**: The extension automatically wipes `/data/fonts` during installation and registers an early `post-fs-data` hook to suppress `/data/fonts` on every boot before `system_server` initializes.

2. **Android 13+ Flag Font Split (`NotoColorEmojiFlags.ttf`)**:
   - Starting with Android 13, Google moved regional flags into `NotoColorEmojiFlags.ttf`.
   - **Solution**: The extension populates all targets (`NotoColorEmoji.ttf`, `NotoColorEmojiFlags.ttf`, `NotoColorEmoji-Legacy.ttf`, and `SamsungColorEmoji.ttf`) to guarantee full flag and emoji coverage.

3. **Android 15 & 16 Fallback Separation (`font_fallback.xml`)**:
   - Modern Android moved the fallback definitions (`und-Zsye`) out of `fonts.xml` into `/system/etc/font_fallback.xml`.
   - **Solution**: Dynamically updates both `fonts.xml` and `font_fallback.xml`.

4. **Gboard Cached Bitmaps**:
   - Google Keyboard caches rendered bitmap emojis in disk cache folders across CE and DE storage.
   - **Solution**: Clears Gboard's disk caches on boot and restarts Gboard to ensure new Apple emoji glyphs render immediately.

5. **GMS Font Provider & EmojiCompat**:
   - Third-party apps (WhatsApp, Facebook, Messenger, Instagram, X/Twitter, Telegram) use AndroidX `EmojiCompat`, which queries Google Play Services (`com.google.android.gms.fonts`) to download Google Noto Emoji.
   - **Solution**: Disables GMS's font provider component and overwrites downloaded in-app emoji fonts with the iOS emoji font.

6. **Samsung OneUI Compatibility**:
   - Automatically detects and replaces `SamsungColorEmoji.ttf`.

---

## Method 1: Use as an Oh My Font (OMF) Extension

### Quick Setup:
1. Download `IosEmoji-OMF.zip` (or `50_ios_emoji.sh` + `IosEmoji.ttf`).
2. Extract the files into `/sdcard/OhMyFont/`:
   ```
   /sdcard/OhMyFont/
   ├── 50_ios_emoji.sh
   └── IosEmoji.ttf
   ```
3. (Optional) In `/sdcard/OhMyFont/config.cfg`:
   The extension automatically activates whenever `IosEmoji.ttf` is present in `/sdcard/OhMyFont/`. You can also explicitly set either `EMOJI = true` or `EMOJ = true` (or set to `false` to disable).
4. Flash `OMF.zip` in Magisk / KernelSU-Next / KernelSU / APatch and reboot.

---

## Method 2: Standalone Magisk / KernelSU Module

If you do not use Oh My Font:
1. Flash `IosEmoji-Magisk.zip` directly in Magisk / KernelSU / APatch.
2. Reboot your device.

---

## Credits

- **Author & Maintainer**: [Fuzail Mansuri](https://github.com/fuzailmansuri)
