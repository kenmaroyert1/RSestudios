# Estructura base para limpieza de datasets

## Objetivo
Esta estructura permite recibir cualquier dataset (CSV/TXT/XLSX/XLS), limpiarlo de forma generica y guardar:
- Dataset limpio en CSV
- Log con resumen del proceso

## Estructura
- data/raw/dataset_1/: colocar aqui el primer dataset
- data/raw/dataset_2/: colocar aqui el segundo dataset
- data/processed/: salidas limpias
- R/funciones_limpieza.R: funciones reutilizables
- scripts/01_limpiar_dataset_1.R: flujo para dataset 1
- scripts/02_limpiar_dataset_2.R: flujo para dataset 2
- outputs/logs/: logs de limpieza

## Como usar
1. Copie el archivo del dataset 1 en data/raw/dataset_1/ y ajuste el nombre en scripts/01_limpiar_dataset_1.R si es necesario.
2. Copie el archivo del dataset 2 en data/raw/dataset_2/ y ajuste el nombre en scripts/02_limpiar_dataset_2.R si es necesario.
3. Ejecute en R:

```r
source("scripts/01_limpiar_dataset_1.R")
source("scripts/02_limpiar_dataset_2.R")
```

## Limpieza aplicada
- Normalizacion de nombres de columnas
- Eliminacion de filas duplicadas exactas
- Conversion de cadenas vacias a NA
- Eliminacion de columnas con NA mayores al 60%
- Conversion tentativa de texto numerico a numerico
- Imputacion simple:
  - Numericas: mediana
  - Texto: moda (categoria mas frecuente)
