# Mesa-Kernel Build Guide
Step-by-step guide to building CPU and GPU optimized Mesa and Linux Kernel. Currently, its focus is on the Ubuntu series of distros. For Debian based distros, this guide should be useful. For Arch users, not so much. It will provide hints on how to optimize other distros.

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

