--#
--Ejercicio



--1
--Hacer un reporte que liste por cada tipo de tarea se liste el nombre, el precio de hora base y el promedio de valor hora real (obtenido de las colaboraciones).

CREATE VIEW vw_ej1 as
select TT.Nombre,
TT.PrecioHoraBase,
(
select AVG(c.PrecioHora) from Colaboraciones C
inner join Tareas T on T.ID=C.IDTarea
where T.ID = TT.ID
) AS PromedioValorHoraReal 
from TiposTarea  TT

select * from vw_ej1
--2
--Modificar el reporte de (1) para que también liste una columna llamada Variación con las siguientes reglas:
--Poca ? Si la diferencia entre el promedio y el precio de hora base es menor a $500.
--Mediana ? Si la diferencia entre el promedio y el precio de hora base está entre $501 y $999.
--Alta ? Si la diferencia entre el promedio y el precio de hora base es $1000 o más.
ALTER VIEW vw_ej1 as
select aux.*, 
CASE
    when (aux.PromedioValorHoraReal-aux.PrecioHoraBase) <500 then 'Poca'
	when (aux.PromedioValorHoraReal-aux.PrecioHoraBase) >500 and (aux.PromedioValorHoraReal-aux.PrecioHoraBase)<1000 then 'Mediana'
	when (aux.PromedioValorHoraReal-aux.PrecioHoraBase) >=1000 then 'Alta'
END as Dif
from
(
select TT.Nombre,TT.PrecioHoraBase,
(
select AVG(c.PrecioHora) from Colaboraciones C
inner join Tareas T on T.ID=C.IDTarea
where T.ID = TT.ID
) AS PromedioValorHoraReal
from TiposTarea  TT) as aux

select * from vw_ej1
--3
--Crear un procedimiento almacenado que liste las colaboraciones de un colaborador cuyo ID se envía como parámetro.
CREATE PROCEDURE SP_EJ3(
@IDCOLAB INT
)AS
BEGIN
SELECT * FROM Colaboraciones WHERE IDColaborador=@IDCOLAB AND Estado=1
END

EXEC SP_EJ3 2  
--4
--Hacer una vista que liste por cada colaborador el apellido y nombre, el nombre del tipo (Interno o Externo) y la cantidad de proyectos distintos en los que haya trabajado.
--Opcional: Hacer una aplicación en C# (consola, escritorio o web) que consuma la vista y la muestre por pantalla.
CREATE VIEW VW_EJ4 AS
SELECT C.Apellido+','+C.Nombre as ApellidoNombre,
CASE 
	WHEN C.Tipo LIKE 'E' THEN 'Externo'
	WHEN C.Tipo LIKE 'I' THEN 'Interno'
END as Tipo,
(SELECT DISTINCT COUNT(*) FROM Proyectos P
INNER JOIN Modulos M ON M.IDProyecto=P.ID
INNER JOIN Tareas T ON T.IDModulo=M.ID
INNER JOIN Colaboraciones CO ON CO.IDTarea=T.ID
WHERE CO.IDColaborador=C.ID)AS CantProyectos

FROM Colaboradores C

SELECT * FROM VW_EJ4
--5
--Hacer un procedimiento almacenado que reciba dos fechas como parámetro y liste todos los datos de los proyectos que se encuentren entre esas fechas.

CREATE PROCEDURE SP_EJ5(
@FECHA1 DATE,
@FECHA2 DATE
) AS
SELECT * FROM Proyectos P WHERE P.FechaInicio BETWEEN  @FECHA1 AND @FECHA2
GO
EXEC SP_EJ5 '2020-5-5', '2021-6-6'


--6
--Hacer un procedimiento almacenado que reciba un ID de Cliente, un ID de Tipo de contacto y un valor y modifique los datos de contacto de dicho cliente. El ID de Tipo de contacto puede ser: 1 - Email, 2 - Teléfono y 3 - Celular.
CREATE PROCEDURE SP_EJ6(
@IDCLIENTE INT,
@IDTIPOCONTACTO INT,
@VALOR VARCHAR(20)
)AS 
BEGIN
	
		IF (@IDTIPOCONTACTO = 1) BEGIN UPDATE Clientes SET	EMail=@VALOR WHERE ID=@IDCLIENTE END
		IF (@IDTIPOCONTACTO = 2) BEGIN UPDATE Clientes SET	Telefono=@VALOR WHERE ID=@IDCLIENTE END
		IF (@IDTIPOCONTACTO = 3) BEGIN UPDATE Clientes SET	Celular=@VALOR WHERE ID=@IDCLIENTE END

END

EXEC SP_EJ6 1,1,'GAZZOALE@GMAIL.COM'
SELECT * FROM Clientes WHERE ID=1
--7
--Hacer un procedimiento almacenado que reciba un ID de Módulo y realice la baja lógica tanto del módulo como de todas sus tareas futuras. Utilizar una transacción para realizar el proceso de manera atómica.

ALTER PROCEDURE SP_EJ7(
@IDMODULO INT
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		UPDATE Modulos SET Estado=0 WHERE ID=@IDMODULO
		UPDATE Tareas SET Estado=0 WHERE IDModulo=@IDMODULO 

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RAISERROR('NO SE PUDO REALIZAR LA ACCION',16,1)
	END CATCH

END


SELECT * FROM Tareas 
SELECT * FROM Modulos


EXEC SP_EJ7 39