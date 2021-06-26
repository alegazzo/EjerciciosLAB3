/* 
RELACION 1a1: 
-Contamos con una tabla principal llamada PELICULAS  que tiene los datos mas importantes que se necesitan saber acerca de la misma. 
-Luego tenemos la tabla DATOSSECUNDARIOS que tiene datos adicionales que para la mayoría del público no serian tan importantes. 
-Ambas tablas se relacionan mediante IDPELICULA. 
*/

create database actividad12

go

use actividad12 

go

create table peliculas (
   idPelicula int not null primary key identity (1,1),
   nombrePelicula varchar(50) not null unique,
   nombreDirector nvarchar(70) not null, 
   genero varchar(50) null, 
   clasificacion char(3) not null check (clasificacion = 'ATP' OR clasificacion = '+13' OR clasificacion = '+16' OR clasificacion = '+18'),
   duracion smallint not null check (duracion > 0),
   estreno datetime null check (estreno < getdate())
) 

go 

create table datosSecundarios(
   idPelicula int not null, 
   nombreGuionista nvarchar(50) null,
   cantidadHorasGrabacion int null,
   presupuesto money not null check( presupuesto > 0),
   recaudacion money null,
   primary key(idPelicula),
   foreign key (idPelicula) references peliculas (idPelicula) 
)

