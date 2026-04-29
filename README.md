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
- [ ] Opcionales
    - [ ] Obtener resultados para todos los cuantizadores x k x tipos de distancia 
    - [ ] Optimizar cuantizadores con Itakura-Saito
    - [ ] Comparar viejos resultados con nuevos
### Parte 2
- [ ] Grabar audios
- [X] Entrenamiento
    - [x] Hiperparámetros como parámetros del entrenamiento
    - [X] Amplificar audios
    - [X] extraccionCaracteristicas
    - [X] Cuantizar -> salida = modelo
- [X] Inferencia
    - [X] Amplificar audios
    - [X] extraccionCaracteristicas
    - [X] calcular distancias -> predecir mínima
    - [X] Output = etiquetas
- [ ] Evaluación
    - [ ] Métricas (Precisión, DICE, MCC?)
    - [X] Matriz de Confusión
    - [ ] Iterar sobre hiperparámetros para encontrar mejor
- [ ] Opcional
  - [ ] Prueba en vivo