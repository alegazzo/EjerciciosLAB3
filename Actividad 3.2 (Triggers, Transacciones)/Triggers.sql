--#
--Ejercicio 3.2
USE BluePrint

--1
--Hacer un trigger que al ingresar una colaboración obtenga el precio de la misma a partir del precio hora base del tipo de tarea. Tener en cuenta que si el colaborador es externo el costo debe ser un 20% más caro.
GO
CREATE TRIGGER TR_EJ1 ON Colaboraciones
AFTER INSERT AS
BEGIN
	/*DECLARAR LAS VARIABLES */
	DECLARE @IDCOLAB INT
	DECLARE @IDTAREA INT
	DECLARE @PRECIO MONEY
	DECLARE @TIPO CHAR
	SELECT @IDCOLAB= IDColaborador,@IDTAREA= IDTarea FROM inserted 
    /* OBTENER EL PRECIO BASE DE TIPOS TAREAS*/
	SELECT @PRECIO = TT.PrecioHoraBase FROM TiposTarea TT 
	INNER JOIN TAREAS T ON T.IDTipo=TT.ID
	WHERE T.ID = @IDTAREA
	/*OBTENER EL TIPO DE COLABORADOR */
	SELECT @TIPO=C.Tipo FROM Colaboradores C WHERE C.ID=@IDCOLAB
	/* AUMENTAR EN 20% SI EL COLABORADOR ES EXTERNO*/
	IF    @TIPO LIKE 'E'
		BEGIN
			SET @PRECIO= @PRECIO * 1.20
		END
	/*HACER EL UPDATE DEL PRECIO EN COLABORACIONES */
	UPDATE Colaboraciones SET PrecioHora=@PRECIO WHERE IDColaborador=@IDCOLAB AND IDTarea=@IDTAREA
END



--2
--Hacer un trigger que no permita que un colaborador registre más de 15 tareas en un mismo mes. De lo contrario generar un error con un mensaje aclaratorio.
GO
CREATE TRIGGER TR_EJ2 ON Colaboraciones
INSTEAD OF INSERT AS
BEGIN
	
	DECLARE @IDCOLABORADOR INT
	DECLARE @IDTAREA INT
	DECLARE @FECHATAREA DATE
	DECLARE @CANT_TAREAS INT
	DECLARE @TIEMPO SMALLINT
	DECLARE @PRECIOHORA MONEY
	  
	SELECT @IDTAREA=IDTarea, @IDCOLABORADOR=IDColaborador,@TIEMPO=Tiempo,@PRECIOHORA=PrecioHora FROM inserted

	/*OBTENER LA FECHA DE ESA TAREA */

	SELECT @FECHATAREA= T.FechaInicio FROM Tareas T WHERE ID=@IDTAREA

	/*CANTIDA DE TAREAS EN ESE MES */
	SELECT @CANT_TAREAS=COUNT(C.IDColaborador) FROM Colaboraciones C
	INNER JOIN Tareas T ON T.ID=C.IDTarea
	WHERE IDColaborador=@IDCOLABORADOR AND MONTH(T.FechaInicio)=MONTH(@FECHATAREA) AND YEAR(T.FechaInicio)= YEAR(@FECHATAREA)

	/*SE REGISTRA SOLO SI TIENE MENOS DE 15 */
	IF @CANT_TAREAS<15
		BEGIN

			INSERT INTO Colaboraciones VALUES(@IDTAREA,@IDCOLABORADOR,@TIEMPO,@PRECIOHORA,1)
		END
	ELSE 
		BEGIN
		/*SINO, SE LANZA EL ERROR */
			RAISERROR('ESTE COLABORADOR YA POSEE 15 TAREAS EN ESTE MES',16,1)

		END
END

--3
--Hacer un trigger que al ingresar una tarea cuyo tipo contenga el nombre 'Programación' se agreguen automáticamente dos tareas de tipo 'Testing unitario' y 'Testing de integración' de 4 horas cada una. La fecha de inicio y fin de las mismas debe ser NULL. Calcular el costo estimado de la tarea.
GO
CREATE TRIGGER TR_EJ3 ON TAREAS
AFTER INSERT AS
BEGIN
	DECLARE @IDMODULO INT
	DECLARE @IDTIPOTAREA INT
	DECLARE @TIPOTAREA VARCHAR
	SELECT @IDTIPOTAREA=IDTipo, @IDMODULO=IDModulo FROM inserted
	/*OBTENGO EL TIPO DE TAREA */
	SELECT @TIPOTAREA=Nombre FROM TiposTarea WHERE ID=@IDTIPOTAREA

	/*SI EL TIPO DE TAREA ES PROGRAMACION AGREGO LAS 2 TAREAS EXTRAS */
	IF @TIPOTAREA LIKE '%Programacion%'
		BEGIN

			/*OBTENGO EL ID DE LOS TIPOS DE TAREA DE TESTING UNITARIO Y DE TESTING DE INTEGRACION */
			DECLARE @IDUNITARIO INT
			DECLARE @IDINTEGRACION INT
			SELECT @IDUNITARIO=ID FROM TiposTarea WHERE Nombre LIKE 'Testing unitario'
			SELECT @IDUNITARIO=ID FROM TiposTarea WHERE Nombre LIKE 'Testing de integración'
			INSERT INTO Tareas VALUES(@IDMODULO,@IDUNITARIO,NULL,NULL,1)
			INSERT INTO Tareas VALUES(@IDMODULO,@IDINTEGRACION,NULL,NULL,1)

		END
END

--4
--Hacer un trigger que al borrar una tarea realice una baja lógica de la misma en lugar de una baja física.
GO
CREATE TRIGGER TR_EJ4 ON TAREAS
INSTEAD OF DELETE AS
BEGIN
/*DECLARAR LAS VARIABLES */

/*DECLARE @IDTAREA INT
SELECT @IDTAREA=ID FROM deleted
UPDATE Tareas SET Estado=0 WHERE ID=@IDTAREA
*/

/* FORMA DE HACERLO SI SE RECIBE MAS DE 1 IDTAREA*/
UPDATE Tareas SET Estado=0 WHERE ID IN (SELECT ID FROM inserted)

END
--5
--Hacer un trigger que al borrar un módulo realice una baja lógica del mismo en lugar de una baja física. Además, debe borrar todas las tareas asociadas al módulo.
GO
CREATE TRIGGER TR_EJ5 ON MODULOS
INSTEAD OF DELETE AS
BEGIN
	/*DECLARAR LAS VARIABLES */

	DECLARE @ID INT
	SELECT @ID=ID FROM deleted
	/*BAJA LOGICA DEL MODULO */
	UPDATE Modulos SET Estado=0 WHERE ID=@ID

	/*ELIMINO LAS TAREAS CON ESE IDMODULO */
	DELETE FROM Tareas  WHERE ID=@ID
END
--6
--Hacer un trigger que al borrar un proyecto realice una baja lógica del mismo en lugar de una baja física. Además, debe borrar todas los módulos asociados al proyecto.
GO
CREATE TRIGGER TR_EJ6 ON Proyectos
AFTER DELETE AS
BEGIN
	DECLARE @IDPROYECTO VARCHAR(5)
	SELECT @IDPROYECTO=ID FROM deleted

	/*BAJA LOGICA DEL PROYECTO AL QUE SE LE HIZO DELETE */
	UPDATE Proyectos SET Estado=0 WHERE ID=@IDPROYECTO

	/*BORRAR TODOS LOS MODULOS ASOCIADOS AL PROYECTO */

	DELETE  FROM Modulos WHERE IDProyecto=@IDPROYECTO

END


--7
--Hacer un trigger que si se agrega una tarea cuya fecha de fin es mayor a la fecha estimada de fin del módulo asociado a la tarea entonces se modifique la fecha estimada de fin en el módulo.
GO
CREATE TRIGGER TR_EJ7 ON Tareas
AFTER INSERT AS
BEGIN
	DECLARE @IDMODULO INT
	DECLARE @FECHATAREA DATE
	DECLARE @FECHAMODULO DATE
	SELECT @IDMODULO=ID, @FECHATAREA=FechaFin FROM inserted

	/*OBTENER LA FECHA DEL MODULO ASOCIADO A LA TAREA */
	SELECT @FECHAMODULO=FechaEstimadaFin FROM Modulos WHERE ID=@IDMODULO

	/*SI LA FECHA DE LA TAREA INSERTADA ES MAYOR A LA DEL MODULO SE ACTUALIZA LA FECHAESTIMADA DEL MODULO */
	IF @FECHATAREA>@FECHAMODULO
		BEGIN

			UPDATE Modulos SET FechaEstimadaFin=@FECHATAREA WHERE ID=@IDMODULO
		END
END



--8
--Hacer un trigger que al borrar una tarea que previamente se ha dado de baja lógica realice la baja física de la misma.
GO
CREATE TRIGGER TR_EJ8 ON TAREAS
INSTEAD OF DELETE AS
BEGIN
	DECLARE @IDTAREA INT
	DECLARE @ESTADO BIT
	SELECT @IDTAREA=ID, @ESTADO=Estado FROM deleted
	IF @ESTADO = 1
		BEGIN
			UPDATE Tareas SET Estado=0 WHERE ID=@IDTAREA
		END
		ELSE BEGIN
			DELETE Tareas WHERE ID=@IDTAREA
		END
END

--9
--Hacer un trigger que al ingresar una colaboración no permita que el colaborador/a superponga las fechas con las de otras colaboraciones que se les hayan asignado anteriormente. En caso contrario, registrar la colaboración sino generar un error con un mensaje aclaratorio.
GO
CREATE TRIGGER TR_EJ9 ON Colaboraciones
INSTEAD OF INSERT AS
BEGIN
	DECLARE @IDCOLAB INT
	DECLARE @IDTAREA INT
	DECLARE @TIEMPO SMALLINT
	DECLARE @PRECIO MONEY
	DECLARE @FECHAINICIO DATE
	DECLARE @COUNT INT

	SELECT @IDCOLAB=IDColaborador, @IDTAREA=IDTarea, @TIEMPO=Tiempo, @PRECIO=PrecioHora FROM inserted
	/*OBTENER LA FECHA DE ESA COLABORACION  */
	SELECT  @FECHAINICIO=FechaInicio FROM Tareas
	WHERE ID=@IDTAREA

	/*OBTENER TODAS LAS COLABORACIONES DEL COLABORADOR PARA COMPARAR LAS FECHAS */

	SELECT @COUNT=COUNT(IDColaborador) FROM Tareas T
	INNER JOIN Colaboraciones C ON C.IDTarea=T.ID
	WHERE C.IDColaborador=@IDCOLAB AND @FECHAINICIO BETWEEN T.FechaInicio AND T.FechaFin
	/*SI COUNT ES 1 O MAS NO SE DEBE REGISTRAR, SINO SI  */
	IF @COUNT >0
		BEGIN
			RAISERROR('SE SUPERPONE LAS FECHAS DE LA COLABORACION',16,1)
		END
	INSERT INTO Colaboraciones VALUES(@IDTAREA,@IDCOLAB,@TIEMPO,@PRECIO,1)
END

--10
--Hacer un trigger que al modificar el precio hora base de un tipo de tarea registre en una tabla llamada HistorialPreciosTiposTarea el ID, el precio antes de modificarse y la fecha de modificación.

--NOTA: La tabla debe estar creada previamente. NO crearla dentro del trigger.




