# Replace system property values for some low performance SoC's

function replaceSystemProps()
{
    sed -i \
        -e 's/ro\.audio\.usb\.period_us=.*$/ro\.audio\.usb\.period_us=5600/' \
        -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=320/' \
            "$MODPATH/system.prop"
}

if "$IS64BIT"; then
    case "`getprop ro.board.platform`" in
        mt67[56]? )
            replaceSystemProps
            ;;
    esac
else
    replaceSystemProps
fi
