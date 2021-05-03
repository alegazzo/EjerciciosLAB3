use BluePrint


--1
--La cantidad de colaboradores
select count(*) from Colaboradores


--2
--La cantidad de colaboradores nacidos entre 1990 y 2000.
select count(*) from Colaboradores
where year(FechaNacimiento) between 1990 and 2000
--3
--El promedio de precio hora base de los tipos de tareas
select avg(PrecioHoraBase) from TiposTarea


--4
--El promedio de costo de los proyectos iniciados en el año 2019.

select avg(CostoEstimado) from Proyectos
where year(FechaInicio) = 2019
--5
--El costo más alto entre los proyectos de clientes de tipo 'Unicornio'

select Max(P.CostoEstimado) from Proyectos as P 
inner join Clientes as C on C.ID=P.IDCliente
inner join TiposCliente as T on T.ID=C.IDTipo
where T.Nombre like 'Unicornio'
--6
--El costo más bajo entre los proyectos de clientes del país 'Argentina'
select Min(P.CostoEstimado) from Proyectos as P 
inner join Clientes as C on C.ID=P.IDCliente
inner join Ciudades as Ci on Ci.ID=C.IDCiudad
inner join Paises as Pa on Pa.ID=Ci.IDPais
where Pa.Nombre like 'Argentina'

--7
--La suma total de los costos estimados entre todos los proyectos.
select sum(CostoEstimado) from Proyectos

--8
--Por cada ciudad, listar el nombre de la ciudad y la cantidad de clientes.
select Ci.Nombre, count(C.IDCiudad) from Clientes as C
right join Ciudades as Ci on Ci.ID=C.IDCiudad
group by Ci.Nombre


--9
--Por cada país, listar el nombre del país y la cantidad de clientes.
select P.Nombre, count(C.IDCiudad) from Clientes as C
inner join Ciudades as Ci on Ci.ID=C.IDCiudad
right join Paises as P on p.ID=Ci.IDPais
group by P.Nombre

--10
--Por cada tipo de tarea, la cantidad de colaboraciones registradas. Indicar el tipo de tarea y la cantidad calculada.
select Ti.Nombre, count(C.IDTarea) from Colaboraciones as C
inner join Tareas as T on T.ID=C.IDTarea
right join TiposTarea as Ti on Ti.ID=T.IDTipo
group by Ti.Nombre

--11
--Por cada tipo de tarea, la cantidad de colaboradores distintos que la hayan realizado. Indicar el tipo de tarea y la cantidad calculada.
select Ti.Nombre, count(distinct Co.IDTarea) from Colaboradores as C
inner join Colaboraciones as Co on Co.IDColaborador=C.ID
inner join Tareas as T on T.ID=Co.IDTarea
right join TiposTarea as Ti on Ti.ID=T.IDTipo
group by Ti.Nombre
--12
--Por cada módulo, la cantidad total de horas trabajadas. Indicar el ID, nombre del módulo y la cantidad totalizada. Mostrar los módulos sin horas registradas con 0.
select M.Id, M.Nombre,sum(Co.Tiempo) from Modulos as M
left join Tareas as T on T.IDModulo=M.ID
inner join Colaboraciones as Co on Co.IDTarea=T.ID
group by M.id, M.Nombre
--13
--Por cada módulo y tipo de tarea, el promedio de horas trabajadas. Indicar el ID y nombre del módulo, el nombre del tipo de tarea y el total calculado.
select M.Id, M.Nombre,Ti.Nombre,avg(Co.Tiempo *1.0) from Modulos as M
left join Tareas as T on T.IDModulo=M.ID
left join Colaboraciones as Co on Co.IDTarea=T.ID
right join TiposTarea as Ti on Ti.ID=T.IDTipo
group by M.id, M.Nombre,Ti.Nombre
order by M.Nombre asc

--14
--Por cada módulo, indicar su ID, apellido y nombre del colaborador y total que se le debe abonar en concepto de colaboraciones realizadas en dicho módulo.
select M.Id,C.Apellido, C.Nombre , sum(Co.Tiempo* Co.PrecioHora) as total from Modulos as M
inner join Tareas as T on T.IDModulo=M.ID
inner join Colaboraciones as Co on Co.IDTarea=T.ID
inner join Colaboradores as C on C.ID=Co.IDColaborador
group by M.id, C.Apellido, C.Nombre

--15
--Por cada proyecto indicar el nombre del proyecto y la cantidad de horas registradas en concepto de colaboraciones y el total que debe abonar en concepto de colaboraciones.
select P.Nombre,sum(C.Tiempo) as horas ,sum(C.PrecioHora*c.Tiempo) as total from Proyectos as P
left join Modulos as M on M.IDProyecto=P.ID
inner join Tareas as T on T.IDModulo=M.ID
inner join Colaboraciones as C on C.IDTarea=T.ID
group by P.Nombre


--16
--Listar los nombres de los proyectos que hayan registrado menos de cinco colaboradores distintos y más de 100 horas total de trabajo.
select P.Nombre from Proyectos as P
left join Modulos as M on M.IDProyecto=P.ID
inner join Tareas as T on T.IDModulo=M.ID
inner join Colaboraciones as C on C.IDTarea=T.ID
group by P.Nombre
having count(distinct C.IDColaborador)<5 and sum(C.Tiempo) >100
 
	
--17
--Listar los nombres de los proyectos que hayan comenzado en el año 2020 que hayan registrado más de tres módulos.
select P.Nombre from Proyectos as P
inner join Modulos as M on M.IDProyecto=P.ID
where year(P.FechaInicio) = 2020
group by P.Nombre
having  Count(M.IDProyecto) >3
--18
--Listar para cada colaborador externo, el apellido y nombres y el tiempo máximo de horas que ha trabajo en una colaboración. 
Select Co.Nombre,Co.Apellido, Max(C.Tiempo) from Colaboradores as Co
inner join Colaboraciones as C on C.IDColaborador=Co.ID
where Co.Tipo like 'E'
group by Co.Nombre,Co.Apellido

--19
--Listar para cada colaborador interno, el apellido y nombres y el promedio percibido en concepto de colaboraciones.
Select Co.Nombre,Co.Apellido, avg(C.PrecioHora*C.Tiempo) from Colaboradores as Co
inner join Colaboraciones as C on C.IDColaborador=Co.ID
where Co.Tipo like 'I'
group by Co.Nombre,Co.Apellido
--20
--Listar el promedio percibido en concepto de colaboraciones para colaboradores internos y el promedio percibido en concepto de colaboraciones para colaboradores externos.
select 
	case when CO.Tipo like 'I' then 'Internos' else 'Externos' end as 'Tipos de colaboradores',
	AVG(CB.PrecioHora * CB.Tiempo) as 'Promedio de colaboraciones'
from Colaboraciones as CB
	inner join Colaboradores as CO on CO.ID = CB.IDColaborador
group by CO.Tipo
order by CO.Tipo asc

--21
--Listar el nombre del proyecto y el total neto estimado. Este último valor surge del costo estimado menos los pagos que requiera hacer en concepto de colaboraciones.
Select P.Nombre, Avg(P.CostoEstimado) - sum(C.PrecioHora*C.Tiempo) as Total from Proyectos as P
inner join Modulos as M on M.IDProyecto=P.ID
inner join Tareas as T on T.IDModulo=M.ID
inner join Colaboraciones as C on C.IDTarea=T.ID
group by P.Nombre
having AVG(P.CostoEstimado) - SUM(C.PrecioHora * C.Tiempo) is not null
--22
--Listar la cantidad de colaboradores distintos que hayan colaborado en alguna tarea que correspondan a proyectos de clientes de tipo 'Unicornio'.
select count(distinct Co.IDColaborador) from Colaboraciones as Co
inner join Tareas as T on T.ID=Co.IDTarea
inner join Modulos as M on M.ID=T.IDModulo
inner join Proyectos as P on P.ID=M.IDProyecto
inner join Clientes AS Cl on Cl.ID=P.IDCliente
inner join TiposCliente as Tc on Tc.ID=Cl.IDTipo
where Tc.Nombre like 'Unicornio'


--23
--La cantidad de tareas realizadas por colaboradores del país 'Argentina'.
select count(distinct Co.IDTarea) from Colaboradores as C
inner join Colaboraciones as Co on Co.IDColaborador=C.ID
inner join Ciudades as Ci on Ci.ID=C.IDCiudad
inner join Paises as P ON p.ID = Ci.IDPais
WHERE p.Nombre like 'Argentina'


--24
--Por cada proyecto, la cantidad de módulos que se haya estimado mal la fecha de fin. Es decir, que se haya finalizado antes o después que la fecha estimada. Indicar el nombre del proyecto y la cantidad calculada.


select P.Nombre,Count(M.ID) as Cantidad from Proyectos as P
left join Modulos as M on M.IDProyecto= P.ID
where M.FechaFin!=M.FechaEstimadaFin
group by P.Nombre
order by Cantidad desc