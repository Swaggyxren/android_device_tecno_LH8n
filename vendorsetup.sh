#!/bin/bash

DEVICE_DIR="$(gettop 2>/dev/null)/device/tecno/LH8n"
[ -d "$DEVICE_DIR" ] || DEVICE_DIR="device/tecno/LH8n"

echo "- Applying Aperture Mediatek HFPS Mode and EIS Patches"
RET=0
cd packages/apps/Aperture || exit 1
curl -fsSL https://raw.githubusercontent.com/MillenniumOSS/patches/refs/heads/sixteen/packages/apps/Aperture/0001-Aperture-Enable-MediaTek-HFPS-Mode-for-60-FPS-video-.patch | git am || {
  RET=1
  git am --abort >/dev/null 2>&1
}
curl -fsSL https://raw.githubusercontent.com/MillenniumOSS/patches/refs/heads/sixteen/packages/apps/Aperture/0002-Aperture-Enable-MediaTek-EIS-and-EIS-preview-mode-fo.patch | git am || {
  RET=1
  git am --abort >/dev/null 2>&1
}
cd ../../../ || exit 1

if [ "$RET" -ne 0 ]; then
  echo "INFO: Aperture patches skipped or already applied."
else
  echo "OK: Aperture patches applied."
fi


echo "- Applying PowerOffAlarm kernel headers fix (bionic sched_param redefinition)"
if [ -f hardware/mediatek/packages/PowerOffAlarm/Android.bp ]; then
  if sed -i '/"generated_kernel_headers",/d' hardware/mediatek/packages/PowerOffAlarm/Android.bp; then
    echo "OK: PowerOffAlarm fix applied"
  else
    echo "ERROR: Failed to patch PowerOffAlarm/Android.bp"
  fi
else
  echo "INFO: hardware/mediatek not found, skipping PowerOffAlarm fix"
fi

# Android 17 audio bp soong select fix
AUDIO_BP="hardware/interfaces/audio/common/all-versions/default/Android.bp"
PATTERN='"true": ["-include common/all-versions/SkipSpeakerLayoutChannelMaskField.h"]'
if [ -f "$AUDIO_BP" ] && ! grep -q 'true: \["-include common/all-versions/SkipSpeakerLayoutChannelMaskField.h"\]' "$AUDIO_BP"; then
  if grep -qF "$PATTERN" "$AUDIO_BP"; then
    sed -i 's|"true": \["-include common/all-versions/SkipSpeakerLayoutChannelMaskField.h"\]|true: ["-include common/all-versions/SkipSpeakerLayoutChannelMaskField.h"]|' "$AUDIO_BP" &&
      echo "OK: applied A17 audio bp soong select fix"
  fi
fi

# hardware/mediatek soong_namespace: ensure hardware/google/pixel/usb and pixelstats are imported
if [ -f hardware/mediatek/Android.bp ]; then
  if ! grep -q '"hardware/google/pixel/usb"' hardware/mediatek/Android.bp; then
    sed -i '/"hardware\/google\/pixel",/a \        "hardware/google/pixel/pixelstats",\n        "hardware/google/pixel/usb",' hardware/mediatek/Android.bp &&
      echo "OK: added pixel/usb and pixelstats imports to hardware/mediatek"
  fi
fi

# device/mediatek/sepolicy_vndr: drop conflicting /class/typec genfscon rule
if [ -f device/mediatek/sepolicy_vndr/base/vendor/genfs_contexts ]; then
  if grep -q "genfscon sysfs /class/typec" device/mediatek/sepolicy_vndr/base/vendor/genfs_contexts; then
    sed -i '/genfscon sysfs \/class\/typec/d' device/mediatek/sepolicy_vndr/base/vendor/genfs_contexts && \
      echo "OK: dropped conflicting /class/typec genfscon from sepolicy_vndr"
  fi
fi

# device/mediatek/sepolicy_vndr: exclude native_app_zygote from mtk_hal_mali_platform_default_service find
if [ -f device/mediatek/sepolicy_vndr/base/vendor/domain.te ]; then
  if ! grep -q -- "-native_app_zygote" device/mediatek/sepolicy_vndr/base/vendor/domain.te; then
    sed -i '/-app_zygote/a \  -native_app_zygote' device/mediatek/sepolicy_vndr/base/vendor/domain.te && \
      echo "OK: excluded native_app_zygote from mtk_hal_mali_platform_default_service in sepolicy_vndr"
  fi
fi


