# DM - Explicacion detallada del taller de Pokemon en R

## 1. Objetivo del script
El script [scripts/08_taller_pokemon_es_exposicion.R](scripts/08_taller_pokemon_es_exposicion.R) construye un taller completo con dos partes:

1. Replica de 15 tipos de graficas vistas en clase.
2. Resolucion de un problema de analisis con 5 graficas simples para presentar.

Ademas, el script:
- exige carga manual del dataset,
- guarda todas las imagenes en una carpeta de salida,
- genera un informe en Markdown automaticamente.

---

## 2. Flujo general del codigo

### 2.1 Instalacion y carga de paquetes
La funcion `instalar_y_cargar()` revisa si cada paquete existe y, si no, lo instala.
Luego carga:
- `readr`, `readxl`: lectura de CSV/Excel.
- `dplyr`, `tidyr`, `forcats`: transformacion de datos.
- `ggplot2`: visualizacion.
- `GGally`: matriz de dispersion (ggpairs).

Esto asegura reproducibilidad en otros equipos.

### 2.2 Carga manual obligatoria del dataset
En el bloque de carga se usa `file.choose()` para que selecciones el archivo manualmente.
Eso cumple el requisito de clase de "carga manual".

Comportamiento:
1. Muestra mensaje para seleccionar archivo.
2. Valida que se haya escogido un archivo existente.
3. Detecta extension.
4. Si es Excel (`xlsx/xls`) usa `read_excel`.
5. Si es CSV/TXT usa `read_csv`.
6. Si no es formato valido, detiene la ejecucion.

Tambien guarda la ruta seleccionada en la variable `fuente`, que luego aparece en el informe.

### 2.3 Preparacion de datos
Se convierten columnas clave a numericas (ataque, defensa, velocidad, etc.).
Esto evita errores en estadistica y graficas.

Transformaciones importantes:
- `tipo_2`: rellena vacios con `sin_tipo_2`.
- `numero_generacion`: extrae numero desde texto como "Generacion 1".
- `generacion`: estandariza y ordena como factor para que los ejes salgan en orden correcto.

### 2.4 Salidas del proyecto
El script crea:
- Carpeta de imagenes: [outputs/taller_pokemon_es](outputs/taller_pokemon_es)
- Informe markdown: [docs/Informe_Taller_Pokemon_ES.md](docs/Informe_Taller_Pokemon_ES.md)

La funcion `save_plot()` centraliza el guardado con tamaño y calidad consistentes.

---

## 3. Explicacion detallada de las 15 graficas

### Grafica 1 - Histograma del poder total
Archivo: [outputs/taller_pokemon_es/grafica_01_histograma_poder_total.png](outputs/taller_pokemon_es/grafica_01_histograma_poder_total.png)

Que muestra:
- Distribucion de `total_estadisticas_base`.

Como leerla:
- Barras mas altas = rango de poder mas comun.
- Colas = Pokemon muy debiles o muy fuertes.

Mensaje para exponer:
- "La mayoria de Pokemon esta en valores intermedios de poder; los extremos son menos frecuentes."

### Grafica 2 - Barras por tipo principal
Archivo: [outputs/taller_pokemon_es/grafica_02_barras_tipos_principales.png](outputs/taller_pokemon_es/grafica_02_barras_tipos_principales.png)

Que muestra:
- Top 12 tipos por cantidad de Pokemon.

Como leerla:
- Barras mas largas = tipos mas comunes.

Mensaje para exponer:
- "No todos los tipos tienen la misma representacion; hay tipos con mucha mayor presencia en el dataset."

### Grafica 3 - Linea de promedio por generacion
Archivo: [outputs/taller_pokemon_es/grafica_03_linea_promedio_generacion.png](outputs/taller_pokemon_es/grafica_03_linea_promedio_generacion.png)

Que muestra:
- Promedio de `total_estadisticas_base` por generacion.

Como leerla:
- Subidas/bajadas de la linea = cambios en balance promedio entre generaciones.

Mensaje para exponer:
- "El poder promedio no es constante: varia segun la generacion."

### Grafica 4 - Dispersion ataque vs velocidad
Archivo: [outputs/taller_pokemon_es/grafica_04_dispersion_ataque_velocidad.png](outputs/taller_pokemon_es/grafica_04_dispersion_ataque_velocidad.png)

Que muestra:
- Relacion entre `ataque` y `velocidad`.

Como leerla:
- Nube ascendente sugeriria asociacion positiva.
- Nube dispersa sugiere relacion debil.

Mensaje para exponer:
- "Sirve para ver si los Pokemon mas ofensivos tambien suelen ser rapidos."

### Grafica 5 - Boxplot poder por tipo
Archivo: [outputs/taller_pokemon_es/grafica_05_boxplot_poder_por_tipo.png](outputs/taller_pokemon_es/grafica_05_boxplot_poder_por_tipo.png)

Que muestra:
- Distribucion de `total_estadisticas_base` por tipo.

Como leerla:
- Linea central: mediana.
- Caja: rango intercuartil.
- Puntos fuera: atipicos.

Mensaje para exponer:
- "Compara no solo promedio, tambien estabilidad del rendimiento por tipo."

### Grafica 6 - Densidad de PS
Archivo: [outputs/taller_pokemon_es/grafica_06_densidad_ps.png](outputs/taller_pokemon_es/grafica_06_densidad_ps.png)

Que muestra:
- Forma de distribucion de `ps`.

Como leerla:
- Pico principal = rango mas comun de PS.

Mensaje para exponer:
- "Ayuda a entender el nivel de resistencia mas frecuente del roster."

### Grafica 7 - Heatmap de combinaciones de tipos
Archivo: [outputs/taller_pokemon_es/grafica_07_heatmap_tipos.png](outputs/taller_pokemon_es/grafica_07_heatmap_tipos.png)

Que muestra:
- Frecuencia de `tipo_1` vs `tipo_2`.

Como leerla:
- Colores mas intensos = combinaciones mas repetidas.

Mensaje para exponer:
- "Permite identificar parejas de tipos comunes en el diseno de Pokemon."

### Grafica 8 - Violin velocidad por generacion
Archivo: [outputs/taller_pokemon_es/grafica_08_violin_velocidad_generacion.png](outputs/taller_pokemon_es/grafica_08_violin_velocidad_generacion.png)

Que muestra:
- Distribucion completa de `velocidad` por generacion.

Como leerla:
- Ancho del violin = mayor concentracion de datos.

Mensaje para exponer:
- "Compara la forma de la distribucion, no solo el promedio."

### Grafica 9 - Area de cantidad por generacion
Archivo: [outputs/taller_pokemon_es/grafica_09_area_cantidad_generacion.png](outputs/taller_pokemon_es/grafica_09_area_cantidad_generacion.png)

Que muestra:
- Cantidad de Pokemon en cada generacion.

Como leerla:
- Mayor altura del area = mas Pokemon.

Mensaje para exponer:
- "Visualiza el volumen de especies por etapa del juego."

### Grafica 10 - Pastel top 8 tipos
Archivo: [outputs/taller_pokemon_es/grafica_10_pastel_tipos_top8.png](outputs/taller_pokemon_es/grafica_10_pastel_tipos_top8.png)

Que muestra:
- Participacion relativa de los 8 tipos mas frecuentes.

Como leerla:
- Sectores mas grandes = mayor proporcion.

Mensaje para exponer:
- "Es una vista rapida de composicion general por tipos."

### Grafica 11 - Matriz de dispersion (GGally)
Archivo: [outputs/taller_pokemon_es/grafica_11_matriz_dispersion_stats.png](outputs/taller_pokemon_es/grafica_11_matriz_dispersion_stats.png)

Que muestra:
- Relaciones cruzadas entre variables de combate.

Como leerla:
- Cada celda compara dos variables.
- Diagonal resume distribuciones individuales.

Mensaje para exponer:
- "Da una radiografia completa de posibles relaciones entre stats."

### Grafica 12 - Heatmap de correlaciones
Archivo: [outputs/taller_pokemon_es/grafica_12_heatmap_correlaciones.png](outputs/taller_pokemon_es/grafica_12_heatmap_correlaciones.png)

Que muestra:
- Correlacion lineal entre stats.

Como leerla:
- Valores cercanos a 1: relacion positiva fuerte.
- Cercanos a -1: relacion negativa fuerte.
- Cercanos a 0: relacion debil.

Mensaje para exponer:
- "Resume numericamente que variables se mueven juntas."

### Grafica 13 - Regresion experiencia vs poder
Archivo: [outputs/taller_pokemon_es/grafica_13_regresion_experiencia_poder.png](outputs/taller_pokemon_es/grafica_13_regresion_experiencia_poder.png)

Que muestra:
- Relacion entre `experiencia_base` y `total_estadisticas_base`.

Como leerla:
- Pendiente de la linea: tendencia general.
- Banda: incertidumbre aproximada.

Mensaje para exponer:
- "Pokemon con mayor experiencia base tienden a tener mayor poder total."

### Grafica 14 - Serie por Pokedex con media movil
Archivo: [outputs/taller_pokemon_es/grafica_14_serie_id_media_movil.png](outputs/taller_pokemon_es/grafica_14_serie_id_media_movil.png)

Que muestra:
- Evolucion de poder segun `id_pokedex`.
- Media movil para suavizar ruido.

Como leerla:
- Linea gris: variacion individual.
- Linea verde: tendencia general.

Mensaje para exponer:
- "La media movil facilita explicar tendencia sin distraerse con picos puntuales."

### Grafica 15 - Burbujas ataque-defensa-PS
Archivo: [outputs/taller_pokemon_es/grafica_15_burbujas_perfil_combate.png](outputs/taller_pokemon_es/grafica_15_burbujas_perfil_combate.png)

Que muestra:
- Eje X: ataque.
- Eje Y: defensa.
- Tamano: PS.
- Color: nivel estadistico.

Como leerla:
- Cuadrante superior derecho = perfiles mas completos en combate fisico.

Mensaje para exponer:
- "Integra 3 dimensiones y permite detectar perfiles tanque, ofensivo o balanceado."

---

## 4. Problema de analisis (5 graficas faciles para exponer)

Problema:
Como seleccionar perfiles de Pokemon para un equipo competitivo equilibrado entre ataque, defensa y velocidad?

### G1 - Barras: tipos con mayor poder promedio
Archivo: [outputs/taller_pokemon_es/problema_g1_tipos_mejor_promedio.png](outputs/taller_pokemon_es/problema_g1_tipos_mejor_promedio.png)

Por que es facil:
- Comparacion directa de alturas.

Idea clave:
- Detectar tipos que, en promedio, dan mejor rendimiento base.

### G2 - Boxplot: poder por generacion
Archivo: [outputs/taller_pokemon_es/problema_g2_boxplot_generaciones.png](outputs/taller_pokemon_es/problema_g2_boxplot_generaciones.png)

Por que es facil:
- Muestra mediana y variabilidad en una sola imagen.

Idea clave:
- Comparar estabilidad y nivel de poder entre generaciones.

### G3 - Dispersion: ataque vs defensa
Archivo: [outputs/taller_pokemon_es/problema_g3_balance_ofensivo_defensivo.png](outputs/taller_pokemon_es/problema_g3_balance_ofensivo_defensivo.png)

Por que es facil:
- Dos ejes clasicos y una linea de tendencia.

Idea clave:
- Ver si existe equilibrio entre ofensiva y defensa.

### G4 - Histograma: distribucion de velocidad
Archivo: [outputs/taller_pokemon_es/problema_g4_velocidad_vs_poder.png](outputs/taller_pokemon_es/problema_g4_velocidad_vs_poder.png)

Por que es facil:
- Rapida lectura de donde se concentra la velocidad.

Idea clave:
- Definir si el equipo debe priorizar rapidez o compensarla con otras stats.

### G5 - Barras: top 10 Pokemon por poder total
Archivo: [outputs/taller_pokemon_es/problema_g5_correlacion_clave.png](outputs/taller_pokemon_es/problema_g5_correlacion_clave.png)

Por que es facil:
- Es ranking directo, muy claro para cerrar la presentacion.

Idea clave:
- Identificar candidatos fuertes para un nucleo competitivo.

---

## 5. Conclusion final para exponer
No hay una sola stat que gane por si sola. La mejor seleccion de equipo combina:
- Pokemon con alto poder total,
- balance entre ataque y defensa,
- velocidad suficiente para tomar ventaja tactica.

Ademas, aunque algunos tipos tengan mejor promedio, no concentran siempre todos los Pokemon mas fuertes. Por eso conviene combinar perfiles y no depender de un unico tipo.

---

## 6. Guion corto de exposicion (2-3 minutos)
1. "Primero cargue el dataset manualmente para cumplir el requisito del taller."
2. "Limpie tipos de datos y estandarice la variable generacion para asegurar comparaciones validas."
3. "Replique las 15 graficas para mostrar distribucion, comparacion, relacion y tendencia."
4. "Plantee el problema de como armar un equipo competitivo balanceado."
5. "Use 5 graficas simples: barras, boxplot, dispersion, histograma y ranking top 10."
6. "Conclui que el rendimiento competitivo mejora cuando se combinan poder total, balance ofensivo-defensivo y velocidad, en lugar de depender de una sola variable."
