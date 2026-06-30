git clone git@github.com:rerunlv/riscv-gnu-toolchain.git
git switch ant
git submodule update --init --recursive
./configure --prefix=/opt/riscv
make linux  # if /opt needs permissions to write into, use: sudo make linux