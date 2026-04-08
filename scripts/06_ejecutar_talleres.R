# Ejecuta ambos talleres en secuencia

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

source(file.path("scripts", "04_taller_musica.R"))
source(file.path("scripts", "05_taller_pokemon.R"))

cat("\nTalleres completados. Revisa la carpeta outputs/.\n")
