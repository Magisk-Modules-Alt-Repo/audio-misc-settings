## A Magisk module for setting miscellaneous audio configuration values

This module,
<ol>
    <li>changes the number of steps in media volume to 100 steps (0.4~0.7dB per step),</li>
    <li>disables the effects framework (nearly direct low jitter audio pass),</li>
    <li>raises the resampling quality of AudioFlinger (the OS mixer) from the AOSP standard one (stop-band attenuation 90dB & cut off 100% of Nyquist frequency) to a mastering quality (160db & 91%, i.e., no resampling distortion in a real sense even though the 160dB targeted attenuation is not accomplished in the AOSP implementation),</li>
    <li>adjusts a USB transfer period,</li>
    <li>raises the bitrate limit of bluetooth codec SBC (dual channel mode) for EDR 2Mbps earphones,</li>
</ol><br/>
    for improving audio quality effectively in a simple manner.
<br/>
<br/>
<br/>

* This module has been tested on LineageOS and ArrowOS ROM's, and phh GSI's (Android 10 & 11 & 12, Qualcomm & MediaTek SoC, and Arm32 & Arm64 combinations). 

* Please disable "Manage apps automatically" in "Battery manager" (or "Adaptive battery" of "Adaptive preferences") in the battery section (needless to say, don't enable battery savers and the like), and change "Battery optimization" from "Optimize" to "Don't optimize" (or change "Battery usage" from "Optimized" to "Unrestricted") for following app's manually through the settings UI of Android OS (to lower less than 10Hz jitter making extremely short reverb or foggy sound like distortion). music (streaming) player apps, their licensing apps (if exist), "AirMusic" (if exists), "AirMusic  Recording Service" (system app; if exists), equalizer apps (if exist), "Bluetooth" (system app), "Bluetooth MIDI Service" (system app), "MTP Host" (system app), "NFC Service" (system app; if exists), "Magisk" (if exists), System WebView apps (system app), Browser apps, "PhhTrebleApp" (system app; if exists), "Android Services Library" (system app), "Android Shared Library" (system app), "Android System" (system app), "System UI" (system app), "Input Devices" (system app), Navigation Bar app (system app; if exists), "crDroid System" (system app; if exists), "LineageOS System" (system app; if exists), launcher app, "Google Play Store" (system app), "Google Play services" (system app), "Styles & wallpaper" or the like (system app), {Lineage, crDroid, Arrow, etc.} themes app (system app; if exists),  "AOSP panel" (system app; if exists), "OmniJaws" (system app; if exists), "OmniStyle" (system app; if exists), "Active Edge Service" (system app; if exists), "Android Device Security Module" (system app; if exists), "Call Management" (system app; if exists), "Phone" (system app; if exists), "Phone Calls" (system app; if exists), "Phone Services" (system app; if exists), "Phone and Messaging Storage" (system app; if exists), "Storage Manager" (system app), "Default" (system app; if exists), "Default StatusBar" (system app; if exists), keyboard app, kernel adiutors (if exist), etc. And also Disable "Digital Wellbeing" (system app; if it exists) itself or change "Battery usage" from "Optimized" to "Unrestricted" (this is very harmful for audio like camera servers).

* See also my companion script ["USB_SampleRate_Changer"](https://github.com/yzyhk904/USB_SampleRate_Changer) to change the sample rate of the USB (HAL) audio class driver and a 3.5mm jack on the fly like Bluetooth LDAC or Windows mixer to enjoy high resolution sound or to reduce resampling distortion (actually pre-echo or ringing) ultimately. If annoying (perhaps, for many people) DRC (Dynamic Range Control, i.e., compression) has been enabled on your device (e.g., smart phones and tablets having an SDM??? or SM???? model numbered SoC internally), you can disable DRC by this script. <br/>


## DISCLAIMER

* I am not responsible for any damage that may occur to your device, so it is your own choice to attempt this module.

## Change logs

# v1.0
* Initial Release

##
