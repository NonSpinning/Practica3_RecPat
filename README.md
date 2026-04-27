# Práctica 3 Reconocimiento de patrones
Plan estructura de archivos:
* practica3_main.mlx -> El archivo a presentar en sí, muestra la comparación de los cuantizadores vectoriales, itera el entrenamiento variando hiperparametros hasta obtener el mejor resultado, despliega ese resultado.
* voz_grabaciones
    * entrenamiento -> 10 repeticiones de cada número
    * prueba -> 5 repeticiones de cada búmero
* src
    * itakura-saito.m -> archivo que define calculo itakura-saito (actualmente en extraccionCaracteristicas)
    * extraccionCaracteristicas.m -> Clase wrapper de funciones de práctica 2 que se encargan de tomar la señal y devolver vectores de características compuestos de los coeficientes LPC
    * cuantizacionVectorial.m -> Implementación de LBG (fijo y aleatorio) y K-medias que aceptan como parámetros la función de distancia a usar.
    * reconocimiento.m, junta los siguentes archivos en uno:
        * entrenamiento.m -> Dado un conjunto de audios de entrenamiento y sus etiquetas, usa extraccionCaracteristicas y cuantizacionVectorial para devolver el "modelo"dado una serie de hiperparametros(#número de regiones, orden de LPC, umbrales de inicio y final, tipo de cuantización vectorial)
        * inferencia.m -> dado un modelo y un conjunto de audios de validación/prueba devuelve su clasificación
        * evaluación.m -> Funciones para calcular métricas de desempeño y grafica matriz de confusión.

## POR HACER
### Parte 1
1. Generar puntos de forma replicable
2. Lind-Buzo-Gray con paramétro para tipo de distancia
    1. Optimizar Lind-Buzo-Gray (aleatorio se tardo 30min para 256 regiones)
    2. Mejorar desplegado de regiones
    3. Comparar LBG fijo con resultados teóricos presentación (ya son muy similares)
    4. Asegurar que LBG aleatorio no sea mucho más ineficiente
3. Codificar K-Medias
    1. Optimizar K-Medias
    2. Comparar con K-Medias con ambos LBG.
### Parte 2
1. Grabar audios
2. Entrenamiento
    1. Hiper-parametros como parametros del entrenamiento
    2. Amplificar audios
    3. extraccionCaracteristicas
    4. Cuantizar -> salida = modelo
3. Inferencia
    1. Amplificar audios
    2. extraccionCaracteristicas
    3. calcular distancias -> predecir mínima
    4. Output = etiquetas
4. Evaluación
    1. Métricas (precisión, DICE, MCC, ...)
    2. Matriz de Confusión
    3. Iterar sobre hiperparametros para encontrar mejor
