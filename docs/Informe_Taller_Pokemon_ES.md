# Taller de Graficas en R - Pokemon (dataset en espanol)

## Dataset utilizado
- Fuente: data/processed/pokemon/pokemon_complete_2025_es.xlsx
- Registros: 1025 Pokemon aprox.
- Variables: estadisticas de combate, tipos, generacion, experiencia.

## Parte 1. Replica de 15 graficas con interpretacion breve
1. Histograma: la mayoria de Pokemon se concentra en poder total intermedio.
2. Barras por tipo: algunos tipos aparecen mucho mas que otros.
3. Linea por generacion: el promedio de poder cambia entre generaciones.
4. Dispersion ataque-velocidad: existe tendencia positiva moderada.
5. Boxplot por tipo: hay tipos con mediana alta y menor variabilidad.
6. Densidad de PS: la mayor parte del roster tiene PS medio.
7. Heatmap tipo1-tipo2: se identifican combinaciones comunes de diseno.
8. Violin de velocidad: la forma distribucional cambia por generacion.
9. Area por generacion: se observa expansion de especies por epoca.
10. Pastel top tipos: resume participacion relativa de tipos frecuentes.
11. Matriz de dispersion: permite detectar posibles relaciones no lineales.
12. Heatmap de correlacion: ataque, defensa y total se relacionan fuertemente.
13. Regresion experiencia-poder: mayor experiencia se asocia con mayor poder.
14. Serie por ID: la media movil facilita leer tendencia global.
15. Burbujas: muestra perfiles de combate en tres dimensiones.

## Parte 2. Problema de analisis
### Problema planteado
Como seleccionar perfiles de Pokemon para un equipo competitivo equilibrado entre ataque, defensa y velocidad?

### Justificacion de las 5 graficas usadas
- G1: compara tipos por promedio y variabilidad para elegir base estrategica.
- G2: compara generaciones para identificar contextos de mayor rendimiento.
- G3: analiza equilibrio ofensivo-defensivo, clave para composicion de equipo.
- G4: evalua el aporte de la velocidad al potencial total.
- G5: integra relaciones entre variables clave para sustentar decisiones.

### Conclusion final
Los resultados muestran que no existe un unico atributo ganador. Los equipos mas solidos combinan Pokemon con alto total de estadisticas, buen balance ofensivo-defensivo y velocidad suficiente para tomar ventaja tactica. Tambien se observa que algunos tipos concentran mayor poder promedio, pero con dispersion distinta, por lo que conviene mezclar perfiles complementarios en lugar de depender de un solo tipo.

