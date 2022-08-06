#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
    MODDIR=${0%/*}

# Note: Don't use "${MAGISKTMP}/mirror/system/vendor/*" instaed of "${MAGISKTMP}/mirror/vendor/*".
# In some cases, the former may link to overlaied "/system/vendor" by Magisk itself (not mirrored original one).

# This script will be executed in post-fs-data mode

if [ \( -e "${MODDIR%/*/*}/modules/usb-samplerate-unlocker"  -a  ! -e "${MODDIR%/*/*}/modules/usb-samplerate-unlocker/disable" \) \
        -o  -e "${MODDIR%/*/*}/modules_update/usb-samplerate-unlocker" ]; then
    # If usb-samplerate-unlock exists, do nothing because it will do the same thing in itself.
    if [ ! -e "$MODDIR/skip_mount" ]; then
        touch "$MODDIR/skip_mount" 1>"/dev/null" 2>&1
    fi
    
else
    if [ -e "$MODDIR/skip_mount" ]; then
        rm -f  "$MODDIR/skip_mount" 1>"/dev/null" 2>&1
    fi

fi

# End of patch
