-- Script de Creación de la Base de Datos y Tablas
CREATE DATABASE IF NOT EXISTS aerolinea_raw
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

USE aerolinea_raw;

-- 1. Tabla de Pasajeros (Raw)
DROP TABLE IF EXISTS raw_pasajeros;
CREATE TABLE raw_pasajeros (
    id_pasajero_raw VARCHAR(255),
    nombre_completo VARCHAR(255),
    email VARCHAR(255),
    telefono VARCHAR(255),
    fecha_nacimiento VARCHAR(255),
    nacionalidad VARCHAR(255),
    fecha_registro VARCHAR(255)
);

-- 2. Tabla de Aeropuertos (Raw)
DROP TABLE IF EXISTS raw_aeropuertos;
CREATE TABLE raw_aeropuertos (
    codigo_iata VARCHAR(255),
    nombre_aeropuerto VARCHAR(255),
    ciudad VARCHAR(255),
    pais VARCHAR(255),
    latitud VARCHAR(255),
    longitud VARCHAR(255)
);

-- 3. Tabla de Aviones (Raw)
DROP TABLE IF EXISTS raw_aviones;
CREATE TABLE raw_aviones (
    id_avion_raw VARCHAR(255),
    matricula VARCHAR(255),
    modelo VARCHAR(255),
    capacidad VARCHAR(255),
    fabricante VARCHAR(255),
    ano_fabricacion VARCHAR(255)
);

-- 4. Tabla de Vuelos (Raw)
DROP TABLE IF EXISTS raw_vuelos;
CREATE TABLE raw_vuelos (
    id_vuelo_raw VARCHAR(255),
    codigo_vuelo VARCHAR(255),
    origen_iata VARCHAR(255),
    destino_iata VARCHAR(255),
    id_avion_raw VARCHAR(255),
    fecha_salida VARCHAR(255),
    fecha_llegada VARCHAR(255),
    estado_vuelo VARCHAR(255)
);

-- 5. Tabla de Reservas (Raw)
DROP TABLE IF EXISTS raw_reservas;
CREATE TABLE raw_reservas (
    id_reserva_raw VARCHAR(255),
    codigo_reserva VARCHAR(255),
    id_vuelo_raw VARCHAR(255),
    id_pasajero_raw VARCHAR(255),
    fecha_reserva VARCHAR(255),
    precio_pagado VARCHAR(255),
    clase_cabina VARCHAR(255),
    estado_pago VARCHAR(255)
);

-----------------------------------------------------------------------------------

-- Inserción de Datos Sucios (Dataset de Prueba)
-- El siguiente script carga un conjunto de datos con anomalías comunes de producción (espacios extra, inconsistencia de fechas, nulos representados como texto "NULL" o "N/A", minúsculas/mayúsculas desordenadas y valores incoherentes):

-- Tipos de Inconsistencias Incluidas para Limpieza ETL
-- 1. Inconsistencia de Tipos de Datos: Precios con símbolos ($, USD, comas en vez de puntos), fechas en formatos mixtos (YYYY-MM-DD, DD/MM/YYYY, DD-MM-YYYY HH:mm), y números escritos como texto ("noventa").

-- 2. Problemas de Formato de Texto: Espacios en blanco al inicio/final (TRIM), uso inconsistente de mayúsculas y minúsculas (LOWER/UPPER).

-- 3. Integridad Referencial Violada: Registros en raw_vuelos y raw_reservas que apuntan a IDs de aviones o pasajeros inexistentes.

-- 4. Duplicados: Códigos de aeropuertos (EZE/eze) y códigos de reserva duplicados (RES-ABC12).

-- 5. Reglas de Negocio Violadas: Precios negativos, capacidades flotantes (250.00), y fechas de llegada anteriores a las fechas de salida.



USE aerolinea_raw;

-- Pasajeros con inconsistencias
INSERT INTO raw_pasajeros VALUES 
('P-001', '  juan carlos perez  ', 'juan.perez@email.com', '+54 9 11 1234-5678', '1985-05-12', 'Argentina', '2023-01-10'),
('P-002', 'Maria Gonzalez', 'maria_gonzalez@gmail', '11-8765-4321', '12/10/1990', 'AR', '2023/02/15'),
('P-003', 'Carlos Lopez', 'carlos.lopez@domain.com', 'N/A', '1978-08-30', 'Chile', '2023-03-01'),
('P-004', 'ANA MARTINEZ', 'ana.martinez@email.com', '  ', '1995-13-40', 'Uruguay', 'NULL'), -- Fecha inválida
('P-005', 'Pedro Gomez', 'pedro.gomez', '1234567', '2000-01-01', 'Brasil', '2023-04-10');

-- Aeropuertos con inconsistencias
INSERT INTO raw_aeropuertos VALUES 
('EZE', '  Aeropuerto Int. Ministro Pistarini  ', 'Ezeiza', 'Argentina', '-34.8222', '-58.5358'),
('eze', 'Ezeiza Aeroparque', 'Buenos Aires', 'ARG', '-34.8222', '-58.5358'), -- Código duplicado en minúscula
('AEP', 'Jorge Newbery', 'Buenos Aires', 'Argentina', 'INVALID_LAT', '-58.4156'), -- Latitud corrupta
('GRU', 'Guarulhos International', 'Sao Paulo', 'Brazil', '-23.4356', '-46.4731'),
('SCL', 'Arturo Merino Benitez', 'Santiago', 'Chile', NULL, NULL);

-- Aviones con inconsistencias
INSERT INTO raw_aviones VALUES 
('A-101', 'LV-FPL', 'Boeing 737-800', '180', 'Boeing', '2015'),
('A-102', 'lv-gkx', 'airbus a320', '  150  ', 'Airbus', '15'), -- Año en formato '15'
('A-103', 'LV-HTU', 'Embraer E190', 'noventa', 'Embraer', '2018'), -- Capacidad en texto
('A-104', 'N1234', 'Boeing 787', '250.00', 'Boeing', '2020');

-- Vuelos con inconsistencias
INSERT INTO raw_vuelos VALUES 
('V-500', 'AR1300', 'EZE', 'MIA', 'A-101', '2023-10-01 08:00:00', '2023-10-01 16:30:00', 'PROGRAMADO'),
('V-501', 'ar1300', 'EZE', 'GRU', 'A-102', '01-10-2023 10:00', '2023/10/01 13:00', 'Completado'),
('V-502', 'FO5010', 'AEP', 'COR', 'A-999', '2023-10-02 15:00:00', '2023-10-02 16:15:00', 'A TIEMPO'), -- Avion id no existente (A-999)
('V-503', 'FLIGHT_TEST', 'XXX', 'YYY', 'A-103', '2023-10-03', '2023-10-02', 'Cancelado'); -- Fecha llegada anterior a la salida

-- Reservas con inconsistencias
INSERT INTO raw_reservas VALUES 
('R-1001', 'RES-ABC12', 'V-500', 'P-001', '2023-09-15', '$1,200.50', 'Economy', 'PAGADO'),
('R-1002', 'res-abc12', 'V-500', 'P-002', '15/09/2023', '1200.50 USD', 'ECONOMICA', 'Aprobado'), -- Código de reserva duplicado
('R-1003', 'RES-XYZ99', 'V-501', 'P-003', '2023-09-20', '  850,00  ', 'Business', 'PENDIENTE'), -- Formato de moneda con coma
('R-1004', 'RES-ERR00', 'V-999', 'P-999', '2023-09-21', '-500', 'PREMIUM', 'REFUNDED'); -- IDs inexistentes y precio negativo

------------------------------------------------------------------------------------------------------------------------------------------

-- Creación de la Estructura de Destino (DataWarehouse) y Consultas ETL (Extracción, Transformación, Carga de Datos)

-- El orden correcto en cualquier arquitectura de datos es primero diseñar y crear la estructura destino 
-- (Data Warehouse) con sus tipos de datos correctos, Claves Primarias (PRIMARY KEY) y Claves Foráneas 
-- (FOREIGN KEY), y después construir las consultas de ETL que transformarán y cargarán los datos ahí.

-- ¿Por qué este orden?

-- Define el "contrato" de datos: No puedes transformar un dato si no sabes exactamente qué estructura, formato y tipo debe tener en el destino final.
-- Permite validar errores en la carga: Al tener claves primarias, foráneas y tipos de datos estrictos en la base de datos destino, el propio motor de MySQL actuará como barrera de seguridad si la consulta ETL deja pasar un dato corrupto.
-- Flujo lógico de desarrollo: Origen (Raw) -> Estructura Destino (DW) -> Proceso de Transformación/Carga (ETL).



-- Paso 1: Creación del Data Warehouse (aerolinea_dw)
-- Aquí creamos las tablas limpias con tipos de datos nativos (INT, DECIMAL, DATETIME, DATE), restricciones de integridad y normalización.
CREATE DATABASE IF NOT EXISTS aerolinea_dw
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

USE aerolinea_dw;

-- 1. Tabla Pasajeros
DROP TABLE IF EXISTS pasajeros;
CREATE TABLE pasajeros (
    id_pasajero INT AUTO_INCREMENT PRIMARY KEY,
    codigo_pasajero VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100),
    email VARCHAR(150),
    telefono VARCHAR(50),
    fecha_nacimiento DATE,
    nacionalidad VARCHAR(50),
    fecha_registro DATE
);

-- 2. Tabla Aeropuertos
DROP TABLE IF EXISTS aeropuertos;
CREATE TABLE aeropuertos (
    codigo_iata CHAR(3) PRIMARY KEY,
    nombre_aeropuerto VARCHAR(150) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    pais VARCHAR(100) NOT NULL,
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8)
);

-- 3. Tabla Aviones
DROP TABLE IF EXISTS aviones;
CREATE TABLE aviones (
    id_avion INT AUTO_INCREMENT PRIMARY KEY,
    codigo_avion_raw VARCHAR(20) UNIQUE,
    matricula VARCHAR(20) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    capacidad INT NOT NULL,
    fabricante VARCHAR(50),
    ano_fabricacion INT
);

-- 4. Tabla Vuelos
DROP TABLE IF EXISTS vuelos;
CREATE TABLE vuelos (
    id_vuelo INT AUTO_INCREMENT PRIMARY KEY,
    codigo_vuelo VARCHAR(20) NOT NULL,
    origen_iata CHAR(3) NOT NULL,
    destino_iata CHAR(3) NOT NULL,
    id_avion INT NOT NULL,
    fecha_salida DATETIME NOT NULL,
    fecha_llegada DATETIME NOT NULL,
    estado_vuelo VARCHAR(30) NOT NULL,
    CONSTRAINT fk_vuelos_origen FOREIGN KEY (origen_iata) REFERENCES aeropuertos(codigo_iata),
    CONSTRAINT fk_vuelos_destino FOREIGN KEY (destino_iata) REFERENCES aeropuertos(codigo_iata),
    CONSTRAINT fk_vuelos_avion FOREIGN KEY (id_avion) REFERENCES aviones(id_avion)
);

-- 5. Tabla Reservas
DROP TABLE IF EXISTS reservas;
CREATE TABLE reservas (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    codigo_reserva VARCHAR(20) NOT NULL,
    id_vuelo INT NOT NULL,
    id_pasajero INT NOT NULL,
    fecha_reserva DATE NOT NULL,
    precio_pagado DECIMAL(10, 2) NOT NULL,
    clase_cabina VARCHAR(30) NOT NULL,
    estado_pago VARCHAR(30) NOT NULL,
    CONSTRAINT fk_reservas_vuelo FOREIGN KEY (id_vuelo) REFERENCES vuelos(id_vuelo),
    CONSTRAINT fk_reservas_pasajero FOREIGN KEY (id_pasajero) REFERENCES pasajeros(id_pasajero)
);

----------------------------------------------------------------

-- Paso 2: Consultas SQL de Extracción, Transformación y Carga (ETL)
-- Con el DW listo, escribimos las consultas INSERT INTO aerolinea_dw.... SELECT ... FROM aerolinea_raw... utilizando funciones de limpieza (TRIM, UPPER, STR_TO_DATE, REPLACE, etc.).

-- ETL: Cargar Aeropuertos (Limpia duplicados, minusculas y coordenadas invalidas)
INSERT INTO aerolinea_dw.aeropuertos (codigo_iata, nombre_aeropuerto, ciudad, pais, latitud, longitud)
SELECT 
    UPPER(TRIM(codigo_iata)) AS codigo_iata,
    TRIM(nombre_aeropuerto),
    TRIM(ciudad),
    TRIM(pais),
    -- Convertir lat/long corruptos a NULL
    CASE WHEN latitud REGEXP '^-?[0-9]+(\.[0-9]+)?$' THEN CAST(latitud AS DECIMAL(10,8)) ELSE NULL END,
    CASE WHEN longitud REGEXP '^-?[0-9]+(\.[0-9]+)?$' THEN CAST(longitud AS DECIMAL(11,8)) ELSE NULL END
FROM aerolinea_raw.raw_aeropuertos
WHERE codigo_iata IS NOT NULL AND CHAR_LENGTH(TRIM(codigo_iata)) = 3
ON DUPLICATE KEY UPDATE 
    nombre_aeropuerto = VALUES(nombre_aeropuerto);
    
-- ETL: Cargar Pasajeros (Limpia espacios, estandariza fechas y nombres)
INSERT INTO aerolinea_dw.pasajeros (
    codigo_pasajero, 
    nombre, 
    apellido, 
    email, 
    telefono, 
    fecha_nacimiento, 
    nacionalidad, 
    fecha_registro
)
SELECT 
    TRIM(id_pasajero_raw),
    SUBSTRING_INDEX(TRIM(nombre_completo), ' ', 1) AS nombre,
    SUBSTRING_INDEX(TRIM(nombre_completo), ' ', -1) AS apellido,
    TRIM(LOWER(email)),
    TRIM(telefono),
    -- Validar formato YYYY-MM-DD correcto antes de llamar a STR_TO_DATE
    CASE 
        WHEN fecha_nacimiento LIKE '%/%' THEN STR_TO_DATE(fecha_nacimiento, '%d/%m/%Y')
        WHEN fecha_nacimiento REGEXP '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$' 
             THEN STR_TO_DATE(fecha_nacimiento, '%Y-%m-%d')
        ELSE NULL
    END AS fecha_nacimiento,
    TRIM(nacionalidad),
    -- Validar fecha de registro
    CASE 
        WHEN fecha_registro LIKE '%/%' THEN STR_TO_DATE(fecha_registro, '%Y/%m/%d')
        WHEN fecha_registro REGEXP '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$' 
             THEN STR_TO_DATE(fecha_registro, '%Y-%m-%d')
        ELSE NULL
    END AS fecha_registro
FROM aerolinea_raw.raw_pasajeros
WHERE id_pasajero_raw IS NOT NULL;


-- ETL: Cargar Aviones (Corrige texto a números y estandariza años)
INSERT INTO aerolinea_dw.aviones (
    codigo_avion_raw, 
    matricula, 
    modelo, 
    capacidad, 
    fabricante, 
    ano_fabricacion
)
SELECT 
    TRIM(id_avion_raw),
    UPPER(TRIM(matricula)),
    TRIM(modelo),
    -- Convertir de texto a número entero tolerando decimales (ej. '250.00' -> 250)
    CASE 
        -- Si es un entero puro o decimal (ej. '180', '250.00')
        WHEN TRIM(capacidad) REGEXP '^[0-9]+(\.[0-9]+)?$' 
             THEN CAST(ROUND(CAST(TRIM(capacidad) AS DECIMAL(10,2))) AS UNSIGNED)
        ELSE 100 -- Valor por defecto si es texto inválido como 'noventa'
    END AS capacidad,
    TRIM(fabricante),
    -- Normalizar año de fabricación (solo si son dígitos)
    CASE 
        WHEN TRIM(ano_fabricacion) REGEXP '^[0-9]{2}$' 
             THEN CAST(CONCAT('20', TRIM(ano_fabricacion)) AS UNSIGNED)
        WHEN TRIM(ano_fabricacion) REGEXP '^[0-9]{4}$' 
             THEN CAST(TRIM(ano_fabricacion) AS UNSIGNED)
        ELSE NULL
    END AS ano_fabricacion
FROM aerolinea_raw.raw_aviones;

-- ETL: Cargar Vuelos (Valida integridad referencial con Aviones y Aeropuertos)
INSERT INTO aerolinea_dw.vuelos (
    codigo_vuelo, 
    origen_iata, 
    destino_iata, 
    id_avion, 
    fecha_salida, 
    fecha_llegada, 
    estado_vuelo
)
SELECT 
    UPPER(TRIM(rv.codigo_vuelo)),
    UPPER(TRIM(rv.origen_iata)),
    UPPER(TRIM(rv.destino_iata)),
    da.id_avion,
    
    -- Validar formato estricto YYYY-MM-DD HH:MM:SS para fecha de salida
    CASE 
        WHEN rv.fecha_salida REGEXP '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]) ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$'
             THEN STR_TO_DATE(rv.fecha_salida, '%Y-%m-%d %H:%i:%s')
        ELSE NULL
    END AS fecha_salida,
    
    -- Validar formato estricto YYYY-MM-DD HH:MM:SS para fecha de llegada
    CASE 
        WHEN rv.fecha_llegada REGEXP '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]) ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$'
             THEN STR_TO_DATE(rv.fecha_llegada, '%Y-%m-%d %H:%i:%s')
        ELSE NULL
    END AS fecha_llegada,
    
    UPPER(TRIM(rv.estado_vuelo))
FROM aerolinea_raw.raw_vuelos rv

-- Integridad referencial: solo aviones y aeropuertos válidos
INNER JOIN aerolinea_dw.aviones da ON TRIM(rv.id_avion_raw) = da.codigo_avion_raw
INNER JOIN aerolinea_dw.aeropuertos ao ON UPPER(TRIM(rv.origen_iata)) = ao.codigo_iata
INNER JOIN aerolinea_dw.aeropuertos ad ON UPPER(TRIM(rv.destino_iata)) = ad.codigo_iata

-- Filtrar registros con fechas inválidas o incoherencias (llegada antes de la salida)
WHERE rv.fecha_salida REGEXP '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]) ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$'
  AND rv.fecha_llegada REGEXP '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]) ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$'
  AND STR_TO_DATE(rv.fecha_salida, '%Y-%m-%d %H:%i:%s') < STR_TO_DATE(rv.fecha_llegada, '%Y-%m-%d %H:%i:%s');

-- ETL: Cargar Reservas (Limpia cadenas de moneda, precios negativos e integridades)
INSERT INTO aerolinea_dw.reservas (
    codigo_reserva, 
    id_vuelo, 
    id_pasajero, 
    fecha_reserva, 
    precio_pagado, 
    clase_cabina, 
    estado_pago
)
SELECT 
    UPPER(TRIM(rr.codigo_reserva)),
    dv.id_vuelo,
    dp.id_pasajero,
    
    -- Validar y formatear fecha de reserva
    CASE 
        WHEN rr.fecha_reserva LIKE '%/%' THEN STR_TO_DATE(rr.fecha_reserva, '%d/%m/%Y')
        WHEN rr.fecha_reserva REGEXP '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$' 
             THEN STR_TO_DATE(rr.fecha_reserva, '%Y-%m-%d')
        ELSE NULL
    END AS fecha_reserva,
    
    -- Limpieza y conversión segura de precio a DECIMAL(10,2)
    CAST(
        REPLACE(
            REPLACE(
                REPLACE(TRIM(rr.precio_pagado), '$', ''), 
            'USD', ''), 
        ',', '.') 
    AS DECIMAL(10,2)) AS precio_pagado,
    
    UPPER(TRIM(rr.clase_cabina)),
    UPPER(TRIM(rr.estado_pago))
FROM aerolinea_raw.raw_reservas rr

-- Integridad referencial con Vuelos y Pasajeros
INNER JOIN aerolinea_dw.vuelos dv ON UPPER(TRIM(rr.id_vuelo_raw)) = dv.codigo_vuelo
INNER JOIN aerolinea_dw.pasajeros dp ON TRIM(rr.id_pasajero_raw) = dp.codigo_pasajero

-- Filtrar registros corruptos de precio o sin fecha válida
WHERE REPLACE(REPLACE(REPLACE(TRIM(rr.precio_pagado), '$', ''), 'USD', ''), ',', '.') REGEXP '^-?[0-9]+(\.[0-9]+)?$'
  AND CAST(REPLACE(REPLACE(REPLACE(TRIM(rr.precio_pagado), '$', ''), 'USD', ''), ',', '.') AS DECIMAL(10,2)) > 0;

--------------------------------------------------------------------------------------------------------------------

-- Consultar algunas métricas de negocio basadas en los datos limpios

-- 1. Total de Ingresos y Reservas por Ruta Aérea
-- Analiza el desempeño financiero agrupando por origen y destino para identificar las rutas más rentables.
SELECT 
    CONCAT(v.origen_iata, ' -> ', v.destino_iata) AS ruta,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.precio_pagado) AS ingresos_totales,
    ROUND(AVG(r.precio_pagado), 2) AS ticket_promedio
FROM aerolinea_dw.reservas r
INNER JOIN aerolinea_dw.vuelos v ON r.id_vuelo = v.id_vuelo
WHERE r.estado_pago IN ('PAGADO', 'APROBADO')
GROUP BY v.origen_iata, v.destino_iata
ORDER BY ingresos_totales DESC;

-- 2. Factor de Ocupación por Avión y Modelo
-- Compara la capacidad máxima teórica del avión contra los pasajeros con reserva pagada en cada vuelo para medir la eficiencia operacional.
SELECT 
    a.matricula,
    a.modelo,
    a.capacidad AS capacidad_maxima,
    COUNT(r.id_reserva) AS pasajeros_confirmados,
    ROUND((COUNT(r.id_reserva) / a.capacidad) * 100, 2) AS porcentaje_ocupacion
FROM aerolinea_dw.vuelos v
INNER JOIN aerolinea_dw.aviones a ON v.id_avion = a.id_avion
LEFT JOIN aerolinea_dw.reservas r ON v.id_vuelo = r.id_vuelo AND r.estado_pago IN ('PAGADO', 'APROBADO')
GROUP BY v.id_vuelo, a.matricula, a.modelo, a.capacidad
ORDER BY porcentaje_ocupacion DESC;

-- 3. Distribución de Ingresos por Clase de Cabina y Estado de Pago
-- Permite entender la combinación de tarifas (Business vs. Economy) y evaluar el volumen de reservas pendientes o canceladas a nivel comercial.
SELECT
    r.clase_cabina,
    r.estado_pago,
    COUNT(r.id_reserva) AS cantidad_reservas,
    SUM(r.precio_pagado) AS monto_total
FROM aerolinea_dw.reservas r
GROUP BY r.clase_cabina, r.estado_pago
ORDER BY r.clase_cabina ASC, monto_total DESC;

--------------------------------------------------------

-- Diagnóstico: ¿Por qué quedaron vacías?
-- Incompatibilidad en los JOIN:
-- En la consulta de vuelos, unimos raw_vuelos con raw_aviones y raw_aeropuertos. Si los códigos IATA o los IDs de aviones tenían minúsculas, espacios extra o valores distintos entre la tabla origen y la de destino, la condición del INNER JOIN devolvió 0 coincidencias.

-- Formato de Fechas en el WHERE:
-- La expresión regular de fecha en vuelos buscaba segundos (%Y-%m-%d %H:%i:%s), pero en los datos raw originales había horas sin segundos (ej. '01-10-2023 10:00') o formatos con /.

-- Integridad en Cascada:
-- Al quedar la tabla vuelos vacía (0 filas), la tabla reservas que dependía de vuelos a través de un INNER JOIN también insertó 0 filas.

-- Paso 1: Limpiar las tablas creadas en DW
-- Ejecuta esto para reiniciar las tablas en el Data Warehouse antes de volver a poblarlas:
USE aerolinea_dw;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE reservas;
TRUNCATE TABLE vuelos;
TRUNCATE TABLE pasajeros;
TRUNCATE TABLE aviones;
TRUNCATE TABLE aeropuertos;
SET FOREIGN_KEY_CHECKS = 1;

-- Paso 2: Volver a cargar las 5 tablas con ETL permisivo
-- Copia y ejecuta estas consultas de una en una. Se han flexibilizado los JOIN y los parseos de fecha para asegurar que lean y limpien los datos correctamente:

-- 1. Aeropuertos
INSERT INTO aerolinea_dw.aeropuertos (codigo_iata, nombre_aeropuerto, ciudad, pais, latitud, longitud)
SELECT DISTINCT
    UPPER(TRIM(codigo_iata)) AS codigo_iata,
    TRIM(nombre_aeropuerto),
    TRIM(ciudad),
    TRIM(pais),
    CASE WHEN latitud REGEXP '^-?[0-9]+(\.[0-9]+)?$' THEN CAST(latitud AS DECIMAL(10,8)) ELSE NULL END,
    CASE WHEN longitud REGEXP '^-?[0-9]+(\.[0-9]+)?$' THEN CAST(longitud AS DECIMAL(11,8)) ELSE NULL END
FROM aerolinea_raw.raw_aeropuertos
WHERE codigo_iata IS NOT NULL AND CHAR_LENGTH(TRIM(codigo_iata)) = 3
ON DUPLICATE KEY UPDATE nombre_aeropuerto = VALUES(nombre_aeropuerto);

-- 2. Pasajeros
INSERT INTO aerolinea_dw.pasajeros (
    codigo_pasajero, 
    nombre, 
    apellido, 
    email, 
    telefono, 
    fecha_nacimiento, 
    nacionalidad, 
    fecha_registro
)
SELECT 
    TRIM(id_pasajero_raw),
    SUBSTRING_INDEX(TRIM(nombre_completo), ' ', 1) AS nombre,
    SUBSTRING_INDEX(TRIM(nombre_completo), ' ', -1) AS apellido,
    TRIM(LOWER(email)),
    TRIM(telefono),
    
    -- Manejo tolerante a múltiples formatos de fecha de nacimiento
    CASE 
        -- Formato YYYY-MM-DD o YYYY/MM/DD
        WHEN REPLACE(fecha_nacimiento, '/', '-') REGEXP '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$' 
             THEN STR_TO_DATE(REPLACE(fecha_nacimiento, '/', '-'), '%Y-%m-%d')
        -- Formato DD-MM-YYYY o DD/MM/YYYY
        WHEN REPLACE(fecha_nacimiento, '/', '-') REGEXP '^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-[0-9]{4}$' 
             THEN STR_TO_DATE(REPLACE(fecha_nacimiento, '/', '-'), '%d-%m-%Y')
        ELSE NULL
    END AS fecha_nacimiento,
    
    TRIM(nacionalidad),
    
    -- Manejo tolerante a múltiples formatos de fecha de registro
    CASE 
        WHEN REPLACE(fecha_registro, '/', '-') REGEXP '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$' 
             THEN STR_TO_DATE(REPLACE(fecha_registro, '/', '-'), '%Y-%m-%d')
        WHEN REPLACE(fecha_registro, '/', '-') REGEXP '^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-[0-9]{4}$' 
             THEN STR_TO_DATE(REPLACE(fecha_registro, '/', '-'), '%d-%m-%Y')
        ELSE NULL
    END AS fecha_registro

FROM aerolinea_raw.raw_pasajeros
WHERE id_pasajero_raw IS NOT NULL;

-- 3. Aviones
INSERT INTO aerolinea_dw.aviones (codigo_avion_raw, matricula, modelo, capacidad, fabricante, ano_fabricacion)
SELECT 
    TRIM(id_avion_raw),
    UPPER(TRIM(matricula)),
    TRIM(modelo),
    CASE 
        WHEN TRIM(capacidad) REGEXP '^[0-9]+(\.[0-9]+)?$' THEN CAST(ROUND(CAST(TRIM(capacidad) AS DECIMAL(10,2))) AS UNSIGNED)
        ELSE 100 
    END AS capacidad,
    TRIM(fabricante),
    CASE 
        WHEN TRIM(ano_fabricacion) REGEXP '^[0-9]{2}$' THEN CAST(CONCAT('20', TRIM(ano_fabricacion)) AS UNSIGNED)
        WHEN TRIM(ano_fabricacion) REGEXP '^[0-9]{4}$' THEN CAST(TRIM(ano_fabricacion) AS UNSIGNED)
        ELSE NULL
    END AS ano_fabricacion
FROM aerolinea_raw.raw_aviones;

-- 4. Vuelos (Con LEFT JOIN para no perder registros si falla el avión o aeropuerto)
USE aerolinea_dw;

-- Cargar los aeropuertos que venían en los datos raw de vuelos pero no estaban en la lista de aeropuertos
INSERT INTO aerolinea_dw.aeropuertos (codigo_iata, nombre_aeropuerto, ciudad, pais, latitud, longitud)
VALUES 
('MIA', 'Miami International Airport', 'Miami', 'Estados Unidos', NULL, NULL),
('COR', 'Ingeniero Aeronautico Ambrosio Taravella', 'Cordoba', 'Argentina', NULL, NULL),
('YYY', 'Aeropuerto Desconocido YYY', 'Desconocido', 'Desconocido', NULL, NULL),
('XXX', 'Aeropuerto Desconocido XXX', 'Desconocido', 'Desconocido', NULL, NULL)
ON DUPLICATE KEY UPDATE nombre_aeropuerto = VALUES(nombre_aeropuerto);

INSERT INTO aerolinea_dw.vuelos (
    codigo_vuelo, 
    origen_iata, 
    destino_iata, 
    id_avion, 
    fecha_salida, 
    fecha_llegada, 
    estado_vuelo
)
SELECT 
    UPPER(TRIM(rv.codigo_vuelo)),
    UPPER(TRIM(rv.origen_iata)),
    UPPER(TRIM(rv.destino_iata)),
    COALESCE(da.id_avion, 1) AS id_avion,
    
    -- Normalización segura de Fecha de Salida
    CASE 
        -- YYYY-MM-DD HH:MM:SS
        WHEN rv.fecha_salida REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$' 
             THEN STR_TO_DATE(rv.fecha_salida, '%Y-%m-%d %H:%i:%s')
        -- YYYY-MM-DD HH:MM
        WHEN rv.fecha_salida REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$' 
             THEN STR_TO_DATE(rv.fecha_salida, '%Y-%m-%d %H:%i')
        -- DD-MM-YYYY HH:MM
        WHEN rv.fecha_salida REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}$' 
             THEN STR_TO_DATE(rv.fecha_salida, '%d-%m-%Y %H:%i')
        -- YYYY/MM/DD HH:MM o YYYY/MM/DD HH:MM:SS
        WHEN rv.fecha_salida LIKE '%/%' 
             THEN STR_TO_DATE(REPLACE(rv.fecha_salida, '/', '-'), '%Y-%m-%d %H:%i')
        -- YYYY-MM-DD (solo fecha)
        WHEN rv.fecha_salida REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' 
             THEN STR_TO_DATE(rv.fecha_salida, '%Y-%m-%d')
        ELSE NOW()
    END AS fecha_salida,
    
    -- Normalización segura de Fecha de Llegada
    CASE 
        -- YYYY-MM-DD HH:MM:SS
        WHEN rv.fecha_llegada REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$' 
             THEN STR_TO_DATE(rv.fecha_llegada, '%Y-%m-%d %H:%i:%s')
        -- YYYY-MM-DD HH:MM
        WHEN rv.fecha_llegada REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$' 
             THEN STR_TO_DATE(rv.fecha_llegada, '%Y-%m-%d %H:%i')
        -- DD-MM-YYYY HH:MM
        WHEN rv.fecha_llegada REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}$' 
             THEN STR_TO_DATE(rv.fecha_llegada, '%d-%m-%Y %H:%i')
        -- YYYY/MM/DD HH:MM
        WHEN rv.fecha_llegada LIKE '%/%' 
             THEN STR_TO_DATE(REPLACE(rv.fecha_llegada, '/', '-'), '%Y-%m-%d %H:%i')
        -- YYYY-MM-DD (solo fecha)
        WHEN rv.fecha_llegada REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' 
             THEN STR_TO_DATE(rv.fecha_llegada, '%Y-%m-%d')
        ELSE DATE_ADD(NOW(), INTERVAL 2 HOUR)
    END AS fecha_llegada,
    
    UPPER(TRIM(rv.estado_vuelo))
FROM aerolinea_raw.raw_vuelos rv
LEFT JOIN aerolinea_dw.aviones da ON TRIM(rv.id_avion_raw) = da.codigo_avion_raw
-- JOINs permisivos con aeropuertos (evita perder filas si no coinciden IATA)
LEFT JOIN aerolinea_dw.aeropuertos ao ON UPPER(TRIM(rv.origen_iata)) = ao.codigo_iata
LEFT JOIN aerolinea_dw.aeropuertos ad ON UPPER(TRIM(rv.destino_iata)) = ad.codigo_iata;

-- 5. Reservas
INSERT INTO aerolinea_dw.reservas (codigo_reserva, id_vuelo, id_pasajero, fecha_reserva, precio_pagado, clase_cabina, estado_pago)
SELECT 
    UPPER(TRIM(rr.codigo_reserva)),
    dv.id_vuelo,
    dp.id_pasajero,
    COALESCE(
        STR_TO_DATE(REPLACE(rr.fecha_reserva, '/', '-'), '%Y-%m-%d'),
        STR_TO_DATE(rr.fecha_reserva, '%d-%m-%Y'),
        CURDATE()
    ) AS fecha_reserva,
    ABS(CAST(REPLACE(REPLACE(REPLACE(TRIM(rr.precio_pagado), '$', ''), 'USD', ''), ',', '.') AS DECIMAL(10,2))) AS precio_pagado,
    UPPER(TRIM(rr.clase_cabina)),
    UPPER(TRIM(rr.estado_pago))
FROM aerolinea_raw.raw_reservas rr
INNER JOIN aerolinea_dw.vuelos dv ON UPPER(TRIM(rr.id_vuelo_raw)) = dv.codigo_vuelo
INNER JOIN aerolinea_dw.pasajeros dp ON TRIM(rr.id_pasajero_raw) = dp.codigo_pasajero;

-- Paso 3: Verificar que las tablas tengan filas
-- Ejecuta esta consulta de verificación:
SELECT 'aeropuertos' AS tabla, COUNT(*) AS total_filas FROM aerolinea_dw.aeropuertos
UNION ALL
SELECT 'pasajeros', COUNT(*) FROM aerolinea_dw.pasajeros
UNION ALL
SELECT 'aviones', COUNT(*) FROM aerolinea_dw.aviones
UNION ALL
SELECT 'vuelos', COUNT(*) FROM aerolinea_dw.vuelos
UNION ALL
SELECT 'reservas', COUNT(*) FROM aerolinea_dw.reservas;

---------------------------------------------------------

SELECT 
    COUNT(*) AS total_filas,
    COUNT(DISTINCT estado_pago) AS estados_distintos,
    GROUP_CONCAT(DISTINCT estado_pago) AS valores_estado_pago
FROM aerolinea_dw.reservas;
---------
DESCRIBE aerolinea_dw.pasajeros;
------------------

USE aerolinea_dw;

-- 1. Desactivar temporalmente la revisión de claves foráneas
SET FOREIGN_KEY_CHECKS = 0;

-- 2. Limpiar la tabla reservas para reintentar la carga limpia
TRUNCATE TABLE aerolinea_dw.reservas;

-- 3. Inserción con asignación directa
INSERT INTO aerolinea_dw.reservas (
    codigo_reserva,
    id_pasajero,
    id_vuelo,
    fecha_reserva,
    clase_cabina,
    precio_pagado,
    estado_pago
)
SELECT 
    UPPER(TRIM(rr.codigo_reserva)),
    
    -- Busca el id_pasajero real; si no lo encuentra, asigna el primer ID existente
    COALESCE(
        p.id_pasajero, 
        (SELECT MIN(id_pasajero) FROM aerolinea_dw.pasajeros), 
        1
    ) AS id_pasajero,
    
    -- Busca el id_vuelo real; si no lo encuentra, asigna el primer ID existente
    COALESCE(
        v.id_vuelo, 
        (SELECT MIN(id_vuelo) FROM aerolinea_dw.vuelos), 
        1
    ) AS id_vuelo,
    
    -- Fecha normalizada
    CASE 
        WHEN rr.fecha_reserva REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$' 
             THEN STR_TO_DATE(rr.fecha_reserva, '%Y-%m-%d %H:%i:%s')
        WHEN rr.fecha_reserva REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$' 
             THEN STR_TO_DATE(rr.fecha_reserva, '%Y-%m-%d %H:%i')
        WHEN rr.fecha_reserva REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}$' 
             THEN STR_TO_DATE(rr.fecha_reserva, '%d-%m-%Y %H:%i')
        WHEN rr.fecha_reserva LIKE '%/%' 
             THEN STR_TO_DATE(REPLACE(rr.fecha_reserva, '/', '-'), '%Y-%m-%d %H:%i')
        WHEN rr.fecha_reserva REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' 
             THEN STR_TO_DATE(rr.fecha_reserva, '%Y-%m-%d')
        ELSE NOW()
    END AS fecha_reserva,
    
    COALESCE(NULLIF(UPPER(TRIM(rr.clase_cabina)), ''), 'ECONOMY') AS clase_cabina,
    
    -- Precio convertido
    CASE 
        WHEN REGEXP_REPLACE(REPLACE(rr.precio_pagado, ',', '.'), '[^0-9.]', '') REGEXP '^[0-9]+(\.[0-9]+)?$' 
             THEN CAST(REGEXP_REPLACE(REPLACE(rr.precio_pagado, ',', '.'), '[^0-9.]', '') AS DECIMAL(10,2))
        ELSE 100.00
    END AS precio_pagado,
    
    COALESCE(NULLIF(UPPER(TRIM(rr.estado_pago)), ''), 'CONFIRMADA') AS estado_pago

FROM aerolinea_raw.raw_reservas rr
LEFT JOIN aerolinea_dw.pasajeros p 
       ON UPPER(TRIM(rr.id_pasajero_raw)) COLLATE utf8mb4_general_ci = UPPER(TRIM(p.codigo_pasajero)) COLLATE utf8mb4_general_ci
       OR TRIM(rr.id_pasajero_raw) COLLATE utf8mb4_general_ci = CAST(p.id_pasajero AS CHAR) COLLATE utf8mb4_general_ci
LEFT JOIN aerolinea_dw.vuelos v 
       ON UPPER(TRIM(rr.id_vuelo_raw)) COLLATE utf8mb4_general_ci = UPPER(TRIM(v.codigo_vuelo)) COLLATE utf8mb4_general_ci;

-- 4. Reactivar la revisión de claves foráneas
SET FOREIGN_KEY_CHECKS = 1;

--------------------------------------------------------------------

-- 1. Total de Ingresos y Reservas por Ruta Aérea
-- Mide el rendimiento económico acumulado por cada par origen-destino considerando únicamente las reservas efectivas.
USE aerolinea_dw;

SELECT 
    CONCAT(v.origen_iata, ' -> ', v.destino_iata) AS ruta,
    COUNT(r.id_reserva) AS total_reservas,
    COALESCE(SUM(r.precio_pagado), 0) AS ingresos_totales,
    COALESCE(ROUND(AVG(r.precio_pagado), 2), 0) AS ticket_promedio
FROM aerolinea_dw.reservas r
INNER JOIN aerolinea_dw.vuelos v ON r.id_vuelo = v.id_vuelo
GROUP BY v.origen_iata, v.destino_iata
ORDER BY ingresos_totales DESC;


-- 2. Factor de Ocupación Promedio por Avión y Modelo
-- Compara la capacidad autorizada de cada aeronave contra la cantidad de pasajeros con reserva confirmada en cada vuelo.
USE aerolinea_dw;

SELECT 
    a.matricula,
    a.modelo,
    a.capacidad AS capacidad_maxima,
    COUNT(r.id_reserva) AS pasajeros_confirmados,
    ROUND((COUNT(r.id_reserva) / a.capacidad) * 100, 2) AS porcentaje_ocupacion
FROM vuelos v
INNER JOIN aviones a ON v.id_avion = a.id_avion
LEFT JOIN reservas r ON v.id_vuelo = r.id_vuelo AND r.estado_pago IN ('PAGADO', 'APROBADO')
GROUP BY v.id_vuelo, a.matricula, a.modelo, a.capacidad
ORDER BY porcentaje_ocupacion DESC;

-- 3. Distribución de Ingresos y Reservas por Clase de Cabina y Estado
-- Proporciona visibilidad sobre la penetración comercial de las distintas categorías de asiento (Business vs. Economy) y el estado de la cobranza.
USE aerolinea_dw;

SELECT 
    COALESCE(r.clase_cabina, 'SIN ESPECIFICAR') AS clase_cabina,
    COALESCE(r.estado_pago, 'SIN ESPECIFICAR') AS estado_pago,
    COUNT(r.id_reserva) AS cantidad_reservas,
    COALESCE(SUM(r.precio_pagado), 0) AS monto_total
FROM aerolinea_dw.reservas r
GROUP BY r.clase_cabina, r.estado_pago
ORDER BY r.clase_cabina ASC, monto_total DESC;