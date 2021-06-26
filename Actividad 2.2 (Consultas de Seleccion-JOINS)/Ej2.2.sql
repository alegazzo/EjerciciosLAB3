use BluePrint


--1
--Por cada cliente listar razón social, cuit y nombre del tipo de cliente.
select C.RazonSocial, C.CUIT, T.Nombre from Clientes as C
inner join TiposCliente as T On C.IDTipo=T.ID
--2
--Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del país. Sólo de aquellos clientes que posean ciudad y país.
select C.RazonSocial, C.Cuit, P.Nombre as Pais, Ci.Nombre as Ciudad  from Clientes as C
inner join Ciudades as Ci ON C.IDCiudad = Ci.ID
inner join Paises as P ON Ci.IDPais = P.ID
--3
--Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del país. Listar también los datos de aquellos clientes que no tengan ciudad relacionada.
select C.RazonSocial, C.Cuit, P.Nombre as Pais, Ci.Nombre as Ciudad  from Clientes as C
left join Ciudades as Ci ON C.IDCiudad = Ci.ID
left join Paises as P ON Ci.IDPais = P.ID
--4
--Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del país. Listar también los datos de aquellas ciudades y países que no tengan clientes relacionados.
select C.RazonSocial, C.Cuit, P.Nombre as Pais, Ci.Nombre as Ciudad  from Clientes as C
right join Ciudades as Ci ON C.IDCiudad = Ci.ID
right join Paises as P ON Ci.IDPais = P.ID
--5
--Listar los nombres de las ciudades que no tengan clientes asociados. Listar también el nombre del país al que pertenece la ciudad.
select  P.Nombre as Pais, Ci.Nombre as Ciudad  from Clientes as C
right join Ciudades as Ci ON C.IDCiudad = Ci.ID
right join Paises as P ON Ci.IDPais = P.ID
where C.id is null
--6
--Listar para cada proyecto el nombre del proyecto, el costo, la razón social del cliente, el nombre del tipo de cliente y el nombre de la ciudad (si la tiene registrada) de aquellos clientes cuyo tipo de cliente sea 'Extranjero' o 'Unicornio'.
Select Pr.Nombre,pr.CostoEstimado,Cl.RazonSocial,Tc.Nombre as Tipo,Ci.Nombre as Ciudad from Proyectos as Pr
inner join Clientes as Cl On Pr.IDCliente=Cl.ID
inner join TiposCliente as Tc on Cl.IDTipo=Tc.ID
left join Ciudades as Ci on Cl.IDCiudad = Ci.ID
where Tc.Nombre = 'Unicornio' or Tc.Nombre ='Extranjero'
--7
--Listar los nombre de los proyectos de aquellos clientes que sean de los países 'Argentina' o 'Italia'.
Select PR.Nombre from Proyectos as Pr
inner join Clientes as Cl on Pr.IDCliente= Cl.ID
inner join Ciudades as Ci on Cl.IDCiudad = Ci.ID
inner join Paises as P on Ci.IDPais = P.ID
where p.Nombre = 'Argentina' or p.Nombre = 'Italia'
--8
--Listar para cada módulo el nombre del módulo, el costo estimado del módulo, el nombre del proyecto, la descripción del proyecto y el costo estimado del proyecto de todos aquellos proyectos que hayan finalizado.
Select M.Nombre as NombreModulo, M.CostoEstimado as CostoModulo,Pr.Nombre as NombreProyecto,Pr.Descripcion,Pr.CostoEstimado as CostoProyecto from Modulos as M
inner join Proyectos as Pr On M.IDProyecto = Pr.ID
where Pr.FechaFin is not null

--9
--Listar los nombres de los módulos y el nombre del proyecto de aquellos módulos cuyo tiempo estimado de realización sea de más de 100 horas.
select M.Nombre as NombreModulo,Pr.Nombre as NombreProyecto  from Modulos as M
inner join Proyectos as Pr On M.IDProyecto=Pr.ID
Where M.TiempoEstimado > 100
--10
--Listar nombres de módulos, nombre del proyecto, descripción y tiempo estimado de aquellos módulos cuya fecha estimada de fin sea mayor a la fecha real de fin y el costo estimado del proyecto sea mayor a cien mil.
select M.Nombre as NombreModulo,Pr.Nombre as NombreProyecto, M.Descripcion as DescripcionModulo, M.TiempoEstimado as TiempoEModulo  from Modulos as M
inner join Proyectos as Pr On M.IDProyecto=Pr.ID
where M.FechaEstimadaFin > M.FechaFin and Pr.CostoEstimado > 100000
--11
--Listar nombre de proyectos, sin repetir, que registren módulos que hayan finalizado antes que el tiempo estimado.
Select distinct Pr.Nombre from Proyectos as Pr
inner join Modulos as M On Pr.ID= M.IDProyecto
where M.FechaFin < M.FechaEstimadaFin
--12
--Listar nombre de ciudades, sin repetir, que no registren clientes pero sí colaboradores.
Select distinct Ci.Nombre from Ciudades as Ci
left join Clientes as Cl on Ci.ID = Cl.IDCiudad
inner join Colaboradores as Co on Ci.ID = Co.IDCiudad
where CL.IDCiudad IS NULL 

--13
--Listar el nombre del proyecto y nombre de módulos de aquellos módulos que contengan la palabra 'login' en su nombre o descripción.
Select Pr.Nombre as NombreProyecto, M.Nombre as NombreModulo from Proyectos as Pr
inner join Modulos as M on Pr.ID= M.IDProyecto
where M.Nombre like '%login%' or M.Descripcion like '%login%'
--14
--Listar el nombre del proyecto y el nombre y apellido de todos los colaboradores que hayan realizado algún tipo de tarea cuyo nombre contenga 'Programación' o 'Testing'. Ordenarlo por nombre de proyecto de manera ascendente.
Select Pr.Nombre Proyecto, Co.Nombre, Co.Apellido,Ti.Nombre from Proyectos as Pr
inner join Modulos as M on Pr.ID=M.IDProyecto
inner join Tareas as T on M.ID = T.IDModulo
inner join Colaboraciones as C on T.id = C.IDTarea
inner join Colaboradores as Co on C.IDColaborador=Co.ID
inner join TiposTarea as Ti on T.IDTipo=Ti.ID
where Ti.Nombre like '%Testing%' or Ti.Nombre like '%Programación%'
order by Pr.Nombre asc

--15
--Listar nombre y apellido del colaborador, nombre del módulo, nombre del tipo de tarea, precio hora de la colaboración y precio hora base de aquellos colaboradores que hayan cobrado su valor hora de colaboración más del 50% del valor hora base.
Select Co.Nombre, Co.Apellido, M.Nombre as Modulo, Ti.Nombre as Tarea, C.PrecioHora, Ti.PrecioHoraBase from Colaboradores as Co
inner join Colaboraciones as C on Co.ID=C.IDColaborador
inner join Tareas as T on C.IDTarea= T.ID
inner join Modulos as M on T.IDModulo= M.ID
inner join TiposTarea as Ti on T.IDTipo=Ti.ID
where C.PrecioHora > 1.5*Ti.PrecioHoraBase
--16
--Listar nombres y apellidos de las tres colaboraciones de colaboradores externos que más hayan demorado en realizar alguna tarea cuyo nombre de tipo de tarea contenga 'Testing'.
Select Top(3) CONCAT(Co.Nombre,' ',Co.Apellido) as NombreApellido from Colaboraciones as C
inner join Colaboradores as Co on C.IDColaborador=Co.ID
inner join Tareas as T on C.IDTarea = T.ID
inner join TiposTarea as Ti on T.IDTipo= Ti.ID
where Ti.Nombre like '%Testing%' and Co.Tipo = 'E'
order by C.Tiempo desc

--17
--Listar apellido, nombre y mail de los colaboradores argentinos que sean internos y cuyo mail no contenga '.com'.
Select Concat(Co.Nombre,' ',Co.Apellido)as NombreApellido, Co.EMail from Colaboradores as Co
inner join Ciudades as C on Co.IDCiudad=C.ID
inner join Paises as P on C.IDPais=P.ID
where Co.Tipo='i' and Co.EMail not like '%.com%' and P.Nombre='Argentina'
--18
--Listar nombre del proyecto, nombre del módulo y tipo de tarea de aquellas tareas realizadas por colaboradores externos.
Select Pr.Nombre as Proyecto, M.Nombre as Modulo, Ti.Nombre as Tarea from Proyectos as Pr
inner join Modulos as M on Pr.ID=M.IDProyecto
inner join Tareas as T on M.ID=T.IDModulo
inner join Colaboraciones as C on T.ID=C.IDTarea
inner join Colaboradores as Co on C.IDColaborador=Co.ID
inner join TiposTarea as Ti on T.IDTipo=Ti.ID
where Co.Tipo='E'
--19
--Listar nombre de proyectos que no hayan registrado tareas.
Select Pr.Nombre from Proyectos as Pr
inner join Modulos as M on Pr.ID=M.IDProyecto
left join Tareas as T on M.ID=T.IDModulo
where T.ID is null
--20
--Listar apellidos y nombres, sin repeticiones, de aquellos colaboradores que hayan trabajado en algún proyecto que aún no haya finalizado.
Select distinct Concat(Co.Apellido,' ',Co.Nombre) as 'Apellido y Nombre' from Colaboradores as Co
inner join Colaboraciones as C on Co.ID=C.IDColaborador
inner join Tareas as T on C.IDTarea=T.ID
inner join Modulos as M on T.IDModulo=M.ID
inner join Proyectos as Pr on M.IDProyecto=Pr.ID
where Pr.FechaFin is null