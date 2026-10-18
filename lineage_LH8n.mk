#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Evolution X Build Flags
WITH_GMS := true
TARGET_USES_MINI_GAPPS := true
TARGET_ENABLE_BLUR := true
PERF_ANIM_OVERRIDE := true
EVO_BUILD_TYPE := Unofficial
TARGET_HAS_UDFPS := false

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from device makefile.
$(call inherit-product, device/tecno/LH8n/device.mk)

# Inherit some common Evolution X stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Device identifier. This must come after all inclusions
PRODUCT_NAME := lineage_LH8n
PRODUCT_DEVICE := LH8n
PRODUCT_MANUFACTURER := TECNO
PRODUCT_BRAND := TECNO
PRODUCT_MODEL := Tecno Pova 5 Pro 5G

# Build info
PRODUCT_GMS_CLIENTID_BASE := android-transsion

# OTA Updater
PRODUCT_SYSTEM_PROPERTIES += \
    evolution.updater.uri=https://raw.githubusercontent.com/Swaggyxren/ota/main/evolution/{device}.json

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="TECNO-LH8n-user 14 UP1A.231005.007 240910V771 release-keys" \
    BuildFingerprint=TECNO/LH8n-GL/TECNO-LH8n:14/UP1A.231005.007/240910V771:user/release-keys
