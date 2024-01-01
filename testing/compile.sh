riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -O0 -c demo.c -o demo.o
riscv64-unknown-elf-ld -m elf32lriscv -T linker.ld -o demo.elf demo.o