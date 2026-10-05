/*
  CapiMovil - reconstruccion segura de la base de datos
  Generado desde las entidades BE, las clases DALC y los procedimientos del proyecto.

  IMPORTANTE: este script NO elimina ni modifica CapiMovilDB.
  Crea una base independiente llamada CapiMovilDB_Reconstruida.
*/
USE master;
GO

IF DB_ID(N'CapiMovilDB_Reconstruida') IS NOT NULL
BEGIN
    THROW 50001, 'CapiMovilDB_Reconstruida ya existe. Eliminela manualmente solo si esta seguro de reemplazarla.', 1;
END;
GO

CREATE DATABASE CapiMovilDB_Reconstruida;
GO
USE CapiMovilDB_Reconstruida;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

CREATE TABLE dbo.CorrelativoDocumento
(
    TipoCodigo VARCHAR(20) NOT NULL CONSTRAINT PK_CorrelativoDocumento PRIMARY KEY,
    UltimoNumero INT NOT NULL CONSTRAINT DF_CorrelativoDocumento_Ultimo DEFAULT (0),
    CONSTRAINT CK_CorrelativoDocumento_Ultimo CHECK (UltimoNumero >= 0)
);
GO

CREATE TABLE dbo.Rol
(
    IdRol UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Rol PRIMARY KEY,
    CodigoRol VARCHAR(20) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Descripcion VARCHAR(250) NULL,
    Estado BIT NOT NULL CONSTRAINT DF_Rol_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Rol_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT UQ_Rol_Codigo UNIQUE (CodigoRol),
    CONSTRAINT UQ_Rol_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE dbo.Usuario
(
    IdUsuario UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Usuario_IdUsuario DEFAULT (NEWID()) CONSTRAINT PK_Usuario PRIMARY KEY,
    IdRol UNIQUEIDENTIFIER NOT NULL,
    CodigoUsuario VARCHAR(20) NOT NULL,
    Username VARCHAR(50) NOT NULL,
    Correo VARCHAR(120) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    FotoPerfilUrl VARCHAR(500) NULL,
    UltimoAcceso DATETIME2(0) NULL,
    Estado BIT NOT NULL CONSTRAINT DF_Usuario_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Usuario_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT FK_Usuario_Rol FOREIGN KEY (IdRol) REFERENCES dbo.Rol(IdRol),
    CONSTRAINT UQ_Usuario_Codigo UNIQUE (CodigoUsuario),
    CONSTRAINT UQ_Usuario_Username UNIQUE (Username),
    CONSTRAINT UQ_Usuario_Correo UNIQUE (Correo)
);
GO

CREATE TABLE dbo.PadreFamilia
(
    IdPadre UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_PadreFamilia PRIMARY KEY,
    IdUsuario UNIQUEIDENTIFIER NOT NULL,
    CodigoPadre VARCHAR(20) NOT NULL,
    Nombres VARCHAR(100) NOT NULL,
    ApellidoPaterno VARCHAR(80) NOT NULL,
    ApellidoMaterno VARCHAR(80) NOT NULL,
    DNI VARCHAR(15) NULL,
    Telefono VARCHAR(20) NULL,
    TelefonoAlterno VARCHAR(20) NULL,
    Direccion VARCHAR(250) NULL,
    CorreoContacto VARCHAR(120) NULL,
    Estado BIT NOT NULL CONSTRAINT DF_PadreFamilia_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_PadreFamilia_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT FK_PadreFamilia_Usuario FOREIGN KEY (IdUsuario) REFERENCES dbo.Usuario(IdUsuario),
    CONSTRAINT UQ_PadreFamilia_Usuario UNIQUE (IdUsuario),
    CONSTRAINT UQ_PadreFamilia_Codigo UNIQUE (CodigoPadre)
);
GO

CREATE TABLE dbo.Conductor
(
    IdConductor UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Conductor PRIMARY KEY,
    IdUsuario UNIQUEIDENTIFIER NOT NULL,
    CodigoConductor VARCHAR(20) NOT NULL,
    Nombres VARCHAR(100) NOT NULL,
    ApellidoPaterno VARCHAR(80) NOT NULL,
    ApellidoMaterno VARCHAR(80) NOT NULL,
    DNI VARCHAR(15) NULL,
    Licencia VARCHAR(30) NOT NULL,
    CategoriaLicencia VARCHAR(20) NULL,
    Telefono VARCHAR(20) NULL,
    Direccion VARCHAR(250) NULL,
    Estado BIT NOT NULL CONSTRAINT DF_Conductor_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Conductor_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT FK_Conductor_Usuario FOREIGN KEY (IdUsuario) REFERENCES dbo.Usuario(IdUsuario),
    CONSTRAINT UQ_Conductor_Usuario UNIQUE (IdUsuario),
    CONSTRAINT UQ_Conductor_Codigo UNIQUE (CodigoConductor),
    CONSTRAINT UQ_Conductor_Licencia UNIQUE (Licencia)
);
GO

CREATE TABLE dbo.Estudiante
(
    IdEstudiante UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Estudiante_IdEstudiante DEFAULT (NEWID()) CONSTRAINT PK_Estudiante PRIMARY KEY,
    IdPadre UNIQUEIDENTIFIER NOT NULL,
    CodigoEstudiante VARCHAR(20) NOT NULL,
    Nombres VARCHAR(100) NOT NULL,
    ApellidoPaterno VARCHAR(80) NOT NULL,
    ApellidoMaterno VARCHAR(80) NOT NULL,
    DNI VARCHAR(15) NULL,
    FechaNacimiento DATE NULL,
    Genero VARCHAR(20) NULL,
    Grado VARCHAR(30) NULL,
    Seccion VARCHAR(20) NULL,
    Direccion VARCHAR(250) NULL,
    LatitudCasa DECIMAL(10,7) NULL,
    LongitudCasa DECIMAL(10,7) NULL,
    FotoUrl VARCHAR(500) NULL,
    Observaciones VARCHAR(500) NULL,
    Estado BIT NOT NULL CONSTRAINT DF_Estudiante_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Estudiante_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT FK_Estudiante_Padre FOREIGN KEY (IdPadre) REFERENCES dbo.PadreFamilia(IdPadre),
    CONSTRAINT UQ_Estudiante_Codigo UNIQUE (CodigoEstudiante)
);
GO

CREATE TABLE dbo.Bus
(
    IdBus UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Bus PRIMARY KEY,
    CodigoBus VARCHAR(20) NOT NULL,
    Placa VARCHAR(15) NOT NULL,
    Marca VARCHAR(50) NULL,
    Modelo VARCHAR(50) NULL,
    Color VARCHAR(30) NULL,
    Anio INT NULL,
    Capacidad INT NOT NULL,
    EstadoOperacion VARCHAR(20) NOT NULL CONSTRAINT DF_Bus_EstadoOperacion DEFAULT ('ACTIVO'),
    SeguroVigente BIT NOT NULL CONSTRAINT DF_Bus_SeguroVigente DEFAULT (1),
    FechaVencimientoSOAT DATE NULL,
    FechaRevisionTecnica DATE NULL,
    Estado BIT NOT NULL CONSTRAINT DF_Bus_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Bus_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT UQ_Bus_Codigo UNIQUE (CodigoBus),
    CONSTRAINT UQ_Bus_Placa UNIQUE (Placa),
    CONSTRAINT CK_Bus_Capacidad CHECK (Capacidad > 0)
);
GO

CREATE TABLE dbo.Ruta
(
    IdRuta UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Ruta PRIMARY KEY,
    CodigoRuta VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(500) NULL,
    Turno VARCHAR(20) NOT NULL CONSTRAINT DF_Ruta_Turno DEFAULT ('MANANA'),
    HoraInicio TIME(0) NOT NULL,
    HoraFin TIME(0) NOT NULL,
    PuntoInicio VARCHAR(250) NULL,
    PuntoFin VARCHAR(250) NULL,
    LatitudInicio DECIMAL(10,7) NULL,
    LongitudInicio DECIMAL(10,7) NULL,
    DireccionInicio VARCHAR(250) NULL,
    LatitudFin DECIMAL(10,7) NULL,
    LongitudFin DECIMAL(10,7) NULL,
    DireccionFin VARCHAR(250) NULL,
    EstadoRuta VARCHAR(20) NOT NULL CONSTRAINT DF_Ruta_EstadoRuta DEFAULT ('ACTIVA'),
    Estado BIT NOT NULL CONSTRAINT DF_Ruta_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Ruta_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT UQ_Ruta_Codigo UNIQUE (CodigoRuta)
);
GO

CREATE TABLE dbo.Paradero
(
    IdParadero UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Paradero PRIMARY KEY,
    IdRuta UNIQUEIDENTIFIER NOT NULL,
    CodigoParadero VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(250) NOT NULL,
    Latitud DECIMAL(10,7) NULL,
    Longitud DECIMAL(10,7) NULL,
    OrdenParada INT NOT NULL,
    HoraEstimada TIME(0) NULL,
    Estado BIT NOT NULL CONSTRAINT DF_Paradero_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Paradero_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT FK_Paradero_Ruta FOREIGN KEY (IdRuta) REFERENCES dbo.Ruta(IdRuta),
    CONSTRAINT UQ_Paradero_Codigo UNIQUE (CodigoParadero),
    CONSTRAINT UQ_Paradero_RutaOrden UNIQUE (IdRuta, OrdenParada),
    CONSTRAINT CK_Paradero_Orden CHECK (OrdenParada > 0)
);
GO

CREATE TABLE dbo.RutaEstudiante
(
    IdRutaEstudiante UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_RutaEstudiante PRIMARY KEY,
    IdRuta UNIQUEIDENTIFIER NOT NULL,
    IdEstudiante UNIQUEIDENTIFIER NOT NULL,
    IdParaderoSubida UNIQUEIDENTIFIER NULL,
    IdParaderoBajada UNIQUEIDENTIFIER NULL,
    CodigoRutaEstudiante VARCHAR(20) NOT NULL,
    FechaInicioVigencia DATE NOT NULL,
    FechaFinVigencia DATE NULL,
    EstadoAsignacion VARCHAR(20) NOT NULL CONSTRAINT DF_RutaEstudiante_EstadoAsignacion DEFAULT ('ACTIVO'),
    Observaciones VARCHAR(500) NULL,
    Estado BIT NOT NULL CONSTRAINT DF_RutaEstudiante_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_RutaEstudiante_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT FK_RutaEstudiante_Ruta FOREIGN KEY (IdRuta) REFERENCES dbo.Ruta(IdRuta),
    CONSTRAINT FK_RutaEstudiante_Estudiante FOREIGN KEY (IdEstudiante) REFERENCES dbo.Estudiante(IdEstudiante),
    CONSTRAINT FK_RutaEstudiante_ParaderoSubida FOREIGN KEY (IdParaderoSubida) REFERENCES dbo.Paradero(IdParadero),
    CONSTRAINT FK_RutaEstudiante_ParaderoBajada FOREIGN KEY (IdParaderoBajada) REFERENCES dbo.Paradero(IdParadero),
    CONSTRAINT UQ_RutaEstudiante_Codigo UNIQUE (CodigoRutaEstudiante)
);
GO

CREATE TABLE dbo.Recorrido
(
    IdRecorrido UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Recorrido PRIMARY KEY,
    IdRuta UNIQUEIDENTIFIER NOT NULL,
    IdBus UNIQUEIDENTIFIER NOT NULL,
    IdConductor UNIQUEIDENTIFIER NOT NULL,
    CodigoRecorrido VARCHAR(20) NOT NULL,
    Fecha DATE NOT NULL,
    HoraInicioProgramada TIME(0) NULL,
    HoraFinProgramada TIME(0) NULL,
    HoraInicioReal DATETIME2(0) NULL,
    HoraFinReal DATETIME2(0) NULL,
    EstadoRecorrido VARCHAR(20) NOT NULL CONSTRAINT DF_Recorrido_EstadoRecorrido DEFAULT ('PROGRAMADO'),
    Observaciones VARCHAR(500) NULL,
    Estado BIT NOT NULL CONSTRAINT DF_Recorrido_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Recorrido_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT FK_Recorrido_Ruta FOREIGN KEY (IdRuta) REFERENCES dbo.Ruta(IdRuta),
    CONSTRAINT FK_Recorrido_Bus FOREIGN KEY (IdBus) REFERENCES dbo.Bus(IdBus),
    CONSTRAINT FK_Recorrido_Conductor FOREIGN KEY (IdConductor) REFERENCES dbo.Conductor(IdConductor),
    CONSTRAINT UQ_Recorrido_Codigo UNIQUE (CodigoRecorrido)
);
GO

CREATE TABLE dbo.UbicacionBus
(
    IdUbicacion UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_UbicacionBus PRIMARY KEY,
    IdRecorrido UNIQUEIDENTIFIER NOT NULL,
    CodigoUbicacion VARCHAR(20) NOT NULL,
    Latitud DECIMAL(10,7) NOT NULL,
    Longitud DECIMAL(10,7) NOT NULL,
    Velocidad DECIMAL(8,2) NULL,
    PrecisionMetros DECIMAL(8,2) NULL,
    FechaHora DATETIME2(0) NOT NULL,
    Fuente VARCHAR(50) NULL,
    Estado BIT NOT NULL CONSTRAINT DF_UbicacionBus_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_UbicacionBus_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT FK_UbicacionBus_Recorrido FOREIGN KEY (IdRecorrido) REFERENCES dbo.Recorrido(IdRecorrido),
    CONSTRAINT UQ_UbicacionBus_Codigo UNIQUE (CodigoUbicacion)
);
GO

CREATE TABLE dbo.EventoAbordaje
(
    IdEvento UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_EventoAbordaje PRIMARY KEY,
    IdRecorrido UNIQUEIDENTIFIER NOT NULL,
    IdEstudiante UNIQUEIDENTIFIER NOT NULL,
    IdParadero UNIQUEIDENTIFIER NULL,
    RegistradoPor UNIQUEIDENTIFIER NULL,
    CodigoEvento VARCHAR(20) NOT NULL,
    TipoEvento VARCHAR(20) NOT NULL,
    FechaHora DATETIME2(0) NOT NULL,
    Observacion VARCHAR(250) NULL,
    Estado BIT NOT NULL CONSTRAINT DF_EventoAbordaje_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_EventoAbordaje_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT FK_EventoAbordaje_Recorrido FOREIGN KEY (IdRecorrido) REFERENCES dbo.Recorrido(IdRecorrido),
    CONSTRAINT FK_EventoAbordaje_Estudiante FOREIGN KEY (IdEstudiante) REFERENCES dbo.Estudiante(IdEstudiante),
    CONSTRAINT FK_EventoAbordaje_Paradero FOREIGN KEY (IdParadero) REFERENCES dbo.Paradero(IdParadero),
    CONSTRAINT FK_EventoAbordaje_Usuario FOREIGN KEY (RegistradoPor) REFERENCES dbo.Usuario(IdUsuario),
    CONSTRAINT UQ_EventoAbordaje_Codigo UNIQUE (CodigoEvento)
);
GO

CREATE TABLE dbo.Notificacion
(
    IdNotificacion UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Notificacion PRIMARY KEY,
    IdPadre UNIQUEIDENTIFIER NOT NULL,
    IdEstudiante UNIQUEIDENTIFIER NULL,
    CodigoNotificacion VARCHAR(20) NOT NULL,
    Titulo VARCHAR(150) NOT NULL,
    Mensaje VARCHAR(1000) NOT NULL,
    TipoNotificacion VARCHAR(30) NOT NULL,
    Canal VARCHAR(30) NOT NULL,
    Leido BIT NOT NULL CONSTRAINT DF_Notificacion_Leido DEFAULT (0),
    FechaLectura DATETIME2(0) NULL,
    FechaEnvio DATETIME2(0) NOT NULL CONSTRAINT DF_Notificacion_FechaEnvio DEFAULT (SYSDATETIME()),
    Estado BIT NOT NULL CONSTRAINT DF_Notificacion_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Notificacion_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT FK_Notificacion_Padre FOREIGN KEY (IdPadre) REFERENCES dbo.PadreFamilia(IdPadre),
    CONSTRAINT FK_Notificacion_Estudiante FOREIGN KEY (IdEstudiante) REFERENCES dbo.Estudiante(IdEstudiante),
    CONSTRAINT UQ_Notificacion_Codigo UNIQUE (CodigoNotificacion)
);
GO

CREATE TABLE dbo.Incidencia
(
    IdIncidencia UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Incidencia PRIMARY KEY,
    IdRecorrido UNIQUEIDENTIFIER NOT NULL,
    IdConductor UNIQUEIDENTIFIER NOT NULL,
    ReportadoPor UNIQUEIDENTIFIER NULL,
    CodigoIncidencia VARCHAR(20) NOT NULL,
    TipoIncidencia VARCHAR(50) NOT NULL,
    Descripcion VARCHAR(1000) NOT NULL,
    FechaHora DATETIME2(0) NOT NULL,
    EstadoIncidencia VARCHAR(20) NOT NULL,
    Prioridad VARCHAR(20) NOT NULL,
    FechaCierre DATETIME2(0) NULL,
    Solucion VARCHAR(1000) NULL,
    Estado BIT NOT NULL CONSTRAINT DF_Incidencia_Estado DEFAULT (1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Incidencia_FechaCreacion DEFAULT (SYSDATETIME()),
    FechaActualizacion DATETIME2(0) NULL,
    FechaEliminacion DATETIME2(0) NULL,
    CONSTRAINT FK_Incidencia_Recorrido FOREIGN KEY (IdRecorrido) REFERENCES dbo.Recorrido(IdRecorrido),
    CONSTRAINT FK_Incidencia_Conductor FOREIGN KEY (IdConductor) REFERENCES dbo.Conductor(IdConductor),
    CONSTRAINT FK_Incidencia_Usuario FOREIGN KEY (ReportadoPor) REFERENCES dbo.Usuario(IdUsuario),
    CONSTRAINT UQ_Incidencia_Codigo UNIQUE (CodigoIncidencia)
);
GO

CREATE TABLE dbo.Auditoria
(
    IdAuditoria UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Auditoria PRIMARY KEY,
    CodigoAuditoria VARCHAR(20) NOT NULL,
    Tabla VARCHAR(80) NOT NULL,
    IdRegistro UNIQUEIDENTIFIER NULL,
    Accion VARCHAR(20) NOT NULL,
    DatosAntes VARCHAR(MAX) NULL,
    DatosDespues VARCHAR(MAX) NULL,
    UsuarioId UNIQUEIDENTIFIER NULL,
    NombreUsuario VARCHAR(100) NULL,
    Ip VARCHAR(50) NULL,
    UserAgent VARCHAR(500) NULL,
    Modulo VARCHAR(80) NULL,
    Observacion VARCHAR(500) NULL,
    Fecha DATETIME2(0) NOT NULL CONSTRAINT DF_Auditoria_Fecha DEFAULT (SYSDATETIME()),
    Estado BIT NOT NULL CONSTRAINT DF_Auditoria_Estado DEFAULT (1),
    CONSTRAINT FK_Auditoria_Usuario FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuario(IdUsuario),
    CONSTRAINT UQ_Auditoria_Codigo UNIQUE (CodigoAuditoria)
);
GO

CREATE TABLE dbo.IA_Consulta
(
    IdConsulta UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_IA_Consulta PRIMARY KEY,
    UsuarioId UNIQUEIDENTIFIER NULL,
    IdRecorrido UNIQUEIDENTIFIER NULL,
    IdEstudiante UNIQUEIDENTIFIER NULL,
    IdIncidencia UNIQUEIDENTIFIER NULL,
    CodigoConsulta VARCHAR(20) NOT NULL,
    Modulo VARCHAR(60) NOT NULL,
    TipoConsulta VARCHAR(60) NOT NULL,
    PromptEnviado VARCHAR(MAX) NOT NULL,
    ContextoEnviado VARCHAR(MAX) NULL,
    RespuestaIA VARCHAR(MAX) NULL,
    TokensEntrada INT NULL,
    TokensSalida INT NULL,
    CostoEstimado DECIMAL(10,4) NULL,
    EstadoConsulta VARCHAR(20) NOT NULL,
    FechaConsulta DATETIME2(0) NOT NULL CONSTRAINT DF_IA_Consulta_Fecha DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT UQ_IA_Consulta_Codigo UNIQUE (CodigoConsulta)
);
GO

CREATE TABLE dbo.IA_Prediccion
(
    IdPrediccion UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_IA_Prediccion PRIMARY KEY,
    IdRecorrido UNIQUEIDENTIFIER NULL,
    IdEstudiante UNIQUEIDENTIFIER NULL,
    CodigoPrediccion VARCHAR(20) NOT NULL,
    TipoPrediccion VARCHAR(60) NOT NULL,
    ValorPredicho DECIMAL(18,6) NULL,
    Confianza DECIMAL(5,2) NULL,
    DatosEntrada VARCHAR(MAX) NULL,
    Explicacion VARCHAR(MAX) NULL,
    FechaGeneracion DATETIME2(0) NOT NULL CONSTRAINT DF_IA_Prediccion_Fecha DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT UQ_IA_Prediccion_Codigo UNIQUE (CodigoPrediccion)
);
GO

CREATE TABLE dbo.CalificacionConductor
(
    IdCalificacion UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_CalificacionConductor PRIMARY KEY,
    IdPadre UNIQUEIDENTIFIER NOT NULL,
    IdConductor UNIQUEIDENTIFIER NOT NULL,
    IdEstudiante UNIQUEIDENTIFIER NULL,
    Puntaje INT NOT NULL,
    Comentario NVARCHAR(250) NULL,
    FechaRegistro DATETIME NOT NULL CONSTRAINT DF_CalificacionConductor_FechaRegistro DEFAULT (GETDATE()),
    Estado BIT NOT NULL CONSTRAINT DF_CalificacionConductor_Estado DEFAULT (1),
    CONSTRAINT FK_CalificacionConductor_Padre FOREIGN KEY (IdPadre) REFERENCES dbo.PadreFamilia(IdPadre),
    CONSTRAINT FK_CalificacionConductor_Conductor FOREIGN KEY (IdConductor) REFERENCES dbo.Conductor(IdConductor),
    CONSTRAINT FK_CalificacionConductor_Estudiante FOREIGN KEY (IdEstudiante) REFERENCES dbo.Estudiante(IdEstudiante),
    CONSTRAINT CK_CalificacionConductor_Puntaje CHECK (Puntaje BETWEEN 1 AND 5)
);
GO

CREATE INDEX IX_Usuario_IdRol ON dbo.Usuario(IdRol);
CREATE INDEX IX_Estudiante_IdPadre ON dbo.Estudiante(IdPadre);
CREATE INDEX IX_Paradero_IdRuta ON dbo.Paradero(IdRuta);
CREATE INDEX IX_RutaEstudiante_RutaEstudiante ON dbo.RutaEstudiante(IdRuta, IdEstudiante);
CREATE INDEX IX_Recorrido_ConductorFecha ON dbo.Recorrido(IdConductor, Fecha);
CREATE INDEX IX_EventoAbordaje_RecorridoEstudiante ON dbo.EventoAbordaje(IdRecorrido, IdEstudiante);
CREATE INDEX IX_UbicacionBus_RecorridoFecha ON dbo.UbicacionBus(IdRecorrido, FechaHora DESC);
CREATE INDEX IX_Notificacion_PadreLeido ON dbo.Notificacion(IdPadre, Leido, FechaEnvio DESC);
CREATE INDEX IX_Incidencia_RecorridoEstado ON dbo.Incidencia(IdRecorrido, EstadoIncidencia);
GO
