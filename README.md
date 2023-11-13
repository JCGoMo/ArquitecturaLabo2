# Informe de Microbenchmark y Simulación en ARMv8

## Introducción

En este informe, se presenta un análisis detallado del microbenchmark daxpy implementado en ensamblador ARMv8. La tarea se divide en varias secciones, abordando aspectos como el rendimiento en diferentes configuraciones de caché, técnicas de mejora estática, y la comparación de resultados entre configuraciones de caché y procesadores.

## Implementación del Microbenchmark

El código assembler ARMv8 para el microbenchmark daxpy se encuentra en el archivo  [daxpy.s] Se utilizó el emulador QEMU para verificar su correcto funcionamiento.

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

Se realizaron simulaciones para diferentes tamaños de caché de datos ([8KB, 16KB, 32KB, 64KB, 128KB]) con mapeo directo de 1 vía, 2 vías, 4 vías y 8 vías. Se analizaron las siguientes métricas:

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


