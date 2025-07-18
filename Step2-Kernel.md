# Linux Kernel and Libraries Build Guide

This guide covers building essential libraries (`zlib`, `liblz4`, and `zstd`) and the Linux Kernel itself from source, optimized for your CPU. You can skip to the Kernel building process. Zlib,liblz4, and zstd are built to increase performance affecting Kernel libraries and are later used in Mesa as well.

---

## Linux Kernel

This section details compiling the Linux Kernel optimized for your CPU. The build process includes preparing the config, compiling with optimized flags, and packaging `.deb` files for easy installation.

## Install dependencies

 Ubuntu specifics will be added for reference.

```
sudo apt-get build-dep linux linux-image-$(uname -r)
```

Ubuntu-specifics are added for reference:

```
sudo apt-get install libqt5x11extras5-dev pkg-config libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf debhelper make lzop liblzo2-dev libzstd-dev vim curl
```

Ubuntu 23.x+

```
sudo apt-get install qt6-base-dev qt6-tools-dev pkg-config libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf debhelper make lzop liblzo2-dev libzstd-dev vim curl
```



### Download the Kernel Source:

Download the Kernel source from https://kernel.org/

At the command line, you can use:

```
wget -c https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.8.tar.xz
```

Then decompress in your source directory.

```
tar -xvf linux-6.14.8.tar.xz
cd linux-6.14.8.tar
```

### Using make xconfig to add (Y), remove (N), or module (M) features:

This will be the most difficult part of this step-by-step process and cannot simply be copied and pasted. There are three ways to use a menu for modification of the .config file. You can use make xconfig, make gconfig, or make menuconfig. I prefer xconfig:

```
make oldconfig  # This will copy the configuration from your current loaded/running Kernel.
```

Stop here, plug in all of your devices, and activate or mount them. Plug in a USB drive, a webcam, start the webcam app, any other devices that you want the new Kernel to support and then run the following command to remove unused Kernel modules from the .config file. Unfortunately, this may remove a number of necessary files for things like KVM or Docker containers or VPN. Ideally, if you activate all of these devices before running the command then it will force your current Kernel to load them and become visible to the make localmodconfig command which will add them to the .config file.

```
make localmodconfig
```

This will trim a lot of features out of the Kernel making the next step easier. I found that after running this command that I always have to go back and add Microsoft VFAT,DOS, NTFS support back in but that's fine.

This step will take the most time: Deciding what to add or remove. I search and remove features using the keywords debug, trace, profile, symbol. I add features by searching for keywords associated with my hardware brands: AMD (That's my CPU and GPU), VFAT, NTFS, Razer, Logitech, Steelseries, and Sony. 

For the most part, the xconfig process is about adding a feature using M or Y and removing features with N. M means module and creates a loadable module for that feature if available. Y tells the Kernel build process to add the feature into the Kernel itself, if available. N tells the build process to remove that feature altogether; you would do this to remove all Intel CPU related features if you have an AMD CPU or vice versa but remember that not all AMD and Intel features are CPU or GPU related. You may have an AMD CPU and an Intel NIC card.

```
make xconfig
```

Save and exit. You can check your Kernel .config using a script for Docker containers. I use this script to point out any missing Kernel components that will break Docker. I use Docker or Podman when building Valve's Proton so this is very useful.

https://blog.hypriot.com/post/verify-kernel-container-compatibility/

You can download and run this script like this:

```bash
wget https://github.com/moby/moby/raw/master/contrib/check-config.sh
chmod +x check-config.sh
./check-config.sh
```

If you find any components missing then run make xconfig again, search for the component, add M for module or Y to build the feature into the Kernel itself.



### Kernel build with generalized CPU optimization flags:

As of the writing of this guide, GCC 15 is not available through most Linux distro package manager. I added the GCC toolchain PPA in order to install GCC 15. Ideally, adding the latest GCC version should increase performance of the binary. Occasionally, there can be regressions. There are performance increases for those using GCC 15 over GCC 14. (https://www.phoronix.com/review/gcc-15-amd-zen5 , https://www.phoronix.com/review/gcc15-amd-epyc-turin/4 )

After your .config file has been modified and you're happy with the changes then you can begin the build process:

```bash
CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -g0" \
RUSTFLAGS="-C opt-level=2 -C target-cpu=native" \
sudo make -j$(nproc) LOCALVERSION=-custom bindeb-pkg CC=gcc-15 HOSTCC=gcc-15
```

If the build process stops, copy and paste the error output to ChatGPT if you're new to tracking these down. Most of the time there will be a missing dependency. 

### For a performance-driven build:

Use this build command instead of the one above if you want to push the Kernel further toward performance. 

```
CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -g0" \
RUSTFLAGS="-C opt-level=2 -C target-cpu=native" \
KCFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -fno-common -pipe -g0" \
KCPPFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -pipe -g0" \
KBUILD_CFLAGS_MODULE="-O3 -march=native -mtune=native -fomit-frame-pointer -funroll-loops -pipe -g0" \
KBUILD_CFLAGS_KERNEL="-O2 -march=native -mtune=native -fomit-frame-pointer -pipe -g0" \
sudo make -j$(nproc) LOCALVERSION=-joels bindeb-pkg CC=gcc-15 HOSTCC=gcc-15
```

### Explanation

- `-O2` and `-O3`: Optimization levels, with `-O3` used for kernel modules for extra speed.
- `-march=native` and `-mtune=native`: Optimize and tune for your current CPU architecture (replacing CPU-specific flags like `znver5` for better compatibility).
- `-fno-stack-protector`: Disable stack protection to reduce overhead (optional, be cautious).
- `-fomit-frame-pointer`: Omit the frame pointer for optimized performance.
- `-pipe`: Use pipes rather than temporary files during compilation for speed.
- `-g0`: Disable debug symbols to reduce binary size.
- `-frename-registers`, `-fgcse-after-reload`, `-funroll-loops`: Advanced optimizations for module compilation.
- `LOCALVERSION=-joelsafe`: Adds a custom suffix to the kernel version.
- `bindeb-pkg`: Build Debian packages for easy installation.
- `CC=gcc-15` and `HOSTCC=gcc-15`: Use GCC version 15 as the compiler and host compiler.

Since I'm using the AMDGPU Kernel driver module for my GPU, I edited the Makefile in 

```
/source/source/kernel/linux-6.15-rc7/drivers/gpu/drm/amd/amdgpu/
```

I added the last 3 lines below.

```
# Locally disable W=1 warnings enabled in drm subsystem Makefile
subdir-ccflags-y += -Wno-override-init
subdir-ccflags-$(CONFIG_DRM_AMDGPU_WERROR) += -Werror

# Add aggressive AMDGPU-specific optimization flags (without SIMD/vectorization)
subdir-ccflags-y += -O3 -march=znver5 -mtune=znver5 -funroll-loops -frename-registers -fgcse-after-reload -fno-stack-protector -fomit-frame-pointer -pipe -g0
```



---

### Installing the built kernel packages:

```bash
sudo dpkg -i linux-headers-*.deb
sudo dpkg -i linux-image-*.deb
sudo dpkg -i linux-libc-dev_*.deb
```

---

## Notes on Compiler Flags

- `-O2` is a balanced optimization level for speed and safety.
- `-O3` is more aggressive and can improve performance at the cost of longer compile times and larger binaries but are fine for the modules.
- `-march=native` and `-mtune=native` automatically optimize for the host CPU. This is preferred over architecture-specific flags like `-march=znver5` for portability.
- Flags like `-fomit-frame-pointer`, `-frename-registers`, and `-fgcse-after-reload` help reduce overhead and improve register allocation. These have been selected as a fusion of -O2 and -O3 depending on the project's functions. Example: loops versus heavy math
- `-fno-stack-protector` disables stack smashing protection for minor performance gain but reduces security. Remove this if security is crucial.
- `-fno-plt` disables Procedure Linkage Table optimizations to reduce indirect calls overhead.
- Rust flags (`RUSTFLAGS`) specify optimization level and CPU tuning for Rust kernel components.

