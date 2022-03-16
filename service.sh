#!/system/bin/sh

# sleep 31 secs needed for "settings" commands to become effective
# and make volume medial steps to be 100 if a volume steps facility is used

function which_resetprop_command()
{
    type resetprop 1>"/dev/null" 2>&1
    if [ $? -eq 0 ]; then
        echo "resetprop"
    else
        type resetprop_phh 1>"/dev/null" 2>&1
        if [ $? -eq 0 ]; then
            echo "resetprop_phh"
        else
            return 1
        fi
    fi
    return 0
}

function additionalSettings()
{
    if [ "`getprop persist.sys.phh.disable_audio_effects`" = "0" ]; then
        resetprop_command="`which_resetprop_command`"
        if [ -n "$resetprop_command" ]; then
            "$resetprop_command" ro.audio.ignore_effects true
        else
            return 1
        fi
        
        if [ "`getprop init.svc.audioserver`" = "running" ]; then
            setprop ctl.restart audioserver
        fi
        
    elif [ "`getprop ro.system.build.version.release`" -ge "12" ]; then
        if [ "`getprop init.svc.audioserver`" = "running" ]; then
            setprop ctl.restart audioserver
        fi
        
    fi
    settings put system volume_steps_music 100
}

(((sleep 31; additionalSettings)  0<&- &>"/dev/null" &) &)
