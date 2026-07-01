# Building Riscv

Pre-requisites

```
sudo git update
sudo git upgrade
sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip python3-tomli libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev libncurses-dev
```

Clone and make toolchain
```
git clone https://github.com/rerunlv/riscv-gnu-toolchain.git

cd riscv-gnu-toolchain

git checkout ant

git submodule update --init --recursive

./configure --prefix=/opt/riscv

sudo make -j$(nproc)  # if /opt needs permissions to write into, use: sudo make linux
```

Before building with riscv-gnu-toolchain, run this 
```
# Add following line to .bashrc file
export PATH=/opt/riscv/bin:$PATH
```
