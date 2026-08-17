#!/usr/bin/env bash

# Ensure the RISC-V toolchain is in the PATH
export PATH=/opt/riscv/bin:$PATH

# Configuration
TIMEOUT_DURATION="30s"
GEM5_BIN="$HOME/gem5/build/RISCV/gem5.opt"
GEM5_CFG="$HOME/gem5/configs/deprecated/example/se.py"
SUMMARY_LOG="results.txt"
TARGET_DIR="${1:-.}"

# Check binaries
if [ ! -f "$GEM5_BIN" ] || [ ! -f "$GEM5_CFG" ]; then
    echo "Error: gem5 binary or config not found."
    exit 1
fi

# Prepare summary log
echo "=== Gem5 Test Run Results ($(date)) ===" > "$SUMMARY_LOG"
printf "%-45s %-15s %s\n" "Source File" "Status" "Exit Code" >> "$SUMMARY_LOG"
printf "%s\n" "----------------------------------------------------------------------" >> "$SUMMARY_LOG"

shopt -s nullglob nocaseglob
asm_files=("$TARGET_DIR"/*.s)

if [ ${#asm_files[@]} -eq 0 ]; then
    echo "No .S or .s files found in '$TARGET_DIR'."
    exit 0
fi

echo "Found ${#asm_files[@]} assembly file(s). Starting execution..."

for src_file in "${asm_files[@]}"; do
    filename=$(basename "$src_file")
    basename_no_ext="${src_file%.*}"
    elf_file="${basename_no_ext}.elf"
    out_file="${basename_no_ext}.out.txt"

    echo "----------------------------------------"
    echo "Processing: $filename"

    # 1. Assemble
    echo "  [1/3] Assembling..."
    compile_err=$(riscv64-unknown-elf-gcc -o "$elf_file" "$src_file" -static -nostartfiles 2>&1)
    compile_status=$?

    if [ $compile_status -ne 0 ]; then
        echo "  [ERROR] Compilation failed."
        echo "$compile_err" > "$out_file"
        printf "%-45s %-15s %d\n" "$filename" "COMPILE_FAIL" "$compile_status" >> "$SUMMARY_LOG"
        continue
    fi

    # 2. Run in Gem5 with timeout, saving output to .out.txt
    echo "  [2/3] Running in Gem5 (timeout: $TIMEOUT_DURATION)..."
    timeout "$TIMEOUT_DURATION" "$GEM5_BIN" "$GEM5_CFG" -c "$elf_file" > "$out_file" 2>&1
    gem5_exit=$?

    # 3. Extract simulated exit code
    if [ $gem5_exit -eq 124 ]; then
        status="TIMEOUT"
        sim_code=124
        echo "  [RESULT] Timed out."
    elif [ $gem5_exit -ne 0 ]; then
        status="CRASH"
        sim_code=$gem5_exit
        echo "  [RESULT] Simulator crashed (Code: $gem5_exit)."
    else
        # Check if Gem5 reported a non-zero simulated guest exit code
        guest_err=$(grep -o "Simulated exit code not 0! Exit code is [0-9]*" "$out_file")
        if [ -n "$guest_err" ]; then
            sim_code=$(echo "$guest_err" | awk '{print $NF}')
            status="FAILED"
            echo "  [RESULT] Failed (Simulated exit code: $sim_code)."
        else
            status="SUCCESS"
            sim_code=0
            echo "  [RESULT] Passed (0)."
        fi
    fi

    printf "%-45s %-15s %s\n" "$filename" "$status" "$sim_code" >> "$SUMMARY_LOG"
done

echo "----------------------------------------"
echo "Done! Summary saved to $SUMMARY_LOG"
echo ""
cat "$SUMMARY_LOG"