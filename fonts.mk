# Fonts
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/themes/fonts/prebuilt,$(TARGET_COPY_OUT_PRODUCT)/fonts)

PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.yaap_emoji_style=android

PRODUCT_PACKAGES += \
    fonts_customization.xml \
    fonts_customization_emoji_ios.xml \
    fonts_customization_emoji_samsung.xml \
    fonts_customization_emoji_swiftui.xml \
    fonts_customization_emoji_facebook.xml \
    FontGoogleSansOverlay \
    FontGoogleSansFlexOverlay \
    FontHarmonySansOverlay \
    FontIBMPlexSansOverlay \
    FontInterOverlay \
    FontLinotteSourceOverlay \
    FontManropeOverlay \
    FontOnePlusSansOverlay \
    FontOneplusSlateSourceOverlay \
    FontRobotoOverlay \
    FontRobotoFlexOverlay \
    FontRubikOverlay \
    FontSonySketchOverlay \
    FontUbuntuOverlay
