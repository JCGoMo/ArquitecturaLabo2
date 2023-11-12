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
    stur d13, [x2, #0]             // X[i] = 1
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
 */


//*****************************************************************

	ldr     x16, =X		       
	ldr		x17, =Y
	ldr		x18, =Z

	scvtf d10, x10
	ldr     x2, =X		        // Posicion base del arreglo X 
	ldr     x3, =Y		        // Posicion base del arreglo Y
	ldr 	x4, =Z

	fsub d11, d11, d11
	fsub d13, d13, d13
	fsub d14, d14, d14
	fsub d15, d15, d15
	fsub d16, d16, d16
	fsub d17, d17, d17
	fsub d18, d18, d18
	fsub d19, d19, d19

	mov x5, #0
	mov x6, #0      // Inicializar el registro x6 con el valor 0
loop:
	
    ldr d11, [x16, #0]	// Cargar el valor en la pos x5 de X en x11
    ldr d13, [x17, #0]	// Cargar el valor en la pos x5 de Y en x13
	fmul d14, d11, d10	//alpha * X[i]
	fadd d15, d14, d13	//(alpha * X[i]) + Y[i]
    str d15, [x18, #0]	// Guardar el valor de x14 en la pos x5 de Z	

	ldr d16, [x16, #8]
	ldr d17, [x17, #8]
	fmul d18, d16, d10
	fadd d19, d18, d17
	str d15, [x18, #8]	// Guardar el valor de x14 en la pos x5 de Z	

	ldr d11, [x16, #16]	// Cargar el valor en la pos x5 de X en x11
    ldr d13, [x17, #16]	// Cargar el valor en la pos x5 de Y en x13
	fmul d14, d11, d10	//alpha * X[i]
	fadd d15, d14, d13	//(alpha * X[i]) + Y[i]
	str d15, [x18, #16]	// Guardar el valor de x14 en la pos x5 de Z	

	ldr d16, [x16, #24]
	ldr d17, [x17, #24]
	fmul d18, d16, d10
	fadd d19, d18, d17
	str d15, [x18, #24]	// Guardar el valor de x14 en la pos x5 de Z	

	add x16, x16, #24
	add x17, x17, #24
	add x18, x18, #24

	add x6, x6, #4	// i = i + 2 (controla i != N)
	cmp x6, x0	// i == N ?
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
