###############################################################
# Taller - Segundo Corte
# Analisis de Datos con RStudio (Dataset de Videojuegos)
#
# Este script cumple los puntos solicitados en el taller:
# - Carga y exploracion del dataset
# - Uso de estructuras de datos de R
# - Estadisticas, filtros, frecuencias y analisis temporal
###############################################################

############################
# 0) Paquetes y utilidades #
############################

instalar_y_cargar <- function(paquetes) {
  for (p in paquetes) {
    if (!requireNamespace(p, quietly = TRUE)) {
      install.packages(p, repos = "https://cloud.r-project.org")
    }
    suppressPackageStartupMessages(
      library(p, character.only = TRUE)
    )
  }
}

instalar_y_cargar(c("readxl", "dplyr", "ggplot2", "lubridate"))

clasificar_tipo <- function(x) {
  if (inherits(x, c("Date", "POSIXct", "POSIXt"))) return("fecha-hora")
  if (is.numeric(x)) return("numerica")
  if (is.factor(x)) return("categorica")
  if (is.character(x)) return("texto/categorica")
  if (is.logical(x)) return("logica")
  "otro"
}

escalar_seguro <- function(x) {
  if (all(is.na(x))) return(rep(NA_real_, length(x)))
  s <- stats::sd(x, na.rm = TRUE)
  if (is.na(s) || s == 0) return(rep(0, length(x)))
  (x - mean(x, na.rm = TRUE)) / s
}

convertir_a_fecha <- function(x) {
  if (inherits(x, c("Date", "POSIXct", "POSIXt"))) {
    return(as.Date(x))
  }

  if (is.numeric(x)) {
    # Caso comun: columna de anio (e.g., 2001, 2017)
    if (sum(!is.na(x)) > 0 && all(x[!is.na(x)] >= 1900 & x[!is.na(x)] <= 2100)) {
      return(as.Date(paste0(as.integer(x), "-01-01")))
    }
    return(rep(as.Date(NA), length(x)))
  }

  if (is.character(x)) {
    x_trim <- trimws(x)

    intentos <- list(
      suppressWarnings(lubridate::ymd(x_trim)),
      suppressWarnings(lubridate::dmy(x_trim)),
      suppressWarnings(lubridate::mdy(x_trim)),
      suppressWarnings(lubridate::ym(x_trim)),
      suppressWarnings(lubridate::my(x_trim))
    )

    na_por_intento <- sapply(intentos, function(v) sum(!is.na(v)))
    mejor <- which.max(na_por_intento)

    if (length(mejor) == 0 || na_por_intento[mejor] == 0) {
      return(rep(as.Date(NA), length(x)))
    }

    return(as.Date(intentos[[mejor]]))
  }

  rep(as.Date(NA), length(x))
}

########################################
# 1) Cargar dataset desde archivo Excel #
########################################

archivo_excel <- "dataset_videojuegos_500.xlsx"

# Intento 1: usar el directorio de trabajo actual
ruta_excel <- archivo_excel

# Intento 2: usar la carpeta del script (funciona al ejecutar desde RStudio)
if (!file.exists(ruta_excel)) {
  args <- commandArgs(trailingOnly = FALSE)
  marcador <- "--file="
  arg_file <- args[grepl(marcador, args)]

  if (length(arg_file) > 0) {
    ruta_script <- normalizePath(sub(marcador, "", arg_file[1]), winslash = "/", mustWork = FALSE)
    dir_script <- dirname(ruta_script)
    ruta_candidata <- file.path(dir_script, archivo_excel)
    if (file.exists(ruta_candidata)) {
      ruta_excel <- ruta_candidata
    }
  }
}

# Intento 3: usar API de RStudio para ubicar el archivo activo
if (!file.exists(ruta_excel) && requireNamespace("rstudioapi", quietly = TRUE)) {
  if (rstudioapi::isAvailable()) {
    ruta_actual <- rstudioapi::getActiveDocumentContext()$path
    if (!is.null(ruta_actual) && nzchar(ruta_actual)) {
      dir_script <- dirname(ruta_actual)
      ruta_candidata <- file.path(dir_script, archivo_excel)
      if (file.exists(ruta_candidata)) {
        ruta_excel <- ruta_candidata
      }
    }
  }
}

# Intento 4: seleccion manual del archivo (ultimo recurso)
if (!file.exists(ruta_excel) && interactive()) {
  cat("\nNo se encontro automaticamente el Excel. Seleccionalo manualmente...\n")
  ruta_seleccionada <- tryCatch(file.choose(), error = function(e) "")
  if (nzchar(ruta_seleccionada) && file.exists(ruta_seleccionada)) {
    ruta_excel <- ruta_seleccionada
  }
}

if (!file.exists(ruta_excel)) {
  stop(paste0(
    "No se encontro el archivo: ", archivo_excel,
    "\nDirectorio de trabajo actual: ", getwd(),
    "\nSugerencia: usa setwd() a la carpeta del proyecto o ejecuta el script abierto en RStudio."
  ))
}

cat("\nArchivo Excel detectado en: ", normalizePath(ruta_excel, winslash = "/"), "\n", sep = "")

datos <- readxl::read_excel(ruta_excel)
datos <- as.data.frame(datos)

##############################################
# 2) Visualizar primeras filas del dataset   #
##############################################

cat("\n===== PRIMERAS FILAS DEL DATASET =====\n")
print(utils::head(datos, 10))

#############################################################
# 3) Numero de registros y numero de variables del dataset  #
#############################################################

n_registros <- nrow(datos)
n_variables <- ncol(datos)

cat("\n===== DIMENSIONES DEL DATASET =====\n")
cat("Numero de registros:", n_registros, "\n")
cat("Numero de variables:", n_variables, "\n")

###################################################
# 4) Tipo de informacion de cada columna          #
###################################################

resumen_tipos <- data.frame(
  variable = names(datos),
  clase_r = sapply(datos, function(x) paste(class(x), collapse = ", ")),
  tipo_general = sapply(datos, clasificar_tipo),
  stringsAsFactors = FALSE
)

cat("\n===== TIPO DE INFORMACION POR COLUMNA =====\n")
print(resumen_tipos)

######################################################################
# 5) Variable numerica principal en vector + promedio, maximo, minimo #
######################################################################

variables_numericas <- names(datos)[sapply(datos, is.numeric)]

if (length(variables_numericas) == 0) {
  stop("El dataset no tiene variables numericas para calcular estadisticas.")
}

# Elegimos la numerica con mayor cantidad de datos no NA
var_num_principal <- variables_numericas[
  which.max(sapply(datos[variables_numericas], function(x) sum(!is.na(x))))
]

vector_principal <- as.numeric(datos[[var_num_principal]])

estadisticas_principal <- c(
  promedio = mean(vector_principal, na.rm = TRUE),
  maximo = max(vector_principal, na.rm = TRUE),
  minimo = min(vector_principal, na.rm = TRUE)
)

cat("\n===== VARIABLE NUMERICA PRINCIPAL =====\n")
cat("Variable elegida:", var_num_principal, "\n")
print(estadisticas_principal)

###################################################################################
# 6) Estructura con distintos tipos de informacion (lista del contexto analitico) #
###################################################################################

info_analisis <- list(
  nombre_analisis = "Taller Segundo Corte - Analitica de Datos",
  dataset = archivo_excel,
  categoria_principal = "Videojuegos",
  fecha_analisis = as.character(Sys.Date()),
  numero_registros = n_registros,
  numero_variables = n_variables,
  variable_numerica_principal = var_num_principal
)

cat("\n===== ESTRUCTURA TIPO LISTA (CONTEXTO DEL ANALISIS) =====\n")
print(info_analisis)

###################################################################################
# 7) Estructura fila-columna con varias numericas + nuevo indicador (compuesto)   #
###################################################################################

vars_indicador <- variables_numericas[1:min(3, length(variables_numericas))]

base_numerica <- datos %>%
  dplyr::select(dplyr::all_of(vars_indicador))

matriz_numerica <- as.matrix(base_numerica)

# Indicador compuesto a partir de las numericas estandarizadas
base_escalada <- as.data.frame(lapply(base_numerica, escalar_seguro))
indicador_compuesto <- rowMeans(base_escalada, na.rm = TRUE)

# Data frame final fila-columna
estructura_indicador <- base_numerica %>%
  dplyr::mutate(indicador_compuesto = indicador_compuesto)

cat("\n===== MATRIZ NUMERICA Y NUEVO INDICADOR =====\n")
cat("Variables usadas para el indicador:", paste(vars_indicador, collapse = ", "), "\n")
cat("Dimension de la matriz numerica:", paste(dim(matriz_numerica), collapse = " x "), "\n")
print(utils::head(estructura_indicador, 10))

################################################################################
# 8) Filtros de informacion y estadisticas basicas del dataset completo         #
################################################################################

cat("\n===== ESTADISTICAS BASICAS DE VARIABLES NUMERICAS =====\n")
resumen_numericas <- datos %>%
  dplyr::select(dplyr::where(is.numeric)) %>%
  summary()
print(resumen_numericas)

umbral_mediana <- median(vector_principal, na.rm = TRUE)

datos_filtrados_altos <- datos %>%
  dplyr::filter(.data[[var_num_principal]] > umbral_mediana)

cat("\n===== FILTRO: REGISTROS CON", var_num_principal, "> mediana =====\n")
cat("Mediana usada como umbral:", umbral_mediana, "\n")
cat("Cantidad de registros filtrados:", nrow(datos_filtrados_altos), "\n")
print(utils::head(datos_filtrados_altos, 10))

#######################################################################################
# 9) Variable categorica -> factor + frecuencia por categoria                         #
#######################################################################################

variables_categoricas <- names(datos)[sapply(datos, function(x) is.character(x) || is.factor(x))]

if (length(variables_categoricas) == 0) {
  stop("El dataset no tiene variables categoricas (texto/factor) para frecuencias.")
}

# Elegimos la categorica con mayor cantidad de datos no NA
var_cat_principal <- variables_categoricas[
  which.max(sapply(datos[variables_categoricas], function(x) sum(!is.na(x))))
]

factor_categoria <- as.factor(datos[[var_cat_principal]])

tabla_frecuencia_categoria <- as.data.frame(table(factor_categoria, useNA = "ifany"),
                                            stringsAsFactors = FALSE)
names(tabla_frecuencia_categoria) <- c("categoria", "frecuencia")
tabla_frecuencia_categoria <- tabla_frecuencia_categoria %>%
  dplyr::arrange(desc(frecuencia))

cat("\n===== VARIABLE CATEGORICA PRINCIPAL =====\n")
cat("Variable elegida:", var_cat_principal, "\n")
print(utils::head(tabla_frecuencia_categoria, 15))

########################################################################################
# 10) Frecuencia segun una o dos variables relevantes                                  #
########################################################################################

frecuencia_1_variable <- datos %>%
  dplyr::count(.data[[var_cat_principal]], sort = TRUE, name = "frecuencia")

cat("\n===== FRECUENCIA SEGUN UNA VARIABLE =====\n")
print(utils::head(frecuencia_1_variable, 15))

frecuencia_2_variables <- NULL
if (length(variables_categoricas) >= 2) {
  var_cat_secundaria <- setdiff(variables_categoricas, var_cat_principal)[1]

  frecuencia_2_variables <- datos %>%
    dplyr::count(.data[[var_cat_principal]], .data[[var_cat_secundaria]],
                 sort = TRUE, name = "frecuencia")

  cat("\n===== FRECUENCIA SEGUN DOS VARIABLES =====\n")
  cat("Variables usadas:", var_cat_principal, "y", var_cat_secundaria, "\n")
  print(utils::head(frecuencia_2_variables, 20))
}

########################################################################################
# 11) Analisis temporal y grafico de tendencia                                         #
########################################################################################

nombres_minuscula <- tolower(names(datos))
patron_fecha <- "fecha|date|time|lanzamiento|release|anio|ano|year"
vars_candidatas_fecha <- names(datos)[grepl(patron_fecha, nombres_minuscula)]

# Priorizamos columnas con nombre sugerente, pero evaluamos todas por robustez
vars_evaluar_fecha <- unique(c(vars_candidatas_fecha, names(datos)))

mejor_var_fecha <- NA_character_
mejor_fecha <- rep(as.Date(NA), nrow(datos))
mejor_cobertura <- -1

for (v in vars_evaluar_fecha) {
  fecha_tmp <- convertir_a_fecha(datos[[v]])
  cobertura <- sum(!is.na(fecha_tmp))
  if (cobertura > mejor_cobertura) {
    mejor_cobertura <- cobertura
    mejor_var_fecha <- v
    mejor_fecha <- fecha_tmp
  }
}

usa_tiempo_real <- mejor_cobertura > 0

if (usa_tiempo_real) {
  datos$fecha_analisis <- mejor_fecha

  serie_tiempo <- datos %>%
    dplyr::filter(!is.na(fecha_analisis)) %>%
    dplyr::mutate(periodo = lubridate::floor_date(fecha_analisis, unit = "month")) %>%
    dplyr::count(periodo, name = "registros") %>%
    dplyr::arrange(periodo)

  grafico_tendencia <- ggplot2::ggplot(serie_tiempo,
                                       ggplot2::aes(x = periodo, y = registros)) +
    ggplot2::geom_line(color = "#1b6ca8", linewidth = 1) +
    ggplot2::geom_point(color = "#145374", size = 2) +
    ggplot2::labs(
      title = paste("Tendencia temporal de registros (", mejor_var_fecha, ")"),
      x = "Periodo (mes)",
      y = "Cantidad de registros"
    ) +
    ggplot2::theme_minimal()

  pendiente <- if (nrow(serie_tiempo) >= 2) {
    coef(stats::lm(registros ~ as.numeric(periodo), data = serie_tiempo))[2]
  } else {
    NA_real_
  }

} else {
  # Si no hay fecha utilizable, se crea una tendencia por secuencia de registros
  serie_tiempo <- data.frame(
    periodo = seq_len(nrow(datos)),
    valor = datos[[var_num_principal]]
  )

  grafico_tendencia <- ggplot2::ggplot(serie_tiempo,
                                       ggplot2::aes(x = periodo, y = valor)) +
    ggplot2::geom_line(color = "#1b6ca8", linewidth = 0.8) +
    ggplot2::labs(
      title = paste("Tendencia secuencial de", var_num_principal),
      subtitle = "No se detecto una variable de fecha valida; se usa indice de fila",
      x = "Orden de registro",
      y = var_num_principal
    ) +
    ggplot2::theme_minimal()

  pendiente <- if (nrow(serie_tiempo) >= 2) {
    coef(stats::lm(valor ~ periodo, data = serie_tiempo))[2]
  } else {
    NA_real_
  }
}

print(grafico_tendencia)

ggplot2::ggsave(
  filename = "grafico_tendencia_videojuegos.png",
  plot = grafico_tendencia,
  width = 10,
  height = 6,
  dpi = 120
)

########################################################################################
# 12) Respuestas solicitadas por el taller                                             #
########################################################################################

categoria_top <- tabla_frecuencia_categoria$categoria[1]
frecuencia_top <- tabla_frecuencia_categoria$frecuencia[1]

maximos_por_variable <- sapply(datos[variables_numericas], function(x) max(x, na.rm = TRUE))
variable_max_global <- names(which.max(maximos_por_variable))[1]
valor_max_global <- unname(max(maximos_por_variable, na.rm = TRUE))

if (is.na(pendiente)) {
  patron_texto <- "No fue posible estimar una tendencia por falta de puntos suficientes."
} else if (pendiente > 0) {
  patron_texto <- "Se observa una tendencia general creciente."
} else if (pendiente < 0) {
  patron_texto <- "Se observa una tendencia general decreciente."
} else {
  patron_texto <- "La tendencia general es estable."
}

cat("\n===== RESPUESTAS DEL TALLER =====\n")
cat("1) Categoria o grupo con mayor cantidad de registros:\n")
cat("   -", as.character(categoria_top), "con", frecuencia_top, "registros.\n\n")

cat("2) Variable con valores mas altos dentro del dataset:\n")
cat("   -", variable_max_global, "con valor maximo", round(valor_max_global, 2), "\n\n")

cat("3) Patron o tendencia observada:\n")
cat("   -", patron_texto, "\n\n")

cat("4) Conclusiones generales (base automatica):\n")
cat("   - El dataset tiene", n_registros, "registros y", n_variables, "variables.\n")
cat("   - La variable numerica principal analizada fue", var_num_principal, ".\n")
cat("   - La variable categorica principal analizada fue", var_cat_principal, ".\n")
cat("   - Se generaron filtros, conteos por categoria y un grafico de tendencia.\n\n")

cat("5) Estructuras de datos utilizadas:\n")
cat("   - Vector: para almacenar la variable numerica principal.\n")
cat("   - Lista: para el contexto general del analisis (metadatos).\n")
cat("   - Matriz: para combinar variables numericas base del indicador.\n")
cat("   - Data frame: para filtros, resumenes y calculo de indicador compuesto.\n")
cat("   - Factor y tabla: para frecuencias por categoria.\n\n")

cat("6) Estructura mas util durante el analisis:\n")
cat("   - Data frame, porque facilita limpieza, filtros, agrupaciones y calculos.\n\n")

cat("7) Aplicacion en un proyecto real de analitica:\n")
cat("   - Vector: metricas puntuales (KPIs).\n")
cat("   - Lista: configuracion y metadatos del proceso analitico.\n")
cat("   - Matriz: transformaciones numericas y modelos basicos.\n")
cat("   - Factor/tabla: segmentacion y perfiles de usuarios/productos.\n")
cat("   - Data frame: flujo principal de integracion, analisis y reporte.\n")

cat("\nArchivo de grafico generado: grafico_tendencia_videojuegos.png\n")
