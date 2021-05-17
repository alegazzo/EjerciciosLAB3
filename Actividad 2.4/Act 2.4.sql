use BluePrint


--1
--Listar los nombres de proyecto y costo estimado de aquellos proyectos cuyo costo estimado sea mayor al promedio de costos.
select P.Nombre,P.CostoEstimado from Proyectos as P 
where P.CostoEstimado>(select Avg(CostoEstimado) from Proyectos )
--2
--Listar razón social, cuit y contacto (email, celular o teléfono) de aquellos clientes que no tengan proyectos que comiencen en el año 2020.
select distinct C.RazonSocial, C.CUIT, coalesce(EMail,Celular,Telefono,'incontactable') as contacto from Clientes as C
where C.ID not in (select IDCliente from Proyectos where year(FechaInicio)!= 2020)
--3
--Listado de países que no tengan clientes relacionados.
select distinct P.Nombre from Paises as P
where P.ID not in(SELECT CI.IDPais FROM Ciudades AS CI
INNER JOIN Clientes AS CL ON CI.ID = CL.IDCiudad)
--4
--Listado de proyectos que no tengan tareas registradas. 
select distinct P.Nombre from Proyectos as P
where P.ID not in ( select M.IDProyecto from Modulos as M inner join Tareas as T on T.IDModulo=M.ID)
--5
--Listado de tipos de tareas que no registren tareas pendientes.
select distinct T.Nombre from TiposTarea as T
where T.ID not in (select T.IDTipo from Tareas as T where T.FechaFin is null)
--6
--Listado con ID, nombre y costo estimado de proyectos cuyo costo estimado sea menor al costo estimado de cualquier proyecto de clientes nacionales (clientes que sean de Argentina o no tengan asociado un país).
Select P.Id, P.nombre, P.costoestimado from Proyectos as P 
where P.CostoEstimado < All (
select CostoEstimado from Proyectos as P 
inner join Clientes as C on C.ID=P.IDCliente
left join Ciudades as Ci on Ci.ID=C.IDCiudad
left join Paises as Pa on Pa.ID=Ci.IDPais
where Pa.Nombre like 'Argentina' or Pa.Nombre is null
)

--7
--Listado de apellido y nombres de colaboradores que hayan demorado más en una tarea que el colaborador de la ciudad de 'Buenos Aires' que más haya demorado.
select distinct C.Apellido, C.Nombre from Colaboradores as C 
inner join Colaboraciones as Co on Co.IDColaborador=C.ID
where Co.Tiempo > (
select max(Co.Tiempo) from Colaboradores as C
inner join Ciudades as Ci on Ci.ID=C.IDCiudad
inner join Colaboraciones as Co on Co.IDColaborador=C.ID
where Ci.Nombre like 'Buenos Aires'
)
--8
--Listado de clientes indicando razón social, nombre del país (si tiene) y cantidad de proyectos comenzados y cantidad de proyectos por comenzar.
select C.RazonSocial,
coalesce((select Pa.Nombre from Paises as Pa inner join Ciudades as Ci on Ci.IDPais=Pa.ID where C.IDCiudad=Ci.ID),'no tiene') as Pais,
(select count(distinct P.ID) from Proyectos as P where P.IDCliente=C.ID and GETDATE() > P.FechaInicio) as ProyectosComenzados,
(select count(distinct P2.ID) from Proyectos as P2 where P2.IDCliente=C.ID and P2.FechaInicio > Getdate()) as ProyectosAComenzar from Clientes as C


--9
--Listado de tareas indicando nombre del módulo, nombre del tipo de tarea, cantidad de colaboradores externos que la realizaron y cantidad de colaboradores internos que la realizaron.
select (select M.Nombre from Modulos M where M.ID=T.IDModulo) as modulo,
(select Ti.Nombre from TiposTarea Ti where Ti.ID=T.IDTipo) as tipoTarea,
(select Count(distinct Co.Id) from Colaboradores Co inner join Colaboraciones as Col on Col.IDColaborador=Co.ID where Co.Tipo like 'E' and Col.IDTarea=T.ID) as ColExt,
(select Count(distinct Co.Id) from Colaboradores Co inner join Colaboraciones as Col on Col.IDColaborador=Co.ID where Co.Tipo like 'I' and Col.IDTarea=T.ID) as ColInt
from Tareas as T

--10
--Listado de proyectos indicando nombre del proyecto, costo estimado, cantidad de módulos cuya estimación de fin haya sido exacta, cantidad de módulos con estimación adelantada y cantidad de módulos con estimación demorada.
--Adelantada →  estimación de fin haya sido inferior a la real.
--Demorada   →  estimación de fin haya sido superior a la real.
select P.nombre, P.CostoEstimado,
(select count (M.Id)from Modulos M where M.FechaEstimadaFin=M.FechaFin and M.IDProyecto=P.ID) as Exacta,
(select count (M.Id)from Modulos M where M.FechaEstimadaFin<M.FechaFin and M.IDProyecto=P.ID) as Adelantada,
(select count (M.Id)from Modulos M where M.FechaEstimadaFin>M.FechaFin and M.IDProyecto=P.ID) as Demorada
from Proyectos P
--11
--Listado con nombre del tipo de tarea y total abonado en concepto de honorarios para colaboradores internos y total abonado en concepto de honorarios para colaboradores externos.
select TT.Nombre, 
(select sum(C.PrecioHora*C.Tiempo) from Colaboraciones C inner join Colaboradores Co on Co.ID=C.IDColaborador inner join Tareas T on T.ID=C.IDTarea where Co.Tipo like 'I' and T.IDTipo=TT.ID) as HonorarioI,
(select sum(C.PrecioHora*C.Tiempo) from Colaboraciones C inner join Colaboradores Co on Co.ID=C.IDColaborador inner join Tareas T on T.ID=C.IDTarea where Co.Tipo like 'E' and T.IDTipo=TT.ID) as HonorarioE
from TiposTarea TT
--12
--Listado con nombre del proyecto, razón social del cliente y saldo final del proyecto. El saldo final surge de la siguiente fórmula: 
--Costo estimado - Σ(HCE) - Σ(HCI) * 0.1
--Siendo HCE → Honorarios de colaboradores externos y HCI → Honorarios de colaboradores internos.
select P.Nombre, C.RazonSocial, 
P.CostoEstimado -
(select  isnull(sum(C.PrecioHora*C.Tiempo),0) from Colaboraciones C 
inner join Colaboradores Co on Co.ID=C.IDColaborador 
inner join Tareas T on T.ID=C.IDTarea
inner join Modulos M on M.ID=T.IDModulo
where M.IDProyecto=P.ID and Co.Tipo like 'E') -
(select  isnull(sum(C.PrecioHora*C.Tiempo),0) from Colaboraciones C 
inner join Colaboradores Co on Co.ID=C.IDColaborador 
inner join Tareas T on T.ID=C.IDTarea
inner join Modulos M on M.ID=T.IDModulo
where M.IDProyecto=P.ID and Co.Tipo like 'I') * 0.1 as SaldoFinal
from Proyectos P inner join Clientes C on C.ID=P.IDCliente
--13
--Para cada módulo listar el nombre del proyecto, el nombre del módulo, el total en tiempo que demoraron las tareas de ese módulo y qué porcentaje de tiempo representaron las tareas de ese módulo en relación al tiempo total de tareas del proyecto.
select P.Nombre Proyecto, M.Nombre Modulo,

(select isnull(sum(Co.Tiempo),0) from Colaboraciones Co 
inner join Tareas T on T.ID=Co.IDTarea
where M.ID=T.IDModulo) as TiempoTareas,

(select isnull(sum(Co.Tiempo),0) from Colaboraciones Co 
inner join Tareas T on T.ID=Co.IDTarea  
where M.ID=T.IDModulo)*1.0 * 100 /

(select isnull(sum(Co.Tiempo),1) from Colaboraciones Co 
inner join Tareas T on T.ID=Co.IDTarea 
inner join Modulos M2 on M2.ID=T.IDModulo 
where  M2.IDProyecto=P.ID)*1.0  as Porcentaje

from Modulos M inner join Proyectos P on P.ID=M.IDProyecto
--14
--Por cada colaborador indicar el apellido, el nombre, 'Interno' o 'Externo' según su tipo y la cantidad de tareas de tipo 'Testing' que haya realizado y la cantidad de tareas de tipo 'Programación' que haya realizado.
--NOTA: Se consideran tareas de tipo 'Testing' a las tareas que contengan la palabra 'Testing' en su nombre. Ídem para Programación.
Select C.Apellido, C.Nombre,
Case 
When C.Tipo like 'I' then 'Interno'
else 'Externo' end as Tipo,

(Select Count(Co.IDTarea) from Colaboraciones Co
inner join Tareas T on T.ID=Co.IDTarea
inner join TiposTarea TT on TT.ID=T.IDTipo
where TT.Nombre like '%Testing%' and Co.IDColaborador=C.ID) Testings,
(Select Count(Co.IDTarea) from Colaboraciones Co
inner join Tareas T on T.ID=Co.IDTarea
inner join TiposTarea TT on TT.ID=T.IDTipo
where TT.Nombre like '%Programación%' and Co.IDColaborador=C.ID) Programacion
from Colaboradores C
--15
--Listado apellido y nombres de los colaboradores que no hayan realizado tareas de 'Diseño de base de datos'.
select * from
(select C.Apellido as Apellido,C.Nombre as Nombre,TT.Nombre as Tipo from Colaboradores C
inner join Colaboraciones Co on Co.IDColaborador=C.ID
inner join Tareas T on T.ID=Co.IDTarea
inner join TiposTarea TT on TT.ID=T.IDTipo) as T1
where T1.Tipo not like 'Diseño de base de datos'

--16
--Por cada país listar el nombre, la cantidad de clientes y la cantidad de colaboradores.
select P.Nombre,

(select count(Cl.Id) from Clientes Cl
inner join Ciudades C on C.ID=Cl.IDCiudad
where C.IDPais=P.ID) as CantClientes,

(select count(Co.Id) from Colaboradores Co
inner join Ciudades C on C.ID=Co.IDCiudad
where C.IDPais=P.ID) as Colaboradores

from Paises P
--17
--Listar por cada país el nombre, la cantidad de clientes y la cantidad de colaboradores de aquellos países que no tengan clientes pero sí colaboradores.
select * from (

select P.Nombre Nombre,

(select count(Cl.Id) from Clientes Cl
inner join Ciudades C on C.ID=Cl.IDCiudad 
where C.IDPais=P.ID) as CantClientes,

(select count(Co.Id) from Colaboradores Co
inner join Ciudades C on C.ID=Co.IDCiudad
where C.IDPais=P.ID) as CantColaboradores

from Paises as P) as T1

where T1.CantClientes=0 and T1.CantColaboradores>0

--18
--Listar apellidos y nombres de los colaboradores internos que hayan realizado más tareas de tipo 'Testing' que tareas de tipo 'Programación'.
select * from (select Co.Nombre Nombre, Co.Apellido Apellido,
(select count(C.IDTarea) from Colaboraciones C
inner join Tareas T on T.ID=C.IDTarea
inner join TiposTarea TT on TT.ID=T.IDTipo
where TT.Nombre like '%Testing%' and C.IDColaborador=Co.ID) TipoTesting,
(select count(C.IDTarea) from Colaboraciones C
inner join Tareas T on T.ID=C.IDTarea
inner join TiposTarea TT on TT.ID=T.IDTipo
where TT.Nombre like '%Programación%' and C.IDColaborador=Co.ID) TipoProgramacion
from Colaboradores Co) as T1
where T1.TipoTesting>T1.TipoProgramacion
--19
--Listar los nombres de los tipos de tareas que hayan abonado más del cuádruple en colaboradores internos que externos
select T1.Tipos from (select TT.Nombre Tipos,

(select sum(C.PrecioHora*C.Tiempo) from Colaboraciones C
inner join Colaboradores Co on Co.ID=C.IDColaborador
inner join Tareas T on T.ID=C.IDTarea
where Co.Tipo like 'I' and T.IDTipo=TT.ID) Internos,

(select sum(C.PrecioHora*C.Tiempo) from Colaboraciones C
inner join Colaboradores Co on Co.ID=C.IDColaborador
inner join Tareas T on T.ID=C.IDTarea
where Co.Tipo like 'E' and T.IDTipo=TT.ID) Externos

from TiposTarea TT) as T1

where T1.Internos > T1.Externos*4
--20
--Listar los proyectos que hayan registrado igual cantidad de estimaciones demoradas que adelantadas y que al menos hayan registrado alguna estimación adelantada y que no hayan registrado ninguna estimación exacta.

Select T1.Nombre from (select P.Nombre Nombre, 

(Select Count(M.id) from Modulos M
where P.ID=M.IDProyecto and M.FechaEstimadaFin<M.FechaFin) Demoradas,

(Select Count(M.id) from Modulos M
where P.ID=M.IDProyecto and M.FechaEstimadaFin>M.FechaFin) Adelantadas,

(Select Count(M.id) from Modulos M
where P.ID=M.IDProyecto and M.FechaEstimadaFin=M.FechaFin) Exactas

from Proyectos P) as T1

where T1.Adelantadas=T1.Demoradas and T1.Adelantadas>0 and T1.Exactas=0