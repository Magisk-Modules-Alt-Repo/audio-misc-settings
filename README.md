## A Magisk module for setting miscellaneous audio configuration values

This module,
<ol>
    <li>changes the number of steps in media volume to 100 steps (0.4~0.7dB per step),</li>
    <li>raises the resampling quality of the Android OS mixer (AudioFlinger) to a very mastering quality (i.e., no resampling distortion in a real sense),</li>
    <li>disables the effects framework of the mixer (to interface to equalizers, virtualizers, visualizers, echo cancelers, automatic gain controls, etc.) for obtaining a nearly direct low jitter audio pass,</li>
    <li>adjusts a USB transfer period,</li>
    <li>sets a higher bitrate limit of bluetooth codec SBC (dual channel mode) for EDR 2Mbps entry class earphones (not for EDR 3Mbps performance ones),</li>
</ol><br/>
    for improving audio quality effectively in a simple manner.
<br/>
<br/>
<br/>

* Note: This module raises the resampling quality from AOSP standard one (stop-band attenuation 90dB & cut off 100% of the Nyquist frequency & half filter length 32) to a very mastering quality (167dB & 106% & 368 for Android 12 and later devices, 160db & 91% & 480 for Android 9 & 10 & 11 ones (except low performance ones), and 160dB & 91% & 320 for low performance Andoird 9 & 10 & 11 ones). But this cannot raise the quality for Android 8.1 and earlier ones. And those attenuation values are target ones used for a resampler design and may not be accomplished in the AOSP implementation.

* This module has been tested on LineageOS and ArrowOS ROM's, and phh GSI's (Android 10 & 11 & 12, Qualcomm & MediaTek SoC, and Arm32 & Arm64 combinations). 

* Please disable "Manage apps automatically" in "Battery manager" (or "Adaptive battery" of "Adaptive preferences") in the battery section (needless to say, don't enable battery savers and the like), and change "Battery optimization" from "Optimize" to "Don't optimize" (or change "Battery usage" from "Optimized" to "Unrestricted") for following app's manually through the settings UI of Android OS (to lower less than 10Hz jitter making extremely short reverb or foggy sound like distortion). music (streaming) player apps, their licensing apps (if exist), "AirMusic" (if exists), "AirMusic  Recording Service" (system app; if exists), equalizer apps (if exist), "Bluetooth" (system app), "Bluetooth MIDI Service" (system app), "MTP Host" (system app), "NFC Service" (system app; if exists), "Magisk" (if exists), System WebView apps (system app), Browser apps, "PhhTrebleApp" (system app; if exists), "Android Services Library" (system app), "Android Shared Library" (system app), "Android System" (system app), "System UI" (system app), "Input Devices" (system app), {Gesture, 3 Button, 2  Button} Navigation Bar apps (system app), "crDroid System" (system app; if exists), "LineageOS System" (system app; if exists), launcher app, "Google Play Store" (system app), "Google Play services" (system app), "Styles & wallpaper" or the like (system app), {Lineage, crDroid, Arrow, etc.} themes app (system app; if exists),  "AOSP panel" (system app; if exists), "OmniJaws" (system app; if exists), "OmniStyle" (system app; if exists), "Active Edge Service" (system app; if exists), "Android Device Security Module" (system app; if exists), "Call Management" (system app; if exists), "Phone" (system app; if exists), "Phone Calls" (system app; if exists), "Phone Services" (system app; if exists), "Phone and Messaging Storage" (system app; if exists), "Storage Manager" (system app), "Default" (system app; if exists), "Default StatusBar" (system app; if exists), "Wfd Service" (system app; if exists),keyboard app, kernel adiutors (if exist), etc. And also Disable "Digital Wellbeing" (system app; if it exists) itself or change "Battery usage" from "Optimized" to "Unrestricted" (this is very harmful for audio like camera servers).

* See also my companion script ["USB_SampleRate_Changer"](https://github.com/yzyhk904/USB_SampleRate_Changer) to change the sample rate of the USB (HAL) audio class driver and a 3.5mm jack on the fly like Bluetooth LDAC or Windows mixer to enjoy high resolution sound or to reduce resampling distortion (actually pre-echo, ringing and intermodulation) ultimately. If annoying (perhaps, for many people) DRC (Dynamic Range Control, i.e., a kind of compression) has been enabled on your device (e.g., smart phones and tablets having an SDM??? or SM???? model numbered SoC internally), you can disable DRC by this script. Or you can use my magisk module ["DRC remover"](https://github.com/Magisk-Modules-Alt-Repo/drc-remover) to simply disable DRC only.<br/>
<br/>

## DISCLAIMER

* I am not responsible for any damage that may occur to your device, so it is your own choice to attempt this module.

## Change logs

# v1.0
* Initial Release

##
