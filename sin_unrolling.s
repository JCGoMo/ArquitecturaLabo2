.global _start

.section .data
	N:      .dword 4096        // Number of elements in the vectors
	Alpha:  .dword 2           // Scalar value

.section .bss
	.align 3
	X:      .space 32768        // Vector X (4096 * 8 bytes)
	Y:      .space 32768        // Vector Y (4096 * 8 bytes)
	Z:      .space 32768        // Vector Z (4096 * 8 bytes)

.section .text
_start:
    // Initialize registers
    mov x0, #0               // i = 0
    ldr x1, =N               // Load N into register x1
    ldr x2, =Alpha           // Load Alpha into register x2
    ldr x3, =X               // Load address of X into register x3
    ldr x4, =Y               // Load address of Y into register x4
    ldr x5, =Z               // Load address of Z into register x5

loop:
    // Check loop condition: i < N
    cmp x0, x1
    bge end_loop

    // Load X[i] and Y[i]
    ldr d6, [x3, x0, lsl #3] // Load X[i] into register d6 (64-bit double)
    ldr d7, [x4, x0, lsl #3] // Load Y[i] into register d7 (64-bit double)

    // Compute Z[i] = alpha * X[i] + Y[i]
    fmov d8, x2              // Convert alpha to double (register d8)
    fmul d9, d6, d8          // Multiply alpha by X[i], result in d9
    fadd d10, d9, d7         // Add Y[i] to the result, result in d10

    // Store the result in Z[i]
    str d10, [x5, x0, lsl #3] // Store Z[i] at the address in register x5

    // Increment i
    add x0, x0, #1

    // Continue with the next iteration of the loop
    b loop

end_loop:
    // End of the program
    mov x8, #93               // System call number for exit
    mov x0, #0                // Exit status
    syscall

