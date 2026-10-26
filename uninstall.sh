#!/system/bin/sh
# Do NOT assume where your module will be located. ALWAYS use $MODDIR if you need to know where this script and module is placed.
# This will make sure your module will still work if Magisk change its mount point in the future
# no longer assume "$MAGISKTMP=/sbin/.magisk" if Android 11 or later
#

# MODDIR=${0%/*}
# MAGISKPATH=$(magisk --path)
# MAGISKTMP=$MAGISKPATH/.magisk

#

function unsetVolumeMediaSteps()
{
    # Delete volume media steps key
    settings delete system volume_steps_music
}

function unsetCSDproperties()
{
    # CSD (Calculated Sound Dose) disabling properties
    settings delete global safe_media_volume_enabled
    settings delete global audio_safe_csd_next_warning
    settings put global audio_safe_volume_state 1
}

# sleep 20 secs needed for settings commans to be effective in an orphan process

(((sleep 20; unsetVolumeMediaSteps; unsetCSDproperties) 0<&- &>"/dev/null" &) &)
