source(file.path("R", "funciones_limpieza.R"))

instalar_y_cargar(c("readr", "readxl"))

ruta_entrada <- file.path("data", "raw", "dataset_2", "Pokemon_Complete_Gen1_to_Gen9.csv")
ruta_salida <- file.path("data", "processed", "dataset_2_pokemon_limpio.csv")
ruta_log <- file.path("outputs", "logs", "dataset_2_limpieza.log")

dataset <- leer_dataset(ruta_entrada)
dataset_limpio <- limpiar_dataset_generico(dataset)

guardar_resultados_limpieza(dataset_limpio, ruta_salida, ruta_log)

cat("Limpieza completada para dataset_2\n")
cat("Salida:", normalizePath(ruta_salida, winslash = "/", mustWork = FALSE), "\n")
cat("Log:", normalizePath(ruta_log, winslash = "/", mustWork = FALSE), "\n")
