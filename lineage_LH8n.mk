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

PRODUCT_SYSTEM_NAME := Tecno Pova 5 Pro 5G
PRODUCT_SYSTEM_DEVICE := LH8n

# Build info
PRODUCT_GMS_CLIENTID_BASE := android-transsion

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="TECNO-LH8n-user 14 UP1A.231005.007 240910V771 release-keys" \
    BuildFingerprint=TECNO/LH8n-GL/TECNO-LH8n:14/UP1A.231005.007/240910V771:user/release-keys \
    SystemModel=$(PRODUCT_SYSTEM_DEVICE) \
    SystemName=$(PRODUCT_SYSTEM_NAME) \
    ProductModel=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME)

# AxionFlags
AXION_CAMERA_REAR_INFO := 50
AXION_CAMERA_FRONT_INFO := 16
AXION_MAINTAINER := xiannn
AXION_PROCESSOR := Dimensity_6080
TARGET_INCLUDE_AXFX := true
BYPASS_CHARGE_SUPPORTED := false
TARGET_DISABLE_EPPE := true

# Vulkan media fix
TARGET_NEEDS_VULKAN_MEDIA_FIX := true

# Enable activity open override fix for low-end devices or devices affected by activity open/exit freezing issue 
PERF_ANIM_OVERRIDE := true

# CPU governor support
PERF_GOV_SUPPORTED := true
PERF_DEFAULT_GOV := schedutil

# doze flags
# for devices with doze/sensor related issues 
TARGET_NEEDS_DOZE_FIX := true
# doze gestures
TARGET_DOZE_TAP_PULSE_SUPPORTED ?= true
TARGET_DOZE_DOUBLE_TAP_PULSE_SUPPORTED ?= true
TARGET_DOZE_PICKUP_PULSE_SUPPORTED ?= true
TARGET_DOZE_SIDE_FPS_PULSE_SUPPORTED ?= true

TARGET_SUPPORTED_REFRESH_RATES := 60,90,120

$(call soong_config_set,surfaceflinger,frame_rate_category_high,120)
$(call soong_config_set,surfaceflinger,frame_rate_category_min,60)

SURFACE_FLINGER_BOOST := true

# Graphics: force OpenGL backend for MediaTek compatibility
PRODUCT_PRODUCT_PROPERTIES += \
    debug.hwui.renderer=skiagl

PRODUCT_SYSTEM_PROPERTIES += \
    debug.renderengine.backend=skiaglthreaded \
    persist.sys.vk_use_ogl_for_media=false

# OTA Updater
PRODUCT_SYSTEM_PROPERTIES += \
    lineage.updater.uri=https://raw.githubusercontent.com/Swaggyxren/axion_ota/main/OTA/{variant}/{device}.json

