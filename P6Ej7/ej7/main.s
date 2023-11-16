	.data
	N:       .dword 5             // Asumimos que N != 0
    n_iter:  .dword 10            // Asumimos que n_iter != 0
    t_amb:   .dword 25
    fc_x:    .dword 2
    fc_y:    .dword 3
    fc_temp: .dword 413

    .bss 
    x: .zero  32784
    x_temp: .zero  32784 

    .text
    ldr     x0, N
    ldr     x1, =x 
    ldr     x2, =x_temp
    ldr     x3, n_iter
    ldr     x4, t_amb
    ldr		x5, fc_x
	ldr		x6, fc_y
    ldr     x7, fc_temp

    mrs x9, CPACR_EL1
    movz x12, 0x0030, lsl #16
    orr x9, x9,x12
    msr CPACR_EL1, x9
    add x9, xzr, xzr
    add x12, xzr, xzr


//---------------------- CODE HERE ------------------------------------
	// x0 = N, x4 = t_amb, x5 = fc_x, x6 = fc_y, x7 = fc_temp
    mov     x8, 0                 // Inicializar el índice del bucle en 0
	//Inicialización
	mul 	x19, x0, x0
	scvtf d7, x7
	scvtf d4, x4
	
init_loop:

	lsl 	x18 , x8, #3
    str     d4, [x1, x18]  		  // X[i] = t_amb
    add     x8, x8, #1             // Incrementar el índice del bucle
    cmp     x8, x19                // Comparar con N (número total de elementos en x)
    b.lt    init_loop              // Si no se ha alcanzado el final del bucle, repetir
	mul  	x9, x5, x0			  //fc_x*N
	add		x9, x9, x6			  //(fc_x*N) + fc_y
	lsl 	x9 , x9, #3			  // lo multiplico por 8 para avanzar en memoria
	str d7, [x1, x9]       // X[(fc_x * N) + fc_y] = fc_temp
/*
float fc_temp,sum, 
// Esta parte inicializa la matriz, solo es necesaria para verificar el código
for (int i = 0; i < N*N; ++i)
x[i] = t_amb;

x[fc_x*N+fc_y] = fc_temp;

// end inicialización


/*
los //**************  <= separan bucles/ciclos
los //--------------  <= separan los if

En los if se ejecuta el computo del "true" si falla la condicion(puesta en el branch)
y si no se salta a donde se ejecuta el codigo del "else", si fue "true" para no
ejecutar el caso "else" tambien se hace un salto incondicional

El codigo comentado de C esta representado en assembler por las instrucciones
que tiene arriba
 */
	
    mov x8, 0                
    mov x9, 0                
    mov x10, 0               
    mov x11, 0               
    mov x12, 0               
    mov x13, 0               
    mov x14, 0               
    mov x15, 0               
    mov x16, 0               
    mov x17, 0               
    mov x18, 0               
    mov x19, 0               
    mov x20, 0               
    mov x21, 0               
    mov x22, 0               
    mov x23, 0               
    mov x25, 0               

	mov 	x24, #4
	scvtf   d24, x24
	scvtf   d14, x14
	mov     x8, 0			// k = 0

	mul x12, x5, x0		  	// fc_x * N	
	add x12, x12, x6	  	// (fc_x * N) + fc_y	
loop_general://************for(int k = 0; k < n_iter; ++k)****************************

	mov x9, 0				  	// i = 0
	loop_1://**************for(int i = 0; i < N; ++i)*********************************
		mov x10, 0			  	// j = 0
		loop_2://**************for(int j = 0; j < N; ++j)*********************************
		
			mul x11, x9, x0		  	// i*N
			add x11, x11,x10 	  	// (i*N) + j
			cmp x11, x12
			b.eq if_1			  	// if((i*N+j) == (fc_x*N+fc_y)) => salta
				sub d13, d13, d13	 	// sum = 0
				
				//----------------------------------
				/*	 X11   !=       X12	
				if((i*N+j) != (fc_x*N+fc_y)){
				sum = 0;
				*/
				
				add x11, x9, #1		   	// x11 = i + 1 
				cmp x11, x0			   	// x11 == N?
					b.ge if_2_false			   // if(i + 1 >= N) => salto a la condicion del else 	
					mul x11, x11, x0   		// (i+1) * N
					add x11, x11, x10  		// ((i+1) * N) + j	
					lsl x11, x11, #3		//avanza memoria de a 8
					ldr d14, [x1, x11] 		// X[((i+1) * N) + j]
					fadd d13, d13, d14  	// sum = sum + x[((i+1)*N) + j]
					b if_2_was_true			//Salto para no ejecutar el caso "else"
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
				sub x11, x9, #1			//i - 1 
				cmp x11, xzr
					b.lt if_3_false
					mul x11, x11, x0   		// (i-1) * N
					add x11, x11, x10  		// ((i-1) * N) + j
					lsl x11, x11, #3
					ldr d14, [x1, x11] 		// X[((i-1) * N) + j]
					add d13, d13, d14  		// sum = sum + x[((i-1)*N) + j]
					b if_3_was_true			//Salto para no ejecutar el caso "else"
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
				sub x11, x11, x11
				fsub d14, d14, d14

				add x15, x10, #1		// j + 1
				cmp x15, x0				// (j+1) < N ?
					b.ge if_4_false
					mul x11, x9, x0			// i * N
					add x11, x11, x15		// (i * N) + (j + 1)
					lsl x11, x11, #3		//avanza memoria de a 8
					ldr d14, [x1, x11]		// X[(i * N) + (j + 1)]
					add d13, d13, d14		// sum = sum + X[(i * N) + (j + 1)]
					b if_4_was_true			//Salto para no ejecutar el caso "else"
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
				cmp x15, xzr			//j - 1 >= 0 ?
					b.lt if_5_false
					mul x11, x9, x0			// i * N
					add x11, x11, x15		// (i * N) + (j - 1)
					lsl x11, x11, #3
					ldr d14, [x1, x11]		// X[(i * N) + (j - 1)]
					fadd d13, d13, d14		// sum = sum + X[(i * N) + (j - 1)]
					b if_5_was_true
					if_5_false:
					fadd d13, d13, d4		//sum = sum + t_amb
				if_5_was_true:
				mul x11, x9, x0			// i * N
				add x11, x11, x10		// (i * N) + j
				lsl x11, x11, #3
				fdiv d14, d13, d24		// sum / 4
				str d14, [x2, x11]		// x_tmp[i*N + j] = sum / 4
			if_1:
			//----------------------------------
			/*
			if(j - 1 >= 0)
				sum = sum + x[i*N + j-1];
			else
				sum = sum + t_amb;
				x_tmp[i*N + j] = sum / 4;
			*/
			add x10, x10, #1	  // j = j + 1
			cmp x10, x0			  // j < N ?
		b.lt loop_2		      // j < N => jump		
		add x9, x9, #1			  // i = i + 1	
		cmp x9, x0				  //i < N ?	
	b.lt loop_1				  // i < N => jump
	
	mov x9, 0				// i = 0
	mul x10, x0, x0			// N*N
	mul x19, x5, x0			  //fc_x*N
	add	x19, x19, x6		  //(fc_x*N) + fc_y	
	loop_3://**************************************************************
		cmp x9, x19	
		b.ne if_false
			add x23, x9, #0
			lsl x23, x23, #3
			ldr x20, [x2, x23]		//x_tmp[i]
			str x20, [x1, x23]		//x[i] = x_tmp[i]
		if_false:				// no hacemos nada si i != (fc_x*N+fc_y)
		add x9, x9, #1		// i = i + 1
		cmp x9, x10			// i < N*N
	b.lt loop_3
	/*
	for (int i = 0; i < N*N; ++i)
		if(i != (fc_x*N+fc_y))
			x[i] = x_tmp[i];|
	*/

	add x8, x8, #1					// k = k + 1
	cmp x8, x3					  // k == n_iter? 
	b.lt    loop_general		  // k < n_iter => jump
	//***********************************************************************
	/*
	for(int k = 0; k < n_iter; ++k) {				<----loop_general
		break 1
		for(int i = 0; i < N; ++i) {				<----loop_1
			for(int j = 0; j < N; ++j) {			<----loop_2
				if((i*N+j) != (fc_x*N+fc_y)){		<----if_1
					sum = 0;
				if(i + 1 < N)						<----if_2
					sum = sum + x[(i+1)*N + j];
				else
					sum = sum + t_amb;
				if(i - 1 >= 0)						<----if_3
					sum = sum + x[(i-1)*N + j];
				else
					sum = sum + t_amb;
				if(j + 1 < N)						<----if_4
					sum = sum + x[i*N + j+1];
				else
					sum = sum + t_amb;
				if(j - 1 >= 0)						<----if_5
					sum = sum + x[i*N + j-1];
				else
					sum = sum + t_amb;
					x_tmp[i*N + j] = sum / 4;
				}
			}
		}
		for (int i = 0; i < N*N; ++i)				<----loop_3
			if(i != (fc_x*N+fc_y))
				x[i] = x_tmp[i];
	}

	break 2
	
	 */

inf_loop:

	b inf_loop
//---------------------- END CODE -------------------------------------


	
