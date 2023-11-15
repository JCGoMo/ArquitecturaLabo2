	.data
	N:       .dword 64	
	t_amb:   .dword 25   
	n_iter:  .dword 10    
	
	.bss 
	x: .zero 32768
	x_temp: .zero 32768  

	fc_x: 		.dword 8
	fc_y:		.dword 12 
	fc_temp:	.dword 400



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
    ldr     x1, =x 
    ldr     x2, =x_temp
    ldr     x3, n_iter
	ldr     x4, t_amb
	

//---------------------- CODE HERE ------------------------------------
	ldr		x5, fc_x
	ldr		x6, fc_y
	ldr		x7, fc_temp

    mov     x8, 0                 // Inicializar el índice del bucle en 0
	//Inicialización
	scvtf d7, x7
init_loop:
    str     x4, [x1, x8, LSL #3]  // Almacena la tmp ambiene en X[i] (x5 = i)

	mul  	x9, x5, x0			  //fc_x*N
	add		x9, x9, x6			  //(fc_x*N) + fc_y

	str		d7, [x4, x9, LSL #3]

    add     x8, x8, #1             // Incrementar el índice del bucle
	mul 	x0, x0, x0
    cmp     x8, x0                // Comparar con N (número total de elementos en x)
    b.ne    init_loop             // Si no se ha alcanzado el final del bucle, repetir
// end inicialización


/*
los //**************  <= separan bucles/ciclos
los //--------------  <= separan los if

En los if se ejecuta el computo del "true" si falla la condicion(puesta en el branch)
y si no se salta a donde se ejecuta el codigo del "else", si fue "true" para no
ejecutar el caso "else" tambien se hace un salto incondicional

 */


	mov     x8, 0				  	// k = 0
loop_general://**************************************************************

	mov x9, 0				  	// i = 0
	loop_1://**************************************************************
	mov x10, 0			  	// j = 0
	loop_2://**************************************************************
	scvtf d4, x4
	mul x11, x9, x0		  	// i*N
	add x11, x11,x10 	  	// (i*N) + j
	mul x12, x5, x0		  	// fc_x * N	
	add x12, x12, x6	  	// (fc_x * N) + fc_y	
	cmp x12, x11
	b.eq if_1			  	// if((i*N+j) == (fc_x*N+fc_y)) => salta y no modifica "sum"
	sub d13, d13, d13	 	// sum = 0
	if_1:
	//----------------------------------
	/*
	if((i*N+j) != (fc_x*N+fc_y)){
	sum = 0;
	*/
	mov x11, 0			   	// x11 = 0
	add x11, x9, #1		   	// x11 = i + 1 
	cpm x11, x0			   	// x11 == N?
	b.ge if_2_false			   // if(i + 1 >= N) => salto a la condicion del else 	
	mul x11, x11, x0   		// (i+1) * N
	lsl x11, x11, #3
	add x11, x11, x10  		// ((i+1) * N) + j	
	ldr d14, [x1, x11] 		// X[((i+1) * N) + j]
	fadd d13, d13, d14  		// sum = sum + x[((i+1)*N) + j]
	b if_2_was_true
	if_2_false:
	fadd d13, d13, d4		//sum = sum + t_amb
	if_2_was_true:
	//----------------------------------
	/*
	if(i + 1 < N)
		sum = sum + x[(i+1)*N + j];
	else
		sum = sum + t_amb;
	*/
	sub x11, x9, #1
	cmp x11, xzr
	b.lt if_3_false
	mul x11, x11, x0   		// (i-1) * N
	add x11, x11, x10  		// ((i-1) * N) + j
	lsl x11, x11, #3
	ldr d14, [x1, x11] 		// X[((i-1) * N) + j]
	add d13, d13, d14  		// sum = sum + x[((i-1)*N) + j]
	b if_3_was_true
	if_3_false:
	fadd d13, d13, d4		//sum = sum + t_amb
	if_3_was_true:
	//----------------------------------
	/*
	if(i - 1 >= 0)
		sum = sum + x[(i-1)*N + j];
	else
		sum = sum + t_amb;
	 */
	add x15, x10, #1		// j + 1
	cmp x15, x0				// (j+1) < N ?
	b.ge if_4_false
	mul x11, x9, x0			// i * N
	add x11, x11, x15		// (i * N) + (j + 1)
	lsl x11, x11, #3
	ldr d14, [x1, x11]		// X[(i * N) + (j + 1)]
	add d13, d13, d14		// sum = sum + X[(i * N) + (j + 1)]
	b if_4_was_true
	if_4_false:
	add d13, d13, d4		//sum = sum + t_amb
	if_4_was_true:
	//----------------------------------
	/*
	if(j + 1 < N)
		sum = sum + x[i*N + j+1];
	else
		sum = sum + t_amb;
	*/
	//----------------------------------
	sub x15, x10, #1
	cmp x15, xzr
	b.lt if_5_false
	mul x11, x9, x0			// i * N
	add x11, x11, x15		// (i * N) + (j - 1)
	lsl x11, x11, #3
	ldr d14, [x1, x11]		// X[(i * N) + (j - 1)]
	fadd d13, d13, d14		// sum = sum + X[(i * N) + (j - 1)]
	b if_5_was_true
	if_5_false:
	fadd d13, d13, d4		//sum = sum + t_amb
	mul x11, x9, x0			// i * N
	add x11, x11, x10		// (i * N) + j
	div x16, d13, #4		// sum / 4
	lsl x11, x11, #3
	str d14, [x2, x11]		// x_tmp[i*N + j] = sum / 4
	if_5_was_true:
	//----------------------------------
	/*
	if(j - 1 >= 0)
		sum = sum + x[i*N + j-1];
	else
		sum = sum + t_amb;
		x_tmp[i*N + j] = sum / 4;
	*/
	add x10, x10, #1	  // j = j + 1
	cmp x10, x0			  // j == N ?
	b.ne loop_2		      // j != N => jump		
	add x9, x9, #1			  // i = i + 1	
	cmp x9, x0				  //i == N ?	
	b.ne loop_1				  // i != N => jump
	
	mov x17, 0				// i = 0
	mul x18, x0, x0			// N*N
	loop_3://**************************************************************
	mul x19, x5, x0			  //fc_x*N
	add	x19, x19, x6		  //(fc_x*N) + fc_y	
	cmp x17, x19	
	b.ne if_false
	add x23, x17, #0
	lsl x23, x23, #3
	ldr x20, [x2, x23]		//x_tmp[i]
	str x20, [x1, x23]		//x[i] = x_tmp[i]
	if_false:
	add x17, x17, #1		// i = i + 1
	cmp x17, x18			// i < N*N
	b.lt loop_3
	/*
	for (int i = 0; i < N*N; ++i)
		if(i != (fc_x*N+fc_y))
			x[i] = x_tmp[i];|
	*/

	add x8, x8, #1					// k = k + 1
	cmp x8, x3					  // k == n_iter? 
	b.ne    loop_general		  // k != n_iter => jump
	//***********************************************************************
	/*
	for(int k = 0; k < n_iter; ++k) {
		for(int i = 0; i < N; ++i) {
			for(int j = 0; j < N; ++j) {
				if((i*N+j) != (fc_x*N+fc_y)){
					sum = 0;
				if(i + 1 < N)
					sum = sum + x[(i+1)*N + j];
				else
					sum = sum + t_amb;
				if(i - 1 >= 0)
					sum = sum + x[(i-1)*N + j];
				else
					sum = sum + t_amb;
				if(j + 1 < N)
					sum = sum + x[i*N + j+1];
				else
					sum = sum + t_amb;
				if(j - 1 >= 0)
					sum = sum + x[i*N + j-1];
				else
					sum = sum + t_amb;
					x_tmp[i*N + j] = sum / 4;
				}
			}
		}
		for (int i = 0; i < N*N; ++i)
			if(i != (fc_x*N+fc_y))
				x[i] = x_tmp[i];
	}
	
	 */

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
