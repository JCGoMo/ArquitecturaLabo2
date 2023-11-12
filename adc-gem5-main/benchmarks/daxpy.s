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


// Inicializacion del arreglo
    sub x15, x15, x15
    add x15, x15, #4
    scvtf d15, x15                // 4

	ldr     x16, =Z		        // Posicion base del arreglo Z
	ldr		x17, =X
	ldr		x18, =Y
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
	b.ne init //*****************************************************************


	scvtf d10, x10
	ldr     x2, =X		        // Posicion base del arreglo X 
	ldr     x3, =Y		        // Posicion base del arreglo Y

	fsub d11, d11, d11
	fsub d13, d13, d13
	fsub d14, d14, d14
	fsub d15, d15, d15

	mov x6, #0      // Inicializar el registro x6 con el valor 0
loop:
	// Cargar el valor correspondiente al elemento en la posición x6 de X en x11
    ldr d11, [x2, #0]
	 // Cargar el valor correspondiente al elemento en la posición x6 de Y en x13
    ldr d13, [x3, #0]
	//alpha * X[i]
	fmul d14, d11, d10
	//(alpha * X[i]) + Y[i]
	fadd d15, d14, d13
	// Guardar el valor de x14 en la posición x6 de Z
    str d15, [x4, #0]
	// i = i + 1
	add x6, x6, #1
	add x2, x2, #8
	add x3, x3, #8
	add x4, x4, #8

	// i == N ?
	cmp x6, x0
	 // Si x6 no es igual a x5, saltar de nuevo a la etiqueta "loop"
    b.ne loop //*****************************************************************

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
