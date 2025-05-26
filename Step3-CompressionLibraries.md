# Compression system libraries used by Mesa, Java, Firefox

- **zlib** (gzip/deflate) — universal and essential
- **liblz4** — very fast compression, common for caches
- **libzstd** — modern, high-performance compression
- **libbz2** — older bzip2 compression, sometimes used for archives
- **libbrotli** — increasingly used by Firefox for HTTP compression
- **libxz / liblzma** — LZMA compression, often for archives or initramfs
- **libsnappy** — fast compression used in some data layers, occasionally in Firefox
- **libdeflate** — alternative fast DEFLATE implementation (sometimes used by Firefox)
- **Mesa** primarily depends on compression libraries like zlib, lz4, zstd, and sometimes bz2 for handling shader caches, textures, and compressed data in graphics drivers or filesystems.
- **Firefox** uses many of these for web content decoding (gzip, brotli, zstd), caching (lz4, zstd), archive unpacking, and cryptography.
- **OpenJDK** relies on zlib primarily but may use or support other compression formats via bundled libraries or JNI bindings.

Compression libraries for the Linux Kernel are all within the Linux Kernel source project. It doesn't use external libraries.

------



## zlib

[zlib](https://github.com/madler/zlib) is widely used for gzip compression, HTTP, ZIP files

```bash
git clone --recurse-submodules https://github.com/madler/zlib.git
cd zlib

CFLAGS="-O2 -march=native -mtune=native -funroll-loops -fomit-frame-pointer -frename-registers -fgcse-after-reload -fweb -g0 -flto -pthread" \
./configure --prefix=/usr/local

make -j$(nproc)
sudo make install
sudo ldconfig
hash -r
```

**Explanation:**

- `-O2`: Optimize code without increasing compilation time excessively.
- `-march=native` and `-mtune=native`: Optimize for the local CPU architecture.
- `-funroll-loops`: Unroll loops to improve speed in some cases.
- `-fomit-frame-pointer`: Omit the frame pointer for slightly better performance.
- `-frename-registers`, `-fgcse-after-reload`, `-fweb`: Advanced optimization passes to improve register usage and eliminate redundancies.
- `-g0`: Strip debug info to reduce binary size.
- `-flto`: Enable link-time optimization.
- `-pthread`: Enable POSIX threads.

---

## liblz4

[liblz4](https://github.com/lz4/lz4) is used for fast cache compression, shader caches, etc.

```bash
git clone https://github.com/lz4/lz4.git
cd lz4

make PREFIX=/usr/local CFLAGS="-O3 -march=native -mtune=native -fomit-frame-pointer -g0 -flto"
sudo make PREFIX=/usr/local install
sudo ldconfig;hash -r
```

**Explanation:**

- `-O3`: Maximum optimization level for performance.
- Other flags are similar in purpose to the ones used in `zlib`.

---

## zstd

[zstd](https://github.com/facebook/zstd) is increasingly popular for caching, compressed files

```bash
git clone --recurse-submodules https://github.com/facebook/zstd.git
cd zstd

make PREFIX=/usr/local CFLAGS="-O2 -march=native -mtune=native -funroll-loops -frename-registers -fweb -fgcse-after-reload -fomit-frame-pointer -g0 -flto"
sudo make PREFIX=/usr/local install
sudo ldconfig;hash -r
```

**Explanation:**

- Mixes `-O2` optimization with aggressive loop unrolling and register optimizations for a balance between compile time and runtime speed.