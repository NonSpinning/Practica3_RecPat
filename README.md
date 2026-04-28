# Práctica 3 Reconocimiento de patrones
Plan estructura de archivos:
* **practica3_main.mlx** -> El archivo a presentar en sí, muestra la comparación de los cuantizador vectoriales, itera el entrenamiento variando hiperparámetros hasta obtener el mejor resultado, despliega ese resultado.
* **src**
    * **itakura-saito.m** -> archivo que define calculo itakura-saito (actualmente en extraccionCaracteristicas)
    * **extraccionCaracteristicas.m** -> Clase wrapper de funciones de práctica 2 que se encargan de tomar la señal y devolver vectores de características compuestos de los coeficientes LPC
    * **cuantizacionVectorial.m** -> Implementación de LBG (fijo y aleatorio) y K-medias que aceptan como parámetros la función de distancia a usar.
    * **reconocimiento.m**, junta los siguientes componentes en uno:
        * **entrenamiento** -> Dado un conjunto de audios de entrenamiento y sus etiquetas, usa extraccionCaracteristicas y cuantizacionVectorial para devolver el "modelo" dado una serie de hiperparámetros(#número de regiones, orden de LPC, umbrales de inicio y final, tipo de cuantización vectorial).
        * **inferencia** -> dado un modelo y un conjunto de audios de validación/prueba devuelve su clasificación.
        * **evaluación** -> Funciones para calcular métricas de desempeño y gráfica matriz de confusión.
* **voz_grabaciones**
    * **entrenamiento** -> 10 repeticiones de cada número
    * **prueba** -> 5 repeticiones de cada número
* **resultados**
    * **Centroides(.0001,1000).mat** -> Resultado de la versión no optimizada de Lind-Buzo-Gray; <br>Las filas corresponden a 1,2,4,8,16,64,256 regiones y las columnas a:
        1. Los centroides obtenidos con epsilon fija
        2. Los centroides obtenidos con epsilon aleatoria
        3. El tiempo de ejecución con epsilon fija
        4. El tiempo de ejecución con epsilon aleatoria.

## POR HACER
### Parte 1
- [X] Generar puntos de forma replicable
- [X] Lind-Buzo-Gray con parámetro para tipo de distancia
    - [X] Separar itakura-saito
    - [X] Optimizar Lind-Buzo-Gray (aleatorio se tardo 30min para 256 regiones)
    - [X] Mejorar desplegado de regiones
    - [ ] Comparar LBG fijo con resultados teóricos presentación (ya son muy similares)
    - [ ] Asegurar que LBG aleatorio no sea mucho más ineficiente
    - [ ] Matriz de umbral???
- [ ] Codificar K-Medias
    - [ ] Optimizar K-Medias
    - [ ] K-Medias ++ 
    - [ ] Comparar con K-Medias con ambos LBG.
- [ ] Comparar LBG optimizados y no optimizados
### Parte 2
- [ ] Grabar audios
- [ ] Entrenamiento
    - [ ] Hiperparámetros como parámetros del entrenamiento
    - [ ] Amplificar audios
    - [ ] extraccionCaracteristicas
    - [ ] Cuantizar -> salida = modelo
- [ ] Inferencia
    - [ ] Amplificar audios
    - [ ] extraccionCaracteristicas
    - [ ] calcular distancias -> predecir mínima
    - [ ] Output = etiquetas
- [ ] Evaluación
    - [ ] Métricas (Precisión, DICE, MCC?)
    - [ ] Matriz de Confusión
    - [ ] Iterar sobre hiperparámetros para encontrar mejor