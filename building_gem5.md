# Building Gem5

```
git clone https://github.com/rerunlv/gem5.git

cd gem5

git checkout ant

scons build/RISCV/gem5.opt -j$(nproc) --ignore-style
```

