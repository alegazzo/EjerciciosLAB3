Use BluePrint


--	1
--	Listado de todos los clientes.
Select * from Clientes
--	2
--	Listado de todos los proyectos.
Select * from Proyectos
--	3
--	Listado con nombre, descripci�n, costo, fecha de inicio y de fin de todos los proyectos.
Select Nombre, Descripcion, CostoEstimado, FechaInicio, FechaFin From Proyectos
--	4
--	Listado con nombre, descripci�n, costo y fecha de inicio de todos los proyectos con costo mayor a cien mil pesos.
Select Nombre, Descripcion, CostoEstimado, FechaInicio From Proyectos
Where CostoEstimado > 100000
--	5
--	Listado con nombre, descripci�n, costo y fecha de inicio de todos los proyectos con costo menor a cincuenta mil pesos .
Select Nombre, Descripcion, CostoEstimado, FechaInicio From Proyectos
Where CostoEstimado < 50000
--	6
--	Listado con todos los datos de todos los proyectos que comiencen en el a�o 2020.
Select * from Proyectos
Where year(FechaInicio)=2020
--	7
--	Listado con nombre, descripci�n y costo de los proyectos que comiencen en el a�o 2020 y cuesten m�s de cien mil pesos.
Select Nombre, Descripcion, CostoEstimado from Proyectos
Where year(FechaInicio)=2020 and CostoEstimado > 100000
--	8
--	Listado con nombre del proyecto, costo y a�o de inicio del proyecto.
Select Nombre, CostoEstimado, year(FechaInicio) as anio from Proyectos
--	9
--	Listado con nombre del proyecto, costo, fecha de inicio, fecha de fin y d�as de duraci�n de los proyectos.
Select Nombre, CostoEstimado, FechaInicio, FechaFin, DATEDIFF(day, FechaInicio, FechaFin) as Dias from Proyectos
--	10	
--	Listado con raz�n social, cuit y tel�fono de todos los clientes cuyo IDTipo sea 1, 3, 5 o 6
Select  RazonSocial, CUIT, Telefono from Clientes 
Where IDTipo IN (1,3,5,6)
--	11
--	Listado con nombre del proyecto, costo, fecha de inicio y fin de todos los proyectos que no pertenezcan a los clientes 1, 5 ni 10.
Select Nombre, CostoEstimado, FechaInicio, FechaFin from Proyectos
Where IDCliente not in(1,5,10)
--	12
--	Listado con nombre del proyecto, costo y descripci�n de aquellos proyectos que hayan comenzado entre el 1/1/2018 y el 24/6/2018.
SET DATEFORMAT 'DMY'
Select Nombre, CostoEstimado, Descripcion from Proyectos
Where FechaInicio between '1/1/2018' and '24/6/2018'
--	13
--	Listado con nombre del proyecto, costo y descripci�n de aquellos proyectos que hayan finalizado entre el 1/1/2019 y el 12/12/2019.
SET DATEFORMAT 'DMY'
Select Nombre, CostoEstimado, Descripcion from Proyectos
Where FechaFin between '1/1/2019' and '12/12/2019'
--	14
--	Listado con nombre de proyecto y descripci�n de aquellos proyectos que a�n no hayan finalizado.
Select Nombre, Descripcion from Proyectos where FechaFin is null
--	15
--	Listado con nombre de proyecto y descripci�n de aquellos proyectos que a�n no hayan comenzado.
Select Nombre, Descripcion from Proyectos where FechaInicio>getdate() or FechaInicio is null
--	16
--	Listado de clientes cuya raz�n social comience con letra vocal.
Select * from Clientes where RazonSocial Like '[aeiou]%'
--	17
--	Listado de clientes cuya raz�n social finalice con vocal.
Select * from Clientes where RazonSocial Like '%[aeiou]'
--	18
--	Listado de clientes cuya raz�n social finalice con la palabra 'Inc'
Select * from Clientes where RazonSocial Like '%inc'
--	19
--	Listado de clientes cuya raz�n social no finalice con vocal.
Select * from Clientes where RazonSocial Like '%[^aeiou]'
--	20
--	Listado de clientes cuya raz�n social no contenga espacios.
Select * from Clientes where RazonSocial not Like '% %'
--	21
--	Listado de clientes cuya raz�n social contenga m�s de un espacio.
Select * from Clientes where RazonSocial Like '% % %'
--	22
--	Listado de raz�n social, cuit, email y celular de aquellos clientes que tengan mail pero no tel�fono.
Select RazonSocial, CUIT, EMail, Celular FROM Clientes where EMail is not null and Telefono is null
--	23
--	Listado de raz�n social, cuit, email y celular de aquellos clientes que no tengan mail pero s� tel�fono.
Select RazonSocial, CUIT, EMail, Celular FROM Clientes where EMail is null and Telefono is not null
--	24
--	Listado de raz�n social, cuit, email, tel�fono o celular de aquellos clientes que tengan mail o tel�fono o celular .
Select RazonSocial, CUIT, EMail, Telefono, Celular FROM Clientes where EMail is not null or Telefono is not null or Celular is not null
--	25
--	Listado de raz�n social, cuit y mail. Si no dispone de mail debe aparecer el texto "Sin mail".
Select RazonSocial, CUIT, 
case
when EMail is null then 'Sin mail'
else EMail end as 'EMail' from Clientes
--	26
--	Listado de raz�n social, cuit y una columna llamada Contacto con el mail, si no posee mail, con el n�mero de celular, si no posee n�mero de celular con el n�mero de tel�fono, de lo contrario un texto que diga "Incontactable".

-- opcion 1

Select RazonSocial, CUIT,
case
when EMail is null and Celular is null and Telefono is null then 'Incontactable'
when Email is not null then Email
when Celular is not null then Celular
when Telefono is not null then Telefono
end as 'Contacto' from Clientes 

--opcion 2
Select RazonSocial, CUIT, isnull(email,isnull(celular,isnull(telefono, 'incontactable'))) as Contacto from clientes

--opcion 3
Select RazonSocial, Cuit, Coalesce(email, celular, telefono, 'incontactable') as Contacto from Clientes


--	27
--	Listado de raz�n social, cuit y una columna llamada Contacto con el mail, si no posee mail, con el n�mero de celular y si no posee n�mero de celular con un texto que diga "Incontactable".
Select RazonSocial, Cuit, coalesce(email,celular,'incontactable') as Contacto from Clientes
