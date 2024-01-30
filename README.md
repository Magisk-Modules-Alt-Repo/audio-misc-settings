## A Magisk module for setting miscellaneous audio configuration values

This module,
<ol>
    <li>changes the number of steps in media volume to 100 steps (0.4~0.7dB per step),</li>
    <li>raises the resampling quality of the Android OS mixer (AudioFlinger) to a very mastering quality (i.e., no resampling distortion in a real sense),</li>
    <li>disables the effects framework of the mixer (to interface to equalizers, virtualizers, visualizers, echo cancelers, automatic gain controls, etc.) for obtaining a nearly direct low jitter audio pass (very few vulnerable equalizers may crash without this framework, but please ignore it),</li>
    <li>disables the android built-in spatial audio feature (A13 or higher; especially Tensor devices) for obtaining a nearly direct low jitter audio pass too,</li>
    <li>disables pre-installed Moto Dolby features and Digital Wellbeing (please uninstall this manually if remaining as a usual app) for the same as above,</li>
    <li>stops Tensor device's AOC daemon for reducing significant jitter,</li>
    <li>adjusts a USB transfer period of the USB HAL driver (not the recently common hardware offloading USB (tunneling) driver, but including Tensor device's offloading USB driver) for directly reducing the jitter of a PLL in a DAC (even in an asynchronous mode); Use <a href="https://github.com/yzyhk904/USB_SampleRate_Changer">"USB_SampleRate_Changer"</a> to switch from the usual hardware offloading USB (tunneling) driver to the USB HAL one,</li>
    <li>sets a higher bitrate limit of bluetooth codec SBC (dual channel mode) for EDR 2Mbps entry class earphones (not for EDR 3Mbps performance ones, but including AV amplifiers and BT speakers),</li>
    <li>sets an audio scheduling tunable "vendor.audio.adm.buffering.ms" "2" to reduce jitter on all audio outputs,</li>
    <li>nullifies volume listener libraries in "soundfx" folders for disabling slight compression (maybe a peak limiter only on Qcomm devices); I recommend using <a href="https://github.com/Magisk-Modules-Alt-Repo/drc-remover">"DRC remover"</a> additionally for disabling much larger compression (DRC) if on Qcomm devices</li>
</ol><br/>
    for improving audio quality effectively in a simple manner.
<br/>
<br/>
<br/>

* Don't forget to install ["Audio jitter silencer"](https://github.com/Magisk-Modules-Alt-Repo/audio-jitter-silencer) together and uninstall "Digital Wellbeing" app (for reducing very large jitters which this module cannot reduce as itself)! If you like much clearer replay (especially on Qcomm devices using an offloading USB driver with large jitter), use <a href="https://github.com/yzyhk904/USB_SampleRate_Changer">"USB_SampleRate_Changer"</a> for reducing the jitter (making foggy sound).

* Don't use Am@zon music using a much worse internal re-sampler which bypasses the mastering quality re-sampling in the OS mixer (audioFlinger). Other music streaming services don't use such an internal re-sampler, as far as I know.

* This module has been tested on LineageOS and ArrowOS ROM's, and phh GSI's (Android 10 ~ 13, Qualcomm & MediaTek SoC, and Arm32 & Arm64 combinations). 

* Note 1: This module raises the resampling quality from AOSP standard one (stop band attenuation 90dB & cut off 100% of the Nyquist frequency & half filter length 32) to a very mastering quality (179dB & 99% & 408 for Android 12 and later devices and 160db & 91% & 480 for Android 9 & 10 & 11 ones (except low performance ones), but 167dB & 106% & 368 (194dB & 100% & 520 exceptionally for Galaxy S4) for low performance Android 12 and later devices, 160dB & 91% & 320 for low performance Android 9 & 10 & 11 ones; because earlier than Android 12 has a bug relating to aliasing processing around the Nyquist frequency). However, this cannot raise the quality for Android 8.1 and earlier ones. Please keep in mind that those attenuation values are used for a resampler design as targeted ones and may not be accomplished in the AOSP implementation.

* Note 2: Entry class USB DAC's usually adopt an interface chip communicating with the adaptive mode or the synchronous one defined in the USB audio standard. As in these modes an Android host controller sends audio sampling rate clock signals to the DAC, jitter generated at the host side affects the audio quality of the DAC tremendously. Higher class DAC's communicate with the asynchronous mode (also defined in the standard) to a host controller, but they actually use a PLL to reduce jitter from the host not to stutter even in heavy jitter situations. As this result, they behave as the adaptive mode with a feedback loop to dynamically adjust the host side sampling clock signals while referring a DAC side clock in a real sense, so even with the asynchronous mode they are more or less affected by host side jitter. You can see the mode of your USB DAC by opening "/proc/asound/card1/stream0" on your phone while playing music. Please see a word in parentheses at "Endpoint:" lines; "SYNC", "ADAPTIVE" or "ASYNC" means that your DAC uses "synchronous", "adaptive" or "asynchronous" mode to communicate to your phone, respectively. Moreover, almost all audio peripherals, e.g., bluetooth earphones, internal DAC's, network audio devices have a PLL in themselves and are affected by host side jitter for the same reason.

* I recommend expert users not to install ["Audio jitter silencer"](https://github.com/Magisk-Modules-Alt-Repo/audio-jitter-silencer), but manually to disable "Manage apps automatically" in "Battery manager" (or "Adaptive battery" of "Adaptive preferences") in the battery section (needless to say, don't enable battery savers, performance limiters and the like), turning off "Adaptive connectivity" in the Network & internet section (if exists), and changing "Battery optimization" from "Optimize" to "Don't optimize" (or change "Battery usage" from "Optimized" to "Unrestricted") for following app's manually through the settings UI of Android OS (to lower less than 10Hz jitter making extremely short reverb or foggy sound like distortion) even though disabling the Android doze itself: music (streaming) player apps, their licensing apps (if exist), "AirMusic" (if exists), "AirMusic  Recording Service" (system app; if exists), equalizer apps (if exist), "Bluetooth" (system app), "Bluetooth MIDI Service" (system app), "MTP Host" (system app), "NFC Service" (system app; if exists), "Magisk" (if exists), System WebView apps (system app), Browser apps, "PhhTrebleApp" (system app; if exists), "Android Services Library" (system app), "Android Shared Library" (system app), "Android System" (system app), "System UI" (system app), "Input Devices" (system app), {Gesture, 3 Button, 2  Button} Navigation Bar apps (which you are using only; system app), "crDroid System" (system app; if exists), "LineageOS System" (system app; if exists), launcher app, "Google Play Store" (system app), "Google Play services" (system app), "Styles & wallpaper" or the like (system app), {Lineage, crDroid, Arrow, etc.} themes app (system app; if exists),  "AOSP panel" (system app; if exists), "OmniJaws" (system app; if exists), "OmniStyle" (system app; if exists), "Active Edge Service" (system app; if exists), "Android Device Security Module" (system app; if exists), "Call Management" (system app; if exists), "Phone" (system app; if exists), "Phone Calls" (system app; if exists), "Phone Services" (system app; if exists), "Phone and Messaging Storage" (system app; if exists), "Storage Manager" (system app), "Default" (system app; if exists), "Default StatusBar" (system app; if exists), "Wfd Service" (system app; if exists), "Wallpaper" or the like (system app), "Adreno Graphics Drivers" (system app; if exists), "com.android.providers.media" (system app), "Files by Google" (system app; if exists), "Google Play Services for AR" (system app; if exists), "Google Services Framework" (system app), "Waterfall cutout" (system app), "Punch Hole cutout" (system app), "Network Manager" (system app), "Companion Device Manager" (system app), "Intent Filter Verification Service" (system app), "Calendar", camera apps, keyboard app, kernel adiutors (if exist), etc. And uninstall "Digital Wellbeing" (system app; if it exists) itself or change "Battery usage" from "Optimized" to "Restricted" (this is very harmful for audio like camera servers). Because "Audio jitter silencer" isn't complete and needs some maintenance after its installation.

* See also my companion script ["USB_SampleRate_Changer"](https://github.com/yzyhk904/USB_SampleRate_Changer) to change the sample rate of the USB (HAL) audio class driver and a 3.5mm jack on the fly like Bluetooth LDAC or Windows mixer to enjoy high resolution sound or to reduce resampling distortion (actually pre-echo, ringing and intermodulation) ultimately. If annoying (perhaps, for many people) DRC (Dynamic Range Control, i.e., a kind of compression) has been enabled on your device (e.g., smart phones and tablets having an SDM??? or SM???? model numbered SoC internally), you can disable DRC by this script. Or you can use my magisk module ["DRC remover"](https://github.com/Magisk-Modules-Alt-Repo/drc-remover) to simply disable DRC only.

* Appendix (Resampling Parameter Examples):
    
    
    | Stop band attenuation (dB) | Half filter length | Cut-off (%) | Stop band (%) | Memo |
    | ---: | ---: | ---: | ---: | ---- |
    | 90 | 32 | 100 | | AOSP default |
    | This mod. parameters: | - | - | - | - |
    | 160 | 320 | 91 | | Low Performance devices under A12 |
    | 160 | 480 | 91 | | High Performance devices under A12 |
    | 167 | 368 | | 106 | Low Performance devices for A12 and later |
    | 179 | 408 | | 99 | High Performance devices for A12 and later, and Galaxy S4 |
    | External examples: | - | - | - | - |
    | 100 | 29 | | 109 | AK4493 (Sharp Roll-Off for N-fold over-sampling) |
    | 120 | 35 | | 110 | ESS 9038PRO (Sharp Roll-Off for N-fold over-sampling) |
    | 98 | 130 | 98.5 | | MacOS Leopard (guess) |
    | 160 | 240 | | 100 | iZotope, No-Alias (guess) |
    | 98 | 64 | | 100 | SoX HQ linear phase (guess) |
    | 170 | 520 | | 100 | SoX VHQ linear phase (guess) |

<br/>
<br/>

## DISCLAIMER

* I am not responsible for any damage that may occur to your device, so it is your own choice to attempt this module.

##
