## A Magisk module for setting miscellaneous audio configuration values (media audio volume steps (100 steps), disabling the effects framework, raising resampling quality, etc.)

This module changes the number of steps in media volume to 100 steps (0.4~0.7dB per step), disables the effects framework (nearly direct low jitter audio pass), and raises the quality of audio resampling (to a mastering quality level) and the bitrate limit of bluetooth codec SBC (dual channel mode) for EDR 2Mbps earphones to improve audio quality effectively in a simple manner.

* This module has been Tested on LineageOS and ArrowOS ROM's, and phh GSI's (Android 10 & 11 & 12, Qualcomm & MediaTek SoC, and Arm32 & Arm64 combinations). 

* Please disable "Adaptive battery" of adaptive preferences in the battery section and battery optimizations for following app's manually through the settings UI of Android OS (to lower less than 10Hz jitter making reverb like distortion). music (streaming) player apps, their licensing apps (if exist), equalizer apps (if exist), "bluetooth" (system app), "NFC Service" (system app; if exists), "Android Services Library" (system app), "Android Shared Library" (system app), "Android System" (system app), "System UI" (system app), "Active Edge Service" (system app; if exists), "Android Device Security Module" (system app; if exists), "crDroid System" (system app; if exists), "LineageOS System" (system app; if exists), launcher app, "Google Play Store" (system app), "Google Play Developer Services" (system app), "Styles & wallpaper" or the like (system app), {Lineage, crDroid, Arrow, etc.} themes app (system app; if exists), Navigation Bar app (system app; if exists), "AOSP panel" (system app; if exists), "OmniJaws" (system app; if exists), "OmniStyle" (system app; if exists), "Magisk", "PhhTrebleApp"(system app; if exists), keyboard app, kernel adiutors (if exist), etc. And also Disable "Digital Wellbeing" (system app; if it exists) itself or its battery optimizations (this is very harmfull for audio like camera servers).

* See also my companion script ["USB_SampleRate_Changer"](https://github.com/yzyhk904/USB_SampleRate_Changer) to change the sample rate of the USB (HAL) audio class driver and a 3.5mm jack on the fly like Bluetooth LDAC or Windows mixer to reduce resampling distortions.

## DISCLAIMER

* I am not responsible for any damage that may occur to your device, so it is your own choice to attempt this module.

## Change logs

# v1.0
* Initial Release

##
