# Informe del Proyecto: Análisis de Microarquitectura con gem5

## Introducción

En este informe, se presenta un análisis detallado del microbenchmark daxpy implementado en ensamblador ARMv8. La tarea se divide en varias secciones, abordando aspectos como el rendimiento en diferentes configuraciones de caché, técnicas de mejora estática, y la comparación de resultados entre configuraciones de caché y procesadores.

## Implementación del Microbenchmark

El código assembler ARMv8 para el microbenchmark daxpy se encuentra en el archivo  `daxpy.s` Se utilizó el emulador QEMU para verificar su correcto funcionamiento.

El codigo en c:
```c
const int N;
double X[N], Y[N], Z[N], alpha;

for (int i = 0; i < N; ++i)
{
    Z[i] = alpha * X[i] + Y[i];
}
```

## Simulaciones con distintos tipos de cache

Se realizaron simulaciones para diferentes tamaños de caché de datos ([8KB, 16KB, 32KB, 64KB, 128KB]) con mapeo de 1 vía, 2 vías, 4 vías y 8 vías. Se analizaron las siguientes métricas:

- Número de ciclos (numCycles)
- Ciclos ociosos (idleCycles)
- Hits totales en la caché de datos (overallHits)
- Hits de lectura en la caché de datos (ReadReq.hits)

## Análisis y Gráficos   

| Número de ciclos (numCycles)  | Ciclos ociosos (idleCycles) |
| :---:    |   :---:  |
| ![numCycles](/graficos/numCycles.png) | ![idleCycles](/graficos/idleCycles.png) |
| **Hits totales en la caché de datos (overallHits)**   | **Hits de lectura en la caché de datos (ReadReq.hits)**  |
| ![overallHits](/graficos/overallHits.png)   | ![ReadReq.hits](/graficos/ReadReq_hits.png)  |

Tras correr la simulación y recopilar los datos solicitados pudimos analizarlos y llegar a ciertas conclusiones. Primero notamos que en la ejecución del programa con una vía y distintos tamaños de caché, la cantidad de ciclos totales desciende a partir de 32KB(con 128KB aumenta pero es por un comportamiento del simulador, nosotros esperábamos que la cantidad de ciclos totales disminuyera de los 200 mil). Razonamos que es porque una mayor cantidad de elementos de los vectores que utiliza el programa son capaces de almacenarse en la caché, disminuyendo los ciclos ociosos (idleCycles)  mientras se traen los datos de memoria. Esto también lo podemos notar tras ver un gran aumento en los hits de la caché.

Luego tras contrastar el comportamiento de la caché de una vía y dos vias con distintos tamaños pudimos observar que la caché de 2 vías posee un desempeño mucho más eficiente en cuanto a la totalidad de ciclos que le toma correr el programa y los hits, (excepto en 2 vías con 64KB vs 1 vía con 64KB), consideramos que este comportamiento se debe a la capacidad de guardar los datos en un mismo índice/set pero en otra vía disminuyendo la competencia por la posición. Por último el comportamiento de la caché de 2 vías con un tamaño de 128KB nos sorprendió, ya que esperábamos que al tener espacio suficiente para todos los vectores la cantidad de ciclos disminuye aún más ya que la cantidad de hits aumenta significativamente ( le atribuimos este comportamiento a lo mismo que paso con la caché de 1 vía y 128KB).

Luego al analizar el comportamiento del código con 4 y 8 vías notamos un aumento aproximado de 20~15 mil ciclos con respecto del comportamiento con 1 vía. Luego de analizarlo concluimos que con tantos accesos consecutivos a memoria a partir de 4 vías con varias opciones de donde almacenar el dato podría ocasionar conflictos en la caché dependiendo de qué políticas usa para escribir los datos lo que genera un aumento en la cantidad de ciclos. Pero cabe notar que a pesar del aumento en los ciclos el funcionamiento de los hits de caché fue considerablemente mayor que en una vía para todos los tamaños de la caché. Creemos que esto también se debe al haber más de un lugar donde guardar el dato ocasionando más hits aun con tamaños pequeños de caché pero que al llenarse y requerir nuevas busquedas en la memoria principal genera el aumento en los ciclos totales. 

## Técnicas estáticas de mejora de rendimiento  

La técnica de mejora utilizada en el inciso “e” fue **loop unrolling**, para incrementar la eficiencia cambiamos la lógica del ciclo para computar 4 valores por iteración. Más en detalle en cada ciclo accedemos primero a todos los valores de X que vamos a necesitar, luego realizamos el cálculo **X[i] * alpha** (para los respectivos i, i+1, i+2 e i+3), posteriormente traemos de memoria todos los valores **Y[i]** que usaremos, luego calculamos **(X[i] * alpha)+Y[i]** (para los i antes mencionados) y finalmente guardamos los resultados **Z[i]** en memoria. Antes de finalizar el ciclo actualizamos los registros que nos señalan a que posición de memoria vamos a acceder en la próxima iteración.

Luego de este cambio notamos una disminución de los **ciclos totales** y **ciclos ociosos** que le tomaba al programa ejecutarse así como un aumento en los hits de la caché de datos. Al analizar los códigos vemos que el optimizado proporciona un uso más eficiente de la caché al tomar ventaja de la proximidad local de los datos. Al acceder a datos consecutivos de un mismo vector lo más probable es que estén localizados en los mismos bloques varios de ellos garantizando que después de un miss de caché se realizarán varios hits al haber traído de memoria por el miss el dato necesarios y los siguientes que serán accedidos justo después. 
Sobre todo notamos una drástica mejora con el procesador “**out of order**” en todos los aspectos, menos ciclos totales y ociosos así como más hits de caché(la cantidad fue menor en número que en el “**in order**” pero teniendo en cuenta la cantidad de ciclos el porcentaje de hits fue mayor). Después de analizarlo concluimos que es debido al uso eficiente de las reservation stations y unidades funcionales del procesador, ya que los accesos a memoria pueden hacerse en paralelo debido a que no dependen uno de otros así como los cálculos de punto flotante. Solo debe cuidarse de esperar a que un dato sea cargado antes de calcularlo y luego que ya esté calculado antes de guardarlo, y realizando esa tarea con 4 elementos por ciclo se alcanza un alto grado de eficiencia y mejora en comparación con el código no mejorado.