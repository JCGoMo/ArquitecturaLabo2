# Informe de Microbenchmark y Simulación en ARMv8

## Introducción

En este informe, se presenta un análisis detallado del microbenchmark daxpy implementado en ensamblador ARMv8. La tarea se divide en varias secciones, abordando aspectos como el rendimiento en diferentes configuraciones de caché, técnicas de mejora estática, y la comparación de resultados entre configuraciones de caché y procesadores.

## a) Implementación del Microbenchmark

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

