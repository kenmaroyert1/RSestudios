# Informe del Taller de Graficas - Dataset Pokemon

## 1. Contexto del Taller
Este informe documenta el desarrollo completo del taller usando el dataset de Pokemon, incluyendo:
1. Replica de 15 tipos de graficas trabajadas en clase.
2. Planteamiento de un problema de analisis.
3. Resolucion del problema con 5 graficas adicionales.
4. Interpretaciones y conclusiones finales.

Script utilizado:
[ scripts/05_taller_pokemon.R ](scripts/05_taller_pokemon.R)

Carpeta de resultados graficos:
[ outputs/taller_pokemon ](outputs/taller_pokemon)

## 2. Objetivo General
Aplicar tecnicas de visualizacion de datos para describir patrones en estadisticas de Pokemon, identificar relaciones entre variables de combate y sustentar conclusiones con evidencia grafica.

## 3. Dataset y Variables
Dataset base usado:
[ data/raw/dataset_2/Pokemon_Complete_Gen1_to_Gen9.csv ](data/raw/dataset_2/Pokemon_Complete_Gen1_to_Gen9.csv)

Variables clave del analisis:
1. id, generation.
2. type1, type2.
3. hp, attack, defense, sp_attack, sp_defense, speed.
4. base_experience.
5. total_stats (suma de estadisticas de combate).

## 4. Metodologia
1. Carga del dataset con deteccion automatica de ruta y opcion manual.
2. Conversion de columnas numericas para evitar errores de tipo.
3. Creacion de variable generation segun id.
4. Creacion de total_stats como indicador global de poder.
5. Generacion de 15 graficas del taller.
6. Formulacion de problema analitico y respuesta con 5 graficas.

## 5. Parte A - Replica de 15 Graficas

### Grafica 01 - Distribucion del poder total
Archivo: [ outputs/taller_pokemon/grafica_01_distribucion_poder_total.png ](outputs/taller_pokemon/grafica_01_distribucion_poder_total.png)
Interpretacion: El histograma muestra como se distribuye el total de stats. La mayor concentracion se ubica en rangos medios, con menos casos extremos.

### Grafica 02 - Cantidad por tipo principal
Archivo: [ outputs/taller_pokemon/grafica_02_cantidad_por_tipo_principal.png ](outputs/taller_pokemon/grafica_02_cantidad_por_tipo_principal.png)
Interpretacion: Permite comparar la frecuencia de aparicion por type1 e identificar tipos con mayor representacion.

### Grafica 03 - Promedio de poder por generacion
Archivo: [ outputs/taller_pokemon/grafica_03_promedio_poder_por_generacion.png ](outputs/taller_pokemon/grafica_03_promedio_poder_por_generacion.png)
Interpretacion: Muestra variaciones del promedio de total_stats entre generaciones, sugiriendo cambios en el balance del juego.

### Grafica 04 - Ataque vs Velocidad
Archivo: [ outputs/taller_pokemon/grafica_04_relacion_ataque_velocidad.png ](outputs/taller_pokemon/grafica_04_relacion_ataque_velocidad.png)
Interpretacion: El diagrama de dispersion permite detectar si los Pokemon con mayor ataque tienden o no a tener mayor velocidad.

### Grafica 05 - Distribucion del poder por tipo
Archivo: [ outputs/taller_pokemon/grafica_05_distribucion_poder_por_tipo.png ](outputs/taller_pokemon/grafica_05_distribucion_poder_por_tipo.png)
Interpretacion: El boxplot resume mediana, dispersion y outliers por tipo principal, mostrando tipos mas consistentes o mas variables.

### Grafica 06 - Densidad de HP
Archivo: [ outputs/taller_pokemon/grafica_06_densidad_hp.png ](outputs/taller_pokemon/grafica_06_densidad_hp.png)
Interpretacion: La curva de densidad muestra la forma de distribucion de hp y ayuda a identificar concentraciones y sesgos.

### Grafica 07 - Mapa de calor type1 vs type2
Archivo: [ outputs/taller_pokemon/grafica_07_mapa_calor_combinaciones_tipo.png ](outputs/taller_pokemon/grafica_07_mapa_calor_combinaciones_tipo.png)
Interpretacion: Resalta las combinaciones de tipos mas frecuentes y permite reconocer patrones de diseno de Pokemon.

### Grafica 08 - Violin de velocidad por generacion
Archivo: [ outputs/taller_pokemon/grafica_08_distribucion_velocidad_por_generacion.png ](outputs/taller_pokemon/grafica_08_distribucion_velocidad_por_generacion.png)
Interpretacion: Compara forma, dispersion y densidad de speed entre generaciones.

### Grafica 09 - Area por generacion
Archivo: [ outputs/taller_pokemon/grafica_09_cantidad_por_generacion_area.png ](outputs/taller_pokemon/grafica_09_cantidad_por_generacion_area.png)
Interpretacion: Visualiza el volumen de Pokemon por generacion y facilita observar crecimiento acumulado.

### Grafica 10 - Pastel de tipos principales
Archivo: [ outputs/taller_pokemon/grafica_10_proporcion_tipos_principales.png ](outputs/taller_pokemon/grafica_10_proporcion_tipos_principales.png)
Interpretacion: Representa la participacion relativa de los tipos principales mas frecuentes.

### Grafica 11 - Matriz de relaciones entre stats
Archivo: [ outputs/taller_pokemon/grafica_11_matriz_relaciones_stats.png ](outputs/taller_pokemon/grafica_11_matriz_relaciones_stats.png)
Interpretacion: El pair plot ofrece una vista general de relaciones posibles entre hp, ataque, defensa y velocidad.

### Grafica 12 - Correlaciones entre stats
Archivo: [ outputs/taller_pokemon/grafica_12_correlaciones_entre_stats.png ](outputs/taller_pokemon/grafica_12_correlaciones_entre_stats.png)
Interpretacion: El mapa de correlacion sintetiza la intensidad y direccion de relaciones lineales entre variables numericas.

### Grafica 13 - Regresion experiencia vs poder
Archivo: [ outputs/taller_pokemon/grafica_13_regresion_experiencia_vs_poder.png ](outputs/taller_pokemon/grafica_13_regresion_experiencia_vs_poder.png)
Interpretacion: Evalua tendencia entre base_experience y total_stats mediante una recta de ajuste.

### Grafica 14 - Evolucion secuencial por ID
Archivo: [ outputs/taller_pokemon/grafica_14_evolucion_poder_por_id.png ](outputs/taller_pokemon/grafica_14_evolucion_poder_por_id.png)
Interpretacion: Muestra variacion de poder total en el orden del Pokedex, util para detectar ciclos o saltos.

### Grafica 15 - Burbujas ataque-defensa-hp
Archivo: [ outputs/taller_pokemon/grafica_15_burbujas_ataque_defensa_hp.png ](outputs/taller_pokemon/grafica_15_burbujas_ataque_defensa_hp.png)
Interpretacion: Integra tres dimensiones (ataque, defensa y hp) para observar perfiles de combate.

## 6. Parte B - Problema de Analisis
Problema planteado:
Que tipos y generaciones parecen tener mayor potencial de combate?

### Problema G1 - Promedio de poder por tipo
Archivo: [ outputs/taller_pokemon/problema_g1_promedio_poder_por_tipo.png ](outputs/taller_pokemon/problema_g1_promedio_poder_por_tipo.png)
Interpretacion: Identifica los tipos con mejor rendimiento promedio de total_stats.

### Problema G2 - Distribucion por generacion
Archivo: [ outputs/taller_pokemon/problema_g2_distribucion_poder_por_generacion.png ](outputs/taller_pokemon/problema_g2_distribucion_poder_por_generacion.png)
Interpretacion: Permite comparar medianas y dispersion del poder entre generaciones.

### Problema G3 - Balance ataque-defensa
Archivo: [ outputs/taller_pokemon/problema_g3_balance_ataque_defensa.png ](outputs/taller_pokemon/problema_g3_balance_ataque_defensa.png)
Interpretacion: Evidencia perfiles ofensivos, defensivos y balanceados, agregando hp como tamano de punto.

### Problema G4 - Experiencia base y poder total
Archivo: [ outputs/taller_pokemon/problema_g4_experiencia_vs_poder.png ](outputs/taller_pokemon/problema_g4_experiencia_vs_poder.png)
Interpretacion: Mide si los Pokemon con mayor experiencia base tienden a tener mayor potencial general.

### Problema G5 - Correlaciones de combate
Archivo: [ outputs/taller_pokemon/problema_g5_correlaciones_combate.png ](outputs/taller_pokemon/problema_g5_correlaciones_combate.png)
Interpretacion: Resume relaciones clave entre variables de combate para sustentar hallazgos globales.

## 7. Conclusiones del Taller
1. El dataset presenta concentracion de Pokemon en rangos medios de poder total, con casos extremos menos frecuentes.
2. Existen diferencias relevantes entre tipos principales en terminos de rendimiento promedio y dispersion.
3. La comparacion por generacion sugiere cambios en equilibrio estadistico a lo largo del tiempo.
4. Las relaciones entre variables de combate muestran patrones utiles, pero no implican causalidad por si solas.
5. La combinacion de visualizaciones descriptivas, comparativas y de relacion fortalece la interpretacion analitica.

## 8. Recomendaciones para la Entrega
1. Incluir este informe junto con las imagenes de outputs/taller_pokemon.
2. Adjuntar el script final para reproducibilidad:
[ scripts/05_taller_pokemon.R ](scripts/05_taller_pokemon.R)
3. Si el docente lo pide, agregar portada con integrantes, fecha y curso.
