# Mesa Build Guide

This guide covers the steps to build Mesa and its related dependencies and libraries with CPU optimization flags and GPU options. The instructions assume you have GCC 15 (`gcc-15` and `g++-15`) and Clang 20 installed and want to install everything under `/usr/local`. **YOU DO NOT HAVE TO BUILD EVERYTHING HERE.** Yes, you can skip to LibDRM  to compile just LibDRM and Mesa. However, many of these other supporting libraries receive regular updates and performance improvements as well as many new features. 

## IMPORTANT: 

You can go to the git link to check for newer versions of the files on this guide. You must learn how the git command works first. We're choosing to use the latest stable released versions or the latest that has been designated a static version number rather than cloning from the master/main, which can often be too bleeding edge and/or broken.

```
git clone --recurse-submodules -b v2025.1 https://github.com/KhronosGroup/SPIRV-Tools.git
```

**`git clone`**
 This command copies the entire remote repository (all the project files, history, branches) to your local machine.

**`--recurse-submodules`**
 This option tells Git to also clone all the submodules (nested repositories) that the main project depends on. Many large projects include other projects as submodules, so this ensures you get all necessary code.

**`-b v2025.1`**
 This specifies which branch or tag to clone from the remote repository. In this case, it clones the branch or tag named `v2025.1`.

> **Important:** Project maintainers often update branches and tags frequently. You should check the project’s [GitHub releases or branches page](https://github.com/KhronosGroup/SPIRV-Tools/branches) to find the latest stable or appropriate version to use. Replace `v2025.1` with the version you want.

**`https://github.com/KhronosGroup/SPIRV-Tools.git`**
 This is the URL of the remote Git repository to clone from.



---

## Table of Contents

- [SPIR-V Headers](#spir-v-headers)  
- [SPIR-V Tools](#spir-v-tools)  
- [glslanglib](#glslanglib)  
- [SPIR-V Translator](#spir-v-translator)  
- [Cairo](#cairo)  
- [Pixman](#pixman)  
- [libDRM](#libdrm)  
- [libva VA-API (Video Acceleration API)](#libva-va-api-video-acceleration-api)  
- [libglvnd](#libglvnd)  
- [System Check Script](#system-check-script)  
- [Library Dependency Check](#library-dependency-check)  
- [Mesa](#mesa)  



---

## SPIR-V Headers

KhronosGroup SPIR-V Headers provide the core definitions for SPIR-V. The **SPIR-V Headers** project provides the official definitions for the SPIR-V intermediate representation used in Vulkan and OpenCL. These headers define the specification’s data structures and constants, ensuring consistent interpretation of SPIR-V bytecode across tools and drivers.

```bash
git clone --recurse-submodules https://github.com/KhronosGroup/SPIRV-Headers.git #  Just use main
cd SPIRV-Headers
mkdir build && cd build
CC=gcc-15 CXX=g++-15 cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_C_FLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -g0 -flto" \
    -DCMAKE_CXX_FLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -g0 -pthread -flto"
cd ..
sudo cmake --build build --target install
sudo ldconfig
hash -r
```



## SPIR-V Tools

SPIR-V Tools provide utilities to work with SPIR-V binaries. **SPIR-V Tools** is a collection of utilities to manipulate, optimize, and validate SPIR-V binaries. It includes assemblers, disassemblers, optimizers, and validators that are essential in the graphics pipeline for handling shader code.

```
git clone --recurse-submodules -b v2025.1 https://github.com/KhronosGroup/SPIRV-Tools.git  # v2025.1 latest version as of May 30, 2025
cd SPIRV-Tools
mkdir build && cd build
CC=gcc-15 CXX=g++-15 cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="-O3 -march=native -mtune=native -fomit-frame-pointer -g0 -flto -pthread" \
  -DCMAKE_CXX_FLAGS="-O3 -march=native -mtune=native -fomit-frame-pointer -g0 -pthread -flto" \
  -DSPIRV-Headers_SOURCE_DIR=/usr/local
cd ..
sudo cmake --build build --target install
sudo ldconfig
hash -r
```

**Notes:**

- `-O3` for maximum optimization since this is a tool with more CPU-intensive workloads.



## glslanglib

Reference front-end compiler for GLSL and ESSL shaders. The **glslang** library is the reference compiler for GLSL (OpenGL Shading Language) and ESSL (OpenGL ES Shading Language). It converts GLSL shader source code into SPIR-V bytecode, which GPUs consume for rendering.

```
git clone --recurse-submodules -b **15.3.0** https://github.com/KhronosGroup/glslang.git  # 15.3.0 latest version as of May 30, 2025
cd glslang
mkdir build && cd build

CC=gcc-15 CXX=g++-15 cmake .. \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="-O2 -march=native -mtune=native -fstrict-aliasing -frename-registers -fweb -fgcse-after-reload -fomit-frame-pointer -g0 -flto" \
  -DCMAKE_CXX_FLAGS="-O2 -march=native -mtune=native -fstrict-aliasing -frename-registers -fweb -fgcse-after-reload -fomit-frame-pointer -g0 -pthread -flto" \
  -DALLOW_EXTERNAL_SPIRV_TOOLS=ON \
  -DGLSLANG_ENABLE_INSTALL=ON

cd ..
sudo cmake --build build --target install
sudo ldconfig
hash -r
```

## SPIR-V Translator

SPIR-V to LLVM Translator. The **SPIR-V Translator** bridges SPIR-V and LLVM intermediate representations, enabling interoperability between Vulkan shaders and other compiler toolchains. It’s used to translate SPIR-V into LLVM IR for optimization and back.

```
git clone --recurse-submodules -b v20.1.2 https://github.com/KhronosGroup/SPIRV-LLVM-Translator.git  # v20.1.2 latest version as of May 30, 2025
cd SPIRV-LLVM-Translator
mkdir build && cd build

CC=gcc-15 CXX=g++-15 cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=/usr/local/include/spirv \
  -DLLVM_DIR=/usr/lib/llvm-20/lib/cmake/llvm \
  -DCMAKE_C_FLAGS="-O3 -march=native -mtune=native -fomit-frame-pointer -g0 -flto" \
  -DCMAKE_CPP_FLAGS="-O3 -march=native -mtune=native -fomit-frame-pointer -g0 -pthread -flto" \
  -DCMAKE_CXX_FLAGS="-O3 -march=native -mtune=native -fomit-frame-pointer -g0 -pthread -flto"

make -j$(nproc)
sudo make install
sudo ldconfig
hash -r
```



## Cairo

2D graphics library used for rendering. **Cairo** is a 2D graphics library that provides vector graphics and image compositing for rendering. It supports multiple output targets like X11, OpenGL, and image buffers and is widely used in graphical applications and toolkits.

------



```
git clone --recurse-submodules git://anongit.freedesktop.org/git/cairo # There's only this link, AKA master/main
cd cairo

meson setup builddir --prefix=/usr/local --buildtype=release \
  -Dc_args="-O2 -march=native -mtune=native -fomit-frame-pointer -g0" \
  -Dcpp_args="-O2 -march=native -mtune=native -fomit-frame-pointer -g0" \
  -Dtee=enabled -Dxlib=enabled -Dxcb=enabled -Dpng=enabled -Dfreetype=enabled -Dfontconfig=enabled

ninja -C builddir -j$(nproc)
sudo ninja -C builddir install
sudo ldconfig
hash -r

pkg-config --modversion cairo
```



## Pixman

Low-level pixel manipulation library. Pixman is a fast, low-level C library for pixel compositing and image manipulation. It provides optimized routines for image blending, format conversions, and rasterization. Mesa uses Pixman for software rendering (when no GPU is available), and it is also a core dependency of Cairo. Pixman is essential for Cairo and for Mesa’s software rasterizers (like LLVMpipe and Softpipe).

Improvements in Pixman directly benefit software rendering performance in both Cairo and Mesa.

```
git clone --recursive git://anongit.freedesktop.org/git/pixman.git
cd pixman

meson setup builddir --prefix=/usr/local --buildtype=release \
  -Dc_args="-O2 -march=native -mtune=native -fomit-frame-pointer -g0" \
  -Dcpp_args="-O2 -march=native -mtune=native -fomit-frame-pointer -g0"

ninja -C builddir -j$(nproc)
sudo ninja -C builddir install
sudo ldconfig
hash -r

pkg-config --modversion pixman-1
```




## libDRM

Direct Rendering Manager library for interacting with GPUs. The **libDRM** (Direct Rendering Manager library) provides user-space APIs to communicate with the Linux kernel’s DRM subsystem. It enables applications to control GPU resources, manage memory, and perform direct rendering operations.

**You will almost certainly need to modify the build command based upon your GPU.**

```
git clone --recurse-submodules -b libdrm-2.4.124 https://gitlab.freedesktop.org/mesa/drm.git  # Version libdrm-2.4.124 is the latest as of May 30, 2025
cd drm

CC=gcc-15 CXX=g++-15 meson setup build \
  --prefix=/usr/local \
  --buildtype=release \
  -Db_lto=true \
  -Dradeon=enabled \ # YOU NEED TO MODIFY BASED ON YOUR GPU
  -Damdgpu=enabled \ # YOU NEED TO MODIFY BASED ON YOUR GPU
  -Dintel=disabled \ # YOU NEED TO MODIFY BASED ON YOUR GPU
  -Dnouveau=disabled \ # YOU NEED TO MODIFY BASED ON YOUR GPU
  -Dvmwgfx=disabled \
  -Domap=disabled \
  -Dfreedreno=disabled \
  -Dtegra=disabled \
  -Detnaviv=disabled \
  -Dexynos=disabled \
  -Dvc4=disabled \
  -Dudev=true \
  -Dvalgrind=disabled \
  -Dinstall-test-programs=true \
  -Ddefault_library=both \
  -Dc_args="-O3 -march=znver5 -fomit-frame-pointer -g0 -fvisibility=hidden -pthread -pipe" \
  -Dcpp_args="-O3 -march=znver5 -fomit-frame-pointer -g0 -fvisibility=hidden -pthread -pipe" \
ninja -C build -j$(nproc)
sudo ninja -C build install
sudo ldconfig
hash -r
```

#### Verification examples:
```
pkg-config --modversion libdrm
ldd /usr/bin/glxinfo | grep libdrm
vulkaninfo | grep "driverInfo"
find /usr/local -name "libdrm.so*"
```



## libva VA-API (Video Acceleration API)

Hardware video acceleration API from Intel but used also by AMD GPUs. It's not updated very often but you can check the git link for something newer. **libva** is a vendor-neutral library offering a standardized API for GPU-accelerated video decoding, encoding, and processing. Primarily developed by Intel, it allows applications to leverage hardware video acceleration transparently across different GPUs.

```
git clone --recurse-submodules -b 2.22.0 https://github.com/intel/libva.git  # Version 2.22.0 is the latests as of May 30,2025
cd libva

meson setup build \
  --prefix=/usr/local \
  --libdir=/usr/local/lib/x86_64-linux-gnu \
  -Dwith_wayland=auto \
  -Ddefault_library=shared \
  -Db_lto=true \
  -Db_lto_mode=thin \
  -Db_ndebug=true \
  -Db_staticpic=true \
  -Dc_link_args='-Wl,-O1 -Wl,-z,defs' \
  -Dc_args='-O2 -march=native -mtune=native -frename-registers -fweb -fgcse-after-reload -fomit-frame-pointer -g0 -flto' \
  -Dcpp_args='-O2 -march=native -mtune=native -frename-registers -fweb -fgcse-after-reload -fomit-frame-pointer -g0 -pthread -flto' \
  -Dbuildtype=release

ninja -C build
sudo ninja -C build install
sudo ldconfig
hash -r
```

#### Check installation:
```
LD_DEBUG=libs vainfo 2>&1 | grep libva
ldd /usr/bin/vainfo
vainfo
```



## libglvnd

Vendor-neutral dispatch library for OpenGL. The **libglvnd** (OpenGL Vendor Neutral Dispatch) library provides a vendor-neutral dispatch layer for OpenGL and EGL. It allows multiple OpenGL implementations (from different GPU vendors) to coexist on a system, enabling proper function dispatching based on the active GPU.

```
git clone --recurse-submodules -b v1.7.0 https://gitlab.freedesktop.org/glvnd/libglvnd.git
cd libglvnd

./autogen.sh
CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -frename-registers -fweb -fgcse-after-reload -g0 -flto -fPIC -pthread" \
./configure --prefix=/usr/local

make -j$(nproc)
sudo make install
sudo ldconfig
hash -r

# Verify installed libs:

ldconfig -p | grep libGL
ldconfig -p | grep libEGL
```



## Mesa

Mesa 3D Graphics Library. **Mesa** is the core open-source implementation of the OpenGL, Vulkan, and other graphics APIs for Linux. It provides GPU drivers and the Gallium framework to enable hardware-accelerated rendering for a wide range of GPUs including AMD, Intel, and Nvidia (via nouveau).

**You will almost certainly need to modify the build command based upon your GPU.** 

```
git clone --recurse-submodules -b mesa-25.1.1 https://gitlab.freedesktop.org/mesa/mesa.git  # Version mesa-25.1.1 is the latest as of May 30,2025 and this project updates often
cd mesa

CC=gcc-15 CXX=g++-15 meson setup builddir \
  --prefix=/usr/local \
  --buildtype=release \
  -Dvulkan-icd-dir=/usr/local/share/vulkan/icd.d \
  -Dva-libs-path=/usr/local/lib \
  -Dshared-llvm=enabled \
  -Dshader-cache-max-size=8G \
  -Dgallium-drivers=radeonsi,zink \ # YOU NEED TO MODIFY BASED ON YOUR GPU
  -Dvulkan-drivers=amd,swrast \ # YOU NEED TO MODIFY BASED ON YOUR GPU
  -Dgallium-va=enabled \
  -Dgallium-vdpau=enabled \
  -Dllvm=enabled \
  -Dopengl=true \
  -Dgles1=disabled \
  -Dgles2=enabled \
  -Dglx=dri \
  -Dgbm=enabled \
  -Dplatforms=wayland,x11 \
  -Dlmsensors=enabled \
  -Dvideo-codecs=all \
  -Dgallium-rusticl=true \
  -Drust_std=2021 \
  -Db_ndebug=true \
  -Db_lto=true \
  -Dwerror=false \
  -Dzstd=enabled \
  -Dshader-cache=enabled \
  -Dvalgrind=disabled \
  -Degl=enabled \
  -Dbuild-tests=false \
  -Ddefault_library=both \
  -Dglvnd=enabled \
  -Dc_args="-O3 -march=znver5 -fomit-frame-pointer -g0 -fvisibility=hidden -pthread -pipe" \
  -Dcpp_args="-O3 -march=znver5 -fomit-frame-pointer -g0 -fvisibility=hidden -pthread -pipe"

meson compile -C build -j$(nproc)
sudo meson install -C build
sudo ldconfig
hash -r
```

#### Verification:
```
glxinfo | grep "OpenGL version"
vulkaninfo | grep "apiVersion"
```

If the verification matches what was just built and you can successfully load Firefox, Steam, and play a game then **you did it!** You are now running a CPU and GPU optimized version of the Linux graphic drivers! This will include code updates, bug fixes, the latest graphic features, more supported games, and more!

### GPU options

#### Gallium Drivers

- `radeonsi`: AMD Radeon GCN 2.0 (HD 7790/R7 260) and newer, including RX 5000/6000/7000/9000.
- `amdgpu`: Legacy, use `radeonsi` for modern AMD.
- `iris`: Intel Gen8+ (Broadwell and newer).
- `i915`: Intel Gen4-7 (older chips).
- `nouveau`: NVIDIA (open-source driver, older and limited performance).
- `zink`: Generic OpenGL-over-Vulkan driver (can work on any Vulkan-capable device).
- `virgl`: Virtualized environments (for QEMU/VirtIO-GPU).
- `svga`: VMware virtual GPU.
- `softpipe`/`llvmpipe`: Software rasterizers (no GPU required; `llvmpipe` is faster).

### Vulkan Drivers

- `amd`: AMD Radeon RX 400 series and newer (RADV).
- `intel`: Intel Gen8+ (ANV driver).
- `nouveau`: Experimental NVIDIA Vulkan driver (very limited).
- `swrast`: Software Vulkan implementation (for testing; very slow).
- `virtio`: Virtualized Vulkan (QEMU/VirtIO-GPU).



# Notes on Optimization Flags

Changes made for this guide from my AMD 9070 CPU and AMD RX 9070 GPU:

- Changed all `-march=znver5 -mtune=znver5` to `-march=native -mtune=native` to improve portability and compatibility while still enabling CPU-specific optimizations automatically.
- Removed `-mprefer-vector-width=512` since it is very specific and may cause issues on some CPUs.
- Used `-O2` or `-O3` depending on whether it's a library or tool to balance compile time vs runtime speed.
- Enabled `-flto` (Link Time Optimization) consistently for improved runtime performance. If your build has an error, remove this first and try again.
- Disabled debug symbols with `-g0` for release builds to reduce binary size.

------

# Usage Tips

- Always run `sudo ldconfig` after installing libraries to update the system's dynamic linker cache.
- Use `pkg-config --modversion <libname>` to verify your libraries are installed and visible to pkg-config.
- Check runtime linkage with `ldd <binary_or_library>` to ensure dependencies resolve correctly.
- For multi-CPU or other architectures, replace `-march=native` with a specific architecture flag suitable for your system.
- You may want to customize build flags further for debugging or profiling builds.
