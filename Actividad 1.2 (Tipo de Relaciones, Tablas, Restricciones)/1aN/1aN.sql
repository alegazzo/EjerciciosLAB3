/*
RELACIÓN UNO A MUCHOS

-Contamos con la tabla EQUIPOS donde figuran los datos principales de los equipos de futbol.
-Luego contamos con la tabla JUGADORES donde figuraran los jugadores de cada uno de los clubes. Cada jugador va a poseer un id de equipo que de existir en tabla equipos. 
*/

use actividad12 

go

create table equipos(
    id int not null identity (1,1),
	nombre varchar(50) not null,
	ciudad varchar(50) not null,
	categoria varchar(20) not null
)
go 

create table jugadores(
  idJugador int not null identity (1,1),
  idEquipo  int null,
  nombre nvarchar (30) not null,
  apellido nvarchar (30) not null,
  edad tinyint not null,
  posicion varchar(15) not null 
)
--restricciones EQUIPOS
go
alter table equipos
add constraint PK_ID primary key(id)

go

alter table equipos
add constraint UNIQUE_name unique (nombre)

go

alter table equipos
add constraint CHK_categoria  check (categoria ='primera' or categoria ='B nacional' or categoria =' B metropolitana' or categoria = 'ascenso')

go

--restricciones JUGADORES
go
alter table jugadores
add constraint PK_IDjugador primary key(idJugador)
go

alter table jugadores
add constraint id_equipo_FK foreign key(idEquipo) references equipos (id)

go

alter table jugadores
add constraint CHK_posicion check (posicion = 'arquero' or posicion = 'defensor' or posicion = 'mediocampista' or  posicion = 'delantero')

alter table jugadores 
add constraint CHK_edad check (edad >= 15)