## Change logs

#v1.3.7
* Added "compatible Magisk-mirroring" message for incompatible Magisk variants
* Adjusted re-sampling parameters for old devices

#v1.3.6
* Tuned the USB period size for SDM845 devices (2500 usec to 2250 usec)
* Tuned the USB period size for other devices (to 2250 usec)
* Added checking incompatible Magisk variants

# v1.3.5
* Changed the re-sampling parameters for Galaxy S4 to the general purpose ones (optimized for 3.5mm jack; not USB DAC's)
* Tuned the USB period size for Tensor devices (2625 usec to 2250 usec)
* Fixed for Pixel 8's

# v1.3.4
* Tuned USB transfer period sizes for reducing jitter

# v1.3.3
* Stopped Tensor device's AOC daemon for reducing significant jitter

# v1.3.2
* Hid preinstalled "Digital Wellbeing" feature for reducing significant jitter (please uninstall this manually if remaining as a usual app)

# v1.3.1
* Reduced the jitter of Tensor device's offload driver for USB DAC's

# v1.3.0
* Fixed some SELinux related bugs for Magisk v26.0's new magic mount feature
* Diabled pre-installed Moto Dolby features for reducing large jitter caused by them

# v1.2.4
* Added support for Tensor devices to bypass their spatial audio feature for reducing jitter distortion

# v1.2.3
* Added support for MTK A12 vendor primary audio HAL (i.e., optimizing the USB period size) to reduce USB audio jitter
(A12 MTK primary audio HAL tunnels USB output via USB audio HAL with a special period size)

# v1.2.2
* Restructured source codes to be sharable with hifi-maximizer-mod at my another repository

# v1.2.1
* Nullified volume listener libraries in "soundfx" folders for disabling slight compression (maybe a peak limiter only on Qcomm devices)

Note: I recommend using ["DRC remover"](https://github.com/Magisk-Modules-Alt-Repo/drc-remover) additionally for disabling much larger compression (DRC) if on Qcomm devices.

# v1.2.0
* Added a workaround for Android 12 SELinux bug w.r.t. "ro.audio.usb.period_us" property
* Changed vendor.audio_hal.period_multiplier=2 to vendor.audio_hal.period_multiplier=1 for reducing jitter

# v1.1.0
* Set an audio scheduling tunable "vendor.audio.adm.buffering.ms" "2" to reduce jitter on all audio outputs
* Adjusted a USB period to reduce jitter on the USB audio output

# v1.0.9
* Tuned for MTK Dimensity's

# v1.08
* Improved the resampling quality for A12 (and latest A11) high performance devices

# v1.0.7
* Tuned a USB transfer period for POCO F3 to reduce the jitter of PLL in a DAC

# v1.0.6
* Optimized for POCO F3

# v1.0.5
* Changed resampling parameters for A12 and later (not having a certain resampling bug) to reduce the computational cost of resampling and raise its quality a little
* Added some info about the effect framework and SBC HD. Changed the effective resampling frequency threshold from 44.1kHz to 48kHz to avoid intermodulation when resampling 44.1kHz to 44.1kHz (pass-through digital filtering)

# v1.0.4
* Shortened the half filter length of resampling and enlarged a USB transfer period, for old MTK SoC's not to stutter

# v1.0.3
* Resampling quality changes from stop band attenuation 140dB & half length 320 to 160dB & 480

# v1.0.2
* Added ro.audio.usb.period_us=4000 or 5600 to system.prop to improve audio quality

# v1.0.1
* Initial release on Magisk-Modules-Alt_Repo (migrated from mine)

# v1.0.0
* Initial Release (on mine repository)

##
