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

# ax_deviceinfo battery capacity: content-based revert (no git revert -> no 3-way merge -> no conflict)
# Fixes "[ax_deviceinfo] fix battery capacity using design capacity from BatteryManager" being
# impossible to revert cleanly once unrelated imports were added adjacent to the reverted line.
AX_DEVICEINFO_FILE="axion_sdk/ax_deviceinfo/DeviceInfoProvider.kt"

echo "- Applying ax_deviceinfo battery capacity revert (content-based, conflict-proof)"
if [ ! -f "$AX_DEVICEINFO_FILE" ]; then
  echo "WARN: $AX_DEVICEINFO_FILE not found, skipping battery fix (adjust AX_DEVICEINFO_FILE if path differs)"
elif ! grep -q "import android.os.BatteryManager" "$AX_DEVICEINFO_FILE"; then
  echo "OK: battery capacity already reverted, nothing to do"
else
  # Remove only the BatteryManager import and restore the original getBatteryCapacity() body.
  perl -0pi -e 's~^import android\.os\.BatteryManager\s*$~~m;
                s~    fun getBatteryCapacity\(\): Int \{\n        val bm = context\.getSystemService\(Context\.BATTERY_SERVICE\) as BatteryManager\n        return bm\.getIntProperty\(BatteryManager\.BATTERY_PROPERTY_DESIGN_CAPACITY\)\n    \}~    fun getBatteryCapacity(): Int {\n        return 0\n    }~' "$AX_DEVICEINFO_FILE"

  # Re-verify before declaring success.
  if grep -q "import android.os.BatteryManager" "$AX_DEVICEINFO_FILE"; then
    echo "ERROR: BatteryManager import still present in $AX_DEVICEINFO_FILE"
  elif grep -q "BATTERY_PROPERTY_DESIGN_CAPACITY" "$AX_DEVICEINFO_FILE"; then
    echo "WARN: import removed but getBatteryCapacity() body differs from known pattern - check manually"
  else
    echo "OK: battery capacity revert applied (import removed, body restored)"
  fi
fi