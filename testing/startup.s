    .section hello.text
    .global _start
    .global main

_start:
    lui sp, %hi(512*1024)
    addi sp, sp, %lo(512*1024)
    
    jal ra, main
