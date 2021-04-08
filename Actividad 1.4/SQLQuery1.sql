Use Blueprint

Go

Create table Modulos(
ID int identity(1,1) not null,
Nombre char(40) not null,
Descripción varchar(50) null,
Proyecto char(8) not null,
TiempoEstimado smallint not null,
CostoEstimado money not null,
FechaDeInicio datetime  not null,
FechaEstimadaFin datetime  not null,
FechaDeFin datetime not null,
Constraint PK_ID Primary key(ID),
Constraint FK_Proyecto Foreign key (Proyecto) references Proyectos (ID),
Constraint Fechas check (FechaDeInicio < FechaDeFin)
)

GO

Create table Colaboradores(
ID int primary key identity(1,1) not null,
Apellido char(40) not null,
Nombre char(40) not null,
Mail varchar(30) null,
Celular varchar(30) null,
FechaNacimiento datetime not null check(FechaNacimiento <getdate()),
Tipo char(1) check(Tipo='I' OR Tipo='E') not null,
Domicilio varchar(50) null,
Ciudad varchar(20) null,
País varchar(20) null,
Constraint Contacto check( Mail is not null OR Celular is not null)
)