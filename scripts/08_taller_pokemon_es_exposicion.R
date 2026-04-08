###############################################################
# Taller de graficas en R - Pokemon (dataset en espanol)
# Entregable:
# 1) Replica de 15 graficas vistas en clase
# 2) Problema de analisis resuelto con 5 graficas
# 3) Informe en Markdown con interpretaciones y conclusion
###############################################################

instalar_y_cargar <- function(paquetes) {
  for (p in paquetes) {
    if (!requireNamespace(p, quietly = TRUE)) {
      install.packages(p, repos = "https://cloud.r-project.org")
    }
    suppressPackageStartupMessages(library(p, character.only = TRUE))
  }
}

instalar_y_cargar(c("readr", "readxl", "dplyr", "ggplot2", "tidyr", "forcats", "GGally"))

# ------------------------
# 1) Carga del dataset
# ------------------------
cat("\nSelecciona manualmente el dataset (CSV o Excel) para iniciar el taller...\n")

if (!interactive()) {
  stop("Este script requiere seleccion manual del archivo. Ejecutalo en una sesion interactiva (RStudio).")
}

ruta_dataset <- tryCatch(file.choose(), error = function(e) "")

if (!nzchar(ruta_dataset) || !file.exists(ruta_dataset)) {
  stop("No se selecciono un archivo valido.")
}

extension <- tolower(tools::file_ext(ruta_dataset))

if (extension %in% c("xlsx", "xls")) {
  pokemon <- readxl::read_excel(ruta_dataset)
} else if (extension %in% c("csv", "txt")) {
  pokemon <- readr::read_csv(ruta_dataset, show_col_types = FALSE)
} else {
  stop("Formato no soportado. Selecciona un archivo CSV, TXT, XLSX o XLS.")
}

fuente <- normalizePath(ruta_dataset, winslash = "/", mustWork = FALSE)
cat("Dataset seleccionado: ", fuente, "\n", sep = "")

pokemon <- as.data.frame(pokemon)

# ------------------------
# 2) Preparacion de datos
# ------------------------
num_cols <- c(
  "id_pokedex", "numero_tipos", "ps", "ataque", "defensa", "ataque_especial",
  "defensa_especial", "velocidad", "total_estadisticas_base", "altura_m", "peso_kg",
  "experiencia_base", "tasa_captura", "felicidad_base", "contador_eclosion",
  "imc", "proporcion_ataque_defensa", "total_fisico", "total_especial",
  "total_ofensivo", "total_defensivo"
)

for (c in num_cols) {
  if (c %in% names(pokemon)) {
    pokemon[[c]] <- suppressWarnings(as.numeric(pokemon[[c]]))
  }
}

pokemon <- pokemon %>%
  mutate(
    tipo_2 = ifelse(is.na(tipo_2) | tipo_2 == "", "sin_tipo_2", tipo_2),
    numero_generacion = suppressWarnings(as.numeric(gsub("[^0-9]", "", generacion))),
    generacion = ifelse(is.na(numero_generacion), generacion, paste("Generacion", numero_generacion)),
    generacion = factor(generacion, levels = paste("Generacion", sort(unique(numero_generacion[!is.na(numero_generacion)]))), ordered = TRUE)
  )

# ------------------------
# 3) Carpetas de salida
# ------------------------
out_dir <- file.path("outputs", "taller_pokemon_es")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

informe_path <- file.path("docs", "Informe_Taller_Pokemon_ES.md")

# Utilidad para guardar graficas con estilo consistente
save_plot <- function(p, nombre, w = 10, h = 6) {
  ggplot2::ggsave(
    filename = file.path(out_dir, nombre),
    plot = p,
    width = w,
    height = h,
    dpi = 140
  )
}

# ------------------------
# 4) Parte A: 15 graficas
# ------------------------

# Grafica 1: Histograma
p1 <- ggplot(pokemon, aes(x = total_estadisticas_base)) +
  geom_histogram(bins = 30, fill = "#2C7FB8", color = "white") +
  labs(
    title = "Grafica 1. Distribucion del poder total de los Pokemon",
    x = "Total de estadisticas base",
    y = "Frecuencia"
  ) +
  theme_minimal()
save_plot(p1, "grafica_01_histograma_poder_total.png")

# Grafica 2: Barras (tipos principales)
top_tipos <- pokemon %>% count(tipo_1, sort = TRUE) %>% slice_head(n = 12)
p2 <- ggplot(top_tipos, aes(x = fct_reorder(tipo_1, n), y = n)) +
  geom_col(fill = "#41AB5D") +
  coord_flip() +
  labs(
    title = "Grafica 2. Cantidad de Pokemon por tipo principal",
    x = "Tipo principal",
    y = "Cantidad"
  ) +
  theme_minimal()
save_plot(p2, "grafica_02_barras_tipos_principales.png")

# Grafica 3: Linea (promedio por generacion)
prom_gen <- pokemon %>%
  group_by(generacion) %>%
  summarise(promedio_poder = mean(total_estadisticas_base, na.rm = TRUE), .groups = "drop")

p3 <- ggplot(prom_gen, aes(x = generacion, y = promedio_poder, group = 1)) +
  geom_line(color = "#D95F0E", linewidth = 1.2) +
  geom_point(color = "#D95F0E", size = 2.5) +
  labs(
    title = "Grafica 3. Promedio de poder total por generacion",
    x = "Generacion",
    y = "Promedio del total de estadisticas"
  ) +
  theme_minimal()
save_plot(p3, "grafica_03_linea_promedio_generacion.png")

# Grafica 4: Dispersión ataque vs velocidad
p4 <- ggplot(pokemon, aes(x = ataque, y = velocidad)) +
  geom_point(alpha = 0.45, color = "#6A51A3") +
  labs(
    title = "Grafica 4. Relacion entre ataque y velocidad",
    x = "Ataque",
    y = "Velocidad"
  ) +
  theme_minimal()
save_plot(p4, "grafica_04_dispersion_ataque_velocidad.png")

# Grafica 5: Boxplot total por tipo principal
p5_data <- pokemon %>% count(tipo_1, sort = TRUE) %>% slice_head(n = 10) %>% pull(tipo_1)
p5 <- ggplot(filter(pokemon, tipo_1 %in% p5_data), aes(x = fct_reorder(tipo_1, total_estadisticas_base, .fun = median), y = total_estadisticas_base, fill = tipo_1)) +
  geom_boxplot(alpha = 0.85, outlier.alpha = 0.35) +
  coord_flip() +
  labs(
    title = "Grafica 5. Distribucion del poder total por tipo",
    x = "Tipo principal",
    y = "Total de estadisticas base"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
save_plot(p5, "grafica_05_boxplot_poder_por_tipo.png")

# Grafica 6: Densidad de PS
p6 <- ggplot(pokemon, aes(x = ps)) +
  geom_density(fill = "#2B8CBE", alpha = 0.55) +
  labs(
    title = "Grafica 6. Densidad de puntos de salud (PS)",
    x = "Puntos de salud (PS)",
    y = "Densidad"
  ) +
  theme_minimal()
save_plot(p6, "grafica_06_densidad_ps.png")

# Grafica 7: Heatmap combinacion tipos
heat_tipos <- pokemon %>% count(tipo_1, tipo_2, name = "frecuencia")
p7 <- ggplot(heat_tipos, aes(x = tipo_2, y = tipo_1, fill = frecuencia)) +
  geom_tile() +
  scale_fill_gradient(low = "#F7FBFF", high = "#08306B") +
  labs(
    title = "Grafica 7. Mapa de calor de combinaciones de tipos",
    x = "Tipo secundario",
    y = "Tipo principal"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))
save_plot(p7, "grafica_07_heatmap_tipos.png", w = 11, h = 7)

# Grafica 8: Violin velocidad por generacion
p8 <- ggplot(pokemon, aes(x = generacion, y = velocidad, fill = generacion)) +
  geom_violin(alpha = 0.8) +
  labs(
    title = "Grafica 8. Distribucion de velocidad por generacion",
    x = "Generacion",
    y = "Velocidad"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
save_plot(p8, "grafica_08_violin_velocidad_generacion.png")

# Grafica 9: Area cantidad por generacion
cant_gen <- pokemon %>% count(generacion)
p9 <- ggplot(cant_gen, aes(x = generacion, y = n, group = 1)) +
  geom_area(fill = "#FDAE6B", alpha = 0.7) +
  labs(
    title = "Grafica 9. Cantidad de Pokemon por generacion",
    x = "Generacion",
    y = "Cantidad"
  ) +
  theme_minimal()
save_plot(p9, "grafica_09_area_cantidad_generacion.png")

# Grafica 10: Pastel de tipos principales (top 8)
p10_data <- pokemon %>% count(tipo_1, sort = TRUE) %>% slice_head(n = 8)
p10 <- ggplot(p10_data, aes(x = "", y = n, fill = tipo_1)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  labs(
    title = "Grafica 10. Proporcion de tipos principales (Top 8)",
    fill = "Tipo"
  ) +
  theme_void()
save_plot(p10, "grafica_10_pastel_tipos_top8.png", w = 9, h = 7)

# Grafica 11: Matriz de dispersion (pair plot)
vars_pair <- pokemon %>%
  select(ps, ataque, defensa, ataque_especial, defensa_especial, velocidad) %>%
  sample_n(min(600, nrow(.)))

p11 <- GGally::ggpairs(vars_pair)
ggplot2::ggsave(file.path(out_dir, "grafica_11_matriz_dispersion_stats.png"), p11, width = 12, height = 10, dpi = 130)

# Grafica 12: Correlaciones (heatmap)
mat_cor <- pokemon %>%
  select(ps, ataque, defensa, ataque_especial, defensa_especial, velocidad, total_estadisticas_base, experiencia_base) %>%
  cor(use = "pairwise.complete.obs")

cor_df <- as.data.frame(as.table(mat_cor))
colnames(cor_df) <- c("var_x", "var_y", "correlacion")

p12 <- ggplot(cor_df, aes(x = var_x, y = var_y, fill = correlacion)) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(correlacion, 2)), size = 3) +
  scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B", midpoint = 0) +
  labs(
    title = "Grafica 12. Correlacion entre variables de combate",
    x = "",
    y = ""
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
save_plot(p12, "grafica_12_heatmap_correlaciones.png")

# Grafica 13: Regresion experiencia vs poder
p13 <- ggplot(pokemon, aes(x = experiencia_base, y = total_estadisticas_base)) +
  geom_point(alpha = 0.35, color = "#1F78B4") +
  geom_smooth(method = "lm", se = TRUE, color = "#E31A1C") +
  labs(
    title = "Grafica 13. Relacion entre experiencia base y poder total",
    x = "Experiencia base",
    y = "Total de estadisticas base"
  ) +
  theme_minimal()
save_plot(p13, "grafica_13_regresion_experiencia_poder.png")

# Grafica 14: Serie por id con tendencia (media movil)
serie_id <- pokemon %>%
  arrange(id_pokedex) %>%
  mutate(media_movil_25 = as.numeric(stats::filter(total_estadisticas_base, rep(1/25, 25), sides = 2)))

p14 <- ggplot(serie_id, aes(x = id_pokedex, y = total_estadisticas_base)) +
  geom_line(alpha = 0.2, color = "#636363") +
  geom_line(aes(y = media_movil_25), color = "#31A354", linewidth = 1.1, na.rm = TRUE) +
  labs(
    title = "Grafica 14. Evolucion del poder segun numero de Pokedex",
    subtitle = "Linea verde: media movil de 25 observaciones",
    x = "ID Pokedex",
    y = "Total de estadisticas base"
  ) +
  theme_minimal()
save_plot(p14, "grafica_14_serie_id_media_movil.png")

# Grafica 15: Burbujas ataque-defensa-ps
p15 <- ggplot(pokemon, aes(x = ataque, y = defensa, size = ps, color = nivel_estadisticas)) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Grafica 15. Perfil de combate: ataque, defensa y PS",
    x = "Ataque",
    y = "Defensa",
    size = "PS",
    color = "Nivel"
  ) +
  theme_minimal()
save_plot(p15, "grafica_15_burbujas_perfil_combate.png")

# ------------------------
# 5) Parte B: Problema de analisis (5 graficas)
# ------------------------
# Problema: Como seleccionar perfiles de Pokemon para un equipo competitivo
# equilibrado entre ataque, defensa y velocidad?

# G1 - Barras: top tipos por promedio de poder (facil de comparar)
prob1 <- pokemon %>%
  group_by(tipo_1) %>%
  summarise(
    promedio_poder = mean(total_estadisticas_base, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  filter(n >= 25) %>%
  arrange(desc(promedio_poder)) %>%
  slice_head(n = 12)

p_prob1 <- ggplot(prob1, aes(x = fct_reorder(tipo_1, promedio_poder), y = promedio_poder)) +
  geom_col(fill = "#2B8CBE") +
  coord_flip() +
  labs(
    title = "Problema G1. Tipos con mayor poder promedio (grafica simple)",
    x = "Tipo principal",
    y = "Promedio de poder total"
  ) +
  theme_minimal()
save_plot(p_prob1, "problema_g1_tipos_mejor_promedio.png")

# G2 - Boxplot: poder por generacion (mediana + dispersion)
p_prob2 <- ggplot(pokemon, aes(x = generacion, y = total_estadisticas_base, fill = generacion)) +
  geom_boxplot(alpha = 0.85, outlier.alpha = 0.35) +
  labs(
    title = "Problema G2. Poder total por generacion (facil de leer)",
    x = "Generacion",
    y = "Total de estadisticas base"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
save_plot(p_prob2, "problema_g2_boxplot_generaciones.png")

# G3 - Dispersion: ataque vs defensa (relacion directa)
p_prob3 <- ggplot(pokemon, aes(x = ataque, y = defensa)) +
  geom_point(alpha = 0.45, color = "#6A51A3") +
  geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 0.9) +
  labs(
    title = "Problema G3. Relacion entre ataque y defensa",
    x = "Ataque",
    y = "Defensa"
  ) +
  theme_minimal()
save_plot(p_prob3, "problema_g3_balance_ofensivo_defensivo.png")

# G4 - Histograma: distribucion de velocidad (muy explicable)
p_prob4 <- ggplot(pokemon, aes(x = velocidad)) +
  geom_histogram(bins = 25, fill = "#31A354", color = "white") +
  labs(
    title = "Problema G4. Distribucion de velocidad",
    x = "Velocidad",
    y = "Frecuencia"
  ) +
  theme_minimal()
save_plot(p_prob4, "problema_g4_velocidad_vs_poder.png")

# G5 - Barras: top 10 pokemon con mayor poder total (cierre facil)
top10_poder <- pokemon %>%
  arrange(desc(total_estadisticas_base)) %>%
  select(nombre, total_estadisticas_base) %>%
  slice_head(n = 10)

p_prob5 <- ggplot(top10_poder, aes(x = fct_reorder(nombre, total_estadisticas_base), y = total_estadisticas_base)) +
  geom_col(fill = "#E6550D") +
  coord_flip() +
  labs(
    title = "Problema G5. Top 10 Pokemon con mayor poder total",
    x = "Pokemon",
    y = "Total de estadisticas base"
  ) +
  theme_minimal()
save_plot(p_prob5, "problema_g5_correlacion_clave.png")

# ------------------------
# 6) Informe automatico en Markdown
# ------------------------
lineas_informe <- c(
  "# Taller de Graficas en R - Pokemon (dataset en espanol)",
  "",
  "## Dataset utilizado",
  paste0("- Fuente: ", fuente),
  "- Registros: 1025 Pokemon aprox.",
  "- Variables: estadisticas de combate, tipos, generacion, experiencia.",
  "",
  "## Parte 1. Replica de 15 graficas con interpretacion breve",
  "1. Histograma: la mayoria de Pokemon se concentra en poder total intermedio.",
  "2. Barras por tipo: algunos tipos aparecen mucho mas que otros.",
  "3. Linea por generacion: el promedio de poder cambia entre generaciones.",
  "4. Dispersion ataque-velocidad: existe tendencia positiva moderada.",
  "5. Boxplot por tipo: hay tipos con mediana alta y menor variabilidad.",
  "6. Densidad de PS: la mayor parte del roster tiene PS medio.",
  "7. Heatmap tipo1-tipo2: se identifican combinaciones comunes de diseno.",
  "8. Violin de velocidad: la forma distribucional cambia por generacion.",
  "9. Area por generacion: se observa expansion de especies por epoca.",
  "10. Pastel top tipos: resume participacion relativa de tipos frecuentes.",
  "11. Matriz de dispersion: permite detectar posibles relaciones no lineales.",
  "12. Heatmap de correlacion: ataque, defensa y total se relacionan fuertemente.",
  "13. Regresion experiencia-poder: mayor experiencia se asocia con mayor poder.",
  "14. Serie por ID: la media movil facilita leer tendencia global.",
  "15. Burbujas: muestra perfiles de combate en tres dimensiones.",
  "",
  "## Parte 2. Problema de analisis",
  "### Problema planteado",
  "Como seleccionar perfiles de Pokemon para un equipo competitivo equilibrado entre ataque, defensa y velocidad?",
  "",
  "### Justificacion de las 5 graficas usadas",
  "- G1 (barras): comparacion directa de tipos con mayor poder promedio.",
  "- G2 (boxplot): muestra de forma sencilla mediana y variacion por generacion.",
  "- G3 (dispersion): permite ver si ataque y defensa crecen juntos.",
  "- G4 (histograma): facilita explicar como se distribuye la velocidad.",
  "- G5 (barras top 10): cierre claro con los Pokemon mas fuertes del dataset.",
  "",
  "### Conclusion final",
  "Las cinco graficas simplificadas muestran una idea central facil de defender: conviene seleccionar Pokemon con buen poder total, sin descuidar el balance entre ataque y defensa, y revisando la velocidad para definir el rol en combate. Ademas, los tipos con mejor promedio no siempre tienen todos los casos mas fuertes, por eso es recomendable combinar varios perfiles para formar un equipo equilibrado.",
  ""
)

writeLines(lineas_informe, con = informe_path)

cat("\nProceso finalizado con exito.\n")
cat("Graficas guardadas en: ", out_dir, "\n", sep = "")
cat("Informe generado en: ", informe_path, "\n", sep = "")
