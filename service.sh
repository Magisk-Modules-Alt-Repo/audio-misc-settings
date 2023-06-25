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
    local force_restart_server=0
    
    if [ "`getprop persist.sys.phh.disable_audio_effects`" = "0" ]; then
        resetprop_command="`which_resetprop_command`"
        if [ -n "$resetprop_command" ]; then
            "$resetprop_command" ro.audio.ignore_effects true
            force_restart_server=1
        else
            return 1
        fi
    fi
    
    # Stop Tensor device's AOC daemon for reducing significant jitter
    if [ "`getprop init.svc.aocd`" = "running" ]; then
        setprop ctl.stop aocd
        force_restart_server=1
    fi
    
    # Nullifying the volume listener for no compressing audio (maybe a peak limiter)
    if [ "`getprop persist.sys.phh.disable_soundvolume_effect`" = "0" ]; then
        if [ -r "/system/phh/empty"  -a  -r "/vendor/lib/soundfx/libvolumelistener.so" ]; then
            mount -o bind "/system/phh/empty" "/vendor/lib/soundfx/libvolumelistener.so"
            force_restart_server=1
        fi
        if [ -r "/system/phh/empty"  -a  -r "/vendor/lib64/soundfx/libvolumelistener.so" ]; then
            mount -o bind "/system/phh/empty" "/vendor/lib64/soundfx/libvolumelistener.so"
            force_restart_server=1
        fi
        
    elif [ "`getprop persist.sys.phh.disable_soundvolume_effect`" != "1" ]; then
        # for non- phh GSI's (Qcomm devices only?)
        if [ -r "/vendor/lib/soundfx/libvolumelistener.so" ]; then
            mount -o bind "/dev/null" "/vendor/lib/soundfx/libvolumelistener.so"
            force_restart_server=1
        fi
        if [ -r "/vendor/lib64/soundfx/libvolumelistener.so" ]; then
            mount -o bind "/dev/null" "/vendor/lib64/soundfx/libvolumelistener.so"
            force_restart_server=1
        fi
        
    fi
        
    if [ "$force_restart_server" = "1"  -o  "`getprop ro.system.build.version.release`" -ge "12" ]; then
        if [ -n "`getprop init.svc.audioserver`" ]; then
            setprop ctl.restart audioserver
            sleep 1.2
            if [ "`getprop init.svc.audioserver`" != "running" ]; then
                # workaround for Android 12 old devices hanging up the audioserver after "setprop ctl.restart audioserver" is executed
                local pid="`getprop init.svc_debug_pid.audioserver`"
                if [ -n "$pid" ]; then
                    kill -HUP $pid 1>"/dev/null" 2>&1
                fi
            fi
        fi
        
    fi
    settings put system volume_steps_music 100
}

(((sleep 31; additionalSettings)  0<&- &>"/dev/null" &) &)
