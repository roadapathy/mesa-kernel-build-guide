## Get the latest toolchain

There has been clear performance benefits on GCC 15 over GCC 14. Therefore, begin the journey by updating your system to the latest version of the GCC compiler.

```
sudo apt install build-essential
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update
```

The install command

```
sudo apt install gcc-15 g++-15 gobjc-15 gfortran-15 gccgo-15 \
  libstdc++-15-dev libgcc-15-dev libobjc-15-dev binutils libc6-dev
```



### Step 1: Register Each Compiler with `update-alternatives`

Run the following commands to register GCC 15 versions as alternatives with high priority:

```
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-15 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-15 100
sudo update-alternatives --install /usr/bin/gobjc gobjc /usr/bin/gobjc-15 100
sudo update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-15 100
sudo update-alternatives --install /usr/bin/gccgo gccgo /usr/bin/gccgo-15 100
```

- This tells the system "here's an alternative choice for these compiler commands."
- The priority `100` makes GCC 15 preferred if no other alternative has a higher priority.

### Step 2: Select Default Versions (If Multiple Are Installed)

If you have multiple versions installed, run these commands to interactively choose which version is the default for each compiler:

```
sudo update-alternatives --config gcc
sudo update-alternatives --config g++
sudo update-alternatives --config gobjc
sudo update-alternatives --config gfortran
sudo update-alternatives --config gccgo
```

- You’ll see a menu listing available versions for each command.
- Enter the number for `/usr/bin/gcc-15`, `/usr/bin/g++-15`, etc. to select GCC 15 as default.

### Step 3: Verify Your Defaults

Check that the defaults are properly set by running:

```
gcc --version
g++ --version
gobjc --version
gfortran --version
gccgo --version
```

Each should show version **15.x.x** indicating GCC 15 is the active compiler.

### Step 4: Optionally install all dependencies for every project used within these guides:

As one huge command.

```
sudo apt-get install \
  autoconf automake build-essential checkinstall cheese clinfo cmake curl \
  debhelper devscripts dkms docker.io ffmpeg flex gawk gir1.2-gtk-4.0 git glmark2-x11 \
  libasio-dev libasound2-dev libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev \
  libcurl4-openssl-dev libcunit1-dev libdrm-dev libegl1-mesa-dev libelf-dev libfreetype-dev \
  libfontconfig1-dev libgl1-mesa-dev libiberty-dev libjack-jackd2-dev libjansson-dev liblzo2-dev \
  libluajit-5.1-dev libncurses-dev libosmesa6-dev libpci-dev libpcsclite-dev libpthread-stubs0-dev \
  libpthreadpool-dev libpulse-dev libqt5x11extras5-dev libsdl2-dev libspeexdsp-dev libssl-dev \
  libswscale-dev libtool libudev-dev libusb-1.0-0-dev libv4l-dev libvlc-dev libwayland-dev \
  libx11-dev libx11-xcb-dev libx264-dev libxcomposite-dev libxcursor-dev libxinerama-dev \
  libxkbcommon-dev libxrandr-dev libxrender-dev libxxf86vm-dev libxcb-composite0-dev \
  libxcb-cursor-dev libxcb-dri3-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-shm0-dev \
  libxcb-xfixes0-dev libxcb-xinerama0-dev lzop make mesa-utils meson nasm openssl pkg-config \
  pulseaudio-utils python3-dev python3-lxml python3-pip python3-setproctitle qt6-base-dev qt6-tools-dev \
  qt6-5compat-dev qt6-networkauth-dev swig ubuntu-restricted-extras vim vulkan-tools xdotool \
  xubuntu-restricted-addons yasm wmctrl zlib1g-dev libpng-dev libxft-dev golang-gir-glib-2.0-dev \
  vainfo cargo cargo-1.84 liblua5.4-dev libunwind-dev gradle sensors-applet xfce4-sensors-plugin \
  libaom-dev libsvtav1enc-dev libdav1d-dev libass-dev libmp3lame-dev libplacebo-dev libsoxr-dev \
  libtheora-dev libvpx-dev libopus-dev libvidstab-dev libvorbis-dev libx265-dev libzimg-dev \
  libbluray-dev xfce4-dev-tools libxvidcore-dev python3-docutils libgstreamer1.0-dev \
  libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev libgstreamermm-1.0-dev \
  gstreamer1.0-libcamera libavahi-client-dev libbluetooth-dev libldacbt-abr-dev libldacbt-enc-dev \
  libsbc-dev libspa-0.2-dev libxfce4util-dev libexo-2-dev libxfce4ui-2-dev libxfce4panel-2.0-dev \
  extra-cmake-modules libffado-dev libsndfile1-dev libcanberra-dev libgirepository1.0-dev \
  libjson-glib-dev libpam0g-dev libpipewire-0.3-dev libfreeaptx
```

## Broken down into categories

------

### 1. Basic Development Tools & Utilities

```bash
sudo apt-get install autoconf automake build-essential checkinstall cmake curl debhelper devscripts dkms docker.io flex gawk git make meson nasm pkg-config swig vim yasm
```

------

### 2. Multimedia & Video Related Libraries

```bash
sudo apt-get install ffmpeg libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev libswscale-dev libv4l-dev libvlc-dev libx264-dev libx265-dev libaom-dev libsvtav1enc-dev libdav1d-dev libass-dev libmp3lame-dev libplacebo-dev libsoxr-dev libtheora-dev libvpx-dev libopus-dev libvidstab-dev libvorbis-dev libxvidcore-dev libbluray-dev
```

------

### 3. Audio & Sound Libraries

```bash
sudo apt-get install libasound2-dev libjack-jackd2-dev libpulse-dev libspeexdsp-dev libsndfile1-dev libcanberra-dev libffado-dev libldacbt-abr-dev libldacbt-enc-dev libsbc-dev libspa-0.2-dev libpipewire-0.3-dev
```

------

### 4. Graphics & Display Libraries

```bash
sudo apt-get install libdrm-dev libegl1-mesa-dev libgl1-mesa-dev libosmesa6-dev libwayland-dev libx11-dev libx11-xcb-dev libxcomposite-dev libxcursor-dev libxinerama-dev libxkbcommon-dev libxrandr-dev libxrender-dev libxxf86vm-dev libxcb-composite0-dev libxcb-cursor-dev libxcb-dri3-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-shm0-dev libxcb-xfixes0-dev libxcb-xinerama0-dev
```

------

### 5. Fonts, Text & Rendering Libraries

```bash
sudo apt-get install libfreetype-dev libfontconfig1-dev libpng-dev libxft-dev libluajit-5.1-dev libzimg-dev
```

------

### 6. Python & Scripting Support

```bash
sudo apt-get install python3-dev python3-lxml python3-pip python3-setproctitle python3-docutils
```

------

### 7. Qt6 and GUI Related Development

```bash
sudo apt-get install qt6-base-dev qt6-tools-dev qt6-5compat-dev qt6-networkauth-dev libqt5x11extras5-dev extra-cmake-modules
```

------

### 8. Xfce Desktop Environment Development Tools

```bash
sudo apt-get install xfce4-dev-tools libxfce4util-dev libexo-2-dev libxfce4ui-2-dev libxfce4panel-2.0-dev sensors-applet xfce4-sensors-plugin wmctrl
```

------

### 9. System & Utility Libraries

```bash
sudo apt-get install libasio-dev libcurl4-openssl-dev libcunit1-dev libelf-dev libiberty-dev libjansson-dev liblzo2-dev libncurses-dev libpci-dev libpcsclite-dev libpthread-stubs0-dev libpthreadpool-dev libssl-dev libtool libudev-dev libusb-1.0-0-dev libvulkan-dev libvulkan1 libwayland-dev libx11-dev libxcomposite-dev libxinerama-dev libxkbcommon-dev libxrandr-dev
```

------

### 10. Additional Developer Tools & Languages

```bash
sudo apt-get install golang-gir-glib-2.0-dev cargo cargo-1.84 gradle liblua5.4-dev libunwind-dev libgstreamer1.0-dev libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev libgstreamermm-1.0-dev gstreamer1.0-libcamera
```

------

### 11. Network, Bluetooth & System Integration

```bash
sudo apt-get install libavahi-client-dev libbluetooth-dev libjson-glib-dev libpam0g-dev libgirepository1.0-dev libfreeaptx
```

------

### 12. Miscellaneous Tools & Utilities

```bash
sudo apt-get install clinfo gir1.2-gtk-4.0 glmark2-x11 pulseaudio-utils ubuntu-restricted-extras vulkan-tools xdotool xubuntu-restricted-addons vainfo
```

------









