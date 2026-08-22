#!/bin/bash

echo "- Applying Aperture Mediatek HFPS Mode and EIS Patches"
cd packages/apps/Aperture
curl https://raw.githubusercontent.com/MillenniumOSS/patches/refs/heads/sixteen/packages/apps/Aperture/0001-Aperture-Enable-MediaTek-HFPS-Mode-for-60-FPS-video-.patch | git am || {
  RET=1
  git am --abort >/dev/null 2>&1
}
curl https://raw.githubusercontent.com/MillenniumOSS/patches/refs/heads/sixteen/packages/apps/Aperture/0002-Aperture-Enable-MediaTek-EIS-and-EIS-preview-mode-fo.patch | git am || {
  RET=1
  git am --abort >/dev/null 2>&1
}
cd ../../../

if [ $RET -ne 0 ]; then
  echo "ERROR: Patch is not applied! Maybe it's already patched, or you'll have to adapt it to this specific rom source?"
else
  echo "OK: All patched"
fi

echo "- Applying PowerOffAlarm kernel headers fix (bionic sched_param redefinition)"
if [ -f hardware/mediatek/packages/PowerOffAlarm/Android.bp ]; then
  if sed -i '/"generated_kernel_headers",/d' hardware/mediatek/packages/PowerOffAlarm/Android.bp; then
    echo "OK: PowerOffAlarm fix applied"
  else
    echo "ERROR: Failed to patch PowerOffAlarm/Android.bp"
  fi
else
  echo "WARN: hardware/mediatek not found here, skipping PowerOffAlarm fix"
fi