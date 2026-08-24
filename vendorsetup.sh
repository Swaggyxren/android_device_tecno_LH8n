#!/bin/bash

APERTURE_FILE="packages/apps/Aperture/app/src/main/java/org/lineageos/aperture/ext/CaptureRequestOptionsBuilder.kt"

if [ ! -f "$APERTURE_FILE" ]; then
  echo "WARN: Aperture not found, skipping patches"
elif grep -q "com.mediatek.streamingfeature.hfpsMode" "$APERTURE_FILE"; then
  echo "OK: Aperture patches already applied, skipping"
else
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
  if [ "${RET:-0}" -ne 0 ]; then
    echo "ERROR: Patch is not applied! Maybe it's already patched, or you'll have to adapt it to this specific rom source?"
  else
    echo "OK: All patched"
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
  echo "WARN: hardware/mediatek not found here, skipping PowerOffAlarm fix"
fi

# ax_deviceinfo battery capacity: content-based revert (no git revert -> no 3-way merge -> no conflict)
# Fixes "[ax_deviceinfo] fix battery capacity using design capacity from BatteryManager" being
# impossible to revert cleanly once unrelated imports were added adjacent to the reverted line.
AX_DEVICEINFO_FILE=""
for c in \
  axion_sdk/ax_deviceinfo/src/com/android/axion/deviceinfo/DeviceInfoProvider.kt \
  axion_sdk/ax_deviceinfo/DeviceInfoProvider.kt \
  vendor/axion/ax_deviceinfo/DeviceInfoProvider.kt; do
  [ -f "$c" ] && AX_DEVICEINFO_FILE="$c" && break
done
[ -z "$AX_DEVICEINFO_FILE" ] && AX_DEVICEINFO_FILE=$(find . -maxdepth 10 -path "*ax_deviceinfo*DeviceInfoProvider.kt" 2>/dev/null | head -1)

echo "- Applying ax_deviceinfo battery capacity revert (content-based, conflict-proof)"
if [ -z "$AX_DEVICEINFO_FILE" ] || [ ! -f "$AX_DEVICEINFO_FILE" ]; then
  echo "WARN: ax_deviceinfo DeviceInfoProvider.kt not found, skipping battery fix"
else
  CHANGED=0
  # 1) If newer Axion (String return type with EXTRA_DESIGN_CAPACITY), force direct PowerProfile read
  if grep -q "EXTRA_DESIGN_CAPACITY" "$AX_DEVICEINFO_FILE"; then
    perl -0pi -e 's~    fun getBatteryCapacity\(context: Context\): String \{.*?\n    \}~    fun getBatteryCapacity(context: Context): String {\n        val capacityMah = PowerProfile(context).getAveragePower(PowerProfile.POWER_BATTERY_CAPACITY).roundToInt()\n        return "\$capacityMah mAh"\n    }~s' "$AX_DEVICEINFO_FILE"
    CHANGED=1
  fi
  # 2) If older Axion (Int return type with BatteryManager property), restore to return 0
  if grep -q "BatteryManager.BATTERY_PROPERTY_DESIGN_CAPACITY" "$AX_DEVICEINFO_FILE"; then
    perl -0pi -e 's~    fun getBatteryCapacity\(\): Int \{\n        val bm = context\.getSystemService\(Context\.BATTERY_SERVICE\) as BatteryManager\n        return bm\.getIntProperty\(BatteryManager\.BATTERY_PROPERTY_DESIGN_CAPACITY\)\n    \}~    fun getBatteryCapacity(): Int {\n        return 0\n    }~' "$AX_DEVICEINFO_FILE"
    CHANGED=1
  fi
  # 3) Ensure the import exists when BatteryManager is used; rebuild the header if needed
  if grep -q "BatteryManager" "$AX_DEVICEINFO_FILE" && ! grep -qx "import android.os.BatteryManager" "$AX_DEVICEINFO_FILE"; then
    tmpfile=$(mktemp)
    { printf 'package com.android.axion.deviceinfo\nimport android.os.BatteryManager\n'; grep -v '^import android.os.BatteryManager\|^package ' "$AX_DEVICEINFO_FILE"; } > "$tmpfile" && mv "$tmpfile" "$AX_DEVICEINFO_FILE"
    CHANGED=1
  fi
  if [ "$CHANGED" -eq 0 ]; then
    echo "OK: battery capacity already patched/reverted, nothing to do"
  else
    echo "OK: battery capacity patch applied (using PowerProfile 5000 mAh)"
  fi
fi

# AxDiagnostics: fix GPU usage parsing for space-separated sysfs nodes (e.g. MediaTek GED "56 0 44")
echo "- Applying AxDiagnostics GPU usage parsing fix"
AX_GPU_INFO=$(find packages/apps/AxDiagnostics -name "GpuInfo.kt" 2>/dev/null | head -1)
if [ -n "$AX_GPU_INFO" ] && [ -f "$AX_GPU_INFO" ]; then
  sed -i 's/busyFile.readText().trim().replace("%", "").toInt()/busyFile.readText().trim().replace("%", "").split(Regex("\\\\s+"))[0].toIntOrNull() ?: 0/g' "$AX_GPU_INFO"
  echo "OK: AxDiagnostics GpuInfo fix applied"
fi

# AxDiagnostics: fix AppUsageCollector microsecond-to-jiffies division (10,000 us/jiffy)
echo "- Applying AxDiagnostics AppUsageCollector jiffies fix"
AX_APP_USAGE=$(find packages/apps/AxDiagnostics -name "AppUsageCollector.kt" 2>/dev/null | head -1)
if [ -n "$AX_APP_USAGE" ] && [ -f "$AX_APP_USAGE" ]; then
  sed -i 's/\/ 10_000_000/\/ 10_000/g' "$AX_APP_USAGE"
  echo "OK: AxDiagnostics AppUsageCollector fix applied"
fi

# Axion: set RenderEngine backend to skiaglthreaded for MediaTek video/gralloc compatibility
echo "- Applying RenderEngine skiaglthreaded backend for MediaTek"
if [ -f device/axion/common/config/defaults_common.prop ]; then
  sed -i 's/debug.renderengine.backend=skiavkthreaded/debug.renderengine.backend=skiaglthreaded/g' device/axion/common/config/defaults_common.prop
  echo "OK: defaults_common.prop updated to skiaglthreaded"
fi