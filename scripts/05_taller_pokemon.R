###############################################################
# Taller de graficas - Dataset Pokemon
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
cat("Directorio de trabajo del taller (pokemon): ", getwd(), "\n", sep = "")

# ==============================
# Configuracion editable dataset
# ==============================
# Opcion A: escribe una ruta completa y deja usar_selector_manual = FALSE
ruta_dataset_manual <- ""

# Opcion B: forzar seleccion manual con ventana
usar_selector_manual <- FALSE

nombre_archivo_dataset <- "Pokemon_Complete_Gen1_to_Gen9.csv"
subcarpetas_dataset <- c("data", "raw", "dataset_2")

resolver_ruta_dataset <- function(
  nombre_archivo,
  subcarpetas = c("data", "raw", "dataset_2"),
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

asignar_generacion <- function(id) {
  dplyr::case_when(
    id <= 151 ~ "Gen1",
    id <= 251 ~ "Gen2",
    id <= 386 ~ "Gen3",
    id <= 493 ~ "Gen4",
    id <= 649 ~ "Gen5",
    id <= 721 ~ "Gen6",
    id <= 809 ~ "Gen7",
    id <= 905 ~ "Gen8",
    TRUE ~ "Gen9"
  )
}

ruta_dataset <- resolver_ruta_dataset(
  nombre_archivo = nombre_archivo_dataset,
  subcarpetas = subcarpetas_dataset,
  ruta_manual_codigo = ruta_dataset_manual,
  usar_selector_manual = usar_selector_manual
)
cat("\nDataset cargado desde: ", normalizePath(ruta_dataset, winslash = "/"), "\n", sep = "")

poke <- leer_dataset(ruta_dataset)
poke <- as.data.frame(poke)

poke <- poke %>%
  dplyr::mutate(
    id = as.numeric(id),
    height = as.numeric(height),
    weight = as.numeric(weight),
    base_experience = as.numeric(base_experience),
    hp = as.numeric(hp),
    attack = as.numeric(attack),
    defense = as.numeric(defense),
    sp_attack = as.numeric(sp_attack),
    sp_defense = as.numeric(sp_defense),
    speed = as.numeric(speed),
    generation = asignar_generacion(id),
    total_stats = hp + attack + defense + sp_attack + sp_defense + speed,
    type2 = ifelse(is.na(type2) | type2 == "", "none", type2)
  )

orden_generacion <- c("Gen1", "Gen2", "Gen3", "Gen4", "Gen5", "Gen6", "Gen7", "Gen8", "Gen9")
poke$generation <- factor(poke$generation, levels = orden_generacion, ordered = TRUE)

out_dir <- file.path("outputs", "taller_pokemon")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

cat("\n===== PARTE A: REPLICA DE 15 GRAFICAS =====\n")

# 1) Histograma
p1 <- ggplot2::ggplot(poke, ggplot2::aes(x = total_stats)) +
  ggplot2::geom_histogram(bins = 25, fill = "#1f77b4", color = "white") +
  ggplot2::labs(
    title = "Grafica 01 - Cuantos Pokemon tienen poder competitivo",
    subtitle = "La concentracion central muestra el rango de stats mas comun para construir equipos.",
    x = "Total de stats",
    y = "Frecuencia"
  )
ggplot2::ggsave(file.path(out_dir, "grafica_01_distribucion_poder_total.png"), p1, width = 9, height = 5, dpi = 120)
cat("1) Histograma: distribucion de poder total de Pokemon.\n")

# 2) Barras
count_type <- poke %>% dplyr::count(type1, sort = TRUE) %>% dplyr::slice_head(n = 12)
p2 <- ggplot2::ggplot(count_type, ggplot2::aes(x = reorder(type1, n), y = n)) +
  ggplot2::geom_col(fill = "#2ca02c") + ggplot2::coord_flip() +
  ggplot2::labs(
    title = "Grafica 02 - Que tipos dominan el catalogo de Pokemon",
    subtitle = "Top 12 tipos principales con mayor disponibilidad para armar estrategia.",
    x = "Tipo principal",
    y = "Cantidad de Pokemon"
  )
ggplot2::ggsave(file.path(out_dir, "grafica_02_cantidad_por_tipo_principal.png"), p2, width = 9, height = 6, dpi = 120)
cat("2) Barras: compara frecuencia de tipos principales.\n")

# 3) Lineas
linea_gen <- poke %>% dplyr::group_by(generation) %>%
  dplyr::summarise(prom_total = mean(total_stats, na.rm = TRUE), .groups = "drop")
p3 <- ggplot2::ggplot(linea_gen, ggplot2::aes(x = generation, y = prom_total, group = 1)) +
  ggplot2::geom_line(color = "#d62728", linewidth = 1) +
  ggplot2::geom_point(color = "#d62728", size = 2) +
  ggplot2::labs(
    title = "Grafica 03 - Evolucion del poder promedio por generacion",
    subtitle = "Permite detectar generaciones con mejor base estadistica para competir.",
    x = "Generacion",
    y = "Promedio de total de stats"
  )
ggplot2::ggsave(file.path(out_dir, "grafica_03_promedio_poder_por_generacion.png"), p3, width = 9, height = 5, dpi = 120)
cat("3) Lineas: muestra variacion promedio por generacion.\n")

# 4) Dispersión
p4 <- ggplot2::ggplot(poke, ggplot2::aes(x = attack, y = speed)) +
  ggplot2::geom_point(alpha = 0.6, color = "#9467bd") +
  ggplot2::labs(
    title = "Grafica 04 - Ataque vs velocidad para perfilar estilos de combate",
    subtitle = "Arriba a la derecha: perfiles ofensivos y rapidos con alto valor tactico.",
    x = "Ataque",
    y = "Velocidad"
  )
ggplot2::ggsave(file.path(out_dir, "grafica_04_relacion_ataque_velocidad.png"), p4, width = 8, height = 5, dpi = 120)
cat("4) Scatter: permite evaluar relacion entre ataque y velocidad.\n")

# 5) Boxplot
type_top <- poke %>% dplyr::count(type1, sort = TRUE) %>% dplyr::slice_head(n = 10) %>% dplyr::pull(type1)
p5 <- ggplot2::ggplot(poke %>% dplyr::filter(type1 %in% type_top), ggplot2::aes(x = type1, y = total_stats, fill = type1)) +
  ggplot2::geom_boxplot() +
  ggplot2::coord_flip() +
  ggplot2::labs(
    title = "Grafica 05 - Calidad de stats por tipo principal",
    subtitle = "Compara mediana y variabilidad para elegir tipos consistentes.",
    x = "Tipo principal",
    y = "Total de stats"
  ) +
  ggplot2::theme(legend.position = "none")
ggplot2::ggsave(file.path(out_dir, "grafica_05_distribucion_poder_por_tipo.png"), p5, width = 9, height = 6, dpi = 120)
cat("5) Boxplot: resume mediana, dispersion y valores extremos por tipo.\n")

# 6) Densidad
p6 <- ggplot2::ggplot(poke, ggplot2::aes(x = hp)) +
  ggplot2::geom_density(fill = "#17becf", alpha = 0.6) +
  ggplot2::labs(
    title = "Grafica 06 - Resistencia promedio del roster (HP)",
    subtitle = "Muestra donde se concentra la supervivencia de los Pokemon.",
    x = "HP",
    y = "Densidad"
  )
ggplot2::ggsave(file.path(out_dir, "grafica_06_densidad_hp.png"), p6, width = 8, height = 5, dpi = 120)
cat("6) Densidad: forma de distribucion de puntos de vida.\n")

# 7) Heatmap
heat_data <- poke %>% dplyr::count(type1, type2, name = "freq") %>% dplyr::slice_max(freq, n = 50)
p7 <- ggplot2::ggplot(heat_data, ggplot2::aes(x = type2, y = type1, fill = freq)) +
  ggplot2::geom_tile() +
  ggplot2::scale_fill_gradient(low = "#f7fbff", high = "#08306b") +
  ggplot2::labs(
    title = "Grafica 07 - Combinaciones de tipos mas repetidas",
    subtitle = "Las celdas mas oscuras indican sinergias frecuentes en el dataset.",
    x = "Tipo secundario",
    y = "Tipo principal"
  )
ggplot2::ggsave(file.path(out_dir, "grafica_07_mapa_calor_combinaciones_tipo.png"), p7, width = 9, height = 7, dpi = 120)
cat("7) Heatmap: identifica combinaciones de tipos mas frecuentes.\n")

# 8) Violin
p8 <- ggplot2::ggplot(poke, ggplot2::aes(x = generation, y = speed, fill = generation)) +
  ggplot2::geom_violin(alpha = 0.8) +
  ggplot2::labs(
    title = "Grafica 08 - Velocidad por generacion",
    subtitle = "Compara el perfil de rapidez para decidir metajuego por epoca.",
    x = "Generacion",
    y = "Velocidad"
  ) +
  ggplot2::theme(legend.position = "none")
ggplot2::ggsave(file.path(out_dir, "grafica_08_distribucion_velocidad_por_generacion.png"), p8, width = 9, height = 5, dpi = 120)
cat("8) Violin: compara forma de distribucion entre generaciones.\n")

# 9) Area
area_data <- poke %>% dplyr::count(generation, name = "cantidad")
p9 <- ggplot2::ggplot(area_data, ggplot2::aes(x = generation, y = cantidad, group = 1)) +
  ggplot2::geom_area(fill = "#ff7f0e", alpha = 0.7) +
  ggplot2::labs(
    title = "Grafica 09 - Volumen de Pokemon por generacion",
    subtitle = "Mide la oferta por generacion para evaluar amplitud de opciones.",
    x = "Generacion",
    y = "Cantidad de Pokemon"
  )
ggplot2::ggsave(file.path(out_dir, "grafica_09_cantidad_por_generacion_area.png"), p9, width = 9, height = 5, dpi = 120)
cat("9) Area: visualiza volumen por generacion.\n")

# 10) Pastel
pie_data <- poke %>% dplyr::count(type1, sort = TRUE) %>% dplyr::slice_head(n = 8)
p10 <- ggplot2::ggplot(pie_data, ggplot2::aes(x = "", y = n, fill = type1)) +
  ggplot2::geom_col(width = 1) +
  ggplot2::coord_polar(theta = "y") +
  ggplot2::labs(
    title = "Grafica 10 - Participacion de mercado por tipo principal",
    subtitle = "Top 8 tipos con mayor presencia relativa.",
    x = NULL,
    y = NULL
  )
ggplot2::ggsave(file.path(out_dir, "grafica_10_proporcion_tipos_principales.png"), p10, width = 7, height = 7, dpi = 120)
cat("10) Pastel: proporciones de tipos principales.\n")

# 11) Pair plot (base R)
pairs_data <- poke %>% dplyr::select(hp, attack, defense, sp_attack, sp_defense, speed) %>% na.omit()
png(file.path(out_dir, "grafica_11_matriz_relaciones_stats.png"), width = 1200, height = 1000)
graphics::pairs(pairs_data, main = "Grafica 11 - Matriz de relaciones entre stats de combate")
dev.off()
cat("11) Pair plot: revisa relaciones entre multiples stats.\n")

# 12) Correlacion
corr_vars <- poke %>% dplyr::select(hp, attack, defense, sp_attack, sp_defense, speed, total_stats) %>% na.omit()
mat_corr <- stats::cor(corr_vars)
heat_corr <- as.data.frame(as.table(mat_corr))
names(heat_corr) <- c("var1", "var2", "corr")
p12 <- ggplot2::ggplot(heat_corr, ggplot2::aes(x = var1, y = var2, fill = corr)) +
  ggplot2::geom_tile() +
  ggplot2::scale_fill_gradient2(low = "#2166ac", mid = "white", high = "#b2182b", midpoint = 0) +
  ggplot2::labs(
    title = "Grafica 12 - Que stats se mueven juntas",
    subtitle = "Correlaciones altas ayudan a priorizar entrenamiento y seleccion.",
    x = "",
    y = ""
  )
ggplot2::ggsave(file.path(out_dir, "grafica_12_correlaciones_entre_stats.png"), p12, width = 7, height = 6, dpi = 120)
cat("12) Correlacion: muestra relaciones lineales entre stats.\n")

# 13) Regresion
p13 <- ggplot2::ggplot(poke %>% dplyr::filter(!is.na(base_experience), !is.na(total_stats)),
                       ggplot2::aes(x = base_experience, y = total_stats)) +
  ggplot2::geom_point(alpha = 0.6, color = "#1f77b4") +
  ggplot2::geom_smooth(method = "lm", se = TRUE, color = "#d62728") +
  ggplot2::labs(
    title = "Grafica 13 - Retorno de inversion: experiencia base vs poder total",
    subtitle = "Evalua si subir experiencia realmente agrega potencia estadistica.",
    x = "Experiencia base",
    y = "Total de stats"
  )
ggplot2::ggsave(file.path(out_dir, "grafica_13_regresion_experiencia_vs_poder.png"), p13, width = 8, height = 5, dpi = 120)
cat("13) Regresion: explora tendencia entre experiencia y poder total.\n")

# 14) Serie de tiempo (secuencia por id)
serie <- poke %>% dplyr::filter(!is.na(id), !is.na(total_stats)) %>% dplyr::arrange(id)
p14 <- ggplot2::ggplot(serie, ggplot2::aes(x = id, y = total_stats)) +
  ggplot2::geom_line(color = "#2ca02c", linewidth = 0.8) +
  ggplot2::labs(
    title = "Grafica 14 - Evolucion del poder a lo largo del Pokedex",
    subtitle = "Permite explicar cambios de diseno y balance entre generaciones.",
    x = "ID Pokedex",
    y = "Total de stats"
  )
ggplot2::ggsave(file.path(out_dir, "grafica_14_evolucion_poder_por_id.png"), p14, width = 10, height = 5, dpi = 120)
cat("14) Serie secuencial: muestra variacion de stats en orden del Pokedex.\n")

# 15) Burbujas
p15 <- ggplot2::ggplot(poke, ggplot2::aes(x = attack, y = defense, size = hp, color = speed)) +
  ggplot2::geom_point(alpha = 0.65) +
  ggplot2::labs(
    title = "Grafica 15 - Mapa de perfiles de combate (ataque, defensa, HP y velocidad)",
    subtitle = "Identifica de forma visual tanques, sweepers y perfiles balanceados.",
    x = "Ataque",
    y = "Defensa"
  )
ggplot2::ggsave(file.path(out_dir, "grafica_15_burbujas_ataque_defensa_hp.png"), p15, width = 9, height = 5, dpi = 120)
cat("15) Burbujas: agrega una tercera variable al tamano del punto.\n")

cat("\n===== PARTE B: PROBLEMA DE ANALISIS (5 GRAFICAS) =====\n")
cat("Problema de negocio: Si fueras entrenador, en que tipo y generacion invertir para competir mejor?\n")

# G1: promedio total por type1
prob_g1 <- poke %>%
  dplyr::group_by(type1) %>%
  dplyr::summarise(prom_total = mean(total_stats, na.rm = TRUE), n = dplyr::n(), .groups = "drop") %>%
  dplyr::filter(n >= 5) %>%
  dplyr::arrange(desc(prom_total)) %>%
  dplyr::slice_head(n = 12)
pg1 <- ggplot2::ggplot(prob_g1, ggplot2::aes(x = reorder(type1, prom_total), y = prom_total)) +
  ggplot2::geom_col(fill = "#1f77b4") + ggplot2::coord_flip() +
  ggplot2::labs(
    title = "Problema G1 - Ranking de tipos por poder promedio",
    subtitle = "Tipos con al menos 5 Pokemon para evitar sesgo por muestras pequenas.",
    x = "Tipo principal",
    y = "Promedio de total de stats"
  )
ggplot2::ggsave(file.path(out_dir, "problema_g1_promedio_poder_por_tipo.png"), pg1, width = 9, height = 6, dpi = 120)
cat("P1 interpretacion: prioriza los tipos del top para construir equipos con mayor techo competitivo.\n")
cat("   Top 3 tipos por promedio de poder: ", paste(head(prob_g1$type1, 3), collapse = ", "), "\n", sep = "")

# G2: boxplot por generacion
pg2 <- ggplot2::ggplot(poke, ggplot2::aes(x = generation, y = total_stats, fill = generation)) +
  ggplot2::geom_boxplot() +
  ggplot2::labs(
    title = "Problema G2 - Que generaciones ofrecen mejor piso y techo de poder",
    subtitle = "Las cajas comparan mediana, dispersion y extremos por generacion.",
    x = "Generacion",
    y = "Total de stats"
  ) +
  ggplot2::theme(legend.position = "none")
ggplot2::ggsave(file.path(out_dir, "problema_g2_distribucion_poder_por_generacion.png"), pg2, width = 9, height = 5, dpi = 120)
cat("P2 interpretacion: enfoca scouting en generaciones con mediana alta y variabilidad manejable.\n")

# G3: attack vs defense con hp
pg3 <- ggplot2::ggplot(poke, ggplot2::aes(x = attack, y = defense, size = hp, color = generation)) +
  ggplot2::geom_point(alpha = 0.65) +
  ggplot2::labs(
    title = "Problema G3 - Segmentacion de perfiles ofensivos, defensivos y balanceados",
    subtitle = "El tamano representa HP y el color la generacion para ubicar nichos tacticos.",
    x = "Ataque",
    y = "Defensa"
  )
ggplot2::ggsave(file.path(out_dir, "problema_g3_balance_ataque_defensa.png"), pg3, width = 9, height = 6, dpi = 120)
cat("P3 interpretacion: util para vender una estrategia de equipo por roles claros de combate.\n")

# G4: regresion experiencia vs poder
pg4 <- ggplot2::ggplot(poke %>% dplyr::filter(!is.na(base_experience), !is.na(total_stats)),
                       ggplot2::aes(x = base_experience, y = total_stats)) +
  ggplot2::geom_point(alpha = 0.6, color = "#2ca02c") +
  ggplot2::geom_smooth(method = "lm", se = TRUE, color = "#d62728") +
  ggplot2::labs(
    title = "Problema G4 - Inversion en experiencia vs resultado en poder",
    subtitle = "La pendiente sugiere que tanto rinde subir experiencia en terminos de stats.",
    x = "Experiencia base",
    y = "Total de stats"
  )
ggplot2::ggsave(file.path(out_dir, "problema_g4_experiencia_vs_poder.png"), pg4, width = 8, height = 5, dpi = 120)
cat("P4 interpretacion: apoya decisiones de entrenamiento con evidencia de retorno.\n")

# G5: heatmap de correlaciones
corr_prob <- poke %>% dplyr::select(hp, attack, defense, sp_attack, sp_defense, speed, total_stats) %>% na.omit()
mat_prob <- stats::cor(corr_prob)
heat_prob <- as.data.frame(as.table(mat_prob))
names(heat_prob) <- c("var1", "var2", "corr")
pg5 <- ggplot2::ggplot(heat_prob, ggplot2::aes(x = var1, y = var2, fill = corr)) +
  ggplot2::geom_tile() +
  ggplot2::scale_fill_gradient2(low = "#2166ac", mid = "white", high = "#b2182b", midpoint = 0) +
  ggplot2::labs(
    title = "Problema G5 - Mapa estrategico de relaciones entre stats",
    subtitle = "Permite defender que variables potenciar juntas para maximizar impacto.",
    x = "",
    y = ""
  )
ggplot2::ggsave(file.path(out_dir, "problema_g5_correlaciones_combate.png"), pg5, width = 7, height = 6, dpi = 120)
cat("P5 interpretacion: cierra la propuesta con evidencia cuantitativa de sinergias.\n")

cat("\nConclusion final (resumen):\n")
cat("- Hay segmentos claros por tipo y generacion para posicionar una estrategia competitiva.\n")
cat("- La historia del analisis va de oferta (cantidad) a rendimiento (stats) y retorno (experiencia).\n")
cat("- Las graficas permiten comunicar decisiones: que captar, que entrenar y como balancear el equipo.\n")
cat("- Se generaron 20 graficas en total (15 de guia + 5 del problema).\n")
cat("- Revisa archivos en: ", normalizePath(out_dir, winslash = "/", mustWork = FALSE), "\n", sep = "")
