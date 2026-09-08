# AOSP Modular Emoji Packages & Overlays

Comprehensive emoji replacement packages, RRO runtime overlays, and framework integration patches for custom Android / AOSP ROMs.

## Included Emoji Packs
- **Apple / iOS Emoji** (`LunarisIosEmoji.ttf`)
- **Facebook Emoji** (`FacebookEmoji.ttf`)
- **Samsung One UI Emoji** (`SamsungColorEmoji.ttf`)
- **SwiftUI Emoji** (`SwiftUIEmoji.ttf`)

## Repository Structure
```
├── prebuilt/       # TrueType font files (.ttf)
├── overlays/       # Runtime Resource Overlay (RRO) configs (und-Zsye fallback)
├── patches/        # Complete patch series for AOSP ROM integration
│   ├── frameworks_base/
│   ├── packages_apps_Settings/
│   ├── vendor_themes/
│   └── vendor_yaap/
├── Android.bp      # Blueprint build definitions
└── fonts.mk        # Product packaging makefile
```

## ROM Integration Guide
1. Include `fonts.mk` in your device/vendor product tree:
   ```make
   $(call inherit-product, vendor/themes/fonts.mk)
   ```
2. Apply the patches in `patches/` to enable runtime switching via Settings and multi-layer OEM font parsing.
