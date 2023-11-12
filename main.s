	.data
	N:       .dword 4096	    // Number of elements in the vectors
	Alpha:   .dword 2           // Scalar value
	
	.bss 
	X: .zero  32768             // Vector X(4096)*8
	Y: .zero  32768             // Vector Y(4096)*8
    Z: .zero  32768             // Vector Y(4096)*8
	
	.text
	ldr     x0, N
    ldr     x10, Alpha	
	ldr     x2, =X		        // Posicion base del arreglo X 
	ldr     x3, =Y		        // Posicion base del arreglo Y
	ldr     x4, =Z		        // Posicion base del arreglo Z

    MRS X9, CPACR_EL1           // Read EL1 Architectural Feature Access Control Register
    MOVZ X12, 0x0030, lsl #16   // Set BITs 20 and 21
    ORR X9, X9, X12
    MSR CPACR_EL1, X9           // Write EL1 Architectural Feature Access Control Register

//---------------------- CODE HERE ------------------------------------

// Inicializacion del arreglo
    sub x15, x15, x15
    add x15, x15, #8
    scvtf d15, x15                // 8

	mov x6, #0

init:
    sub x13, x13, x13
    add x13, x13, #2
    scvtf d13, x13
    fdiv d13, d13, d15
    stur d13, [x2, #0]             // 0.25
   
    sub x14, x14, x14
    add x14, x14, #10
    scvtf d14, x14
    fdiv d14, d14, d15
    stur d14, [x3, #0]             // 0.8

	add x2, x2, #8				//Avanzo en las pos de los vectores
	add x3, x3, #8
	add x6, x6, #1				//Incrmento por que elemento del vector voy

	cmp x6, x0
	b.ne init //*****************************************************************


	scvtf d10, x10
	ldr     x2, =X		        // Posicion base del arreglo X 
	ldr     x3, =Y		        // Posicion base del arreglo Y
	sub x14, x14, x14
	sub x13, x13, x13

	mov x6, #0      // Inicializar el registro x6 con el valor 0
loop:
	// Cargar el valor correspondiente al elemento en la posición x6 de X en x11
    ldr d11, [x2, #0]
	 // Cargar el valor correspondiente al elemento en la posición x6 de Y en x13
    ldr d13, [x3, #0]
	//alpha * X[i]
	fmul d14, d13, d10
	//(alpha * X[i]) + Y[i]
	add d15, d14, d13
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

infloop:

	b infloop //*****************************************************************
//---------------------- CODE END ------------------------------------
