# Apple iOS Emoji Engine

A system-wide Apple iOS emoji replacement package engineered for **Oh My Font (OMF)**, standalone **KernelSU-Next / KernelSU / Magisk / APatch**, and custom AOSP ROMs across Android 10 through Android 16.

**Author & Maintainer**: [Fuzail Mansuri](https://github.com/fuzailmansuri)  
**Repository**: [fuzailmansuri/emoji-fonts](https://github.com/fuzailmansuri/emoji-fonts)

---

## What This Project Provides

- **TrueType Color Font**: High-resolution Apple iOS emoji font (`IosEmoji.ttf`) formatted in Android's native bitmap specification (`CBDT`/`CBLC`) with complete Unicode glyph coverage and regional indicator flags.
- **Oh My Font (OMF) Extension**: Drop-in extension script (`50_ios_emoji.sh`) that hooks into OMF's installation pipeline and unifies iOS emoji into the single OMF module.
- **KernelSU-Next Standalone Module**: Root package (`IosEmoji-Magisk.zip`) that mounts via overlayfs cleanly alongside Oh My Font without XML collisions or bootloops.
- **AOSP ROM Integration**: Blueprint definitions (`Android.bp`) and Runtime Resource Overlay (`fonts_customization_emoji_ios.xml`) for source-built AOSP trees.

---

## Repository Structure

```
├── prebuilt/
│   └── IosEmoji.ttf               # Android-native Apple iOS color emoji font (CBDT/CBLC)
├── omf-extension/
│   ├── 50_ios_emoji.sh            # OMF drop-in extension script (Stage 1-8 hook)
│   ├── build_omf_extension.sh     # Extension packaging tool
│   └── README.md                  # Extension documentation & technical specs
├── standalone-magisk-module/
│   ├── build_magisk_module.sh     # Standalone module packaging tool
│   ├── customize.sh               # KernelSU-Next / Magisk deployment script
│   ├── post-fs-data.sh            # Early boot /data/fonts purge
│   ├── service.sh                 # Late boot GMS & Gboard cache cleanup
│   └── module.prop                # Module metadata
├── overlays/
│   └── fonts_customization_emoji_ios.xml  # AOSP runtime resource overlay
├── Android.bp                     # AOSP blueprint definition
└── fonts.mk                       # Product copy rules
```

---

## Why Other Emoji Modules Fail on Modern Android

1. **/data/fonts SystemFontManager Override (Android 12–16)**:
   Google Play System Updates store updated emojis in `/data/fonts/files/` and register them in `/data/fonts/config/config.xml`. Android's framework prioritizes `/data/fonts/` over `/system/fonts/`. This package purges `/data/fonts` at install time and suppresses it on every boot via `post-fs-data.sh`.

2. **Flag Font Split (`NotoColorEmojiFlags.ttf` on Android 13+)**:
   Google split regional flags into a separate font file. This package populates both `NotoColorEmoji.ttf` and `NotoColorEmojiFlags.ttf` simultaneously to ensure complete flag sequences.

3. **Android 15 & 16 Fallback Separation (`font_fallback.xml`)**:
   Fallback definitions (`und-Zsye`) were moved out of `fonts.xml` into `/system/etc/font_fallback.xml`. This package handles both configurations.

4. **Gboard Cached Bitmaps**:
   Gboard caches rendered emoji bitmaps on disk. This package automatically purges keyboard caches on boot and restarts Gboard so new Apple glyphs appear immediately.

5. **GMS Font Provider & EmojiCompat**:
   Apps using AndroidX `EmojiCompat` download Google Noto Emoji from Google Play Services (`com.google.android.gms.fonts`). This package disables the GMS font provider and replaces cached in-app emoji fonts.

6. **Samsung OneUI Compatibility**:
   Automatically detects and replaces `SamsungColorEmoji.ttf`.

---

## Installation Guide

### Option 1: As an Oh My Font (OMF) Extension (Recommended)
1. Place [`50_ios_emoji.sh`](omf-extension/50_ios_emoji.sh) and [`IosEmoji.ttf`](prebuilt/IosEmoji.ttf) into `/sdcard/OhMyFont/`:
   ```
   /sdcard/OhMyFont/
   ├── 50_ios_emoji.sh
   └── IosEmoji.ttf
   ```
2. The extension auto-detects `IosEmoji.ttf` and enables itself automatically.
3. Flash `OMF.zip` in KernelSU-Next, KernelSU, Magisk, or APatch and reboot.

### Option 2: Standalone Module in KernelSU-Next (Works Alongside OMF)
1. Build the standalone module:
   ```bash
   ./standalone-magisk-module/build_magisk_module.sh
   ```
2. Flash `IosEmoji-Magisk.zip` in KernelSU-Next, KernelSU, Magisk, or APatch.
3. Reboot.

---

## Credits & Maintainer

- **Author & Maintainer**: [Fuzail Mansuri](https://github.com/fuzailmansuri)
