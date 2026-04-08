instalar_y_cargar <- function(paquetes) {
  for (p in paquetes) {
    if (!requireNamespace(p, quietly = TRUE)) {
      install.packages(p, repos = "https://cloud.r-project.org")
    }
    suppressPackageStartupMessages(library(p, character.only = TRUE))
  }
}

normalizar_nombres <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z0-9]+", "_", x)
  x <- gsub("^_+|_+$", "", x)
  x <- gsub("_+", "_", x)
  x
}

leer_dataset <- function(ruta_archivo) {
  if (!file.exists(ruta_archivo)) {
    stop(paste("No existe el archivo:", ruta_archivo))
  }

  ext <- tolower(tools::file_ext(ruta_archivo))

  if (ext %in% c("csv", "txt")) {
    return(readr::read_csv(ruta_archivo, show_col_types = FALSE))
  }

  if (ext %in% c("xlsx", "xls")) {
    return(readxl::read_excel(ruta_archivo))
  }

  stop("Formato no soportado. Use CSV, TXT, XLSX o XLS.")
}

limpiar_dataset_generico <- function(df, umbral_na_columna = 0.6) {
  df <- as.data.frame(df)

  names(df) <- normalizar_nombres(names(df))
  names(df) <- make.unique(names(df), sep = "_")

  # Eliminar duplicados exactos
  df <- unique(df)

  # Reemplazar cadenas vacias por NA
  df[] <- lapply(df, function(col) {
    if (is.character(col)) {
      col <- trimws(col)
      col[col == ""] <- NA_character_
    }
    col
  })

  # Eliminar columnas con demasiados NA
  proporcion_na <- sapply(df, function(col) mean(is.na(col)))
  df <- df[, proporcion_na <= umbral_na_columna, drop = FALSE]

  # Intentar convertir texto numerico a numerico
  df[] <- lapply(df, function(col) {
    if (!is.character(col)) return(col)

    col_num <- gsub(",", ".", col)
    suppressWarnings(num <- as.numeric(col_num))

    if (sum(!is.na(num)) >= 0.8 * sum(!is.na(col))) {
      return(num)
    }

    col
  })

  # Imputacion simple
  df[] <- lapply(df, function(col) {
    if (is.numeric(col)) {
      med <- stats::median(col, na.rm = TRUE)
      if (is.finite(med)) col[is.na(col)] <- med
      return(col)
    }

    if (is.character(col)) {
      tabla <- sort(table(col), decreasing = TRUE)
      if (length(tabla) > 0) col[is.na(col)] <- names(tabla)[1]
      return(as.factor(col))
    }

    col
  })

  df
}

guardar_resultados_limpieza <- function(df_limpio, ruta_salida_csv, ruta_log) {
  readr::write_csv(df_limpio, ruta_salida_csv)

  resumen <- c(
    paste("Fecha:", as.character(Sys.time())),
    paste("Filas:", nrow(df_limpio)),
    paste("Columnas:", ncol(df_limpio)),
    paste("Variables:", paste(names(df_limpio), collapse = ", "))
  )

  writeLines(resumen, con = ruta_log)
}
