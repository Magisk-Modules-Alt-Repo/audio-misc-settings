#!/system/bin/sh

# no longer assume $MAGISKTMP=/sbin/.magisk if Android 11 or later
MAGISKTMP="$(magisk --path)/.magisk"

.  "$MODPATH/functions4.sh"

REPLACE=""

function makeLibraries()
{
    local d lname
    
    for d in "lib" "lib64"; do
        for lname in "libalsautils.so" "libalsautilsv2.so"; do
            if [ -r "${MAGISKTMP}/mirror/vendor/${d}/${lname}" ]; then
                mkdir -p "${MODPATH}/system/vendor/${d}"
                patchMapProperty "${MAGISKTMP}/mirror/vendor/${d}/${lname}" "${MODPATH}/system/vendor/${d}/${lname}"
                chmod 644 "${MODPATH}/system/vendor/${d}/${lname}"
                chmod -R a+rX "${MODPATH}/system/vendor/${d}"
                if [ -z "${REPLACE}" ]; then
                    REPLACE="/system/vendor/${d}/${lname}"
                else
                    REPLACE="${REPLACE} /system/vendor/${d}/${lname}"
                fi
            fi
        done
    done
}

# Replace system property values for old Androids and some low performance SoC's

function loosenedMessage()
{
    local freq="96kHz"
    if [ $# -gt 0 ]; then
        freq="$1"
    fi
    
    ui_print ""
    ui_print "****************************************************************"
    ui_print " Loosened the USB jitter level for more than $freq USB outputs! "
    ui_print "   (\"USB Samplerate Unlocker\" was detected) "
    ui_print "****************************************************************"
    ui_print ""
}

function replaceSystemProps_Old()
{
    if [ -e "${MODPATH%/*/*}/modules/usb-samplerate-unlocker"  -o  -e "${MODPATH%/*/*}/modules_update/usb-samplerate-unlocker" ]; then
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=3875/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=3875/' \
                "$MODPATH/system.prop-workaround"
        
        loosenedMessage
        
    else
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=3375/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=3375/' \
                "$MODPATH/system.prop-workaround"
    
    fi
    
    sed -i \
        -e 's/ro\.audio\.resampler\.psd\.enable_at_samplerate=.*$/ro\.audio\.resampler\.psd\.enable_at_samplerate=48000/' \
        -e 's/ro\.audio\.resampler\.psd\.stopband=.*$/ro\.audio\.resampler\.psd\.stopband=167/' \
        -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=368/' \
        -e 's/ro\.audio\.resampler\.psd\.tbwcheat=.*$/ro\.audio\.resampler\.psd\.tbwcheat=106/' \
            "$MODPATH/system.prop"
    sed -i \
        -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=320/' \
            "$MODPATH/system.prop-workaround"

}

function replaceSystemProps_kona()
{
    if [ -e "${MODPATH%/*/*}/modules/usb-samplerate-unlocker"  -o  -e "${MODPATH%/*/*}/modules_update/usb-samplerate-unlocker" ]; then
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=20375/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=20375/' \
                "$MODPATH/system.prop-workaround"

        loosenedMessage 192kHz

    else
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2625/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2625/' \
                "$MODPATH/system.prop-workaround"

    fi
}

function replaceSystemProps_SDM()
{
    # Do nothing even if "usb-samplerate-unlocker" exists
    :
}

function replaceSystemProps_MTK_Dimensity()
{
    if [ -e "${MODPATH%/*/*}/modules/usb-samplerate-unlocker"  -o  -e "${MODPATH%/*/*}/modules_update/usb-samplerate-unlocker" ]; then
        sed -i \
            -e '$avendor.audio.usb.out.period_us=3250\nvendor.audio.usb.out.period_count=2' \
                "$MODPATH/system.prop"
        sed -i \
            -e '$avendor.audio.usb.out.period_us=3250\nvendor.audio.usb.out.period_count=2' \
                "$MODPATH/system.prop-workaround"

        loosenedMessage
        
    else
        sed -i \
            -e '$avendor.audio.usb.out.period_us=2625\nvendor.audio.usb.out.period_count=2' \
                "$MODPATH/system.prop"
        sed -i \
            -e '$avendor.audio.usb.out.period_us=2625\nvendor.audio.usb.out.period_count=2' \
                "$MODPATH/system.prop-workaround"
        
    fi
    
}

function replaceSystemProps_Others()
{
    if [ -e "${MODPATH%/*/*}/modules/usb-samplerate-unlocker"  -o  -e "${MODPATH%/*/*}/modules_update/usb-samplerate-unlocker" ]; then
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=3250/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=3250/' \
                "$MODPATH/system.prop-workaround"
        
        loosenedMessage
        
    fi
    
}

makeLibraries

if "$IS64BIT"; then
    local board="`getprop ro.board.platform`"
    case "$board" in
        "kona" )
            replaceSystemProps_kona
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
        mt67[56]* )
            replaceSystemProps_Old
            ;;
        * )
            replaceSystemProps_Others
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

rm -f "$MODPATH/functions4.sh"
