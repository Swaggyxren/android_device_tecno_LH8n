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

# Apply Window Secure Ignore & Screen Capture Privacy Patches
if [ -d "$DEVICE_DIR/patches" ]; then
  echo "- Applying Window Secure Ignore & Hide Screen Capture Patches"
  if [ -d "frameworks/base" ] && [ -f "$DEVICE_DIR/patches/frameworks/base/0001-base-Allow-to-ignore-secure-flags-and-hide-screen-ca.patch" ]; then
    (cd frameworks/base && git am "$DEVICE_DIR/patches/frameworks/base/0001-base-Allow-to-ignore-secure-flags-and-hide-screen-ca.patch" 2>/dev/null || git am --abort >/dev/null 2>&1)
  fi
  if [ -d "packages/apps/Settings" ] && [ -f "$DEVICE_DIR/patches/packages/apps/Settings/0001-Settings-Add-toggles-for-window-secure-ignore-and-hi.patch" ]; then
    (cd packages/apps/Settings && git am "$DEVICE_DIR/patches/packages/apps/Settings/0001-Settings-Add-toggles-for-window-secure-ignore-and-hi.patch" 2>/dev/null || git am --abort >/dev/null 2>&1)
  fi
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
