#!/system/bin/sh

[ -z "$(magisk --path)" ] && alias magisk='ksu-magisk'

. "$MODPATH/customize-functions.sh"

if ! isMagiskMountCompatible; then
    abort '  ***
  Aborted by no magisk-mirrors (even including kernelSUs):
    Try again after reawaking the mirrors
        by installing my another magisk/kernelSU module
        "Compatible Magisk-mirroring" and rebooting

  ***'
fi

REPLACE=""
REPLACEFILES=""

# Make patched ALSA utility and Tensor's offload libraries for "ro.audio.usb.period_us"
makeLibraries

# Remove post-A13 (especially Tensor's) spatial audio flags in an audio configuration file for avoiding errors
deSpatializeAudioPolicyConfig "/vendor/etc/bluetooth_audio_policy_configuration_7_0.xml"

# Disable pre-installed Moto Dolby faetures and Wellbeing for reducing very large jitter caused by them
#   Excluded "MotorolaSettingsProvider" on Motorala devices only for avoiding their bootloop
if [ "`getprop ro.product.manufacturer`" = "motorola" ]; then
    disablePrivApps "
/system_ext/priv-app/MotoDolbyDax3
/system_ext/priv-app/daxService
/system_ext/priv-app/DaxUI
/system_ext/app/MotoSignatureApp
/product/priv-app/WellbeingPrebuilt
/product/priv-app/Wellbeing
/system_ext/priv-app/WellbeingPrebuilt
/system_ext/priv-app/Wellbeing
"

else
    disablePrivApps "
/system_ext/priv-app/MotoDolbyDax3
/system_ext/priv-app/MotorolaSettingsProvider
/system_ext/priv-app/daxService
/system_ext/priv-app/DaxUI
/system_ext/app/MotoSignatureApp
/product/priv-app/WellbeingPrebuilt
/product/priv-app/Wellbeing
/system_ext/priv-app/WellbeingPrebuilt
/system_ext/priv-app/Wellbeing
"

fi

if "$IS64BIT"; then
    board="`getprop ro.board.platform`"
    case "$board" in
        zuma* | "pineapple"  )
            replaceSystemProps_VHPerf
            ;;
        "kona" | "kalama" | "shima" | "yupik" )
            replaceSystemProps_Kona
            ;;
        "sdm845" )
            replaceSystemProps_SDM845
            ;;
        gs* )
            replaceSystemProps_Tensor
            ;;
        "sdm660" | "bengal" | "holi" )
            replaceSystemProps_SDM
            ;;
        mt68* )
            replaceSystemProps_MTK_Dimensity
            ;;
        mt67[56]? )
            replaceSystemProps_Others
            ;;
        * )
            replaceSystemProps_Others
            ;;
    esac
    
    deleteSystemProps_for_some_Stocks

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

rm -f "$MODPATH/customize-functions.sh" "$MODPATH/LICENSE" "$MODPATH/README.md" "$MODPATH/changelog.md"
ui_print_replacelist "$REPLACEFILES"
