create database UTN
GO
use UTN
GO
create table Carreras(
    ID varchar(4) not null primary key,
    Nombre varchar(30) not null,
    FechaCreación datetime not null check (FechaCreación <= getdate() ),
    Mail varchar(100) not null,
	Nivel varchar(20) not null check (nivel = 'diplomatura' or nivel = 'pregrado' or nivel = 'grado' or nivel = 'postgrado')
)
GO
create table Alumnos(
    Legajo int not null primary key identity(1000, 1),
    IDCarrera varchar(4) not null foreign key references Carreras(ID),
    Apellidos varchar(100) not null,
    Nombres varchar(100) not null,
    Nacimiento datetime not null check (Nacimiento <= getdate() ),
	Mail varchar(100) not null unique,
    Telefono varchar(20) null
)
GO
create table Materias(
	ID int not null primary key identity(1,1),
	IDCarrera varchar(4) not null foreign key references Carreras(ID), 
	Nombre varchar(100) not null,
	CargaHoraria int not null check (CargaHoraria > 0)
)

