#!/system/bin/sh

. "$MODPATH/customize-functions.sh"

REPLACE=""
makeLibraries

if "$IS64BIT"; then
    board="`getprop ro.board.platform`"
    case "$board" in
        "kona" )
            replaceSystemProps_Kona
            ;;
        "sdm660" | "sdm845" )
            replaceSystemProps_SDM
            ;;
        mt68* )
            if [ -r "/vendor/lib64/hw/audio.usb.${board}.so" ]; then
                replaceSystemProps_MTK_Dimensity
            else
                replaceSystemProps_Others
            fi
            ;;
        mt67[56]? )
            replaceSystemProps_Others
            ;;
        * )
            replaceSystemProps_Others
            ;;
    esac

else
    if [ "`getprop ro.build.product`" = "jfltexx" ]; then
        replaceSystemProps_S4
    else
        replaceSystemProps_Old
    fi

fi

# AudioFlinger's resampler has a bug on an Android OS of which version is less than 12.
# This bug makes the resampler to distort audible audio output by wrong aliasing processing
#   when specifying a transition band around or higher than the Nyquist frequency

if [ "`getprop ro.system.build.version.release`" -lt "12"  -a  "`getprop ro.system.build.date.utc`" -lt "1648632000" ]; then
    mv -f "$MODPATH/system.prop-workaround" "$MODPATH/system.prop"
else
    rm -f "$MODPATH/system.prop-workaround"
fi

rm -f "$MODPATH/customize-functions.sh"
