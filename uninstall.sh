#!/system/bin/sh
# Do NOT assume where your module will be located. ALWAYS use $MODDIR if you need to know where this script and module is placed.
# This will make sure your module will still work if Magisk change its mount point in the future
# no longer assume "$MAGISKTMP=/sbin/.magisk" if Android 11 or later
#

# MODDIR=${0%/*}
# MAGISKPATH=$(magisk --path)
# MAGISKTMP=$MAGISKPATH/.magisk

#

# sleep 20 secs needed for settings commans to be effective in an orphan process

(((sleep 20; settings delete system volume_steps_music) 0<&- &>"/dev/null" &) &)
