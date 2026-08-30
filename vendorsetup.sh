#!/bin/bash
# Android 17 ROM-source fixes, applied idempotently at lunch time.
# (The Aperture HFPS/EIS patches are disabled: they are LOS sixteen-era and
#  do not apply to YAAP 17's Aperture.)

BASE="${TOP:-$(pwd)}"
AUDIO_BP="$BASE/hardware/interfaces/audio/common/all-versions/default/Android.bp"
PATTERN='"true": ["-include common/all-versions/SkipSpeakerLayoutChannelMaskField.h"]'

if [ -f "$AUDIO_BP" ] && ! grep -q 'true: \["-include common/all-versions/SkipSpeakerLayoutChannelMaskField.h"\]' "$AUDIO_BP"; then
    if grep -qF "$PATTERN" "$AUDIO_BP"; then
        sed -i 's|"true": \["-include common/all-versions/SkipSpeakerLayoutChannelMaskField.h"\]|true: ["-include common/all-versions/SkipSpeakerLayoutChannelMaskField.h"]|' "$AUDIO_BP" &&
            echo "[LH8n] applied A17 audio bp soong select fix"
    else
        echo "[LH8n] WARN: audio bp select pattern not found, skipping"
    fi
fi

# PowerOffAlarm: drop generated_kernel_headers to avoid the bionic
# sched_param redefinition (same fix as the axion tree's vendorsetup).
POA_BP="$BASE/hardware/mediatek/packages/PowerOffAlarm/Android.bp"
if [ -f "$POA_BP" ] && grep -q '"generated_kernel_headers",' "$POA_BP"; then
    sed -i '/"generated_kernel_headers",/d' "$POA_BP" &&
        echo "[LH8n] applied PowerOffAlarm sched_param fix"
fi