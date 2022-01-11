#!/system/bin/sh

# sleep 31 secs needed for "settings" commands to become effective
# and make volume medial steps to be 100 if a volume steps facility is used

function additionalSettings()
{
    if [ "`getprop persist.sys.phh.disable_audio_effects`" = "0" ]; then
        
        type resetprop 1>/dev/null 2>&1
        if [ $? -eq 0 ]; then
            resetprop ro.audio.ignore_effects true
        else
            type resetprop_phh 1>/dev/null 2>&1
            if [ $? -eq 0 ]; then
                resetprop_phh ro.audio.ignore_effects true
            else
                return 1
            fi
        fi
        
        if [ "`getprop init.svc.audioserver`" = "running" ]; then
            setprop ctl.restart audioserver
        fi
        
    elif [ "`getprop ro.system.build.version.release`" -ge "12" ]; then
        
        local audioHal
        setprop ctl.restart audioserver
        audioHal="$(getprop |sed -nE 's/.*init\.svc\.(.*audio-hal[^]]*).*/\1/p')"
        setprop ctl.restart "$audioHal" 1>"/dev/null" 2>&1
        setprop ctl.restart vendor.audio-hal-2-0 1>"/dev/null" 2>&1
        setprop ctl.restart audio-hal-2-0 1>"/dev/null" 2>&1
        
    fi
    settings put system volume_steps_music 100
}

(((sleep 31; additionalSettings)  0<&- &>"/dev/null" &) &)
