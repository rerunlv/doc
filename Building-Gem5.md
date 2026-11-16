### Install Prerequisites:

```
sudo apt install build-essential scons python3-dev git pre-commit zlib1g zlib1g-dev \
    libprotobuf-dev protobuf-compiler libprotoc-dev libgoogle-perftools-dev \
    libboost-all-dev  libhdf5-serial-dev python3-pydot python3-venv python3-tk mypy \
    m4 libcapstone-dev libpng-dev libelf-dev pkg-config wget cmake doxygen clang-format -y
```

### Clone and build Gem5


```
git clone https://github.com/rerunlv/gem5.git

cd gem5

git checkout ant

scons build/RISCV/gem5.opt -j$(nproc) --ignore-style
```