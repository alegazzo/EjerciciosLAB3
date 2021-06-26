/*

RELACION MUCHOS A MUCHOS

-En la tabla LUCHADORES MMA vamos a encontrar los datos mas importantes de cada deportista. 
- En la tabla DISCIPLINAS encontraremos el nombre de las posibles artes marciales que los luchadores saben. Algunos ejemplos son BOXEO, JUDO, KARATE, AIKIDO, MUAY THAI etc.
-En la tabla DISCIPLINAS POR LUCHADOR se relacionan los id de luchador con las disciplinas que sabe y en que nivel: "novato", "intermedio", "experto"
*/

use actividad12 

go

 create table luchadoresMMA(
   id int not null primary key identity (1,1),
    nombre nvarchar (30) not null,
    apellido nvarchar (30) not null,
	fecha_nacimiento datetime not null check (fecha_nacimiento<getdate()),
	peso decimal (5,2) not null check (peso > 0 and peso <180),
	altura tinyint not null check (altura > 0),
	nacionalidad varchar (40) null
 ) 

 go 

 create table disciplinas (
   id_disciplina char(4) not null primary key,
   nombre_disciplina nvarchar (40) not null
 ) 

 go 

 create table disciplinas_por_luchador(
    idLuchador int not null,
	idDisciplina char(4) not null, 
	nivel varchar(11) not null check ( nivel ='novato' or nivel ='intermedio' or nivel ='experto'),
	primary key(idLuchador, idDisciplina),
	foreign key(idLuchador) references luchadoresMMA (id),
	foreign key (idDisciplina)references disciplinas (id_disciplina) 
 )