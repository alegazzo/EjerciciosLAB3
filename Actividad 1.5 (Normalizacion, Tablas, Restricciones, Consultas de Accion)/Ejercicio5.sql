Use Blueprint
GO

Create table Tipos_Tareas(
ID int primary key identity(1,1) not null,
Tipo char(50) not null
)


Go
Create table Tareas(
ID int primary key identity(1,1) not null,
IdModulo int foreign key references Modulos(ID) not null,
Tipo int foreign key references Tipos_Tareas(ID) not null,
FechaInicio datetime  null,
FechaFin datetime  null,
Estado bit not null,
Constraint FechasTareas check(FechaInicio < FechaFin)
)		

GO
Create table Colaboraciones(
IdColaborador int not null,
IdTarea int not null,
CantidadHoras int check (CantidadHoras > 0) not null,
ValorXHora smallmoney check(ValorXHora > 0) not null,
Estado bit not null,
Constraint Pk Primary key (IdColaborador,IdTarea),
Constraint Fk_Tareas foreign key (IdTarea) references Tareas (ID),
Constraint Fk_Colaboradores foreign key (IdColaborador) references Colaboradores (ID)
)