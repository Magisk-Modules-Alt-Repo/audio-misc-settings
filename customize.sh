# Replace the value of "ro.audio.usb.period_us"

if "$IS64BIT"; then
 :
else
  sed -i \
    -e 's/ro\.audio\.usb\.period_us=.*$/ro\.audio\.usb\.period_us=5600/' \
    -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=320/' \
        "$MODPATH/system.prop"
fi
