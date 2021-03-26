create database Blueprint
GO
use Blueprint
GO


create table TiposClientes(
ID tinyint primary key identity(1,1) not null,
Tipo varchar(50) unique not null
)

GO
create table Clientes(
ID int  primary key identity(1,1) not null,
RazonSocial varchar(50) not null,
CUIT char(20) unique not null,
TipoCliente tinyint foreign key references TiposClientes (ID),
Mail varchar(50) null,
Telefono char(20) null,
Celular char (20) null
)
GO
create table Proyectos(
ID char(8) primary key not null,
Nombre varchar(20) not null,
Descripcion varchar(100) null,
CostoEstimado money not null,
FechaInicio datetime not null check(FechaInicio < getdate()),
FechaFin datetime null check(FechaFin < getdate()),
IdCliente int foreign key references Clientes(ID),
Estado varchar(8) not null check(Estado='vigente' or Estado='cancelado')
)

