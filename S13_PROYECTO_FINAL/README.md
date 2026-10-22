# Clientes con nombre propio: segmentar para conquistar

**Del cliente esporádico al cliente fiel. Retención y segmentación en un e-commerce de venta flash de viajes.**

Proyecto final del **Bootcamp de Analítica de Datos**. Analiza la recurrencia de compra de un e-commerce de venta flash de viajes (2021-2025) para responder a una pregunta de negocio: **¿qué clientes tienen mayor potencial de convertirse en recurrentes y qué acciones pueden aumentar su frecuencia de compra?**

El proyecto recorre un flujo completo: exploración de datos y cohortes en Python, segmentación RFM y K-Means,  modelo de datos y dashboard en Power BI, informe en PDF y presentación de defensa.

---

## Pipeline del proyecto

1. **Exploración y validación (EDA):** revisión de nulos, duplicados y valores atípicos, y descripción de la frecuencia de compra.
2. **Análisis de cohortes:** retención mensual por mes de primera compra.).
3. **RFM por quintiles:** puntuación de recencia, frecuencia y valor monetario, que da 5 segmentos de viajeros.
4. **K-Means sin estandarizar (k = 5):** para comprobar que el valor monetario domina sobre las otras dos variables.
5. **K-Means estandarizado (k = 5):** con `StandardScaler`, para que las tres variables pesen igual.
6. **Elección de k:** método del codo y coeficiente de silueta (k de 2 a 8). Se elige **k = 4**.
7. **Ventana de 18 meses:** se mide la segunda compra solo en clientes con al menos 18 meses de antigüedad (clientes elegibles), para evitar la censura por la derecha.
8. **Contrastes sobre el descuento:** se mide el porcentaje por tramo de descuento en las reservas
9. **Plan de acción y escenario:** acciones por grupo y estimación del ingreso potencial.
10. **Dashboard en Power BI**, informe en PDF y presentación de defensa.

> Se descartó una fase de regresión logística para predecir la recurrencia: los contrastes mostraron que el descuento y el perfil de la primera compra no distinguen a quienes repiten, así que no había señal que predecir con esas variables.

---

## Dashboard de Power BI 

| Pág. | Título | Contenido |
| --- | --- | --- |
| 1 | ¿Quién es mi competencia en la venta flash? | Facturación, cuota de mercado, ticket y recurrencia de 4 competidores (datos públicos estimados) |
| 2 | ¿Cómo y cuándo viajan los españoles? | Datos del INE: auge del extranjero, ranking de destinos, estacionalidad |
| 3 | ¿Quién es mi cliente? | Perfil sociodemográfico: destino, edad, sexo, ámbito, categoría de viaje y origen |
| 4 | ¿Qué reserva mi cliente? | Perfil de reservas: descuento, estancia, tipo de grupo |
| 5 | Conocer al cliente | 6 tarjetas y 4 gráficos: frecuencia, retención, ventana de 18 meses, clientes frente a ventas |
| 6 | RFM: 5 tipos de viajeros | Segmentos RFM y dispersiones |
| 7 | ¿Por qué estandarizar los datos? | K-Means sin estandarizar frente a estandarizado |
| 8 | K-Means: 4 grupos de clientes | Codo, silueta, peso por grupo, perfil y matriz RFM a K-Means |
| 9 | Descuento y ventana de 18 meses | Recompra por tramo de descuento y captación por ventana |
| 10 | ¿En qué clientes invertir esfuerzo? | Clientes en ventana, escenario What-if y acciones por grupo |


---

## Datasets generados para Power BI

Archivos CSV con separador `;`, coma decimal y codificación UTF-8 con BOM, generados a partir del notebook.

| Archivo | Contenido |
| --- | --- |
| `RFM.csv` | Una fila por cliente: recencia, frecuencia, valor monetario, puntuaciones, segmento RFM, clusters (k = 5 y k = 4) y nombre del grupo |
| `RFM_estandarizado.csv` | Una fila por cliente: recencia, frecuencia, valor monetario, puntuaciones, segmento RFM a escala, valores estandarizados, clusters (k = 5 y k = 4) y nombre del grupo |
| `primera_compra.csv` | Fecha de primera y segunda compra, si repite, días hasta la 2.ª compra, elegibilidad a 18 meses, descuento y tramo de la primera compra |
| `cohortes.csv` | Clientes activos y tamaño de cada cohorte por mes desde la primera compra |
| `tabla_frecuencia.csv` | Clientes por número de compras |
| `tabla_segmentos.csv` | Perfil medio de los 5 segmentos RFM |
| `tabla_segmentos_finales.csv` | Perfil medio de los 4 grupos K-Means |
| `tabla_tramos_pct.csv` | % que repite en 18 meses por tramo de descuento |

---

## Estructura sugerida del repositorio

```text
Proyecto final/
├── CÓDIGO PY/            # Creación del dataset, Notebook de EDA, segmentación y clustering (.ipynb)
├── CONJUNTO DE DATOS SINTÉTICOS /      # CSV generados con python
├── DATOS_INE /           # CVS extraidos del Instituto Nacional de Estadística
├── ENTREGAS/          # Informe, Fichero de Power BI  y presentación (PDF)
├── TABLAS EXTRAIDAS DE PYTHON /    # CSV de ayuda para modelado de datos en PowerBI
└── README.md
```

---

*Autora: Silvia Vilches · Bootcamp de Analítica de Datos (2026)*
