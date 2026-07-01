# Building Riscv

```
git clone https://github.com/rerunlv/riscv-gnu-toolchain.git

cd riscv-gnu-toolchain

git checkout ant

git submodule update --init --recursive

./configure --prefix=/opt/riscv

make -j$(nproc)  # if /opt needs permissions to write into, use: sudo make linux

# Add following line to .bashrc file
export PATH=/opt/riscv/bin:$PATH
```
