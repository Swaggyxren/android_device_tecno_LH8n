#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from device makefile.
$(call inherit-product, device/tecno/LH8n/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Device identifier. This must come after all inclusions
PRODUCT_NAME := lineage_LH8n
PRODUCT_DEVICE := LH8n
PRODUCT_MANUFACTURER := TECNO
PRODUCT_BRAND := TECNO
PRODUCT_MODEL := Tecno Pova 5 Pro 5G

# Build info
PRODUCT_GMS_CLIENTID_BASE := android-transsion

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="TECNO-LH8n-user 14 UP1A.231005.007 240910V771 release-keys" \
    BuildFingerprint=TECNO/LH8n-GL/TECNO-LH8n:14/UP1A.231005.007/240910V771:user/release-keys

# AviumUI
AVIUM_MAINTAINER := xiannn
AVIUM_SETTINGS_SOC_MODEL_NAME := MediaTek Dimensity 6080
AVIUM_SETTINGS_DEVICE_CODENAME := LH8n
AVIUM_VERSION_APPEND_TIME_OF_DAY := false
WITH_GMS := true
TARGET_INCLUDE_GOOGLEIME := false
TARGET_GOOGLEIME_OVERRIDE_IME := false
AVIUM_FORCE_SET_FAKE_PROP := true
TARGET_FORCE_ENABLE_BLUR := true
