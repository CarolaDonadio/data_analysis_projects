# 📊 Proyecto ETL y Preparación de Datos en Power Query

## 📄 Descripción del Proyecto
Este repositorio contiene el proceso completo de **Extracción, Transformación y Carga (ETL)** realizado sobre tres conjuntos de datos heterogéneos (encuestas sociológicas y monitoreo ambiental de calidad del aire).

El objetivo principal fue transformar datos crudos, desestructurados o codificados en datasets limpios, estandarizados y optimizados para análisis estadístico y visualización en Excel / Power BI.

---

## 🛠️ Herramientas Utilizadas
* **Editor de Power Query (Excel):** Extracción, limpieza, transformación, filtrado masivo y lógica condicional.
* **Markdown:** Documentación del proyecto.

---

## 📂 Archivos y Fuentes de Datos

| Nombre del Archivo | Tipo de Datos | Descripción / Desafío Inicial |
| :--- | :--- | :--- |
| `air-quality-monitoring-sites-summary.csv` | Monitoreo Ambiental | Resumen de estaciones de calidad del aire en Nueva Gales del Sur (NSW). Requería promover encabezados y convertir marcas de verificación a booleanos. |
| `Earlwood_Air_Data_17_18.xls` | Series Temporales | Lecturas horarias de contaminantes atmosféricos y variables meteorológicas (8,784 filas). Requería unificación de fecha y hora. |
| `njs2016_data.csv` | Encuesta Sociológica | Base de datos de opinión pública de Canadá con 447 columnas y más de 4,000 registros. Presentaba códigos numéricos de omisión (`99`/`999`) y variables sin etiquetar. |
| `njs2016_dd_en.xlsx` | Diccionario de Datos | Tabla de referencia con las descripciones en texto de los códigos de respuesta de la encuesta. |

---

## 🔄 Proceso de ETL Realizado Paso a Paso

### 1. Limpieza y Estandarización de Estaciones (`air-quality-monitoring-sites-summary`)
* **Promoción de Encabezados:** Se promovió la primera fila como cabeceras reales de la tabla (`NSW air quality monitoring site`, `AQMN Region`, `Latitude`, etc.).
* **Eliminación de Columnas Residuales:** Se quitó la columna vacía inicial creada al importar (`Column1` / `Unnamed: 0`).
* **Limpieza de Texto (*Trim & Clean*):** Se eliminaron espacios invisibles al inicio y final de los nombres de estaciones (`Bulga`, `Camberwell`, etc.) para evitar fallos de coincidencia.
* **Transformación Booleana de Sensores:** Las columnas de contaminantes (`PM10`, `PM2.5`, `TSP`, `NO/NO2/NOx`, `SO2`, `O3`, etc.) que contenían caracteres `ü` fueron transformadas:
  * `ü` $\rightarrow$ `TRUE`
  * Celdas vacías / nulas $\rightarrow$ `FALSE`
  * Tipo de dato convertido a **Verdadero/Falso (Logical)**.

---

### 2. Estructuración de Series Temporales (`Earlwood_Air_Data_17_18`)
* **Creación de Clave Temporal Unificada:** Se combinaron las columnas independientes `Date` y `Time` en una única columna de tipo `DateTime` llamada `Fecha_Hora_Lectura` (`YYYY-MM-DD HH:MM:SS`).
* **Ajuste de Tipos de Datos:** Se definieron los tipos numéricos decimales para las variables de concentración de gases y partículas (`PM10`, `PM2.5`, `OZONE`, `TEMP`, `HUMID`).

---

### 3. Tratamiento de Datos Masivos de la Encuesta (`njs2016_data`)
* **Tratamiento de Caracteres Especiales:** Importación con codificación `Windows-1252` / `UTF-8` para preservar acentos e idioma francés en las preguntas abiertas.
* **Reemplazo Masivo de Códigos No Válidos (Limpieza masiva):**
  * Se identificaron **163 columnas** afectadas por códigos de omisión ("No sabe / No responde").
  * Se aplicó una sustitución masiva seleccionando la totalidad de columnas de la tabla (`Ctrl + A`) para reemplazar el valor `99` y `999` por `null` (valores vacíos de Power Query), evitando la distorsión de futuros promedios estadísticos.
* **Lógica Condicional de Negocio (`CONF_AD`):**
  * Para la variable de confianza en el sistema de justicia de adultos (`CONF_AD`), se implementó una **Columna Condicional** en Power Query que mapea los valores numéricos de la escala del 1 al 10 hacia etiquetas descriptivas estandarizadas (`1 - No Confidence`, `2 - Bajo`, ..., `5 - Moderate confidence`, ..., `10 - A great deal of confidence`, `Sin respuesta`).

---

### 4. Mapeo y Diccionario de Datos (`njs2016_dd_en`)
* **Creación de Llave Primaria Relacional:** Se generó una columna calculada `ID_Variable_Respuesta` / `ID_Clave` combinando el nombre de la variable y el código de respuesta (`NombreVariable-CodigoRespuesta`), dejando lista la tabla para cruzarse con la encuesta mediante relaciones relacionales.

---

## 📈 Estrategia de Carga y Optimización (Load)
1. Las tablas se cargaron en hojas físicas únicamente las tablas resumen requeridas para inspección directa.

---

## 🚀 Resultados Obtenidos
* **3 Datasets completamente limpios** y preparados para análisis de inteligencia de negocios (BI).
* Supresión de errores en métricas numéricas al convertir correctamente los nulos (`99` $\rightarrow$ `null`).
* Estructura optimizada lista para construir **Tablas Dinámicas Multitabla** o conectar directo a **Power BI / Tableau**.
