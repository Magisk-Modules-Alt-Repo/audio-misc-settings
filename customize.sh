# Replace the value of "ro.audio.usb.period_us"

if "$IS64BIT"; then
 :
else
  sed -i 's/ro\.audio\.usb\.period_us=.*$/ro\.audio\.usb\.period_us=5600/' "$MODPATH/system.prop"
fi
