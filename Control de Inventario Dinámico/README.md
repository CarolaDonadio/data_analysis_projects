# 📊 Sistema de Control de Stock Dinámico en Excel

Un modelo relacional y automatizado en Microsoft Excel diseñado para simplificar y optimizar la gestión de inventarios, reduciendo errores manuales y calculando existencias en tiempo real.

---

## 📌 Descripción del Proyecto

El **Sistema de Control de Stock Dinámico** es una solución desarrollada para pequeñas y medianas gestiones que requieren un seguimiento preciso de entradas y salidas de mercancía. 

A través de la interacción entre tablas estructuradas y fórmulas avanzadas, el sistema automatiza el registro de operaciones y mantiene actualizado el estado del inventario sin necesidad de recurrir a macros complejas (VBA).

---

## 🛠️ Funcionalidades Principales

* **Registro Único de Movimientos:** Captura centralizada de compras (*Entradas*) y ventas (*Salidas*) asociadas a referencias o comprobantes.
* **Autocompletado de Datos:** Búsqueda automática del nombre del producto al ingresar su ID para evitar inconsistencias de tipeo.
* **Cálculo Automático de Inventario:** Consolidación instantánea del total ingresado, egresado y disponible (*Stock Actual*).
* **Gestión de Umbrales de Alerta:** Control del stock mínimo necesario por cada producto para evitar quiebres de inventario.

---

## 📐 Estructura del Libro de Trabajo

El archivo consta de dos pestañas principales estructuradas como Tablas Oficiales de Excel (`tStock` y `tMovimientos`):

### 1. Pestaña `Stock`
Funciona como el maestro de productos y matriz de control centralizado.

| Columna | Descripción / Tipo de Dato |
| :--- | :--- |
| `IdProducto` | Identificador único del producto (Clave primaria). |
| `Nombre` | Descripción o nombre del artículo. |
| `Alerta` | Cantidad mínima sugerida en almacén. |
| `Entradas` | Suma calculada automáticamente de todas las compras. |
| `Salidas` | Suma calculada automáticamente de todas las ventas. |
| `Stock Actual` | Saldo disponible (*Entradas − Salidas*). |

### 2. Pestaña `Movimientos`
Bitácora donde se registran las transacciones diarias.

| Columna | Descripción / Tipo de Dato |
| :--- | :--- |
| `Referencia` | Código de factura, remito o comprobante. |
| `Fecha` | Fecha de la operación. |
| `Producto` | ID del producto involucrado. |
| `Nombre` | Nombre traído automáticamente desde la pestaña `Stock`. |
| `Movimiento` | Categoría de la transacción (*Entrada* / *Salida*). |
| `Cantidad` | Unidades operadas. |

---

## 🧠 Fórmulas y Lógica Aplicada

Para lograr el dinamismo del sistema se emplearon las siguientes funciones y técnicas:

* **`BUSCARX` / `XLOOKUP` + `SI.ERROR` / `IFERROR`:**  
  Trae el nombre del producto desde `tStock` a `tMovimientos` de forma ágil y maneja celdas vacías sin mostrar errores `#N/A`.
  ```
  =SI.ERROR(BUSCARX(tMovimientos[[#Esta fila],[Producto]], tStock[IdProducto], tStock[Nombre]), "-")
´´´

* **`=SUMAR.SI.CONJUNTO` / `SUMIFS`:**
Consolida el total acumulado de Entradas y Salidas en la tabla de Stock filtrando por tipo de movimiento e ID de producto.
```
  =SUMAR.SI.CONJUNTO(tMovimientos[Cantidad], tMovimientos[Movimiento], "Entrada", tMovimientos[Producto], tStock[[#Esta fila],[IdProducto]])
```

* **Referencias Estructuradas de Tablas:**

El uso de sintaxis de tabla nativa de Excel garantiza que al agregar nuevos productos o registrar nuevos movimientos, las fórmulas se expandan automáticamente sin necesidad de reconfigurar rangos.

👤 Autora
  * Carola Donadio
    * Estudiante de la Tecnicatura Superior en Ciencia de Datos e IA (Instituto N°57).
    * Apasionada por el análisis de datos, desarrollo de modelos operativos y Business Intelligence.
    * **GitHub:** [github.com/CarolaDonadio](https://github.com/CarolaDonadio)
    * **LinkedIn:** [linkedin.com/in/caroladonadio](https://www.linkedin.com/in/caroladonadio)
