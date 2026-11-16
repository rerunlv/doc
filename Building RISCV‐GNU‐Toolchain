### Notice

Building this requires ~10GB available memory. Ubuntu with 4GB raises error. Ubuntu with 16GB works as intended.

### Pre-requisites

Ubuntu
```
sudo apt update
sudo apt upgrade -y
sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip python3-tomli libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev libncurses-dev -y
```

Arch
```
sudo pacman -Syu curl python3 libmpc mpfr gmp base-devel texinfo gperf patchutils bc zlib expat libslirp ncurses ninja cmake
```

### Clone and make toolchain
```
sudo echo something 

git clone https://github.com/rerunlv/riscv-gnu-toolchain.git

cd riscv-gnu-toolchain

git checkout ant

git submodule update --init --recursive

./configure --prefix=/opt/riscv

sudo make -j$(nproc)
```

### Rebuilding binutils-gdb specifically
```

sudo rm -f stamps/build-binutils-newlib

sudo make -j$(nproc) stamps/build-binutils-newlib
```


### switching to `ant` branch from `master`
``` 

cd binutils-gdb

git switch ant
```
