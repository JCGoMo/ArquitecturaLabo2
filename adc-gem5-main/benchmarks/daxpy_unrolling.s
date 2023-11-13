	.data
	N:       .dword 4096	// Number of elements in the vectors
	Alpha:   .dword 2      // scalar value
	
	.bss 
	X: .zero  32768        // vector X(4096)*8
	Y: .zero  32768        // Vector Y(4096)*8
    Z: .zero  32768        // Vector Y(4096)*8

	.arch armv8-a
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB6:
	.cfi_startproc
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov	x29, sp
	mov	x1, 0
	mov	x0, 0
	bl	m5_dump_stats

	ldr     x0, N
    	ldr     x10, =Alpha
    	ldr     x2, =X
    	ldr     x3, =Y
	ldr     x4, =Z

//---------------------- CODE HERE ------------------------------------



/*
// Inicializacion del arreglo
    sub x15, x15, x15
    add x15, x15, #4
    scvtf d15, x15                // 4

	
	mov x6, #0

init:
    sub x13, x13, x13
    add x13, x13, #2
    scvtf d13, x13
    fdiv d13, d13, d15				// 0.50	
    stur d13, [x2, #0]            
    sub x14, x14, x14
    add x14, x14, #10
    scvtf d14, x14
    fdiv d14, d14, d15
    stur d14, [x3, #0]             // 2,5

	add x2, x2, #8				//Avanzo en las pos de los vectores
	add x3, x3, #8
	add x6, x6, #1				//Incrmento por que elemento del vector voy

	cmp x6, x0
	b.ne init 

	ldr     x2, =X		        // Posicion base del arreglo X 
	ldr     x3, =Y		        // Posicion base del arreglo Y
	ldr 	x4, =Z				// Posicion base del arreglo Z

 */

	scvtf d10, x10
	

	fsub d11, d11, d11
	fsub d13, d13, d13
	fsub d14, d14, d14
	fsub d15, d15, d15
	fsub d16, d16, d16
	fsub d17, d17, d17
	fsub d18, d18, d18

	mov x6, #0      // i = 0
loop:
	
    ldr d11, [x2, #0]		//X[i]
    ldr d12, [x3, #0]		//Y[i]
	fmul d11, d11, d10		//X[i] * alpha
	fadd d12, d11, d12		//(X[i] * alpha) + Y[i]
	ldr d13, [x2, #8]		//X[i+1]
	ldr d14, [x3, #8]		//Y[i+1]
	fmul d13, d13, d10		//X[i+1] * alpha
	fadd d14, d13, d14		//(X[i+1] * alpha) + Y[i+1]

	ldr d15, [x2, #16]		//X[i+2]
    ldr d16, [x3, #16]		//Y[i+2]
	fmul d15, d15, d10		//X[i+2] * alpha
	fadd d16, d15, d16		//(X[i+2] * alpha) + Y[i+2]
	
	ldr d17, [x2, #24]		//X[i+3]
	ldr d18, [x3, #24]		//Y[i+3]
	fmul d17, d17, d10		//X[i+3] * alpha
	fadd d18, d17, d18		//(X[i+3] * alpha) + Y[i+3]
	
	str d12, [x4, #0]		//Z[i] = (X[i] * alpha) + Y[i]
	add x6, x6, #4			// i = i + 4
	str d14, [x4, #8]		//Z[i+1] = (X[i+1] * alpha) + Y[i+1]
	add X2, x2, #32		//Avanzan 4 pos en mem: en X
	str d16, [x4, #16]		//Z[i+2] = (X[i+2] * alpha) + Y[i+2]
	add x3, x3, #32		// 						en Y
	str d18, [x4, #24]		//Z[i+3] = (X[i+3] * alpha) + Y[i+3]
	cmp x6, x0				// i == N ?

	add x4, x4, #32		// 						en Z 
	
    b.ne loop

//---------------------- END CODE -------------------------------------

	mov 	x0, 0
	mov 	x1, 0
	bl	m5_dump_stats
	mov	w0, 0
	ldp	x29, x30, [sp], 16
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
