# Guion de exposicion extendido - Taller Pokemon en R

## 1. Apertura de la exposicion
Buenos dias. En esta presentacion voy a mostrar un analisis visual completo de un dataset de Pokemon, desarrollado en R, con dos objetivos academicos:

1. Replicar 15 tipos de graficas trabajadas en clase para demostrar dominio tecnico de visualizacion.
2. Plantear y resolver un problema de analisis con 5 graficas seleccionadas para toma de decisiones.

El enfoque no es solo "dibujar graficas", sino argumentar con datos de forma clara, comparativa y defendible.

---

## 2. Contexto del dataset
### 2.1 Fuente y tipo de datos
El dataset utilizado es una version traducida al espanol, con informacion de Pokemon de distintas generaciones. Incluye variables numericas, categoricas y derivadas.

Archivo usado en ejecucion manual:
- [data/processed/pokemon/pokemon_complete_2025_es.xlsx](data/processed/pokemon/pokemon_complete_2025_es.xlsx)

Script principal del taller:
- [scripts/08_taller_pokemon_es_exposicion.R](scripts/08_taller_pokemon_es_exposicion.R)

### 2.2 Variables relevantes para el analisis
Variables estructurales:
- id_pokedex
- nombre
- generacion
- tipo_1, tipo_2

Variables de combate:
- ps
- ataque
- defensa
- ataque_especial
- defensa_especial
- velocidad
- total_estadisticas_base

Variables complementarias:
- experiencia_base
- total_ofensivo
- total_defensivo
- nivel_estadisticas

### 2.3 Valor analitico del dataset
Este dataset es adecuado para clase porque permite:
- Analisis descriptivo de distribuciones.
- Comparacion entre categorias (tipos y generaciones).
- Relacion entre variables numericas.
- Sintesis de hallazgos para toma de decisiones.

---

## 3. Metodologia aplicada en R

### 3.1 Carga manual del dataset
El script fue diseñado para exigir seleccion manual del archivo con selector interactivo. Esto cumple una condicion frecuente en evaluaciones: no depender de rutas fijas y permitir que el docente ejecute el taller con distintos archivos compatibles.

### 3.2 Validaciones de entrada
El flujo valida:
- Que el usuario si haya seleccionado un archivo.
- Que el archivo exista realmente.
- Que el formato sea permitido: CSV, TXT, XLSX o XLS.

### 3.3 Estandarizacion de datos
Antes de graficar, se realiza:
- Conversion de columnas numericas.
- Manejo de faltantes en tipo_2 con categoria sin_tipo_2.
- Homologacion y orden de la variable generacion.

Esto evita errores de interpretacion y asegura que los ejes y escalas representen correctamente la informacion.

### 3.4 Generacion de salidas
Todas las graficas se guardan en:
- [outputs/taller_pokemon_es](outputs/taller_pokemon_es)

Informe automatico resumido:
- [docs/Informe_Taller_Pokemon_ES.md](docs/Informe_Taller_Pokemon_ES.md)

Documento de explicacion detallada:
- [docs/DM_Explicacion_Taller_Pokemon_ES.md](docs/DM_Explicacion_Taller_Pokemon_ES.md)

---

## 4. Desarrollo de la Parte 1: 15 graficas de clase
En esta parte el objetivo es mostrar cobertura metodologica de tecnicas de visualizacion.

## 4.1 Grafica 1 - Histograma del poder total
Archivo:
- [outputs/taller_pokemon_es/grafica_01_histograma_poder_total.png](outputs/taller_pokemon_es/grafica_01_histograma_poder_total.png)

Lectura:
- Muestra frecuencia por rangos del total_estadisticas_base.
- Permite detectar si el dataset esta sesgado hacia Pokemon debiles, medios o fuertes.

Interpretacion para exponer:
- "La mayor densidad se concentra en rangos intermedios; los extremos son menos comunes. Esto sugiere que el dataset tiene mayor representacion de Pokemon de rendimiento medio, algo razonable para una coleccion amplia y no filtrada solo por elite competitiva."

## 4.2 Grafica 2 - Barras por tipo principal
Archivo:
- [outputs/taller_pokemon_es/grafica_02_barras_tipos_principales.png](outputs/taller_pokemon_es/grafica_02_barras_tipos_principales.png)

Lectura:
- Compara cantidades entre tipos.

Interpretacion para exponer:
- "No existe una distribucion uniforme de tipos. Algunos concentran mas especies, lo que influye en la probabilidad de que aparezcan en cualquier muestra o recomendacion de equipo."

## 4.3 Grafica 3 - Linea de promedio por generacion
Archivo:
- [outputs/taller_pokemon_es/grafica_03_linea_promedio_generacion.png](outputs/taller_pokemon_es/grafica_03_linea_promedio_generacion.png)

Lectura:
- Traza evolucion del promedio de total_estadisticas_base por generacion.

Interpretacion para exponer:
- "Se observan variaciones entre generaciones, lo cual puede interpretarse como cambios de balance de diseno a lo largo del tiempo."

## 4.4 Grafica 4 - Dispersion ataque vs velocidad
Archivo:
- [outputs/taller_pokemon_es/grafica_04_dispersion_ataque_velocidad.png](outputs/taller_pokemon_es/grafica_04_dispersion_ataque_velocidad.png)

Lectura:
- Cada punto representa un Pokemon.
- Relacion visual entre capacidad ofensiva y rapidez.

Interpretacion para exponer:
- "Aunque hay dispersion, se pueden observar zonas con perfiles ofensivos rapidos. Esto ayuda a identificar candidatos para estilos de juego agresivos."

## 4.5 Grafica 5 - Boxplot del poder por tipo
Archivo:
- [outputs/taller_pokemon_es/grafica_05_boxplot_poder_por_tipo.png](outputs/taller_pokemon_es/grafica_05_boxplot_poder_por_tipo.png)

Lectura:
- Mediana, dispersion y atipicos por tipo.

Interpretacion para exponer:
- "No basta con mirar promedios. El boxplot revela estabilidad: un tipo puede tener media alta pero variabilidad muy grande, lo cual afecta consistencia en seleccion de equipo."

## 4.6 Grafica 6 - Densidad de PS
Archivo:
- [outputs/taller_pokemon_es/grafica_06_densidad_ps.png](outputs/taller_pokemon_es/grafica_06_densidad_ps.png)

Lectura:
- Distribucion suavizada de resistencia.

Interpretacion para exponer:
- "La curva permite ver donde se concentra la resistencia tipica y cuantos Pokemon se alejan de ese valor central."

## 4.7 Grafica 7 - Heatmap de combinaciones de tipos
Archivo:
- [outputs/taller_pokemon_es/grafica_07_heatmap_tipos.png](outputs/taller_pokemon_es/grafica_07_heatmap_tipos.png)

Lectura:
- Frecuencia tipo_1 contra tipo_2.

Interpretacion para exponer:
- "Las celdas mas intensas marcan combinaciones frecuentes. Esto sugiere patrones de diseno recurrentes y sinergias que el juego repite."

## 4.8 Grafica 8 - Violin de velocidad por generacion
Archivo:
- [outputs/taller_pokemon_es/grafica_08_violin_velocidad_generacion.png](outputs/taller_pokemon_es/grafica_08_violin_velocidad_generacion.png)

Lectura:
- Forma completa de distribucion por grupo.

Interpretacion para exponer:
- "El violin aporta mas detalle que una media: muestra si la velocidad se concentra en uno o varios rangos en cada generacion."

## 4.9 Grafica 9 - Area por generacion
Archivo:
- [outputs/taller_pokemon_es/grafica_09_area_cantidad_generacion.png](outputs/taller_pokemon_es/grafica_09_area_cantidad_generacion.png)

Lectura:
- Volumen de especies por generacion.

Interpretacion para exponer:
- "Sirve para contextualizar cualquier comparacion, porque no es lo mismo un promedio calculado sobre pocas especies que sobre muchas."

## 4.10 Grafica 10 - Pastel de tipos principales
Archivo:
- [outputs/taller_pokemon_es/grafica_10_pastel_tipos_top8.png](outputs/taller_pokemon_es/grafica_10_pastel_tipos_top8.png)

Lectura:
- Participacion proporcional de tipos top.

Interpretacion para exponer:
- "Es una vista ejecutiva de composicion general, util para audiencia no tecnica por su lectura inmediata."

## 4.11 Grafica 11 - Matriz de dispersion
Archivo:
- [outputs/taller_pokemon_es/grafica_11_matriz_dispersion_stats.png](outputs/taller_pokemon_es/grafica_11_matriz_dispersion_stats.png)

Lectura:
- Todas las combinaciones entre stats principales.

Interpretacion para exponer:
- "Permite detectar relaciones potenciales de forma exploratoria antes de construir modelos mas formales."

## 4.12 Grafica 12 - Heatmap de correlaciones
Archivo:
- [outputs/taller_pokemon_es/grafica_12_heatmap_correlaciones.png](outputs/taller_pokemon_es/grafica_12_heatmap_correlaciones.png)

Lectura:
- Relacion lineal entre pares de variables.

Interpretacion para exponer:
- "Resume en una sola imagen que variables se mueven juntas y cuales son relativamente independientes."

## 4.13 Grafica 13 - Regresion experiencia vs poder
Archivo:
- [outputs/taller_pokemon_es/grafica_13_regresion_experiencia_poder.png](outputs/taller_pokemon_es/grafica_13_regresion_experiencia_poder.png)

Lectura:
- Tendencia lineal entre experiencia y poder total.

Interpretacion para exponer:
- "Existe tendencia positiva esperada: mayor experiencia base suele asociarse con mayor potencial estadistico."

## 4.14 Grafica 14 - Serie por ID con media movil
Archivo:
- [outputs/taller_pokemon_es/grafica_14_serie_id_media_movil.png](outputs/taller_pokemon_es/grafica_14_serie_id_media_movil.png)

Lectura:
- Variacion individual y tendencia suavizada.

Interpretacion para exponer:
- "La media movil reduce ruido y mejora la lectura de patrones globales."

## 4.15 Grafica 15 - Burbujas ataque-defensa-PS
Archivo:
- [outputs/taller_pokemon_es/grafica_15_burbujas_perfil_combate.png](outputs/taller_pokemon_es/grafica_15_burbujas_perfil_combate.png)

Lectura:
- Tres dimensiones en una misma figura.

Interpretacion para exponer:
- "Esta visualizacion permite perfilar roles de combate: ofensivos, defensivos, tanques o balanceados."

---

## 5. Parte 2: Problema de analisis y resolucion con 5 graficas

## 5.1 Problema planteado
Pregunta de negocio/analisis:
Como seleccionar perfiles de Pokemon para construir un equipo competitivo equilibrado entre ataque, defensa y velocidad?

La palabra clave es equilibrado. No buscamos solo maximo ataque ni solo maximo poder total.

## 5.2 Justificacion metodologica de las 5 graficas elegidas
Se eligieron graficas simples para presentacion oral, con lectura rapida:
- Barras
- Boxplot
- Dispersion
- Histograma
- Barras de ranking

Estas cinco cubren los cuatro enfoques base de analisis:
- Comparar
- Distribuir
- Relacionar
- Priorizar

### G1 - Tipos con mayor poder promedio
Archivo:
- [outputs/taller_pokemon_es/problema_g1_tipos_mejor_promedio.png](outputs/taller_pokemon_es/problema_g1_tipos_mejor_promedio.png)

Lectura para exponer:
- "Primero identifico que tipos tienen mejor rendimiento promedio. Esto da una base estrategica para elegir el nucleo del equipo."

### G2 - Poder total por generacion
Archivo:
- [outputs/taller_pokemon_es/problema_g2_boxplot_generaciones.png](outputs/taller_pokemon_es/problema_g2_boxplot_generaciones.png)

Lectura para exponer:
- "Luego comparo estabilidad por generacion: no solo importa que tan alto es el poder, sino cuan variable es."

### G3 - Relacion ataque y defensa
Archivo:
- [outputs/taller_pokemon_es/problema_g3_balance_ofensivo_defensivo.png](outputs/taller_pokemon_es/problema_g3_balance_ofensivo_defensivo.png)

Lectura para exponer:
- "Aqui evalúo balance. Si me voy solo por ataque, puedo sacrificar mucha defensa. La grafica ayuda a encontrar perfiles mas completos."

### G4 - Distribucion de velocidad
Archivo:
- [outputs/taller_pokemon_es/problema_g4_velocidad_vs_poder.png](outputs/taller_pokemon_es/problema_g4_velocidad_vs_poder.png)

Lectura para exponer:
- "La velocidad define iniciativa en combate. Esta distribucion indica cual es el rango normal y donde estan los realmente rapidos."

### G5 - Top 10 por poder total
Archivo:
- [outputs/taller_pokemon_es/problema_g5_correlacion_clave.png](outputs/taller_pokemon_es/problema_g5_correlacion_clave.png)

Lectura para exponer:
- "Cierro con un ranking claro de candidatos fuertes. Esto facilita tomar decision final y comunicarla."

---

## 6. Interpretacion global e integracion de hallazgos

La combinacion de las 5 graficas permite una decision multicriterio:
1. Elegir tipos con buen promedio (G1).
2. Entender contexto generacional y estabilidad (G2).
3. Evitar sesgo extremo a solo ataque o solo defensa (G3).
4. Incorporar velocidad como variable tactica (G4).
5. Priorizar candidatos concretos de alto nivel (G5).

Mensaje integrador para defensa oral:
"Un equipo competitivo robusto no se selecciona por una sola variable. Se construye equilibrando poder total, consistencia, balance ofensivo-defensivo y velocidad."

---

## 7. Conclusion final extendida
En este trabajo se evidencia que el analisis visual, cuando se aplica con estructura metodologica, permite pasar de observaciones descriptivas a decisiones argumentadas.

Conclusiones centrales:
- El dataset presenta concentracion en niveles intermedios de poder, con una franja menor de Pokemon de elite.
- Existen diferencias de representacion por tipo y variaciones por generacion que afectan comparaciones directas.
- El balance entre ataque, defensa y velocidad es mas util para seleccion competitiva que la optimizacion de una sola stat.
- Las graficas simples, bien elegidas, comunican mejor en exposicion que figuras complejas sin narrativa.

Conclusion de decision:
Para armar un equipo competitivo, se recomienda una estrategia mixta:
- base en tipos con promedio alto,
- validacion de consistencia por distribucion,
- inclusion de perfiles rapidos,
- y seleccion final de candidatos con alto total de estadisticas.

---

## 8. Limitaciones y mejoras futuras

Limitaciones del analisis actual:
- Es un analisis descriptivo, no causal.
- No incluye ventajas y desventajas de emparejamientos por tabla de tipos en combate real.
- No modela sinergias de habilidades, movimientos ni formatos competitivos especificos.

Mejoras sugeridas:
- Agregar simulacion de equipo con restricciones (por ejemplo, maximo un legendario).
- Construir indice compuesto con pesos ajustables por estilo de juego.
- Incorporar clustering para identificar arquetipos automaticos de Pokemon.

---

## 9. Preguntas esperadas del jurado y respuestas sugeridas

Pregunta 1:
Por que usar 5 graficas simples para el problema y no solo una compleja?

Respuesta sugerida:
Porque la decision final requiere cubrir distintos angulos: promedio, dispersion, relacion, distribucion y priorizacion. Una sola grafica no comunica todo con claridad.

Pregunta 2:
Como aseguras que no hay sesgo por generacion?

Respuesta sugerida:
Se incluye comparacion por generacion (boxplot y linea) para contextualizar diferencias y evitar conclusiones fuera de contexto.

Pregunta 3:
El top 10 por poder total basta para seleccionar equipo?

Respuesta sugerida:
No. Es solo criterio de cierre. Antes ya se reviso equilibrio de stats y velocidad para evitar decisiones unidimensionales.

Pregunta 4:
Por que carga manual del dataset?

Respuesta sugerida:
Para cumplir el requisito del taller y asegurar portabilidad del script sin depender de rutas absolutas del equipo.

---

## 10. Cierre de presentacion
Cierre recomendado textual:
"Este taller demuestra que una estrategia de visualizacion bien estructurada permite explicar datos complejos de forma clara. No solo replique 15 tecnicas graficas, sino que las conecte en un problema real de seleccion competitiva. La principal conclusion es que la mejor decision no depende de una stat aislada, sino del equilibrio entre poder total, balance de combate y velocidad."
