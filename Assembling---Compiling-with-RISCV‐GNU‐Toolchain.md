Before building with riscv-gnu-toolchain, export path must be set to riscv. The following line can be added to the bottom of .bashrc or can be ran when each time a new terminal is used to assemble.

```
export PATH=/opt/riscv/bin:$PATH
```

Assembling from source assembly file

```
riscv64-unknown-elf-gcc -o output_file_name input_file.s -static -nostartfiles
```