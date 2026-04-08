source(file.path("R", "funciones_limpieza.R"))

instalar_y_cargar(c("readr", "readxl"))

ruta_entrada <- file.path("data", "processed", "music", "spotify_dataset_unificado.csv")
ruta_salida <- file.path("data", "processed", "dataset_1_musica_limpio.csv")
ruta_log <- file.path("outputs", "logs", "dataset_1_limpieza.log")

dataset <- leer_dataset(ruta_entrada)
dataset_limpio <- limpiar_dataset_generico(dataset)

guardar_resultados_limpieza(dataset_limpio, ruta_salida, ruta_log)

cat("Limpieza completada para dataset_1\n")
cat("Salida:", normalizePath(ruta_salida, winslash = "/", mustWork = FALSE), "\n")
cat("Log:", normalizePath(ruta_log, winslash = "/", mustWork = FALSE), "\n")
