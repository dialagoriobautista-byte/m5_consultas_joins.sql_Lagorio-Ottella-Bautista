use Ventas_Tech_DB

---Consulta 1 — Vista base del proyecto (INNER JOIN)

SELECT v.Fecha_venta,
	   c.Nombre,
	   c.Ciudad,
	   v.Cantidad,
	   p.Nombre_Producto,
	   v.Precio_Unitario,
	   ca.Nombre_Categoria,
	   v.Cantidad * v.Precio_Unitario AS Total_Venta
FROM Ventas v
INNER JOIN Clientes c on v.ID_Cliente = c.ID_Cliente
INNER JOIN Productos p on v.ID_Producto = p.ID_Producto
INNER JOIN Categorias ca on p.ID_Categoria = ca.ID_Categoria;

--Hallazgos--> la categoría "computación" concentra casi el 77% de la facturación de las ventas. Aunque "accesorios" vende más unidades (17vs6)

--Consulta 2 — Clientes sin ventas (LEFT JOIN)

SELECT c.Nombre,
	   c.Email,
	   c.Fecha_Registro,
	   c.Ciudad
FROM Clientes c
LEFT JOIN Ventas v on c.ID_Cliente = v.ID_Cliente
WHERE v.ID_Cliente is null;

--Hallazgos-->	la consulta no devolvió registros eso significa los 5 clientes registrados compraron al menos una vez (y todos repitieron compra). 
--CRM no necesita campañas de primera compra, conviene enfocarse en retener a estos clientes.

--Consulta 3 — Productos sin ventas (LEFT JOIN)

SELECT	p.Nombre_Producto,
		p.Precio,
		ca.Nombre_Categoria
FROM Productos p
LEFT JOIN Ventas v on p.ID_Producto = v.ID_Producto
INNER JOIN Categorias ca on p.ID_Categoria = ca.ID_Categoria
WHERE v.ID_Producto is null;

--Hallazgo-->los 6 productos del catálogo registran ventas, no hay stock inmovilizado.
-- El producto que se debería priorizar sería Computación (76,8% de la facturación) y asegurar reposición de Accesorios, que concentra 17 de las 29 unidades vendidas.

--Consulta 4 — Consolidado por canal (UNION ALL): el canal es simulado (ventas impares = Online, pares = Presencial).

SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT Fecha_Venta,
           Cantidad * Precio_Unitario AS total,
           'Online' AS canal
    FROM Ventas WHERE ID_Venta % 2 = 1
    UNION ALL
    SELECT Fecha_Venta,
           Cantidad * Precio_Unitario AS total,
           'Presencial' AS canal
    FROM Ventas WHERE ID_Venta % 2 = 0
) AS consolidado
GROUP BY canal;

--Hallazgos--> el canal Online factura 4.560 (70,8%) contra 1.884 del Presencial, con la misma cantidad de ventas (5 cada uno): el ticket Online es más del doble.