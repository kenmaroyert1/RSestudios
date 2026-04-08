# Informe Taller de Graficas - Dataset de Musica (Spotify)

## 1. Contexto del analisis
Este informe resume y explica las 20 graficas generadas en el taller de musica:
- 15 graficas de replica de tipos de visualizacion.
- 5 graficas orientadas al problema de negocio.

Enfoque de presentacion: tratar el analisis como un producto para vender una estrategia basada en datos.

## 2. Objetivo de negocio
Pregunta principal:
Que atributos musicales debemos priorizar para maximizar streams?

## 3. Variables clave utilizadas
- streams_billions: nivel de reproducciones.
- genre_simple: genero principal.
- release_year: anio de lanzamiento.
- danceability: que tan bailable es la cancion.
- energy: nivel de intensidad.
- valence: tono emocional (triste vs alegre).
- acousticness: nivel de sonido acustico.
- bpm: tempo de la cancion.
- explicit: contenido explicito o no.

## 4. Explicacion de las 15 graficas (Parte A)

### Grafica 01 - Cuantas canciones tienen alto potencial de reproduccion
Tipo: Histograma.
Lectura: muestra la distribucion de streams del catalogo.
Valor de negocio: permite identificar si el catalogo esta concentrado en desempeno medio o si tiene cola de hits.

### Grafica 02 - Que generos dominan la oferta musical
Tipo: Barras.
Lectura: compara cantidad de canciones por genero (top 12).
Valor de negocio: ayuda a detectar en que segmentos hay mayor oferta y competencia.

### Grafica 03 - Evolucion del rendimiento promedio por anio
Tipo: Lineas.
Lectura: promedio de streams por anio de lanzamiento.
Valor de negocio: permite identificar periodos con mejor traccion para orientar lanzamientos.

### Grafica 04 - Danceability vs energy para perfilar sonido ganador
Tipo: Dispersión.
Lectura: relacion entre canciones bailables y energia.
Valor de negocio: ubica zonas de sonido con mayor valor comercial potencial.

### Grafica 05 - Impacto del contenido explicito en reproducciones
Tipo: Boxplot.
Lectura: compara mediana, dispersion y outliers entre explicit y no explicit.
Valor de negocio: apoya decisiones editoriales y de segmentacion de audiencia.

### Grafica 06 - BPM mas frecuentes del catalogo
Tipo: Densidad.
Lectura: concentra el rango de tempo mas utilizado.
Valor de negocio: orienta decisiones de produccion sobre ritmo objetivo.

### Grafica 07 - Combinaciones genero-contenido con mayor presencia
Tipo: Heatmap.
Lectura: combinaciones con mayor frecuencia de aparicion.
Valor de negocio: ayuda a definir nichos de catalogo y posicionamiento.

### Grafica 08 - Emocion musical por genero (valence)
Tipo: Violin plot.
Lectura: distribucion de valence por genero.
Valor de negocio: permite vender propuestas por estado emocional y perfil de publico.

### Grafica 09 - Volumen anual acumulado de streams
Tipo: Area.
Lectura: total de streams acumulados por anio.
Valor de negocio: muestra crecimiento o desaceleracion del rendimiento global.

### Grafica 10 - Participacion de mercado por genero
Tipo: Pastel.
Lectura: peso relativo de los 6 generos principales.
Valor de negocio: util para comunicar rapido composicion del portafolio.

### Grafica 11 - Matriz de relaciones entre variables musicales
Tipo: Pair plot.
Lectura: vista general de relaciones entre variables numericas.
Valor de negocio: primer filtro visual para detectar patrones prometedores.

### Grafica 12 - Que variables musicales se mueven juntas
Tipo: Mapa de correlacion.
Lectura: intensidad y direccion de relaciones lineales.
Valor de negocio: sugiere que variables conviene trabajar en conjunto.

### Grafica 13 - Retorno de energia musical sobre reproducciones
Tipo: Regresion lineal.
Lectura: tendencia entre energy y streams.
Valor de negocio: respalda decisiones sobre intensidad sonora del producto musical.

### Grafica 14 - Evolucion de lanzamientos por anio
Tipo: Serie temporal.
Lectura: cantidad de canciones publicadas por anio.
Valor de negocio: describe dinamica de oferta y ritmos de publicacion.

### Grafica 15 - Mapa comercial de canciones
Tipo: Burbujas.
Lectura: combina danceability, energy, streams (tamano) y bpm (color).
Valor de negocio: resume en una sola vista los perfiles con mayor potencial comercial.

## 5. Explicacion del problema de negocio (Parte B - 5 graficas)

### Problema G1 - Ranking de generos por promedio de streams
Pregunta que responde: que genero rinde mejor en promedio?
Uso para vender: priorizar inversiones en generos con mejor retorno esperado.

### Problema G2 - Diferencia de rendimiento por contenido explicito
Pregunta que responde: conviene linea editorial explicit o no explicit?
Uso para vender: definir estrategia de catalogo segun objetivo de audiencia.

### Problema G3 - Danceability como palanca de reproduccion
Pregunta que responde: lo bailable impulsa streams?
Uso para vender: alinear composicion y produccion con consumo real.

### Problema G4 - Nivel de energia y resultado comercial
Pregunta que responde: mayor energia implica mejor desempeno?
Uso para vender: ajustar direccion sonora para mejorar probabilidad de exito.

### Problema G5 - Mapa estrategico de correlaciones musicales
Pregunta que responde: que variables conviene potenciar juntas?
Uso para vender: construir una receta de atributos musicales con respaldo estadistico.

## 6. Conclusiones ejecutivas
- Hay segmentos de genero y estilo con mejor potencial de reproduccion.
- El enfoque correcto no es solo lanzar mas canciones, sino lanzar canciones con atributos optimos.
- El analisis permite argumentar una propuesta comercial concreta:
  - Que genero priorizar.
  - Que perfil sonoro producir.
  - Que tipo de catalogo construir.

## 7. Entregables
- Script del taller: [scripts/04_taller_musica.R](../scripts/04_taller_musica.R)
- Carpeta de graficas: [outputs/taller_musica](../outputs/taller_musica)
- Dataset unificado (CSV): [data/processed/music/spotify_dataset_unificado.csv](../data/processed/music/spotify_dataset_unificado.csv)
- Dataset unificado (XLSX): [data/processed/music/spotify_dataset_unificado.xlsx](../data/processed/music/spotify_dataset_unificado.xlsx)
