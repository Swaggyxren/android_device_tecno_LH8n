#
# Copyright (C) 2026 The LineageOS Project
# Copyright (C) 2026 The Infinity-X Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from device makefile.
$(call inherit-product, device/tecno/LH8n/device.mk)

# Inherit common Infinity stuff.
$(call inherit-product, vendor/infinity/config/common_full_phone.mk)

# Infinity-X Specific Flags
INFINITY_MAINTAINER := xiannn
TARGET_BOOT_ANIMATION_RES := 1080
TARGET_HAS_UDFPS := false
TARGET_SUPPORTS_QUICK_TAP := true
WITH_GAPPS ?= true
PERF_ANIM_OVERRIDE := true

# Device identifier. This must come after all inclusions
PRODUCT_NAME := infinity_LH8n
PRODUCT_DEVICE := LH8n
PRODUCT_MANUFACTURER := TECNO
PRODUCT_BRAND := TECNO
PRODUCT_MODEL := Tecno Pova 5 Pro 5G

PRODUCT_SYSTEM_NAME := Tecno Pova 5 Pro 5G
PRODUCT_SYSTEM_DEVICE := LH8n

# Build info
PRODUCT_GMS_CLIENTID_BASE := android-transsion

# A17 requires a space-free system fingerprint (derived value would contain
# the pretty PRODUCT_SYSTEM_NAME); override it explicitly.
BUILD_SYSTEM_FINGERPRINT := TECNO/LH8n-GL/TECNO-LH8n:$(PLATFORM_VERSION)/$(BUILD_ID)/$(BUILD_NUMBER_FROM_FILE):$(TARGET_BUILD_VARIANT)/$(BUILD_VERSION_TAGS)

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="TECNO-LH8n-user 14 UP1A.231005.007 240910V771 release-keys" \
    BuildFingerprint=TECNO/LH8n-GL/TECNO-LH8n:14/UP1A.231005.007/240910V771:user/release-keys \
    SystemModel="$(PRODUCT_SYSTEM_DEVICE)" \
    SystemName="$(PRODUCT_SYSTEM_NAME)" \
    ProductModel="$(PRODUCT_SYSTEM_DEVICE)" \
    DeviceProduct="$(PRODUCT_SYSTEM_NAME)"
