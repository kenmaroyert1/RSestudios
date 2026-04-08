###############################################################
# Taller de graficas - Dataset de Musica (Spotify)
# Incluye:
# 1) Replica de 15 graficas
# 2) Problema de analisis resuelto con 5 graficas
# 3) Carga automatica + seleccion manual del dataset
###############################################################

instalar_y_cargar <- function(paquetes) {
  for (p in paquetes) {
    if (!requireNamespace(p, quietly = TRUE)) {
      install.packages(p, repos = "https://cloud.r-project.org")
    }
    suppressPackageStartupMessages(library(p, character.only = TRUE))
  }
}

instalar_y_cargar(c("readr", "readxl", "dplyr", "ggplot2", "tidyr"))

obtener_dir_script <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  marcador <- "--file="
  arg_file <- args[grepl(marcador, args)]

  if (length(arg_file) > 0) {
    ruta_script <- normalizePath(sub(marcador, "", arg_file[1]), winslash = "/", mustWork = FALSE)
    return(dirname(ruta_script))
  }

  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    ruta_actual <- rstudioapi::getActiveDocumentContext()$path
    if (!is.null(ruta_actual) && nzchar(ruta_actual)) {
      return(dirname(normalizePath(ruta_actual, winslash = "/", mustWork = FALSE)))
    }
  }

  getwd()
}

dir_script <- obtener_dir_script()
dir_proyecto <- normalizePath(file.path(dir_script, ".."), winslash = "/", mustWork = FALSE)
setwd(dir_proyecto)
cat("Directorio de trabajo del taller (musica): ", getwd(), "\n", sep = "")

# ==============================
# Configuracion editable dataset
# ==============================
# Opcion A: escribe una ruta completa y deja usar_selector_manual = FALSE
ruta_dataset_manual <- ""

# Opcion B: forzar seleccion manual con ventana
usar_selector_manual <- FALSE

nombre_archivo_dataset <- "spotify_dataset_unificado.csv"
subcarpetas_dataset <- c("data", "processed", "music")

resolver_ruta_dataset <- function(
  nombre_archivo,
  subcarpetas = c("data", "processed", "music"),
  ruta_manual_codigo = "",
  usar_selector_manual = FALSE
) {
  if (nzchar(ruta_manual_codigo)) {
    if (file.exists(ruta_manual_codigo)) {
      return(ruta_manual_codigo)
    }
    warning(paste("La ruta manual no existe:", ruta_manual_codigo))
  }

  if (usar_selector_manual) {
    if (interactive()) {
      cat("\nSeleccion manual forzada: elige el dataset...\n")
      ruta_manual <- tryCatch(file.choose(), error = function(e) "")
      if (nzchar(ruta_manual) && file.exists(ruta_manual)) return(ruta_manual)
      stop("No se selecciono un archivo valido.")
    } else {
      stop("usar_selector_manual=TRUE requiere sesion interactiva (RStudio).")
    }
  }

  ruta_directa <- do.call(file.path, as.list(c(subcarpetas, nombre_archivo)))
  if (file.exists(ruta_directa)) return(ruta_directa)

  args <- commandArgs(trailingOnly = FALSE)
  marcador <- "--file="
  arg_file <- args[grepl(marcador, args)]
  if (length(arg_file) > 0) {
    ruta_script <- normalizePath(sub(marcador, "", arg_file[1]), winslash = "/", mustWork = FALSE)
    dir_script <- dirname(ruta_script)
    ruta_candidata <- do.call(file.path, as.list(c(dir_script, "..", subcarpetas, nombre_archivo)))
    ruta_candidata <- normalizePath(ruta_candidata, winslash = "/", mustWork = FALSE)
    if (file.exists(ruta_candidata)) return(ruta_candidata)
  }

  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    ruta_actual <- rstudioapi::getActiveDocumentContext()$path
    if (!is.null(ruta_actual) && nzchar(ruta_actual)) {
      dir_script <- dirname(ruta_actual)
      ruta_candidata <- do.call(file.path, as.list(c(dir_script, "..", subcarpetas, nombre_archivo)))
      ruta_candidata <- normalizePath(ruta_candidata, winslash = "/", mustWork = FALSE)
      if (file.exists(ruta_candidata)) return(ruta_candidata)
    }
  }

  if (interactive()) {
    cat("\nNo se encontro el dataset automaticamente. Seleccionalo manualmente...\n")
    ruta_manual <- tryCatch(file.choose(), error = function(e) "")
    if (nzchar(ruta_manual) && file.exists(ruta_manual)) return(ruta_manual)
  }

  stop(paste0(
    "No se encontro el archivo: ", nombre_archivo,
    "\nDirectorio actual: ", getwd(),
    "\nPuedes seleccionarlo manualmente al ejecutar en modo interactivo."
  ))
}

leer_dataset <- function(ruta) {
  ext <- tolower(tools::file_ext(ruta))
  if (ext %in% c("csv", "txt")) {
    return(readr::read_csv(ruta, show_col_types = FALSE))
  }
  if (ext %in% c("xlsx", "xls")) {
    return(readxl::read_excel(ruta))
  }
  stop("Formato no soportado. Usa CSV/TXT/XLSX/XLS")
}

ruta_dataset <- resolver_ruta_dataset(
  nombre_archivo = nombre_archivo_dataset,
  subcarpetas = subcarpetas_dataset,
  ruta_manual_codigo = ruta_dataset_manual,
  usar_selector_manual = usar_selector_manual
)
cat("\nDataset cargado desde: ", normalizePath(ruta_dataset, winslash = "/"), "\n", sep = "")

musica_raw <- leer_dataset(ruta_dataset)
musica_raw <- as.data.frame(musica_raw)

musica <- musica_raw %>%
  dplyr::mutate(
    record_type = dplyr::coalesce(record_type, ifelse(!is.na(artist_name), "artist", "song"))
  ) %>%
  dplyr::filter(record_type == "song") %>%
  dplyr::mutate(
    streams_billions = dplyr::coalesce(as.numeric(streams_2025_billions), as.numeric(total_streams_billions)),
    bpm = as.numeric(bpm),
    release_year = as.numeric(release_year),
    danceability = as.numeric(danceability),
    energy = as.numeric(energy),
    valence = as.numeric(valence),
    acousticness = as.numeric(acousticness),
    explicit = as.character(explicit),
    genre_simple = ifelse(is.na(primary_genre), "unknown", primary_genre)
  )

out_dir <- file.path("outputs", "taller_musica")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

cat("\n===== PARTE A: REPLICA DE 15 GRAFICAS =====\n")

# 1) Histograma
p1 <- ggplot2::ggplot(musica, ggplot2::aes(x = streams_billions)) +
  ggplot2::geom_histogram(bins = 20, fill = "#1f77b4", color = "white") +
  ggplot2::labs(
    title = "Grafica 01 - Cuantas canciones tienen alto potencial de reproduccion",
    subtitle = "El centro de la distribucion muestra el nivel de streams mas comun del catalogo.",
    x = "Streams (billions)",
    y = "Frecuencia"
  )
ggplot2::ggsave(file.path(out_dir, "01_histograma_streams.png"), p1, width = 9, height = 5, dpi = 120)
cat("1) Histograma: permite ver la distribucion de streams.\n")

# 2) Barras
freq_genero <- musica %>% dplyr::count(genre_simple, sort = TRUE) %>% dplyr::slice_head(n = 12)
p2 <- ggplot2::ggplot(freq_genero, ggplot2::aes(x = reorder(genre_simple, n), y = n)) +
  ggplot2::geom_col(fill = "#2ca02c") +
  ggplot2::coord_flip() +
  ggplot2::labs(
    title = "Grafica 02 - Que generos dominan la oferta musical",
    subtitle = "Top 12 generos con mayor inventario para estrategia de portafolio.",
    x = "Genero",
    y = "Cantidad"
  )
ggplot2::ggsave(file.path(out_dir, "02_barras_genero.png"), p2, width = 9, height = 6, dpi = 120)
cat("2) Barras: compara cantidad de canciones por genero.\n")

# 3) Lineas
linea_year <- musica %>% dplyr::filter(!is.na(release_year), !is.na(streams_billions)) %>%
  dplyr::group_by(release_year) %>% dplyr::summarise(promedio_streams = mean(streams_billions), .groups = "drop")
p3 <- ggplot2::ggplot(linea_year, ggplot2::aes(x = release_year, y = promedio_streams)) +
  ggplot2::geom_line(color = "#d62728", linewidth = 1) +
  ggplot2::geom_point(color = "#d62728", size = 1.7) +
  ggplot2::labs(
    title = "Grafica 03 - Evolucion del rendimiento promedio por anio",
    subtitle = "Permite identificar epocas con mejor traccion de reproducciones.",
    x = "Anio",
    y = "Promedio de streams"
  )
ggplot2::ggsave(file.path(out_dir, "03_lineas_streams_anio.png"), p3, width = 9, height = 5, dpi = 120)
cat("3) Lineas: muestra tendencia temporal por anio de lanzamiento.\n")

# 4) Dispersión
p4 <- ggplot2::ggplot(musica, ggplot2::aes(x = danceability, y = energy)) +
  ggplot2::geom_point(alpha = 0.7, color = "#9467bd") +
  ggplot2::labs(
    title = "Grafica 04 - Danceability vs energy para perfilar sonido ganador",
    subtitle = "La nube de puntos ubica zonas de estilo que concentran canciones comerciales.",
    x = "Danceability",
    y = "Energy"
  )
ggplot2::ggsave(file.path(out_dir, "04_scatter_danceability_energy.png"), p4, width = 8, height = 5, dpi = 120)
cat("4) Scatter: permite ver relacion entre dos variables numericas.\n")

# 5) Boxplot
p5 <- ggplot2::ggplot(musica %>% dplyr::filter(!is.na(explicit), !is.na(streams_billions)),
                      ggplot2::aes(x = explicit, y = streams_billions, fill = explicit)) +
  ggplot2::geom_boxplot(alpha = 0.8) +
  ggplot2::labs(
    title = "Grafica 05 - Impacto del contenido explicito en reproducciones",
    subtitle = "Compara mediana y variabilidad de streams entre contenido explicito y no explicito.",
    x = "Explicit",
    y = "Streams"
  ) +
  ggplot2::theme(legend.position = "none")
ggplot2::ggsave(file.path(out_dir, "05_boxplot_explicit_streams.png"), p5, width = 8, height = 5, dpi = 120)
cat("5) Boxplot: resume mediana, dispersion y outliers.\n")

# 6) Densidad
p6 <- ggplot2::ggplot(musica %>% dplyr::filter(!is.na(bpm)), ggplot2::aes(x = bpm)) +
  ggplot2::geom_density(fill = "#17becf", alpha = 0.6) +
  ggplot2::labs(
    title = "Grafica 06 - BPM mas frecuentes del catalogo",
    subtitle = "Muestra el rango de ritmo donde se concentran mas lanzamientos.",
    x = "BPM",
    y = "Densidad"
  )
ggplot2::ggsave(file.path(out_dir, "06_densidad_bpm.png"), p6, width = 8, height = 5, dpi = 120)
cat("6) Densidad: muestra forma de distribucion de BPM.\n")

# 7) Heatmap
heat_data <- musica %>% dplyr::count(genre_simple, explicit, name = "freq") %>% dplyr::slice_max(freq, n = 40)
p7 <- ggplot2::ggplot(heat_data, ggplot2::aes(x = explicit, y = genre_simple, fill = freq)) +
  ggplot2::geom_tile() +
  ggplot2::scale_fill_gradient(low = "#f7fbff", high = "#08306b") +
  ggplot2::labs(
    title = "Grafica 07 - Combinaciones genero-contenido con mayor presencia",
    subtitle = "Las celdas mas oscuras representan segmentos de mayor volumen.",
    x = "Explicit",
    y = "Genero"
  )
ggplot2::ggsave(file.path(out_dir, "07_heatmap_genero_explicit.png"), p7, width = 8, height = 7, dpi = 120)
cat("7) Heatmap: resalta concentraciones por combinaciones de categorias.\n")

# 8) Violin
top_gen <- musica %>% dplyr::count(genre_simple, sort = TRUE) %>% dplyr::slice_head(n = 8) %>% dplyr::pull(genre_simple)
p8 <- ggplot2::ggplot(musica %>% dplyr::filter(genre_simple %in% top_gen),
                      ggplot2::aes(x = genre_simple, y = valence, fill = genre_simple)) +
  ggplot2::geom_violin(alpha = 0.8) +
  ggplot2::coord_flip() +
  ggplot2::labs(
    title = "Grafica 08 - Emocion musical por genero (valence)",
    subtitle = "Ayuda a definir posicionamiento emocional de cada genero.",
    x = "Genero",
    y = "Valence"
  ) +
  ggplot2::theme(legend.position = "none")
ggplot2::ggsave(file.path(out_dir, "08_violin_valence_genero.png"), p8, width = 9, height = 6, dpi = 120)
cat("8) Violin: combina forma de distribucion y comparacion entre grupos.\n")

# 9) Area
area_data <- musica %>% dplyr::filter(!is.na(release_year), !is.na(streams_billions)) %>%
  dplyr::group_by(release_year) %>% dplyr::summarise(total_streams = sum(streams_billions), .groups = "drop")
p9 <- ggplot2::ggplot(area_data, ggplot2::aes(x = release_year, y = total_streams)) +
  ggplot2::geom_area(fill = "#ff7f0e", alpha = 0.7) +
  ggplot2::labs(
    title = "Grafica 09 - Volumen anual acumulado de streams",
    subtitle = "Permite mostrar crecimiento o contraccion del rendimiento total.",
    x = "Anio",
    y = "Streams acumulados"
  )
ggplot2::ggsave(file.path(out_dir, "09_area_streams_anio.png"), p9, width = 9, height = 5, dpi = 120)
cat("9) Area: util para visualizar acumulados en el tiempo.\n")

# 10) Pastel
pie_data <- musica %>% dplyr::count(genre_simple, sort = TRUE) %>% dplyr::slice_head(n = 6)
p10 <- ggplot2::ggplot(pie_data, ggplot2::aes(x = "", y = n, fill = genre_simple)) +
  ggplot2::geom_col(width = 1) +
  ggplot2::coord_polar(theta = "y") +
  ggplot2::labs(
    title = "Grafica 10 - Participacion de mercado por genero",
    subtitle = "Top 6 generos con mayor peso relativo en el catalogo.",
    x = NULL,
    y = NULL
  )
ggplot2::ggsave(file.path(out_dir, "10_pastel_generos.png"), p10, width = 7, height = 7, dpi = 120)
cat("10) Pastel: muestra participacion relativa por categoria.\n")

# 11) Pair plot (base R)
pairs_data <- musica %>% dplyr::select(streams_billions, danceability, energy, valence, acousticness, bpm) %>% na.omit()
png(file.path(out_dir, "11_pairplot_variables.png"), width = 1200, height = 1000)
graphics::pairs(pairs_data, main = "11) Pair plot de variables musicales")
dev.off()
cat("11) Pair plot: permite inspeccionar relaciones entre multiples variables.\n")

# 12) Correlacion
corr_vars <- musica %>% dplyr::select(streams_billions, danceability, energy, valence, acousticness, bpm) %>% na.omit()
mat_corr <- stats::cor(corr_vars)
heat_corr <- as.data.frame(as.table(mat_corr))
names(heat_corr) <- c("var1", "var2", "corr")
p12 <- ggplot2::ggplot(heat_corr, ggplot2::aes(x = var1, y = var2, fill = corr)) +
  ggplot2::geom_tile() +
  ggplot2::scale_fill_gradient2(low = "#2166ac", mid = "white", high = "#b2182b", midpoint = 0) +
  ggplot2::labs(
    title = "Grafica 12 - Que variables musicales se mueven juntas",
    subtitle = "Correlaciones altas orientan decisiones de produccion musical.",
    x = "",
    y = ""
  )
ggplot2::ggsave(file.path(out_dir, "12_correlacion_heatmap.png"), p12, width = 7, height = 6, dpi = 120)
cat("12) Correlacion: identifica relaciones lineales entre variables.\n")

# 13) Regresion
p13 <- ggplot2::ggplot(musica %>% dplyr::filter(!is.na(energy), !is.na(streams_billions)),
                       ggplot2::aes(x = energy, y = streams_billions)) +
  ggplot2::geom_point(alpha = 0.7, color = "#1f77b4") +
  ggplot2::geom_smooth(method = "lm", se = TRUE, color = "#d62728") +
  ggplot2::labs(
    title = "Grafica 13 - Retorno de energia musical sobre reproducciones",
    subtitle = "La pendiente resume si un sonido mas energetico se asocia a mas streams.",
    x = "Energy",
    y = "Streams"
  )
ggplot2::ggsave(file.path(out_dir, "13_regresion_energy_streams.png"), p13, width = 8, height = 5, dpi = 120)
cat("13) Regresion: estima tendencia lineal entre variables.\n")

# 14) Serie de tiempo (por anio)
serie <- musica %>% dplyr::filter(!is.na(release_year)) %>%
  dplyr::count(release_year, name = "canciones") %>%
  dplyr::arrange(release_year)
p14 <- ggplot2::ggplot(serie, ggplot2::aes(x = release_year, y = canciones)) +
  ggplot2::geom_line(color = "#2ca02c", linewidth = 1) +
  ggplot2::geom_point(color = "#2ca02c", size = 1.8) +
  ggplot2::labs(
    title = "Grafica 14 - Evolucion de lanzamientos por anio",
    subtitle = "Muestra la dinamica de oferta en el tiempo.",
    x = "Anio",
    y = "Cantidad"
  )
ggplot2::ggsave(file.path(out_dir, "14_serie_tiempo_canciones_anio.png"), p14, width = 9, height = 5, dpi = 120)
cat("14) Serie temporal: muestra evolucion cronologica del dataset.\n")

# 15) Burbujas
p15 <- ggplot2::ggplot(musica %>% dplyr::filter(!is.na(danceability), !is.na(energy), !is.na(streams_billions)),
                       ggplot2::aes(x = danceability, y = energy, size = streams_billions, color = bpm)) +
  ggplot2::geom_point(alpha = 0.65) +
  ggplot2::labs(
    title = "Grafica 15 - Mapa comercial de canciones (danceability, energy, streams y BPM)",
    subtitle = "Ayuda a detectar perfiles sonoros con mayor potencial de reproduccion.",
    x = "Danceability",
    y = "Energy"
  )
ggplot2::ggsave(file.path(out_dir, "15_burbujas_multivariable.png"), p15, width = 9, height = 5, dpi = 120)
cat("15) Burbujas: agrega una tercera variable en el tamano del punto.\n")

cat("\n===== PARTE B: PROBLEMA DE ANALISIS (5 GRAFICAS) =====\n")
cat("Problema de negocio: Que atributos musicales debemos priorizar para maximizar streams?\n")

# G1: promedio de streams por genero
prob_g1 <- musica %>%
  dplyr::group_by(genre_simple) %>%
  dplyr::summarise(prom_stream = mean(streams_billions, na.rm = TRUE), n = dplyr::n(), .groups = "drop") %>%
  dplyr::filter(n >= 2) %>%
  dplyr::arrange(desc(prom_stream)) %>%
  dplyr::slice_head(n = 12)
pg1 <- ggplot2::ggplot(prob_g1, ggplot2::aes(x = reorder(genre_simple, prom_stream), y = prom_stream)) +
  ggplot2::geom_col(fill = "#1f77b4") + ggplot2::coord_flip() +
  ggplot2::labs(
    title = "Problema G1 - Ranking de generos por promedio de streams",
    subtitle = "Generos con al menos 2 canciones para reducir sesgo por muestra pequena.",
    x = "Genero",
    y = "Promedio de streams"
  )
ggplot2::ggsave(file.path(out_dir, "problema_01_genero_prom_streams.png"), pg1, width = 9, height = 6, dpi = 120)
cat("P1 interpretacion: prioriza en el top de generos para aumentar probabilidad de exito comercial.\n")
cat("   Top 3 generos por promedio de streams: ", paste(head(prob_g1$genre_simple, 3), collapse = ", "), "\n", sep = "")

# G2: explicit vs streams
pg2 <- ggplot2::ggplot(musica %>% dplyr::filter(!is.na(explicit), !is.na(streams_billions)),
                       ggplot2::aes(x = explicit, y = streams_billions, fill = explicit)) +
  ggplot2::geom_boxplot() +
  ggplot2::labs(
    title = "Problema G2 - Diferencia de rendimiento por contenido explicito",
    subtitle = "Compara mediana y dispersion para decidir linea editorial.",
    x = "Explicit",
    y = "Streams"
  ) +
  ggplot2::theme(legend.position = "none")
ggplot2::ggsave(file.path(out_dir, "problema_02_explicit_streams.png"), pg2, width = 8, height = 5, dpi = 120)
cat("P2 interpretacion: ofrece evidencia para decidir si conviene un catalogo mas explicit o familiar.\n")

# G3: danceability vs streams
pg3 <- ggplot2::ggplot(musica %>% dplyr::filter(!is.na(danceability), !is.na(streams_billions)),
                       ggplot2::aes(x = danceability, y = streams_billions)) +
  ggplot2::geom_point(alpha = 0.65, color = "#9467bd") +
  ggplot2::geom_smooth(method = "lm", se = TRUE, color = "#d62728") +
  ggplot2::labs(
    title = "Problema G3 - Danceability como palanca de reproduccion",
    subtitle = "La tendencia lineal ayuda a validar si lo bailable impulsa el consumo.",
    x = "Danceability",
    y = "Streams"
  )
ggplot2::ggsave(file.path(out_dir, "problema_03_danceability_streams.png"), pg3, width = 8, height = 5, dpi = 120)
cat("P3 interpretacion: util para alinear produccion musical con preferencias de consumo.\n")

# G4: energy vs streams
pg4 <- ggplot2::ggplot(musica %>% dplyr::filter(!is.na(energy), !is.na(streams_billions)),
                       ggplot2::aes(x = energy, y = streams_billions)) +
  ggplot2::geom_point(alpha = 0.65, color = "#2ca02c") +
  ggplot2::geom_smooth(method = "lm", se = TRUE, color = "#d62728") +
  ggplot2::labs(
    title = "Problema G4 - Nivel de energia y resultado comercial",
    subtitle = "Evalua si una propuesta mas intensa mejora el alcance.",
    x = "Energy",
    y = "Streams"
  )
ggplot2::ggsave(file.path(out_dir, "problema_04_energy_streams.png"), pg4, width = 8, height = 5, dpi = 120)
cat("P4 interpretacion: fortalece decisiones de produccion sobre intensidad sonora.\n")

# G5: correlaciones clave
corr_prob <- musica %>% dplyr::select(streams_billions, danceability, energy, valence, acousticness, bpm) %>% na.omit()
mat_prob <- stats::cor(corr_prob)
heat_prob <- as.data.frame(as.table(mat_prob))
names(heat_prob) <- c("var1", "var2", "corr")
pg5 <- ggplot2::ggplot(heat_prob, ggplot2::aes(x = var1, y = var2, fill = corr)) +
  ggplot2::geom_tile() +
  ggplot2::scale_fill_gradient2(low = "#2166ac", mid = "white", high = "#b2182b", midpoint = 0) +
  ggplot2::labs(
    title = "Problema G5 - Mapa estrategico de correlaciones musicales",
    subtitle = "Resume que variables conviene potenciar en conjunto.",
    x = "",
    y = ""
  )
ggplot2::ggsave(file.path(out_dir, "problema_05_correlaciones.png"), pg5, width = 7, height = 6, dpi = 120)
cat("P5 interpretacion: cierra la propuesta con evidencia cuantitativa para toma de decisiones.\n")

cat("\nConclusion final (resumen):\n")
cat("- Existen segmentos de genero y estilo con mayor potencial comercial de streams.\n")
cat("- La narrativa va de inventario (oferta) a rendimiento y termina en decisiones de produccion.\n")
cat("- La evidencia permite vender una estrategia: que genero lanzar y que sonido priorizar.\n")
cat("- Se generaron 20 graficas en total (15 de guia + 5 del problema).\n")
cat("- Revisa archivos en: ", normalizePath(out_dir, winslash = "/", mustWork = FALSE), "\n", sep = "")
