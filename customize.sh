#!/system/bin/sh

# Replace system property values for old Androids and some low performance SoC's

function replaceSystemProps_Old()
{
    sed -i \
        -e 's/ro\.audio\.usb\.period_us=.*$/ro\.audio\.usb\.period_us=3875/' \
        -e 's/ro\.audio\.resampler\.psd\.enable_at_samplerate=.*$/ro\.audio\.resampler\.psd\.enable_at_samplerate=48000/' \
        -e 's/ro\.audio\.resampler\.psd\.stopband=.*$/ro\.audio\.resampler\.psd\.stopband=167/' \
        -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=368/' \
        -e 's/ro\.audio\.resampler\.psd\.tbwcheat=.*$/ro\.audio\.resampler\.psd\.tbwcheat=106/' \
            "$MODPATH/system.prop"
    sed -i \
        -e 's/ro\.audio\.usb\.period_us=.*$/ro\.audio\.usb\.period_us=3875/' \
        -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=320/' \
            "$MODPATH/system.prop-workaround"
}

function replaceSystemProps_Kona()
{
    sed -i \
        -e 's/ro\.audio\.usb\.period_us=.*$/ro\.audio\.usb\.period_us=20375/' \
            "$MODPATH/system.prop"
    sed -i \
        -e 's/ro\.audio\.usb\.period_us=.*$/ro\.audio\.usb\.period_us=20375/' \
            "$MODPATH/system.prop-workaround"
}

function replaceSystemProps_MTK_some()
{
    sed -i \
        -e 's/ro\.audio\.usb\.period_us=.*$/ro\.audio\.usb\.period_us=875/' \
            "$MODPATH/system.prop"
    sed -i \
        -e 's/ro\.audio\.usb\.period_us=.*$/ro\.audio\.usb\.period_us=875/' \
            "$MODPATH/system.prop-workaround"
}

if "$IS64BIT"; then
    case "`getprop ro.board.platform`" in
        "kona" )
            replaceSystemProps_Kona
            ;;
        mt68* )
            if [ "`getprop ro.vendor.build.version.release`" -ge "11" ]; then
                replaceSystemProps_MTK_some
            fi
            ;;
        mt67[56]* )
            replaceSystemProps_Old
            ;;
    esac
else
    replaceSystemProps_Old
fi

# AudioFlinger's resampler has a bug on an Android OS of which version is less than 12.
# This bug makes the resampler to distort audible audio output by wrong aliasing processing
#   when specifying a transition band around or higher than the Nyquist frequency

if [ "`getprop ro.system.build.version.release`" -lt "12"  -a  "`getprop ro.system.build.date.utc`" -lt "1648632000" ]; then
    mv -f "$MODPATH/system.prop-workaround" "$MODPATH/system.prop"
else
    rm -f "$MODPATH/system.prop-workaround"
fi
