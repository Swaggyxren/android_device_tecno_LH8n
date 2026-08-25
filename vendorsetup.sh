#!/bin/bash

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
  echo "ERROR: Patch is not applied! Maybe it's already patched, or you'll have to adapt it to this specific rom source?"
else
  echo "OK: All patched"
fi
