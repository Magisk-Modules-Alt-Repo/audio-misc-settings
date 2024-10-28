#!/system/bin/sh

# Check whether Magisk magic mount compatible or not
function isMagiskMountCompatible()
{
    local tmp="$(magisk --path)"
    if [ -z "$tmp" ]; then
        return 1
    elif [ -d "${tmp}/.magisk/mirror/vendor" ]; then
        return 0
    else
        return 1
    fi
}

# Get the active audio policy configuration fille from the audioserever
function getActivePolicyFile()
{
    dumpsys media.audio_policy | awk ' 
        /^ Config source: / {
            print $3
        }' 
}

function stopDRC()
{
    # stopDRC has two args specifying a main audio policy configuration XML file (eg. audio_policy_configuration.xml) and its dummy one to be overridden

     if [ $# -eq 2  -a  -r "$1"  -a  -w "$2" ]; then
        # Copy and override an original audio_policy_configuration.xml to its dummy file
        cp -f "$1" "$2"
        # Change audio_policy_configuration.xml file to remove DRC
        sed -i 's/speaker_drc_enabled[:space:]*=[:space:]*"true"/speaker_drc_enabled="false"/' "$2"
    fi
}

# Get the actual audio configuration XML file name, even for Xiaomi, OnePlus, etc.  stock devices
#    that may overlay another file on the dummy mount point file

function getActualConfigXML()
{
    if [ $# -eq 1 ]; then
        local dir=${1%/*}
        local fname=${1##*/}
        local sname=${fname%.*}
        
        if [ -r "${dir}/${sname}_sec.xml" ]; then
            echo "${dir}/${sname}_sec.xml"
        elif [ -e "${dir}_qssi"  -a  -r "${dir}_qssi/${fname}" ]; then
            # OnePlus stock pattern
            echo "${dir}_qssi/${fname}"
        elif [ "${dir##*/}"  = "sku_`getprop ro.board.platform`"  -a  -r "${dir%/*}/${fname}" ]; then
            # OnePlus stock pattern2
            echo "${dir%/*}/${fname}"
        elif [ -r "${dir}/audio/${fname}" ]; then
            # Xiaomi stock pattern
            echo "${dir}/audio/${fname}"
        elif [ -r "${dir}/${sname}_base.xml" ]; then
            echo "${dir}/${sname}_base.xml"
        else
            echo "$1"
        fi
    fi
}

function toHexLE()
{
    if [ $# -eq 1  -a  $1 -gt 0 ]; then
        printf "%2.2x%2.2x%2.2x%2.2x" $(( $1 % 256 ))  $(( $1 / 256 % 256 ))  $(( $1 / 256 / 256 % 256 ))  $(( $1 / 256 / 256 / 256 % 256 ))
        return 0
    else
        return 1
    fi
}

function toHexLineLE()
{
    if [ $# -eq 1 ]; then
        local i
        for i in $1; do
            toHexLE $i
        done
        return 0
    else
        return 1
    fi
}

function toHexString()
{
    if [ $# -ge 1 ]; then
        local tmp
        tmp=`echo -n "$1" | xxd -p | tr -d ' \n'`
        if [ $# -eq 2 ]; then
            if [ ${#tmp} -ge $2 ]; then
                echo -n ${tmp:0:$2}
            else
                local strt=`expr ${#tmp} + 1`
                echo -n "$tmp"
                for i in `seq $strt $2` ; do
                    echo -n "0"
                done
            fi
        else
            echo -n "$tmp"
        fi
    else
      return 1
    fi
}

# Patch libalsautils.so and audio_usb_aoc.so (Tensor's offload USB driver) to map a property string to another
#   arg1: original libalsautils.so file;  arg2: patched libalsautils.so file; 
function patchMapProperty()
{
    local orig_prop='ro.audio.usb.period_us'
    local new_prop='vendor.audio.usb.perio'
    
    if [ $# -eq 2  -a  -r "$1" ]; then
      local pat1=`toHexString "$orig_prop"`
      local pat2=`toHexString "$new_prop" ${#pat1}`
      
      xxd -p <"$1" | tr -d ' \n' | sed -e "s/$pat1/$pat2/" \
          | awk 'BEGIN {
                 foldWidth=60
                 getline buf
                 len=length(buf)
                 for (i=1; i <= len; i+=foldWidth) {
                     if (i + foldWidth - 1 <= len)
                         print substr(buf, i, foldWidth)
                     else
                         print substr(buf, i, len)
                 }
                 exit
             }'  \
         | xxd -r -p >"$2"
      return $?
    else
      return 1
    fi
}

# Patch libalsautils.so to clear the 96kHz lock of USB audio class drivers
#   arg1: original libalsautils.so file;  arg2: patched libalsautils.so file; 
#     optional arg3: "max" (clearing upto 768kHz), "full" (clearing upto 386kHz), "default" or others (clearing upto 192kHz)
function patchClearLock()
{
    local orig_rates='96000  88200  192000  176400  48000  44100  32000  24000  22050  16000  12000  11025  8000'
    local new_rates='192000  176400  96000  88200  48000  44100  32000  24000  22050  16000  12000  11025  8000'
    
    if [ $# -ge 2  -a  -r "$1" ]; then
        if [ $# -gt 2 ]; then
            case "$3" in
                "max" )
                    new_rates='768000  705600  384000  352800  192000  176400  96000  88200  48000  44100  24000  16000  8000'
                    ;;
                "full" )
                    new_rates='384000  352800  192000  176400  96000  88200  48000  44100  32000  24000  16000  12000  8000'
                    ;;
                "default" | * )
                    ;;
          esac
      fi

        local pat1=`toHexLineLE "$orig_rates"`
        local pat2=`toHexLineLE "$new_rates"`
      
        # A workaroud for a SELinux permission bug on Android 12
        local prop1=`toHexString "ro.audio.usb.period_us"`
        local prop2=`toHexString "vendor.audio.usb.perio"`
      
        xxd -p <"$1" | tr -d ' \n' | sed -e "s/$prop1/$prop2/" -e "s/$pat1/$pat2/" \
            | awk 'BEGIN {
                foldWidth=60
                getline buf
                len=length(buf)
                for (i=1; i <= len; i+=foldWidth) {
                    if (i + foldWidth - 1 <= len)
                        print substr(buf, i, foldWidth)
                    else
                        print substr(buf, i, len)
                }
                exit
              }'  \
            | xxd -r -p >"$2"
            
        return $?
        
    else
        
        return 1
    fi
}

# Patch audio_usb_aoc.so file to clear the 192kHz lock of USB audio class Tensor offload drivers
#   arg1: original audio_usb_aoc.so file;  arg2: patched audio_usb_aoc.so file; 
function patchClearTensorOffloadLock()
{
    local orig_rates='192000  96000  48000  44100  32000  24000  22050  16000  12000  11025  8000'
    local new_rates='768000  705600  384000  352800  192000  176400  96000  88200  48000  44100  8000'

    if [ $# -ge 2  -a  -r "$1" ]; then
        local pat1=`toHexLineLE "$orig_rates"`
        local pat2=`toHexLineLE "$new_rates"`

        # A workaroud for a SELinux permission bug on Android 12
        local prop1=`toHexString "ro.audio.usb.period_us"`
        local prop2=`toHexString "vendor.audio.usb.perio"`

        # sample rate limiter at 192kHz
        local ul1=`toHexLineLE "192000"`
        local ul2=`toHexLineLE "768000"`
          
#        Don't work yet. Need more inviestigations
#        xxd -p <"$1" | tr -d ' \n' | sed -e "s/$prop1/$prop2/" -e "s/$ul1/$ul2/" -e "s/$pat1/$pat2/" \
        xxd -p <"$1" | tr -d ' \n' | sed -e "s/$prop1/$prop2/" \
            | awk 'BEGIN {
                 foldWidth=60
                 getline buf
                 len=length(buf)
                 for (i=1; i <= len; i+=foldWidth) {
                     if (i + foldWidth - 1 <= len)
                         print substr(buf, i, foldWidth)
                     else
                         print substr(buf, i, len)
                 }
                 exit
               }'  \
             | xxd -r -p >"$2"
             
        return $?
        
    else
        return 1
    fi
}

function makeLibraries()
{
    local MAGISKPATH="$(magisk --path)"
    local d lname
    
    for d in "lib" "lib64"; do
        for lname in "libalsautils.so" "libalsautilsv2.so" "audio_usb_aoc.so"; do
            if [ -r "${MAGISKPATH}/.magisk/mirror/vendor/${d}/${lname}" ]; then
                mkdir -p "${MODPATH}/system/vendor/${d}"
                patchMapProperty "${MAGISKPATH}/.magisk/mirror/vendor/${d}/${lname}" "${MODPATH}/system/vendor/${d}/${lname}"
                chmod 644 "${MODPATH}/system/vendor/${d}/${lname}"
                chcon u:object_r:vendor_file:s0 "${MODPATH}/system/vendor/${d}/${lname}"
                chown root:root "${MODPATH}/system/vendor/${d}/${lname}"
                chmod -R a+rX "${MODPATH}/system/vendor/${d}"
                if [ -z "${REPLACEFILES}" ]; then
                    REPLACEFILES="/system/vendor/${d}/${lname}"
                else
                    REPLACEFILES="${REPLACEFILES} /system/vendor/${d}/${lname}"
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

function replaceSystemProps_VHPerf()
{
    sed -i \
        -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
        -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
            "$MODPATH/system.prop"
    sed -i \
        -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
        -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
            "$MODPATH/system.prop-workaround"
   
    sed -i \
        -e 's/ro\.audio\.resampler\.psd\.enable_at_samplerate=.*$/ro\.audio\.resampler\.psd\.enable_at_samplerate=44100/' \
        -e 's/ro\.audio\.resampler\.psd\.stopband=.*$/ro\.audio\.resampler\.psd\.stopband=194/' \
        -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=520/' \
        -e 's/ro\.audio\.resampler\.psd\.tbwcheat=.*$/ro\.audio\.resampler\.psd\.tbwcheat=98/' \
            "$MODPATH/system.prop"
    sed -i \
        -e 's/ro\.audio\.resampler\.psd\.enable_at_samplerate=.*$/ro\.audio\.resampler\.psd\.enable_at_samplerate=44100/' \
        -e 's/ro\.audio\.resampler\.psd\.stopband=.*$/ro\.audio\.resampler\.psd\.stopband=194/' \
        -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=520/' \
        -e 's/ro\.audio\.resampler\.psd\.tbwcheat=.*$/ro\.audio\.resampler\.psd\.tbwcheat=98/' \
            "$MODPATH/system.prop-workaround"
}

function replaceSystemProps_Old()
{
    if [ -e "${MODPATH%/*/*}/modules/usb-samplerate-unlocker"  -o  -e "${MODPATH%/*/*}/modules_update/usb-samplerate-unlocker" ]; then
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2250/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2250/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2250/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2250/' \
                "$MODPATH/system.prop-workaround"
        
        loosenedMessage
        
    else
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2250/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2250/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2250/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2250/' \
                "$MODPATH/system.prop-workaround"
    
    fi
    
    sed -i \
        -e 's/ro\.audio\.resampler\.psd\.enable_at_samplerate=.*$/ro\.audio\.resampler\.psd\.enable_at_samplerate=48000/' \
        -e 's/ro\.audio\.resampler\.psd\.stopband=.*$/ro\.audio\.resampler\.psd\.stopband=165/' \
        -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=360/' \
        -e 's/ro\.audio\.resampler\.psd\.tbwcheat=.*$/ro\.audio\.resampler\.psd\.tbwcheat=104/' \
            "$MODPATH/system.prop"
    sed -i \
        -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=320/' \
            "$MODPATH/system.prop-workaround"

}

function replaceSystemProps_S4()
{
    if [ -e "${MODPATH%/*/*}/modules/usb-samplerate-unlocker"  -o  -e "${MODPATH%/*/*}/modules_update/usb-samplerate-unlocker" ]; then
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=5000/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=5000/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=5000/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=5000/' \
                "$MODPATH/system.prop-workaround"
        
        loosenedMessage
        
    else
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=3875/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=3875/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=3875/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=3875/' \
                "$MODPATH/system.prop-workaround"

    fi
    
    sed -i \
        -e 's/ro\.audio\.resampler\.psd\.enable_at_samplerate=.*$/ro\.audio\.resampler\.psd\.enable_at_samplerate=48000/' \
        -e 's/ro\.audio\.resampler\.psd\.stopband=.*$/ro\.audio\.resampler\.psd\.stopband=165/' \
        -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=360/' \
        -e 's/ro\.audio\.resampler\.psd\.tbwcheat=.*$/ro\.audio\.resampler\.psd\.tbwcheat=104/' \
            "$MODPATH/system.prop"
    sed -i \
        -e 's/ro\.audio\.resampler\.psd\.halflength=.*$/ro\.audio\.resampler\.psd\.halflength=320/' \
            "$MODPATH/system.prop-workaround"
}

function replaceSystemProps_Kona()
{
    if [ -e "${MODPATH%/*/*}/modules/usb-samplerate-unlocker"  -o  -e "${MODPATH%/*/*}/modules_update/usb-samplerate-unlocker" ]; then
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2750/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2750/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2750/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2750/' \
                "$MODPATH/system.prop-workaround"

        loosenedMessage 192kHz

    else
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
                "$MODPATH/system.prop-workaround"

    fi
}

function replaceSystemProps_SDM845()
{
    sed -i \
        -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
        -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
            "$MODPATH/system.prop"
    sed -i \
        -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
        -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
            "$MODPATH/system.prop-workaround"
}

function replaceSystemProps_SDM()
{
    # Do nothing even if "usb-samplerate-unlocker" exists
    :
}

function replaceSystemProps_MTK_Dimensity()
{
    sed -i \
        -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
        -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
            "$MODPATH/system.prop"
    sed -i \
        -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
        -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
            "$MODPATH/system.prop-workaround"
}

function replaceSystemProps_Tensor()
{
    sed -i \
        -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
        -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
            "$MODPATH/system.prop"
    sed -i \
        -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
        -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
            "$MODPATH/system.prop-workaround"
}

function replaceSystemProps_Others()
{
    if [ -e "${MODPATH%/*/*}/modules/usb-samplerate-unlocker"  -o  -e "${MODPATH%/*/*}/modules_update/usb-samplerate-unlocker" ]; then
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
                "$MODPATH/system.prop"
        sed -i \
            -e 's/vendor\.audio\.usb\.perio=.*$/vendor\.audio\.usb\.perio=2000/' \
            -e 's/vendor\.audio\.usb\.out\.period_us=.*$/vendor\.audio\.usb\.out\.period_us=2000/' \
                "$MODPATH/system.prop-workaround"
        
        loosenedMessage
        
    fi
    
}

function stopSpatializer()
{
    # stopSpatializer has two args specifying an audio policy configuration XML file (eg. bluetooth_audio_policy_configuration_7_0.xml) 
    #   and its dummy one to be overridden

    if [ $# -eq 2  -a  -r "$1"  -a  -w "$2" ]; then
        # Copy and override an original audio_policy_configuration.xml to its dummy file
        cp -f "$1" "$2"
        # Change an audio_policy_configuration.xml file to remove Spatializer
        sed -i 's/flags[:space:]*=[:space:]*"AUDIO_OUTPUT_FLAG_SPATIALIZER"//' "$2"
    fi
}

function deSpatializeAudioPolicyConfig()
{
    if [ $# -ne 1  -o  -z "$1"  -o  ! -r "$1" ]; then
        return 1
    fi
    local MAGISKPATH="$(magisk --path)"
    local configXML="$1"
    
    # Don't use "$MAGISKPATH/.magisk/mirror/system${configXML}" instead of "$MAGISKPATH/.magisk/mirror${configXML}".
    # In some cases, the former may link to overlaied "${configXML}" by Magisk itself (not original mirrored "${configXML}").
    local mirrorConfigXML="$MAGISKPATH/.magisk/mirror${configXML}"

    if [ -n "$configXML"  -a  -r "$mirrorConfigXML" ]; then
        grep -e "flags[[:space:]]*=[[:space:]]*\"AUDIO_OUTPUT_FLAG_SPATIALIZER\"" "$mirrorConfigXML" >"/dev/null" 2>&1
        if [ "$?" -eq 0 ]; then
            local modConfigXML="$MODPATH/system${configXML}"
            mkdir -p "${modConfigXML%/*}"
            touch "$modConfigXML"
            stopSpatializer "$mirrorConfigXML" "$modConfigXML"
            chmod 644 "$modConfigXML"
            chcon u:object_r:vendor_configs_file:s0 "$modConfigXML"
            chown root:root "$modConfigXML"
            chmod -R a+rX "${modConfigXML%/*}"
            if [ -z "$REPLACEFILES" ]; then
                REPLACEFILES="/system${configXML}"
            else
                REPLACEFILES="$REPLACEFILES /system${configXML}"
            fi
        fi
    fi
}

function disablePrivApps()
{
    if [ $# -ne 1  -o  -z "$1" ]; then
        return 1
    fi

    local MAGISKPATH="$(magisk --path)"
    local dir mdir
    local PrivApps="$1"
    
    for dir in $PrivApps; do
        if [ -d "${MAGISKPATH}/.magisk/mirror${dir}" ]; then
            case "${dir}" in
                /system/* )
                    dir="${dir#/system}"
                ;;
            esac
            mdir="${MODPATH}/system${dir}"
            mkdir -p "$mdir"
            chmod a+rx "$mdir"
            if [ -z "$REPLACE" ]; then
                REPLACE="/system${dir}"
            else
                REPLACE="${REPLACE} /system${dir}"
            fi
        fi
    done
}

function ui_print_replacelist()
{
    local f
    for f in $1; do
        ui_print "- Replace target file: $f"
    done
}
