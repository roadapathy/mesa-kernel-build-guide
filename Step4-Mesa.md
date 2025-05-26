# Mesa Build Guide

This guide covers the steps to build Mesa and its related dependencies and libraries with CPU optimization flags suitable for AMD Zen (znver5) architecture. The instructions assume you have GCC 15 (`gcc-15` and `g++-15`) installed and want to install everything under `/usr/local`.

---

## Table of Contents

- [SPIR-V Headers](#spir-v-headers)  
- [SPIR-V Tools](#spir-v-tools)  
- [glslanglib](#glslanglib)  
- [SPIR-V Translator](#spir-v-translator)  
- [Cairo](#cairo)  
- [libDRM](#libdrm)  
- [libva VA-API (Video Acceleration API)](#libva-va-api-video-acceleration-api)  
- [libglvnd](#libglvnd)  
- [System Check Script](#system-check-script)  
- [Library Dependency Check](#library-dependency-check)  
- [Mesa](#mesa)  

---

## SPIR-V Headers

KhronosGroup SPIR-V Headers provide the core definitions for SPIR-V.

```bash
git clone --recurse-submodules https://github.com/KhronosGroup/SPIRV-Headers.git
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

SPIR-V Tools provide utilities to work with SPIR-V binaries.

```
git clone --recurse-submodules -b v2025.1 https://github.com/KhronosGroup/SPIRV-Tools.git
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

Reference front-end compiler for GLSL and ESSL shaders.

```
git clone --recurse-submodules -b 15.3.0 https://github.com/KhronosGroup/glslang.git
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

SPIR-V to LLVM Translator.

```
git clone --recurse-submodules -b v20.1.2 https://github.com/KhronosGroup/SPIRV-LLVM-Translator.git
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

2D graphics library used for rendering.

```
git clone --recurse-submodules git://anongit.freedesktop.org/git/cairo
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



## libDRM

Direct Rendering Manager library for interacting with GPUs.

```
git clone --recurse-submodules -b libdrm-2.4.124 https://gitlab.freedesktop.org/mesa/drm.git
cd drm

CC=gcc-15 CXX=g++-15 meson setup build \
  --prefix=/usr/local \
  --buildtype=release \
  -Db_lto=true \
  -Dradeon=enabled \
  -Damdgpu=enabled \
  -Dintel=disabled \
  -Dnouveau=disabled \
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
  -Dc_args="-O2 -march=native -mtune=native -frename-registers -fweb -fgcse-after-reload -fomit-frame-pointer -g0 -pthread -flto" \
  -Dcpp_args="-O2 -march=native -mtune=native -frename-registers -fweb -fgcse-after-reload -fomit-frame-pointer -g0 -pthread -flto"

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

Hardware video acceleration API from Intel.

```
git clone --recurse-submodules -b 2.22.0 https://github.com/intel/libva.git
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

# 
```

#### Check installation:
```
LD_DEBUG=libs vainfo 2>&1 | grep libva
ldd /usr/bin/vainfo
vainfo
```



## libglvnd

Vendor-neutral dispatch library for OpenGL.

```
git clone --recurse-submodules -b v1.7.0 https://gitlab.freedesktop.org/glvnd/libglvnd.git
cd libglvnd

./autogen.sh
CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -frename-registers -fweb -fgcse-after-reload -g0 -flto -fvisibility=hidden -fPIC -pthread" \
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

Mesa 3D Graphics Library.

```
git clone --recurse-submodules -b mesa-25.1.0-rc3 https://gitlab.freedesktop.org/mesa/mesa.git
cd mesa

CC=gcc-15 CXX=g++-15 meson setup build \
  --prefix=/usr/local \
  --buildtype=release \
  -Dgallium-drivers=radeonsi,zink,softpipe,llvmpipe \
  -Dvulkan-drivers=amd,swrast,virtio \
  -Dgallium-va=enabled \
  -Dgallium-vdpau=enabled \
  -Dllvm=enabled \
  -Dshared-llvm=enabled \
  -Dopengl=true \
  -Dgles1=disabled \
  -Dgles2=enabled \
  -Dglx=dri \
  -Dgbm=enabled \
  -Dplatforms=x11,wayland \
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
  -Dc_args="-O3 -march=native -mtune=native -fomit-frame-pointer -g0 -pthread -flto" \
  -Dcpp_args="-O3 -march=native -mtune=native -fomit-frame-pointer -g0 -pthread -flto"

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