/* CapiMovilDB_Reconstruida - instalacion completa sin SQLCMD Mode */

/* ===== 00_Crear_Esquema.sql ===== */
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

/* ===== 01_Corregir_Claves_Default.sql ===== */
USE CapiMovilDB_Reconstruida;
GO

/* Permite que los INSERT de la aplicacion omitan los GUID de estas entidades. */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.default_constraints dc
    INNER JOIN sys.columns c
        ON c.object_id = dc.parent_object_id
       AND c.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID(N'dbo.Usuario')
      AND c.name = N'IdUsuario'
)
BEGIN
    ALTER TABLE dbo.Usuario
        ADD CONSTRAINT DF_Usuario_IdUsuario DEFAULT (NEWID()) FOR IdUsuario;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.default_constraints dc
    INNER JOIN sys.columns c
        ON c.object_id = dc.parent_object_id
       AND c.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID(N'dbo.Estudiante')
      AND c.name = N'IdEstudiante'
)
BEGIN
    ALTER TABLE dbo.Estudiante
        ADD CONSTRAINT DF_Estudiante_IdEstudiante DEFAULT (NEWID()) FOR IdEstudiante;
END;
GO


/* ===== 05_Funciones_Auxiliares.sql ===== */
USE CapiMovilDB_Reconstruida;
GO

CREATE OR ALTER FUNCTION dbo.fn_Codigo_Sanitizar(@Texto NVARCHAR(4000))
RETURNS NVARCHAR(4000)
AS
BEGIN
    DECLARE @s NVARCHAR(4000) = UPPER(LTRIM(RTRIM(ISNULL(@Texto, N''))));
    DECLARE @r NVARCHAR(4000) = N'';
    DECLARE @i INT = 1;
    DECLARE @c NCHAR(1);

    SET @s = REPLACE(@s, N'Á', N'A');
    SET @s = REPLACE(@s, N'É', N'E');
    SET @s = REPLACE(@s, N'Í', N'I');
    SET @s = REPLACE(@s, N'Ó', N'O');
    SET @s = REPLACE(@s, N'Ú', N'U');
    SET @s = REPLACE(@s, N'Ü', N'U');
    SET @s = REPLACE(@s, N'Ñ', N'N');

    WHILE @i <= LEN(@s)
    BEGIN
        SET @c = SUBSTRING(@s, @i, 1);
        IF @c LIKE N'[A-Z0-9]' SET @r += @c;
        SET @i += 1;
    END;

    RETURN @r;
END;
GO

CREATE OR ALTER FUNCTION dbo.fn_Bus_Codigo_Fragmento
(
    @Placa NVARCHAR(100),
    @Marca NVARCHAR(100)
)
RETURNS VARCHAR(6)
AS
BEGIN
    DECLARE @placaSan NVARCHAR(100) = dbo.fn_Codigo_Sanitizar(@Placa);
    DECLARE @marcaSan NVARCHAR(100) = dbo.fn_Codigo_Sanitizar(@Marca);
    DECLARE @placaFrag NVARCHAR(6) = LEFT(@placaSan, 3);
    DECLARE @marcaFrag NVARCHAR(6) = LEFT(@marcaSan, 3);

    IF LEN(@placaFrag) < 3 SET @placaFrag += LEFT(@marcaSan, 3 - LEN(@placaFrag));
    IF LEN(@marcaFrag) < 3 SET @marcaFrag += LEFT(@placaSan, 3 - LEN(@marcaFrag));
    IF LEN(@placaFrag) < 3 SET @placaFrag += REPLICATE('B', 3 - LEN(@placaFrag));
    IF LEN(@marcaFrag) < 3 SET @marcaFrag += REPLICATE('U', 3 - LEN(@marcaFrag));

    RETURN CONVERT(VARCHAR(6), LEFT(@placaFrag, 3) + LEFT(@marcaFrag, 3));
END;
GO

/* ===== 10_Procedimientos_Base.sql ===== */
﻿USE [CapiMovilDB_Reconstruida]
GO
/****** Object:  StoredProcedure [dbo].[sp_Auditoria_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =============================================
   SECCIÓN E: CONSULTA DE AUDITORÍA (USUARIO)
   ============================================= */
CREATE   PROCEDURE [dbo].[sp_Auditoria_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.IdAuditoria,
        a.CodigoAuditoria,
        a.Tabla,
        a.IdRegistro,
        a.Accion,
        a.DatosAntes,
        a.DatosDespues,
        a.UsuarioId,
        COALESCE(NULLIF(a.NombreUsuario, ''), u.Username, 'SISTEMA') AS NombreUsuario,
        a.Ip,
        a.UserAgent,
        a.Modulo,
        a.Observacion,
        a.Fecha
    FROM dbo.Auditoria a
    LEFT JOIN dbo.Usuario u ON u.IdUsuario = a.UsuarioId
    ORDER BY a.Fecha DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Auditoria_ListarPorAccion]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Auditoria_ListarPorAccion]
(
    @Accion VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.IdAuditoria,
        a.CodigoAuditoria,
        a.Tabla,
        a.IdRegistro,
        a.Accion,
        a.DatosAntes,
        a.DatosDespues,
        a.UsuarioId,
        a.NombreUsuario,
        a.Ip,
        a.UserAgent,
        a.Modulo,
        a.Observacion,
        a.Fecha
    FROM Auditoria a
    WHERE a.Accion = @Accion
    ORDER BY a.Fecha DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Auditoria_ListarPorTabla]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Auditoria_ListarPorTabla]
(
    @Tabla VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.IdAuditoria,
        a.CodigoAuditoria,
        a.Tabla,
        a.IdRegistro,
        a.Accion,
        a.DatosAntes,
        a.DatosDespues,
        a.UsuarioId,
        a.NombreUsuario,
        a.Ip,
        a.UserAgent,
        a.Modulo,
        a.Observacion,
        a.Fecha
    FROM Auditoria a
    WHERE a.Tabla = @Tabla
    ORDER BY a.Fecha DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Auditoria_ListarPorUsuario]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[sp_Auditoria_ListarPorUsuario]
(
    @UsuarioId UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.IdAuditoria,
        a.CodigoAuditoria,
        a.Tabla,
        a.IdRegistro,
        a.Accion,
        a.DatosAntes,
        a.DatosDespues,
        a.UsuarioId,
        a.NombreUsuario,
        a.Ip,
        a.UserAgent,
        a.Modulo,
        a.Observacion,
        a.Fecha
    FROM Auditoria a
    WHERE a.UsuarioId = @UsuarioId
    ORDER BY a.Fecha DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Auditoria_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Auditoria_ObtenerPorId]
    @IdAuditoria UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.IdAuditoria,
        a.CodigoAuditoria,
        a.Tabla,
        a.IdRegistro,
        a.Accion,
        a.DatosAntes,
        a.DatosDespues,
        a.UsuarioId,
        COALESCE(NULLIF(a.NombreUsuario, ''), u.Username, 'SISTEMA') AS NombreUsuario,
        a.Ip,
        a.UserAgent,
        a.Modulo,
        a.Observacion,
        a.Fecha
    FROM dbo.Auditoria a
    LEFT JOIN dbo.Usuario u ON u.IdUsuario = a.UsuarioId
    WHERE a.IdAuditoria = @IdAuditoria;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Auditoria_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =============================================
   SECCIÓN D: AUDITORÍA (CÓDIGO + DATOS LIMPIOS)
   ============================================= */
CREATE   PROCEDURE [dbo].[sp_Auditoria_Registrar]
(
    @Tabla VARCHAR(100),
    @IdRegistro UNIQUEIDENTIFIER = NULL,
    @Accion VARCHAR(20),
    @DatosAntes NVARCHAR(MAX) = NULL,
    @DatosDespues NVARCHAR(MAX) = NULL,
    @UsuarioId UNIQUEIDENTIFIER = NULL,
    @NombreUsuario VARCHAR(120) = NULL,
    @Ip VARCHAR(50) = NULL,
    @UserAgent VARCHAR(300) = NULL,
    @Modulo VARCHAR(100) = NULL,
    @Observacion VARCHAR(250) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdAuditoria UNIQUEIDENTIFIER = NEWID();
    DECLARE @Correlativo INT = 0;
    DECLARE @CodigoGenerado VARCHAR(20);

    BEGIN TRY
        BEGIN TRAN;

        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'AUD')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('AUD', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'AUD';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'AUD';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoAuditoria, 4) AS INT)), 0) + 1
            FROM dbo.Auditoria
            WHERE CodigoAuditoria LIKE 'AUD-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('AUD-', RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Auditoria
        (
            IdAuditoria, CodigoAuditoria, Tabla, IdRegistro, Accion,
            DatosAntes, DatosDespues, UsuarioId, NombreUsuario, Ip,
            UserAgent, Modulo, Observacion, Fecha
        )
        VALUES
        (
            @IdAuditoria,
            @CodigoGenerado,
            LEFT(LTRIM(RTRIM(@Tabla)), 100),
            @IdRegistro,
            LEFT(UPPER(LTRIM(RTRIM(@Accion))), 20),
            @DatosAntes,
            @DatosDespues,
            @UsuarioId,
            NULLIF(LEFT(LTRIM(RTRIM(ISNULL(@NombreUsuario, ''))), 120), ''),
            NULLIF(LEFT(LTRIM(RTRIM(ISNULL(@Ip, ''))), 50), ''),
            NULLIF(LEFT(LTRIM(RTRIM(ISNULL(@UserAgent, ''))), 300), ''),
            NULLIF(LEFT(LTRIM(RTRIM(ISNULL(@Modulo, ''))), 100), ''),
            NULLIF(LEFT(LTRIM(RTRIM(ISNULL(@Observacion, ''))), 250), ''),
            GETDATE()
        );

        COMMIT;

        SELECT
            1 AS FilasAfectadas,
            @IdAuditoria AS IdAuditoria,
            @CodigoGenerado AS CodigoGenerado,
            CAST(NULL AS VARCHAR(200)) AS Mensaje;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;

        SELECT
            0 AS FilasAfectadas,
            CAST(NULL AS UNIQUEIDENTIFIER) AS IdAuditoria,
            CAST(NULL AS VARCHAR(20)) AS CodigoGenerado,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Bus_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Bus_Actualizar]
(
    @IdBus UNIQUEIDENTIFIER,
    @Placa VARCHAR(15),
    @Marca VARCHAR(50) = NULL,
    @Modelo VARCHAR(50) = NULL,
    @Color VARCHAR(30) = NULL,
    @Anio INT = NULL,
    @Capacidad INT,
    @EstadoOperacion VARCHAR(20),
    @SeguroVigente BIT,
    @FechaVencimientoSOAT DATE = NULL,
    @FechaRevisionTecnica DATE = NULL,
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Bus
    SET
        Placa = @Placa,
        Marca = @Marca,
        Modelo = @Modelo,
        Color = @Color,
        Anio = @Anio,
        Capacidad = @Capacidad,
        EstadoOperacion = @EstadoOperacion,
        SeguroVigente = @SeguroVigente,
        FechaVencimientoSOAT = @FechaVencimientoSOAT,
        FechaRevisionTecnica = @FechaRevisionTecnica,
        Estado = @Estado,
        FechaActualizacion = SYSDATETIME()
    WHERE IdBus = @IdBus
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Bus_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[sp_Bus_EliminarLogico]
(
    @IdBus UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Bus
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdBus = @IdBus
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Bus_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Bus_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdBus,
        CodigoBus,
        Placa,
        Marca,
        Modelo,
        Color,
        Anio,
        Capacidad,
        EstadoOperacion,
        SeguroVigente,
        FechaVencimientoSOAT,
        FechaRevisionTecnica,
        Estado,
        FechaCreacion,
        FechaActualizacion,
        FechaEliminacion
    FROM Bus
    WHERE FechaEliminacion IS NULL
    ORDER BY FechaCreacion DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Bus_ListarActivos]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Bus_ListarActivos]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdBus,
        CodigoBus,
        Placa
    FROM Bus
    WHERE FechaEliminacion IS NULL
      AND Estado = 1
      AND EstadoOperacion = 'ACTIVO'
    ORDER BY Placa;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Bus_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Bus_ObtenerPorId]
(
    @IdBus UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdBus,
        CodigoBus,
        Placa,
        Marca,
        Modelo,
        Color,
        Anio,
        Capacidad,
        EstadoOperacion,
        SeguroVigente,
        FechaVencimientoSOAT,
        FechaRevisionTecnica,
        Estado,
        FechaCreacion,
        FechaActualizacion,
        FechaEliminacion
    FROM Bus
    WHERE IdBus = @IdBus
      AND FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Bus_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   SP BUS REGISTRAR (fuente oficial de CodigoBus)
   ========================================================= */
CREATE   PROCEDURE [dbo].[sp_Bus_Registrar]
    @Placa VARCHAR(20),
    @Marca VARCHAR(60) = NULL,
    @Modelo VARCHAR(60) = NULL,
    @Color VARCHAR(30) = NULL,
    @Anio INT = NULL,
    @Capacidad INT,
    @EstadoOperacion VARCHAR(20),
    @SeguroVigente BIT,
    @FechaVencimientoSOAT DATE = NULL,
    @FechaRevisionTecnica DATE = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @Fragmento VARCHAR(6);
    DECLARE @CodigoGenerado VARCHAR(20);

    SET @Fragmento = dbo.fn_Bus_Codigo_Fragmento(@Placa, @Marca);

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'BUS')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('BUS', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'BUS';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'BUS';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoBus, 4) AS INT)), 0) + 1
            FROM dbo.Bus
            WHERE CodigoBus LIKE 'BUS-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('BUS-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Bus
        (
            IdBus, CodigoBus, Placa, Marca, Modelo, Color, Anio, Capacidad,
            EstadoOperacion, SeguroVigente, FechaVencimientoSOAT, FechaRevisionTecnica,
            Estado, FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            NEWID(), @CodigoGenerado, @Placa, NULLIF(@Marca, ''), NULLIF(@Modelo, ''), NULLIF(@Color, ''),
            @Anio, @Capacidad, @EstadoOperacion, @SeguroVigente, @FechaVencimientoSOAT, @FechaRevisionTecnica,
            @Estado, SYSUTCDATETIME(), NULL, NULL
        );

        COMMIT TRANSACTION;
        SELECT CAST(1 AS INT) AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT CAST(0 AS INT) AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Conductor_Actualizar]
    @IdConductor UNIQUEIDENTIFIER,
    @IdUsuario UNIQUEIDENTIFIER,
    @Nombres VARCHAR(80),
    @ApellidoPaterno VARCHAR(60),
    @ApellidoMaterno VARCHAR(60),
    @DNI VARCHAR(8) = NULL,
    @Licencia VARCHAR(30),
    @CategoriaLicencia VARCHAR(10) = NULL,
    @Telefono VARCHAR(20) = NULL,
    @Direccion VARCHAR(200) = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Conductor
    SET
        IdUsuario = @IdUsuario,
        Nombres = @Nombres,
        ApellidoPaterno = @ApellidoPaterno,
        ApellidoMaterno = @ApellidoMaterno,
        DNI = NULLIF(@DNI, ''),
        Licencia = @Licencia,
        CategoriaLicencia = NULLIF(@CategoriaLicencia, ''),
        Telefono = NULLIF(@Telefono, ''),
        Direccion = NULLIF(@Direccion, ''),
        Estado = @Estado,
        FechaActualizacion = SYSUTCDATETIME()
    WHERE IdConductor = @IdConductor
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_Eliminar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Conductor_Eliminar]
    @IdConductor UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Conductor
    SET
        Estado = 0,
        FechaEliminacion = SYSUTCDATETIME(),
        FechaActualizacion = SYSUTCDATETIME()
    WHERE IdConductor = @IdConductor
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Conductor_EliminarLogico]
    @IdConductor UNIQUEIDENTIFIER
AS
BEGIN
    EXEC dbo.sp_Conductor_Eliminar @IdConductor;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_ExistePorDni]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Conductor_ExistePorDni]
    @DNI VARCHAR(8),
    @IdConductorExcluir UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(1)
    FROM dbo.Conductor c
    WHERE c.DNI = @DNI
      AND c.FechaEliminacion IS NULL
      AND (@IdConductorExcluir IS NULL OR c.IdConductor <> @IdConductorExcluir);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_ExistePorIdUsuario]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Conductor_ExistePorIdUsuario]
    @IdUsuario UNIQUEIDENTIFIER,
    @IdConductorExcluir UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(1)
    FROM dbo.Conductor c
    WHERE c.IdUsuario = @IdUsuario
      AND c.FechaEliminacion IS NULL
      AND (@IdConductorExcluir IS NULL OR c.IdConductor <> @IdConductorExcluir);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_ExistePorLicencia]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Conductor_ExistePorLicencia]
    @Licencia VARCHAR(30),
    @IdConductorExcluir UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(1)
    FROM dbo.Conductor c
    WHERE c.Licencia = @Licencia
      AND c.FechaEliminacion IS NULL
      AND (@IdConductorExcluir IS NULL OR c.IdConductor <> @IdConductorExcluir);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Conductor_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.IdConductor,
        c.IdUsuario,
        c.CodigoConductor,
        c.Nombres,
        c.ApellidoPaterno,
        c.ApellidoMaterno,
        c.DNI,
        c.Licencia,
        c.CategoriaLicencia,
        c.Telefono,
        c.Direccion,
        c.Estado,
        c.FechaCreacion,
        c.FechaActualizacion,
        c.FechaEliminacion
    FROM dbo.Conductor c
    WHERE c.FechaEliminacion IS NULL
    ORDER BY c.FechaCreacion DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_ListarActivos]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Conductor_ListarActivos]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdConductor,
        CodigoConductor,
        Nombres,
        ApellidoPaterno,
        ApellidoMaterno
    FROM Conductor
    WHERE FechaEliminacion IS NULL
      AND Estado = 1
    ORDER BY Nombres, ApellidoPaterno;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_ListarPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Conductor_ListarPorId]
    @IdConductor UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.IdConductor,
        c.IdUsuario,
        c.CodigoConductor,
        c.Nombres,
        c.ApellidoPaterno,
        c.ApellidoMaterno,
        c.DNI,
        c.Licencia,
        c.CategoriaLicencia,
        c.Telefono,
        c.Direccion,
        c.Estado,
        c.FechaCreacion,
        c.FechaActualizacion,
        c.FechaEliminacion
    FROM dbo.Conductor c
    WHERE c.IdConductor = @IdConductor
      AND c.FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_ListarPorIdUsuario]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Conductor_ListarPorIdUsuario]
    @IdUsuario UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        c.IdConductor,
        c.IdUsuario,
        c.CodigoConductor,
        c.Nombres,
        c.ApellidoPaterno,
        c.ApellidoMaterno,
        c.DNI,
        c.Licencia,
        c.CategoriaLicencia,
        c.Telefono,
        c.Direccion,
        c.Estado,
        c.FechaCreacion,
        c.FechaActualizacion,
        c.FechaEliminacion
    FROM dbo.Conductor c
    WHERE c.IdUsuario = @IdUsuario
      AND c.FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Conductor_ObtenerPorId]
    @IdConductor UNIQUEIDENTIFIER
AS
BEGIN
    EXEC dbo.sp_Conductor_ListarPorId @IdConductor;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Conductor_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Conductor_Registrar]
    @IdUsuario UNIQUEIDENTIFIER,
    @Nombres VARCHAR(80),
    @ApellidoPaterno VARCHAR(60),
    @ApellidoMaterno VARCHAR(60),
    @DNI VARCHAR(8) = NULL,
    @Licencia VARCHAR(30),
    @CategoriaLicencia VARCHAR(10) = NULL,
    @Telefono VARCHAR(20) = NULL,
    @Direccion VARCHAR(200) = NULL,
    @Estado BIT,
    @CodigoGenerado VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @Fragmento VARCHAR(6);

    SET @Fragmento =
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@Nombres, 'X'))), 2)) +
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@ApellidoPaterno, 'X'))), 2)) +
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@ApellidoMaterno, 'X'))), 2));

    BEGIN TRANSACTION;

    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'CONDUCTOR')
            BEGIN
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero)
                VALUES ('CONDUCTOR', 0);
            END

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'CONDUCTOR';

            SELECT @Correlativo = UltimoNumero
              FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
             WHERE TipoCodigo = 'CONDUCTOR';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoConductor, 4) AS INT)), 0) + 1
            FROM dbo.Conductor
            WHERE CodigoConductor LIKE 'CON-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('CON-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Conductor
    (
        IdConductor,
        IdUsuario,
        CodigoConductor,
        Nombres,
        ApellidoPaterno,
        ApellidoMaterno,
        DNI,
        Licencia,
        CategoriaLicencia,
        Telefono,
        Direccion,
        Estado,
        FechaCreacion,
        FechaActualizacion,
        FechaEliminacion
    )
        VALUES
        (
            NEWID(),
            @IdUsuario,
            @CodigoGenerado,
            @Nombres,
            @ApellidoPaterno,
            @ApellidoMaterno,
            NULLIF(@DNI, ''),
            @Licencia,
            NULLIF(@CategoriaLicencia, ''),
            NULLIF(@Telefono, ''),
            NULLIF(@Direccion, ''),
            @Estado,
            SYSUTCDATETIME(),
            NULL,
            NULL
        );

        COMMIT TRANSACTION;

        SELECT
            @@ROWCOUNT AS FilasAfectadas,
            @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Estudiante_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Estudiante_Actualizar]
(
    @IdEstudiante UNIQUEIDENTIFIER,
    @IdPadre UNIQUEIDENTIFIER,
    @CodigoEstudiante VARCHAR(25),
    @Nombres VARCHAR(50),
    @ApellidoPaterno VARCHAR(50),
    @ApellidoMaterno VARCHAR(50),
    @DNI CHAR(8) = NULL,
    @FechaNacimiento DATE = NULL,
    @Genero CHAR(1) = NULL,
    @Grado VARCHAR(30) = NULL,
    @Seccion VARCHAR(20) = NULL,
    @Direccion VARCHAR(200) = NULL,
    @LatitudCasa DECIMAL(10,7) = NULL,
    @LongitudCasa DECIMAL(10,7) = NULL,
    @FotoUrl VARCHAR(300) = NULL,
    @Observaciones VARCHAR(250) = NULL,
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Estudiante
    SET
        IdPadre = @IdPadre,
        CodigoEstudiante = @CodigoEstudiante,
        Nombres = @Nombres,
        ApellidoPaterno = @ApellidoPaterno,
        ApellidoMaterno = @ApellidoMaterno,
        DNI = @DNI,
        FechaNacimiento = @FechaNacimiento,
        Genero = @Genero,
        Grado = @Grado,
        Seccion = @Seccion,
        Direccion = @Direccion,
        LatitudCasa = @LatitudCasa,
        LongitudCasa = @LongitudCasa,
        FotoUrl = @FotoUrl,
        Observaciones = @Observaciones,
        Estado = @Estado,
        FechaActualizacion = SYSDATETIME()
    WHERE IdEstudiante = @IdEstudiante
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Estudiante_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Estudiante_EliminarLogico]
(
    @IdEstudiante UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Estudiante
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdEstudiante = @IdEstudiante
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Estudiante_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   ESTUDIANTE
   ========================================================= */

CREATE   PROCEDURE [dbo].[sp_Estudiante_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.IdEstudiante,
        e.IdPadre,
        p.CodigoPadre,
        CONCAT(p.Nombres, ' ', p.ApellidoPaterno, ' ', p.ApellidoMaterno) AS NombrePadre,
        e.CodigoEstudiante,
        e.Nombres,
        e.ApellidoPaterno,
        e.ApellidoMaterno,
        e.DNI,
        e.FechaNacimiento,
        e.Genero,
        e.Grado,
        e.Seccion,
        e.Direccion,
        e.LatitudCasa,
        e.LongitudCasa,
        e.FotoUrl,
        e.Observaciones,
        e.Estado,
        e.FechaCreacion,
        e.FechaActualizacion,
        e.FechaEliminacion
    FROM Estudiante e
    INNER JOIN PadreFamilia p ON e.IdPadre = p.IdPadre
    WHERE e.FechaEliminacion IS NULL
    ORDER BY e.ApellidoPaterno, e.ApellidoMaterno, e.Nombres;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Estudiante_ListarActivos]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[sp_Estudiante_ListarActivos]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdEstudiante,
        CodigoEstudiante,
        Nombres,
        ApellidoPaterno,
        ApellidoMaterno
    FROM Estudiante
    WHERE FechaEliminacion IS NULL
      AND Estado = 1
    ORDER BY Nombres, ApellidoPaterno, ApellidoMaterno;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Estudiante_ObtenerPadrePorEstudiante]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Estudiante_ObtenerPadrePorEstudiante]
(
    @IdEstudiante UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT IdPadre
    FROM Estudiante
    WHERE IdEstudiante = @IdEstudiante
      AND FechaEliminacion IS NULL
      AND Estado = 1;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Estudiante_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Estudiante_ObtenerPorId]
(
    @IdEstudiante UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.IdEstudiante,
        e.IdPadre,
        p.CodigoPadre,
        CONCAT(p.Nombres, ' ', p.ApellidoPaterno, ' ', p.ApellidoMaterno) AS NombrePadre,
        e.CodigoEstudiante,
        e.Nombres,
        e.ApellidoPaterno,
        e.ApellidoMaterno,
        e.DNI,
        e.FechaNacimiento,
        e.Genero,
        e.Grado,
        e.Seccion,
        e.Direccion,
        e.LatitudCasa,
        e.LongitudCasa,
        e.FotoUrl,
        e.Observaciones,
        e.Estado,
        e.FechaCreacion,
        e.FechaActualizacion,
        e.FechaEliminacion
    FROM Estudiante e
    INNER JOIN PadreFamilia p ON e.IdPadre = p.IdPadre
    WHERE e.IdEstudiante = @IdEstudiante
      AND e.FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Estudiante_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Estudiante_Registrar]
    @IdPadre UNIQUEIDENTIFIER,
    @Nombres VARCHAR(80),
    @ApellidoPaterno VARCHAR(60),
    @ApellidoMaterno VARCHAR(60),
    @DNI VARCHAR(8) = NULL,
    @FechaNacimiento DATE = NULL,
    @Genero VARCHAR(1) = NULL,
    @Grado VARCHAR(30) = NULL,
    @Seccion VARCHAR(20) = NULL,
    @Direccion VARCHAR(200) = NULL,
    @LatitudCasa DECIMAL(10,7) = NULL,
    @LongitudCasa DECIMAL(10,7) = NULL,
    @FotoUrl VARCHAR(250) = NULL,
    @Observaciones VARCHAR(300) = NULL,
    @Estado BIT,
    @CodigoGenerado VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @Fragmento NVARCHAR(6);

    SET @Fragmento =
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@Nombres, 'X'))), 2)) +
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@ApellidoPaterno, 'X'))), 2)) +
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@ApellidoMaterno, 'X'))), 2));

    BEGIN TRANSACTION;

    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'ESTUDIANTE')
            BEGIN
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero)
                VALUES ('ESTUDIANTE', 0);
            END

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'ESTUDIANTE';

            SELECT @Correlativo = UltimoNumero
              FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
             WHERE TipoCodigo = 'ESTUDIANTE';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoEstudiante, 4) AS INT)), 0) + 1
            FROM dbo.Estudiante
            WHERE CodigoEstudiante LIKE 'EST-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('EST-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Estudiante
    (
        IdPadre,
        CodigoEstudiante,
        Nombres,
        ApellidoPaterno,
        ApellidoMaterno,
        DNI,
        FechaNacimiento,
        Genero,
        Grado,
        Seccion,
        Direccion,
        LatitudCasa,
        LongitudCasa,
        FotoUrl,
        Observaciones,
        Estado
    )
        VALUES
        (
            @IdPadre,
            @CodigoGenerado,
            @Nombres,
            @ApellidoPaterno,
            @ApellidoMaterno,
            @DNI,
            @FechaNacimiento,
            @Genero,
            @Grado,
            @Seccion,
            @Direccion,
            @LatitudCasa,
            @LongitudCasa,
            @FotoUrl,
            @Observaciones,
            @Estado
        );

        COMMIT TRANSACTION;

        SELECT
            @@ROWCOUNT AS FilasAfectadas,
            @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_EventoAbordaje_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_EventoAbordaje_Actualizar]
(
    @IdEvento UNIQUEIDENTIFIER,
    @IdRecorrido UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER,
    @IdParadero UNIQUEIDENTIFIER = NULL,
    @RegistradoPor UNIQUEIDENTIFIER = NULL,
    @TipoEvento VARCHAR(20),
    @FechaHora DATETIME2,
    @Observacion VARCHAR(250) = NULL,
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE EventoAbordaje
    SET
        IdRecorrido = @IdRecorrido,
        IdEstudiante = @IdEstudiante,
        IdParadero = @IdParadero,
        RegistradoPor = @RegistradoPor,
        TipoEvento = @TipoEvento,
        FechaHora = @FechaHora,
        Observacion = @Observacion,
        Estado = @Estado,
        FechaActualizacion = SYSDATETIME()
    WHERE IdEvento = @IdEvento
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_EventoAbordaje_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_EventoAbordaje_EliminarLogico]
(
    @IdEvento UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE EventoAbordaje
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdEvento = @IdEvento
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_EventoAbordaje_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_EventoAbordaje_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.IdEvento,
        e.IdRecorrido,
        e.IdEstudiante,
        e.IdParadero,
        e.RegistradoPor,
        e.CodigoEvento,
        e.TipoEvento,
        e.FechaHora,
        e.Observacion,
        e.Estado,
        e.FechaCreacion,
        e.FechaActualizacion,
        e.FechaEliminacion,
        r.CodigoRecorrido,
        es.CodigoEstudiante,
        es.Nombres AS NombresEstudiante,
        es.ApellidoPaterno AS ApellidoPaternoEstudiante,
        p.CodigoParadero,
        p.Nombre AS NombreParadero
    FROM EventoAbordaje e
    INNER JOIN Recorrido r ON e.IdRecorrido = r.IdRecorrido
    INNER JOIN Estudiante es ON e.IdEstudiante = es.IdEstudiante
    LEFT JOIN Paradero p ON e.IdParadero = p.IdParadero
    WHERE e.FechaEliminacion IS NULL
    ORDER BY e.FechaHora DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_EventoAbordaje_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_EventoAbordaje_ObtenerPorId]
(
    @IdEvento UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdEvento,
        IdRecorrido,
        IdEstudiante,
        IdParadero,
        RegistradoPor,
        CodigoEvento,
        TipoEvento,
        FechaHora,
        Observacion,
        Estado
    FROM EventoAbordaje
    WHERE IdEvento = @IdEvento
      AND FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_EventoAbordaje_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_EventoAbordaje_Registrar]
    @IdRecorrido UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER,
    @IdParadero UNIQUEIDENTIFIER = NULL,
    @RegistradoPor UNIQUEIDENTIFIER = NULL,
    @TipoEvento VARCHAR(20),
    @FechaHora DATETIME,
    @Observacion VARCHAR(300) = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @Nombre VARCHAR(80);
    DECLARE @Apellido VARCHAR(60);
    DECLARE @Fragmento VARCHAR(6);
    DECLARE @CodigoGenerado VARCHAR(20);

    SELECT @Nombre = e.Nombres, @Apellido = e.ApellidoPaterno
    FROM dbo.Estudiante e
    WHERE e.IdEstudiante = @IdEstudiante;

    SET @Fragmento =
        dbo.fn_Codigo_Fragmento(@TipoEvento, 2, 'EV') +
        dbo.fn_Codigo_Fragmento(@Nombre, 2, 'NO') +
        dbo.fn_Codigo_Fragmento(@Apellido, 2, 'AP');

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'EVE')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('EVE', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'EVE';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'EVE';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoEvento, 4) AS INT)), 0) + 1
            FROM dbo.EventoAbordaje
            WHERE CodigoEvento LIKE 'EVE-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('EVE-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.EventoAbordaje
        (
            IdEvento, IdRecorrido, IdEstudiante, IdParadero, RegistradoPor,
            CodigoEvento, TipoEvento, FechaHora, Observacion, Estado,
            FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            NEWID(), @IdRecorrido, @IdEstudiante, @IdParadero, @RegistradoPor,
            @CodigoGenerado, @TipoEvento, @FechaHora, NULLIF(@Observacion, ''), @Estado,
            SYSUTCDATETIME(), NULL, NULL
        );

        COMMIT TRANSACTION;
        SELECT CAST(1 AS INT) AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT CAST(0 AS INT) AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_IA_Consulta_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_IA_Consulta_Registrar]
    @UsuarioId UNIQUEIDENTIFIER = NULL,
    @IdRecorrido UNIQUEIDENTIFIER = NULL,
    @IdEstudiante UNIQUEIDENTIFIER = NULL,
    @IdIncidencia UNIQUEIDENTIFIER = NULL,
    @Modulo VARCHAR(60),
    @TipoConsulta VARCHAR(60),
    @PromptEnviado VARCHAR(MAX),
    @ContextoEnviado VARCHAR(MAX) = NULL,
    @RespuestaIA VARCHAR(MAX) = NULL,
    @TokensEntrada INT = NULL,
    @TokensSalida INT = NULL,
    @CostoEstimado DECIMAL(10,4) = NULL,
    @EstadoConsulta VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @Fragmento VARCHAR(3) = UPPER(LEFT(REPLACE(REPLACE(ISNULL(@TipoConsulta, 'CON'), ' ', ''), '-', ''), 3));
    DECLARE @CodigoGenerado VARCHAR(20);

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'IAC')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('IAC', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'IAC';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'IAC';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoConsulta, 4) AS INT)), 0) + 1
            FROM dbo.IA_Consulta
            WHERE CodigoConsulta LIKE 'IAC-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('IAC-', RIGHT(CONCAT(@Fragmento, 'XXX'), 3), RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.IA_Consulta
        (
            IdConsulta, UsuarioId, IdRecorrido, IdEstudiante, IdIncidencia,
            CodigoConsulta, Modulo, TipoConsulta, PromptEnviado, ContextoEnviado,
            RespuestaIA, TokensEntrada, TokensSalida, CostoEstimado, EstadoConsulta, FechaConsulta
        )
        VALUES
        (
            NEWID(), @UsuarioId, @IdRecorrido, @IdEstudiante, @IdIncidencia,
            @CodigoGenerado, @Modulo, @TipoConsulta, @PromptEnviado, @ContextoEnviado,
            @RespuestaIA, @TokensEntrada, @TokensSalida, @CostoEstimado, @EstadoConsulta, SYSUTCDATETIME()
        );

        COMMIT TRANSACTION;
        SELECT @@ROWCOUNT AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_IA_Prediccion_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_IA_Prediccion_Registrar]
    @IdRecorrido UNIQUEIDENTIFIER = NULL,
    @IdEstudiante UNIQUEIDENTIFIER = NULL,
    @TipoPrediccion VARCHAR(60),
    @ValorPredicho DECIMAL(18,6) = NULL,
    @Confianza DECIMAL(5,2) = NULL,
    @DatosEntrada VARCHAR(MAX) = NULL,
    @Explicacion VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @Fragmento VARCHAR(3) = UPPER(LEFT(REPLACE(REPLACE(ISNULL(@TipoPrediccion, 'PRE'), ' ', ''), '-', ''), 3));
    DECLARE @CodigoGenerado VARCHAR(20);

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'IAP')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('IAP', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'IAP';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'IAP';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoPrediccion, 4) AS INT)), 0) + 1
            FROM dbo.IA_Prediccion
            WHERE CodigoPrediccion LIKE 'IAP-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('IAP-', RIGHT(CONCAT(@Fragmento, 'XXX'), 3), RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.IA_Prediccion
        (
            IdPrediccion, IdRecorrido, IdEstudiante, CodigoPrediccion, TipoPrediccion,
            ValorPredicho, Confianza, DatosEntrada, Explicacion, FechaGeneracion
        )
        VALUES
        (
            NEWID(), @IdRecorrido, @IdEstudiante, @CodigoGenerado, @TipoPrediccion,
            @ValorPredicho, @Confianza, @DatosEntrada, @Explicacion, SYSUTCDATETIME()
        );

        COMMIT TRANSACTION;
        SELECT @@ROWCOUNT AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Incidencia_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Incidencia_Actualizar]
(
    @IdIncidencia UNIQUEIDENTIFIER,
    @IdRecorrido UNIQUEIDENTIFIER,
    @IdConductor UNIQUEIDENTIFIER,
    @TipoIncidencia VARCHAR(50),
    @Descripcion VARCHAR(300),
    @FechaHora DATETIME2,
    @EstadoIncidencia VARCHAR(20),
    @Prioridad VARCHAR(20),
    @Solucion VARCHAR(300) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Incidencia
    SET
        IdRecorrido = @IdRecorrido,
        IdConductor = @IdConductor,
        TipoIncidencia = @TipoIncidencia,
        Descripcion = @Descripcion,
        FechaHora = @FechaHora,
        EstadoIncidencia = @EstadoIncidencia,
        Prioridad = @Prioridad,
        Solucion = @Solucion,
        FechaActualizacion = SYSDATETIME()
    WHERE IdIncidencia = @IdIncidencia
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Incidencia_CambiarEstado]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* =========================================================
   INCIDENCIA - CAMBIAR ESTADO
   ========================================================= */
CREATE   PROCEDURE [dbo].[sp_Incidencia_CambiarEstado]
(
    @IdIncidencia UNIQUEIDENTIFIER,
    @EstadoIncidencia VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Incidencia
    SET
        EstadoIncidencia = @EstadoIncidencia,
        FechaCierre = CASE
                        WHEN @EstadoIncidencia = 'CERRADA' AND FechaCierre IS NULL THEN SYSDATETIME()
                        WHEN @EstadoIncidencia <> 'CERRADA' THEN NULL
                        ELSE FechaCierre
                      END,
        FechaActualizacion = SYSDATETIME()
    WHERE IdIncidencia = @IdIncidencia
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Incidencia_Cerrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[sp_Incidencia_Cerrar]
(
    @IdIncidencia UNIQUEIDENTIFIER,
    @Solucion VARCHAR(300)
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Incidencia
    SET
        EstadoIncidencia = 'CERRADA',
        Solucion = @Solucion,
        FechaCierre = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdIncidencia = @IdIncidencia
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Incidencia_Eliminar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Incidencia_Eliminar]
(
    @IdIncidencia UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Incidencia
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdIncidencia = @IdIncidencia
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Incidencia_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Incidencia_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        i.IdIncidencia,
        i.IdRecorrido,
        i.IdConductor,
        i.ReportadoPor,
        i.CodigoIncidencia,
        i.TipoIncidencia,
        i.Descripcion,
        i.FechaHora,
        i.EstadoIncidencia,
        i.Prioridad,
        i.FechaCierre,
        i.Solucion,
        i.Estado,
        i.FechaCreacion,
        i.FechaActualizacion,
        i.FechaEliminacion,
        r.CodigoRecorrido,
        CONCAT(c.Nombres, ' ', c.ApellidoPaterno, ' ', c.ApellidoMaterno) AS NombreConductor,
        u.Username AS UsernameReportadoPor
    FROM Incidencia i
    INNER JOIN Recorrido r ON i.IdRecorrido = r.IdRecorrido
    INNER JOIN Conductor c ON i.IdConductor = c.IdConductor
    LEFT JOIN Usuario u ON i.ReportadoPor = u.IdUsuario
    WHERE i.FechaEliminacion IS NULL
    ORDER BY i.FechaHora DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Incidencia_ListarActivas]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* =========================================================
   INCIDENCIA - LISTAR ACTIVAS
   Solo incidencias no eliminadas y activas
   ========================================================= */
CREATE   PROCEDURE [dbo].[sp_Incidencia_ListarActivas]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        i.IdIncidencia,
        i.IdRecorrido,
        i.IdConductor,
        i.ReportadoPor,
        i.CodigoIncidencia,
        i.TipoIncidencia,
        i.Descripcion,
        i.FechaHora,
        i.EstadoIncidencia,
        i.Prioridad,
        i.FechaCierre,
        i.Solucion,
        i.Estado,
        i.FechaCreacion,
        i.FechaActualizacion,
        i.FechaEliminacion,

        r.CodigoRecorrido,
        CONCAT(c.Nombres, ' ', c.ApellidoPaterno, ' ', c.ApellidoMaterno) AS NombreConductor,
        u.Username AS UsernameReportadoPor

    FROM Incidencia i
    INNER JOIN Recorrido r
        ON i.IdRecorrido = r.IdRecorrido
    INNER JOIN Conductor c
        ON i.IdConductor = c.IdConductor
    LEFT JOIN Usuario u
        ON i.ReportadoPor = u.IdUsuario
    WHERE i.Estado = 1
      AND i.FechaEliminacion IS NULL
    ORDER BY i.FechaHora DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Incidencia_ListarPendientes]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* =========================================================
   INCIDENCIA - LISTAR PENDIENTES
   ========================================================= */
CREATE   PROCEDURE [dbo].[sp_Incidencia_ListarPendientes]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        i.IdIncidencia,
        i.IdRecorrido,
        i.IdConductor,
        i.ReportadoPor,
        i.CodigoIncidencia,
        i.TipoIncidencia,
        i.Descripcion,
        i.FechaHora,
        i.EstadoIncidencia,
        i.Prioridad,
        i.FechaCierre,
        i.Solucion,
        i.Estado,
        i.FechaCreacion,
        i.FechaActualizacion,
        i.FechaEliminacion,

        r.CodigoRecorrido,
        CONCAT(c.Nombres, ' ', c.ApellidoPaterno, ' ', c.ApellidoMaterno) AS NombreConductor,
        u.Username AS UsernameReportadoPor

    FROM Incidencia i
    INNER JOIN Recorrido r
        ON i.IdRecorrido = r.IdRecorrido
    INNER JOIN Conductor c
        ON i.IdConductor = c.IdConductor
    LEFT JOIN Usuario u
        ON i.ReportadoPor = u.IdUsuario
    WHERE i.FechaEliminacion IS NULL
      AND i.EstadoIncidencia IN ('PENDIENTE', 'ATENDIDA')
    ORDER BY
        CASE i.Prioridad
            WHEN 'CRITICA' THEN 1
            WHEN 'ALTA' THEN 2
            WHEN 'MEDIA' THEN 3
            WHEN 'BAJA' THEN 4
            ELSE 5
        END,
        i.FechaHora DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Incidencia_ListarPorConductor]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Incidencia_ListarPorConductor]
    @IdConductor UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        i.IdIncidencia,
        i.IdRecorrido,
        i.IdConductor,
        i.ReportadoPor,
        i.CodigoIncidencia,
        i.TipoIncidencia,
        i.Descripcion,
        i.FechaHora,
        i.EstadoIncidencia,
        i.Prioridad,
        i.FechaCierre,
        i.Solucion,
        i.Estado,
        i.FechaCreacion,
        i.FechaActualizacion,
        i.FechaEliminacion,
        r.CodigoRecorrido,
        (c.Nombres + ' ' + c.ApellidoPaterno + ' ' + c.ApellidoMaterno) AS NombreConductor,
        u.Username AS UsernameReportadoPor
    FROM dbo.Incidencia i
    INNER JOIN dbo.Recorrido r ON r.IdRecorrido = i.IdRecorrido
    INNER JOIN dbo.Conductor c ON c.IdConductor = i.IdConductor
    LEFT JOIN dbo.Usuario u ON u.IdUsuario = i.ReportadoPor
    WHERE i.IdConductor = @IdConductor
      AND i.FechaEliminacion IS NULL
    ORDER BY i.FechaHora DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Incidencia_ListarPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Incidencia_ListarPorId]
(
    @IdIncidencia UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        i.IdIncidencia,
        i.IdRecorrido,
        i.IdConductor,
        i.ReportadoPor,
        i.CodigoIncidencia,
        i.TipoIncidencia,
        i.Descripcion,
        i.FechaHora,
        i.EstadoIncidencia,
        i.Prioridad,
        i.FechaCierre,
        i.Solucion,
        i.Estado,
        i.FechaCreacion,
        i.FechaActualizacion,
        i.FechaEliminacion,
        r.CodigoRecorrido,
        CONCAT(c.Nombres, ' ', c.ApellidoPaterno, ' ', c.ApellidoMaterno) AS NombreConductor,
        u.Username AS UsernameReportadoPor
    FROM Incidencia i
    INNER JOIN Recorrido r ON i.IdRecorrido = r.IdRecorrido
    INNER JOIN Conductor c ON i.IdConductor = c.IdConductor
    LEFT JOIN Usuario u ON i.ReportadoPor = u.IdUsuario
    WHERE i.IdIncidencia = @IdIncidencia
      AND i.FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Incidencia_ListarPorPadre]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Incidencia_ListarPorPadre]
    @IdPadre UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH RutasPadre AS
    (
        SELECT DISTINCT re.IdRuta
        FROM dbo.Estudiante e
        INNER JOIN dbo.RutaEstudiante re ON re.IdEstudiante = e.IdEstudiante
        WHERE e.IdPadre = @IdPadre
          AND e.Estado = 1
          AND e.FechaEliminacion IS NULL
          AND re.Estado = 1
          AND re.FechaEliminacion IS NULL
    )
    SELECT
        i.IdIncidencia,
        i.IdRecorrido,
        i.IdConductor,
        i.ReportadoPor,
        i.CodigoIncidencia,
        i.TipoIncidencia,
        i.Descripcion,
        i.FechaHora,
        i.EstadoIncidencia,
        i.Prioridad,
        i.FechaCierre,
        i.Solucion,
        i.Estado,
        i.FechaCreacion,
        i.FechaActualizacion,
        i.FechaEliminacion,
        r.CodigoRecorrido,
        (c.Nombres + ' ' + c.ApellidoPaterno + ' ' + c.ApellidoMaterno) AS NombreConductor,
        u.Username AS UsernameReportadoPor
    FROM dbo.Incidencia i
    INNER JOIN dbo.Recorrido r ON r.IdRecorrido = i.IdRecorrido
    INNER JOIN RutasPadre rp ON rp.IdRuta = r.IdRuta
    INNER JOIN dbo.Conductor c ON c.IdConductor = i.IdConductor
    LEFT JOIN dbo.Usuario u ON u.IdUsuario = i.ReportadoPor
    WHERE i.FechaEliminacion IS NULL
    ORDER BY i.FechaHora DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Incidencia_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =============================================
   SECCIÓN C: INCIDENCIA (CÓDIGO CONSISTENTE)
   ============================================= */
CREATE   PROCEDURE [dbo].[sp_Incidencia_Registrar]
(
    @IdRecorrido UNIQUEIDENTIFIER,
    @IdConductor UNIQUEIDENTIFIER,
    @ReportadoPor UNIQUEIDENTIFIER = NULL,
    @TipoIncidencia VARCHAR(50),
    @Descripcion VARCHAR(300),
    @FechaHora DATETIME,
    @EstadoIncidencia VARCHAR(20),
    @Prioridad VARCHAR(20),
    @Solucion VARCHAR(300) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdIncidencia UNIQUEIDENTIFIER = NEWID();
    DECLARE @Correlativo INT = 0;
    DECLARE @CodigoGenerado VARCHAR(20);
    DECLARE @Fragmento VARCHAR(6) = dbo.fn_Codigo_Fragmento(@TipoIncidencia, 6, 'INCIDE');

    BEGIN TRY
        BEGIN TRAN;

        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'INC')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('INC', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'INC';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'INC';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoIncidencia, 4) AS INT)), 0) + 1
            FROM dbo.Incidencia
            WHERE CodigoIncidencia LIKE 'INC-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('INC-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Incidencia
        (
            IdIncidencia, IdRecorrido, IdConductor, ReportadoPor, CodigoIncidencia,
            TipoIncidencia, Descripcion, FechaHora, EstadoIncidencia, Prioridad,
            FechaCierre, Solucion, Estado, FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            @IdIncidencia, @IdRecorrido, @IdConductor, @ReportadoPor, @CodigoGenerado,
            UPPER(LTRIM(RTRIM(@TipoIncidencia))), LTRIM(RTRIM(@Descripcion)), @FechaHora, UPPER(LTRIM(RTRIM(@EstadoIncidencia))), UPPER(LTRIM(RTRIM(@Prioridad))),
            NULL, NULLIF(LTRIM(RTRIM(@Solucion)), ''), 1, GETDATE(), NULL, NULL
        );

        COMMIT;

        SELECT
            1 AS FilasAfectadas,
            @IdIncidencia AS IdIncidencia,
            @CodigoGenerado AS CodigoGenerado,
            CAST(NULL AS VARCHAR(200)) AS Mensaje;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;

        SELECT
            0 AS FilasAfectadas,
            CAST(NULL AS UNIQUEIDENTIFIER) AS IdIncidencia,
            CAST(NULL AS VARCHAR(20)) AS CodigoGenerado,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Notificacion_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Notificacion_Actualizar]
(
    @IdNotificacion UNIQUEIDENTIFIER,
    @IdPadre UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER = NULL,
    @Titulo VARCHAR(150),
    @Mensaje VARCHAR(300),
    @TipoNotificacion VARCHAR(30),
    @Canal VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Notificacion
    SET
        IdPadre = @IdPadre,
        IdEstudiante = @IdEstudiante,
        Titulo = @Titulo,
        Mensaje = @Mensaje,
        TipoNotificacion = @TipoNotificacion,
        Canal = @Canal,
        FechaActualizacion = SYSDATETIME()
    WHERE IdNotificacion = @IdNotificacion
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Notificacion_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Notificacion_EliminarLogico]
(
    @IdNotificacion UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Notificacion
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdNotificacion = @IdNotificacion
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Notificacion_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Notificacion_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        n.IdNotificacion,
        n.IdPadre,
        n.IdEstudiante,
        n.CodigoNotificacion,
        n.Titulo,
        n.Mensaje,
        n.TipoNotificacion,
        n.Canal,
        n.Leido,
        n.FechaLectura,
        n.FechaEnvio,
        n.Estado,
        n.FechaCreacion,
        n.FechaActualizacion,
        n.FechaEliminacion,

        CONCAT(p.Nombres, ' ', p.ApellidoPaterno, ' ', p.ApellidoMaterno) AS NombrePadre,
        CONCAT(e.Nombres, ' ', e.ApellidoPaterno, ' ', e.ApellidoMaterno) AS NombreEstudiante

    FROM Notificacion n
    INNER JOIN PadreFamilia p ON n.IdPadre = p.IdPadre
    LEFT JOIN Estudiante e ON n.IdEstudiante = e.IdEstudiante
    WHERE n.FechaEliminacion IS NULL
    ORDER BY n.FechaEnvio DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Notificacion_ListarNoLeidasPorPadre]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Notificacion_ListarNoLeidasPorPadre]
(
    @IdPadre UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        n.IdNotificacion,
        n.IdPadre,
        n.IdEstudiante,
        n.CodigoNotificacion,
        n.Titulo,
        n.Mensaje,
        n.TipoNotificacion,
        n.Canal,
        n.Leido,
        n.FechaLectura,
        n.FechaEnvio,
        n.Estado,
        n.FechaCreacion,
        n.FechaActualizacion,
        n.FechaEliminacion,
        CONCAT(e.Nombres, ' ', e.ApellidoPaterno, ' ', e.ApellidoMaterno) AS NombreEstudiante
    FROM Notificacion n
    LEFT JOIN Estudiante e ON n.IdEstudiante = e.IdEstudiante
    WHERE n.IdPadre = @IdPadre
      AND n.Leido = 0
      AND n.FechaEliminacion IS NULL
    ORDER BY n.FechaEnvio DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Notificacion_ListarPorPadre]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Notificacion_ListarPorPadre]
(
    @IdPadre UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        n.IdNotificacion,
        n.IdPadre,
        n.IdEstudiante,
        n.CodigoNotificacion,
        n.Titulo,
        n.Mensaje,
        n.TipoNotificacion,
        n.Canal,
        n.Leido,
        n.FechaLectura,
        n.FechaEnvio,
        n.Estado,
        n.FechaCreacion,
        n.FechaActualizacion,
        n.FechaEliminacion,
        CONCAT(e.Nombres, ' ', e.ApellidoPaterno, ' ', e.ApellidoMaterno) AS NombreEstudiante
    FROM Notificacion n
    LEFT JOIN Estudiante e ON n.IdEstudiante = e.IdEstudiante
    WHERE n.IdPadre = @IdPadre
      AND n.FechaEliminacion IS NULL
    ORDER BY n.FechaEnvio DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Notificacion_MarcarLeida]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Notificacion_MarcarLeida]
(
    @IdNotificacion UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Notificacion
    SET
        Leido = 1,
        FechaLectura = CASE WHEN FechaLectura IS NULL THEN SYSDATETIME() ELSE FechaLectura END,
        FechaActualizacion = SYSDATETIME()
    WHERE IdNotificacion = @IdNotificacion
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Notificacion_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Notificacion_ObtenerPorId]
(
    @IdNotificacion UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        n.IdNotificacion,
        n.IdPadre,
        n.IdEstudiante,
        n.CodigoNotificacion,
        n.Titulo,
        n.Mensaje,
        n.TipoNotificacion,
        n.Canal,
        n.Leido,
        n.FechaLectura,
        n.FechaEnvio,
        n.Estado,
        n.FechaCreacion,
        n.FechaActualizacion,
        n.FechaEliminacion,

        CONCAT(p.Nombres, ' ', p.ApellidoPaterno, ' ', p.ApellidoMaterno) AS NombrePadre,
        CONCAT(e.Nombres, ' ', e.ApellidoPaterno, ' ', e.ApellidoMaterno) AS NombreEstudiante

    FROM Notificacion n
    INNER JOIN PadreFamilia p ON n.IdPadre = p.IdPadre
    LEFT JOIN Estudiante e ON n.IdEstudiante = e.IdEstudiante
    WHERE n.IdNotificacion = @IdNotificacion
      AND n.FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Notificacion_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Notificacion_Registrar]
    @IdPadre UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER = NULL,
    @Titulo VARCHAR(150),
    @Mensaje VARCHAR(500),
    @TipoNotificacion VARCHAR(30),
    @Canal VARCHAR(20),
    @Leido BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @Fragmento VARCHAR(6);
    DECLARE @CodigoGenerado VARCHAR(20);

    SET @Fragmento =
        dbo.fn_Codigo_Fragmento(@TipoNotificacion, 3, 'NOT') +
        dbo.fn_Codigo_Fragmento(@Canal, 3, 'CAN');

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'NOT')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('NOT', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'NOT';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'NOT';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoNotificacion, 4) AS INT)), 0) + 1
            FROM dbo.Notificacion
            WHERE CodigoNotificacion LIKE 'NOT-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('NOT-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Notificacion
        (
            IdNotificacion, IdPadre, IdEstudiante, CodigoNotificacion, Titulo, Mensaje,
            TipoNotificacion, Canal, Leido, FechaLectura, FechaEnvio, Estado,
            FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            NEWID(), @IdPadre, @IdEstudiante, @CodigoGenerado, @Titulo, @Mensaje,
            @TipoNotificacion, @Canal, @Leido, CASE WHEN @Leido = 1 THEN SYSUTCDATETIME() ELSE NULL END,
            SYSUTCDATETIME(), 1, SYSUTCDATETIME(), NULL, NULL
        );

        COMMIT TRANSACTION;
        SELECT CAST(1 AS INT) AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT CAST(0 AS INT) AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PadreFamilia_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_PadreFamilia_Actualizar]
    @IdPadre UNIQUEIDENTIFIER,
    @IdUsuario UNIQUEIDENTIFIER,
    @Nombres VARCHAR(80),
    @ApellidoPaterno VARCHAR(60),
    @ApellidoMaterno VARCHAR(60),
    @DNI VARCHAR(8) = NULL,
    @Telefono VARCHAR(20) = NULL,
    @TelefonoAlterno VARCHAR(20) = NULL,
    @Direccion VARCHAR(200) = NULL,
    @CorreoContacto VARCHAR(120) = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.PadreFamilia
    SET
        IdUsuario = @IdUsuario,
        Nombres = @Nombres,
        ApellidoPaterno = @ApellidoPaterno,
        ApellidoMaterno = @ApellidoMaterno,
        DNI = NULLIF(@DNI, ''),
        Telefono = NULLIF(@Telefono, ''),
        TelefonoAlterno = NULLIF(@TelefonoAlterno, ''),
        Direccion = NULLIF(@Direccion, ''),
        CorreoContacto = NULLIF(@CorreoContacto, ''),
        Estado = @Estado,
        FechaActualizacion = SYSUTCDATETIME()
    WHERE IdPadre = @IdPadre
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PadreFamilia_Eliminar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_PadreFamilia_Eliminar]
    @IdPadre UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.PadreFamilia
    SET
        Estado = 0,
        FechaEliminacion = SYSUTCDATETIME(),
        FechaActualizacion = SYSUTCDATETIME()
    WHERE IdPadre = @IdPadre
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PadreFamilia_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_PadreFamilia_EliminarLogico]
    @IdPadre UNIQUEIDENTIFIER
AS
BEGIN
    EXEC dbo.sp_PadreFamilia_Eliminar @IdPadre;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PadreFamilia_ExistePorDni]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_PadreFamilia_ExistePorDni]
    @DNI VARCHAR(8),
    @IdPadreExcluir UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(1)
    FROM dbo.PadreFamilia p
    WHERE p.DNI = @DNI
      AND p.FechaEliminacion IS NULL
      AND (@IdPadreExcluir IS NULL OR p.IdPadre <> @IdPadreExcluir);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PadreFamilia_ExistePorIdUsuario]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_PadreFamilia_ExistePorIdUsuario]
    @IdUsuario UNIQUEIDENTIFIER,
    @IdPadreExcluir UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(1)
    FROM dbo.PadreFamilia p
    WHERE p.IdUsuario = @IdUsuario
      AND p.FechaEliminacion IS NULL
      AND (@IdPadreExcluir IS NULL OR p.IdPadre <> @IdPadreExcluir);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PadreFamilia_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_PadreFamilia_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IdPadre,
        p.IdUsuario,
        p.CodigoPadre,
        p.Nombres,
        p.ApellidoPaterno,
        p.ApellidoMaterno,
        p.DNI,
        p.Telefono,
        p.TelefonoAlterno,
        p.Direccion,
        p.CorreoContacto,
        p.Estado,
        p.FechaCreacion,
        p.FechaActualizacion,
        p.FechaEliminacion
    FROM dbo.PadreFamilia p
    WHERE p.FechaEliminacion IS NULL
    ORDER BY p.FechaCreacion DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PadreFamilia_ListarParaCombo]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =============================================
   SECCIÓN F: PADRE FAMILIA (COMBO ESTUDIANTE)
   ============================================= */
CREATE   PROCEDURE [dbo].[sp_PadreFamilia_ListarParaCombo]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IdPadre,
        p.CodigoPadre,
        p.Nombres,
        p.ApellidoPaterno,
        p.ApellidoMaterno,
        u.Username,
        u.Correo
    FROM dbo.PadreFamilia p
    INNER JOIN dbo.Usuario u ON u.IdUsuario = p.IdUsuario
    WHERE p.Estado = 1
      AND p.FechaEliminacion IS NULL
      AND u.Estado = 1
      AND u.FechaEliminacion IS NULL
    ORDER BY p.ApellidoPaterno, p.ApellidoMaterno, p.Nombres;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PadreFamilia_ListarPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_PadreFamilia_ListarPorId]
    @IdPadre UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IdPadre,
        p.IdUsuario,
        p.CodigoPadre,
        p.Nombres,
        p.ApellidoPaterno,
        p.ApellidoMaterno,
        p.DNI,
        p.Telefono,
        p.TelefonoAlterno,
        p.Direccion,
        p.CorreoContacto,
        p.Estado,
        p.FechaCreacion,
        p.FechaActualizacion,
        p.FechaEliminacion
    FROM dbo.PadreFamilia p
    WHERE p.IdPadre = @IdPadre
      AND p.FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PadreFamilia_ListarPorIdUsuario]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_PadreFamilia_ListarPorIdUsuario]
    @IdUsuario UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        p.IdPadre,
        p.IdUsuario,
        p.CodigoPadre,
        p.Nombres,
        p.ApellidoPaterno,
        p.ApellidoMaterno,
        p.DNI,
        p.Telefono,
        p.TelefonoAlterno,
        p.Direccion,
        p.CorreoContacto,
        p.Estado,
        p.FechaCreacion,
        p.FechaActualizacion,
        p.FechaEliminacion
    FROM dbo.PadreFamilia p
    WHERE p.IdUsuario = @IdUsuario
      AND p.Estado = 1
      AND p.FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PadreFamilia_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_PadreFamilia_ObtenerPorId]
    @IdPadre UNIQUEIDENTIFIER
AS
BEGIN
    EXEC dbo.sp_PadreFamilia_ListarPorId @IdPadre;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PadreFamilia_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_PadreFamilia_Registrar]
    @IdUsuario UNIQUEIDENTIFIER,
    @Nombres VARCHAR(80),
    @ApellidoPaterno VARCHAR(60),
    @ApellidoMaterno VARCHAR(60),
    @DNI VARCHAR(8) = NULL,
    @Telefono VARCHAR(20) = NULL,
    @TelefonoAlterno VARCHAR(20) = NULL,
    @Direccion VARCHAR(200) = NULL,
    @CorreoContacto VARCHAR(120) = NULL,
    @Estado BIT,
    @CodigoGenerado VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @Fragmento VARCHAR(6);

    SET @Fragmento =
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@Nombres, 'X'))), 2)) +
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@ApellidoPaterno, 'X'))), 2)) +
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@ApellidoMaterno, 'X'))), 2));

    BEGIN TRANSACTION;

    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'PADRE')
            BEGIN
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero)
                VALUES ('PADRE', 0);
            END

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'PADRE';

            SELECT @Correlativo = UltimoNumero
              FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
             WHERE TipoCodigo = 'PADRE';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoPadre, 4) AS INT)), 0) + 1
            FROM dbo.PadreFamilia
            WHERE CodigoPadre LIKE 'PAD-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('PAD-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.PadreFamilia
    (
        IdPadre,
        IdUsuario,
        CodigoPadre,
        Nombres,
        ApellidoPaterno,
        ApellidoMaterno,
        DNI,
        Telefono,
        TelefonoAlterno,
        Direccion,
        CorreoContacto,
        Estado,
        FechaCreacion,
        FechaActualizacion,
        FechaEliminacion
    )
        VALUES
        (
            NEWID(),
            @IdUsuario,
            @CodigoGenerado,
            @Nombres,
            @ApellidoPaterno,
            @ApellidoMaterno,
            NULLIF(@DNI, ''),
            NULLIF(@Telefono, ''),
            NULLIF(@TelefonoAlterno, ''),
            NULLIF(@Direccion, ''),
            NULLIF(@CorreoContacto, ''),
            @Estado,
            SYSUTCDATETIME(),
            NULL,
            NULL
        );

        COMMIT TRANSACTION;

        SELECT
            @@ROWCOUNT AS FilasAfectadas,
            @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Paradero_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[sp_Paradero_Actualizar]
(
    @IdParadero UNIQUEIDENTIFIER,
    @IdRuta UNIQUEIDENTIFIER,
    @Nombre VARCHAR(100),
    @Direccion VARCHAR(200),
    @Latitud DECIMAL(10,7) = NULL,
    @Longitud DECIMAL(10,7) = NULL,
    @OrdenParada INT,
    @HoraEstimada TIME = NULL,
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Paradero
    SET
        IdRuta = @IdRuta,
        Nombre = @Nombre,
        Direccion = @Direccion,
        Latitud = @Latitud,
        Longitud = @Longitud,
        OrdenParada = @OrdenParada,
        HoraEstimada = @HoraEstimada,
        Estado = @Estado,
        FechaActualizacion = SYSDATETIME()
    WHERE IdParadero = @IdParadero
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Paradero_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Paradero_EliminarLogico]
(
    @IdParadero UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Paradero
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdParadero = @IdParadero
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Paradero_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Paradero_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IdParadero,
        p.IdRuta,
        p.CodigoParadero,
        p.Nombre,
        p.Direccion,
        p.Latitud,
        p.Longitud,
        p.OrdenParada,
        p.HoraEstimada,
        p.Estado,
        p.FechaCreacion,
        p.FechaActualizacion,
        p.FechaEliminacion,
        r.CodigoRuta,
        r.Nombre AS NombreRuta
    FROM Paradero p
    INNER JOIN Ruta r ON p.IdRuta = r.IdRuta
    WHERE p.FechaEliminacion IS NULL
    ORDER BY r.Nombre, p.OrdenParada;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Paradero_ListarActivos]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Paradero_ListarActivos]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdParadero,
        CodigoParadero,
        Nombre
    FROM Paradero
    WHERE FechaEliminacion IS NULL
      AND Estado = 1
    ORDER BY Nombre;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Paradero_ListarPorRuta]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Paradero_ListarPorRuta]
(
    @IdRuta UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdParadero,
        IdRuta,
        CodigoParadero,
        Nombre,
        OrdenParada
    FROM Paradero
    WHERE IdRuta = @IdRuta
      AND FechaEliminacion IS NULL
      AND Estado = 1
    ORDER BY OrdenParada;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Paradero_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[sp_Paradero_ObtenerPorId]
(
    @IdParadero UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdParadero,
        IdRuta,
        CodigoParadero,
        Nombre,
        Direccion,
        Latitud,
        Longitud,
        OrdenParada,
        HoraEstimada,
        Estado,
        FechaCreacion,
        FechaActualizacion,
        FechaEliminacion
    FROM Paradero
    WHERE IdParadero = @IdParadero
      AND FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Paradero_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Paradero_Registrar]
    @IdRuta UNIQUEIDENTIFIER,
    @Nombre VARCHAR(120),
    @Direccion VARCHAR(250),
    @Latitud DECIMAL(10,7) = NULL,
    @Longitud DECIMAL(10,7) = NULL,
    @OrdenParada INT,
    @HoraEstimada TIME = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @RutaNombre VARCHAR(120);
    DECLARE @Fragmento VARCHAR(6);
    DECLARE @CodigoGenerado VARCHAR(20);

    SELECT @RutaNombre = r.Nombre
    FROM dbo.Ruta r
    WHERE r.IdRuta = @IdRuta;

    SET @Fragmento =
        dbo.fn_Codigo_Fragmento(@Nombre, 3, 'PAR') +
        dbo.fn_Codigo_Fragmento(@RutaNombre, 3, 'RUT');

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'PAR')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('PAR', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'PAR';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'PAR';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoParadero, 4) AS INT)), 0) + 1
            FROM dbo.Paradero
            WHERE CodigoParadero LIKE 'PAR-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('PAR-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Paradero
        (
            IdParadero, IdRuta, CodigoParadero, Nombre, Direccion, Latitud, Longitud,
            OrdenParada, HoraEstimada, Estado, FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            NEWID(), @IdRuta, @CodigoGenerado, @Nombre, @Direccion, @Latitud, @Longitud,
            @OrdenParada, @HoraEstimada, @Estado, SYSUTCDATETIME(), NULL, NULL
        );

        COMMIT TRANSACTION;
        SELECT CAST(1 AS INT) AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT CAST(0 AS INT) AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Recorrido_Actualizar]
(
    @IdRecorrido UNIQUEIDENTIFIER,
    @IdRuta UNIQUEIDENTIFIER,
    @IdBus UNIQUEIDENTIFIER,
    @IdConductor UNIQUEIDENTIFIER,
    @Fecha DATE,
    @HoraInicioProgramada TIME = NULL,
    @HoraFinProgramada TIME = NULL,
    @EstadoRecorrido VARCHAR(20),
    @Observaciones VARCHAR(300) = NULL,
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Recorrido
    SET
        IdRuta = @IdRuta,
        IdBus = @IdBus,
        IdConductor = @IdConductor,
        Fecha = @Fecha,
        HoraInicioProgramada = @HoraInicioProgramada,
        HoraFinProgramada = @HoraFinProgramada,
        EstadoRecorrido = @EstadoRecorrido,
        Observaciones = @Observaciones,
        Estado = @Estado,
        FechaActualizacion = SYSDATETIME()
    WHERE IdRecorrido = @IdRecorrido
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_Cancelar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Recorrido_Cancelar]
(
    @IdRecorrido UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Recorrido
    SET
        EstadoRecorrido = 'CANCELADO',
        FechaActualizacion = SYSDATETIME()
    WHERE IdRecorrido = @IdRecorrido
      AND FechaEliminacion IS NULL
      AND EstadoRecorrido IN ('PROGRAMADO','EN_CURSO');

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Recorrido_EliminarLogico]
(
    @IdRecorrido UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Recorrido
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdRecorrido = @IdRecorrido
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_Finalizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Recorrido_Finalizar]
(
    @IdRecorrido UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Recorrido
    SET
        EstadoRecorrido = 'FINALIZADO',
        HoraFinReal = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdRecorrido = @IdRecorrido
      AND FechaEliminacion IS NULL
      AND EstadoRecorrido = 'EN_CURSO';

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_Iniciar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Recorrido_Iniciar]
(
    @IdRecorrido UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FilasAfectadas INT = 0;

    UPDATE Recorrido
    SET
        EstadoRecorrido = 'EN_CURSO',
        HoraInicioReal = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdRecorrido = @IdRecorrido
      AND FechaEliminacion IS NULL
      AND EstadoRecorrido = 'PROGRAMADO';

    SET @FilasAfectadas = @@ROWCOUNT;

    SELECT @FilasAfectadas AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Recorrido_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        rc.IdRecorrido,
        rc.IdRuta,
        rc.IdBus,
        rc.IdConductor,
        rc.CodigoRecorrido,
        rc.Fecha,
        rc.HoraInicioProgramada,
        rc.HoraFinProgramada,
        rc.HoraInicioReal,
        rc.HoraFinReal,
        rc.EstadoRecorrido,
        rc.Observaciones,
        rc.Estado,
        rc.FechaCreacion,
        rc.FechaActualizacion,
        rc.FechaEliminacion,
        r.CodigoRuta,
        r.Nombre AS NombreRuta,
        b.CodigoBus,
        b.Placa,
        c.CodigoConductor,
        c.Nombres AS NombresConductor,
        c.ApellidoPaterno AS ApellidoPaternoConductor
    FROM Recorrido rc
    INNER JOIN Ruta r ON rc.IdRuta = r.IdRuta
    INNER JOIN Bus b ON rc.IdBus = b.IdBus
    INNER JOIN Conductor c ON rc.IdConductor = c.IdConductor
    WHERE rc.FechaEliminacion IS NULL
    ORDER BY rc.Fecha DESC, rc.FechaCreacion DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_ListarActivosParaOperacion]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Recorrido_ListarActivosParaOperacion]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdRecorrido,
        CodigoRecorrido,
        Fecha
    FROM Recorrido
    WHERE FechaEliminacion IS NULL
      AND Estado = 1
      AND EstadoRecorrido IN ('PROGRAMADO','EN_CURSO')
    ORDER BY Fecha DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_ListarDestinatariosNotificacion]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Recorrido_ListarDestinatariosNotificacion]
(
    @IdRecorrido UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        e.IdPadre,
        e.IdEstudiante
    FROM Recorrido r
    INNER JOIN RutaEstudiante re ON r.IdRuta = re.IdRuta
    INNER JOIN Estudiante e ON re.IdEstudiante = e.IdEstudiante
    WHERE r.IdRecorrido = @IdRecorrido
      AND r.FechaEliminacion IS NULL
      AND re.FechaEliminacion IS NULL
      AND e.FechaEliminacion IS NULL
      AND r.Estado = 1
      AND re.Estado = 1
      AND e.Estado = 1;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_ListarPorConductor]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Recorrido_ListarPorConductor]
    @IdConductor UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.IdRecorrido,
        r.IdRuta,
        r.IdBus,
        r.IdConductor,
        r.CodigoRecorrido,
        r.Fecha,
        r.EstadoRecorrido,
        r.Estado,
        ru.CodigoRuta,
        ru.Nombre AS NombreRuta,
        b.CodigoBus,
        b.Placa
    FROM dbo.Recorrido r
    INNER JOIN dbo.Ruta ru ON ru.IdRuta = r.IdRuta
    INNER JOIN dbo.Bus b ON b.IdBus = r.IdBus
    WHERE r.IdConductor = @IdConductor
      AND r.FechaEliminacion IS NULL
    ORDER BY r.Fecha DESC, r.FechaCreacion DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_ObtenerActivoPorConductor]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Recorrido_ObtenerActivoPorConductor]
    @IdConductor UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        r.IdRecorrido,
        r.IdRuta,
        r.IdBus,
        r.IdConductor,
        r.CodigoRecorrido,
        r.Fecha,
        r.EstadoRecorrido,
        r.Estado,
        ru.CodigoRuta,
        ru.Nombre AS NombreRuta,
        b.CodigoBus,
        b.Placa
    FROM dbo.Recorrido r
    INNER JOIN dbo.Ruta ru ON ru.IdRuta = r.IdRuta
    INNER JOIN dbo.Bus b ON b.IdBus = r.IdBus
    WHERE r.IdConductor = @IdConductor
      AND r.FechaEliminacion IS NULL
      AND r.Estado = 1
      AND r.EstadoRecorrido IN ('PROGRAMADO', 'EN_CURSO')
    ORDER BY CASE WHEN r.EstadoRecorrido = 'EN_CURSO' THEN 0 ELSE 1 END, r.Fecha DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Recorrido_ObtenerPorId]
(
    @IdRecorrido UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdRecorrido,
        IdRuta,
        IdBus,
        IdConductor,
        CodigoRecorrido,
        Fecha,
        HoraInicioProgramada,
        HoraFinProgramada,
        HoraInicioReal,
        HoraFinReal,
        EstadoRecorrido,
        Observaciones,
        Estado
    FROM Recorrido
    WHERE IdRecorrido = @IdRecorrido
      AND FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Recorrido_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   OPERACIONES
   ========================================================= */
CREATE   PROCEDURE [dbo].[sp_Recorrido_Registrar]
    @IdRuta UNIQUEIDENTIFIER,
    @IdBus UNIQUEIDENTIFIER,
    @IdConductor UNIQUEIDENTIFIER,
    @Fecha DATE,
    @HoraInicioProgramada TIME = NULL,
    @HoraFinProgramada TIME = NULL,
    @EstadoRecorrido VARCHAR(20),
    @Observaciones VARCHAR(300) = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @RutaNombre VARCHAR(120);
    DECLARE @Turno VARCHAR(20);
    DECLARE @Fragmento VARCHAR(4);
    DECLARE @CodigoGenerado VARCHAR(20);

    SELECT @RutaNombre = r.Nombre, @Turno = r.Turno
    FROM dbo.Ruta r
    WHERE r.IdRuta = @IdRuta;

    SET @Fragmento =
        dbo.fn_Codigo_Fragmento(@RutaNombre, 2, 'RU') +
        dbo.fn_Codigo_Fragmento(@Turno, 2, 'TU');

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'REC')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('REC', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'REC';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'REC';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoRecorrido, 4) AS INT)), 0) + 1
            FROM dbo.Recorrido
            WHERE CodigoRecorrido LIKE 'REC-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('REC-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Recorrido
        (
            IdRecorrido, IdRuta, IdBus, IdConductor, CodigoRecorrido, Fecha,
            HoraInicioProgramada, HoraFinProgramada, HoraInicioReal, HoraFinReal,
            EstadoRecorrido, Observaciones, Estado, FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            NEWID(), @IdRuta, @IdBus, @IdConductor, @CodigoGenerado, @Fecha,
            @HoraInicioProgramada, @HoraFinProgramada, NULL, NULL,
            @EstadoRecorrido, NULLIF(@Observaciones, ''), @Estado,
            SYSUTCDATETIME(), NULL, NULL
        );

        COMMIT TRANSACTION;
        SELECT CAST(1 AS INT) AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT CAST(0 AS INT) AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Rol_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Rol_Actualizar]
(
    @IdRol UNIQUEIDENTIFIER,
    @CodigoRol VARCHAR(20),
    @Nombre VARCHAR(50),
    @Descripcion VARCHAR(150) = NULL,
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Rol
    SET
        CodigoRol = @CodigoRol,
        Nombre = @Nombre,
        Descripcion = @Descripcion,
        Estado = @Estado,
        FechaActualizacion = SYSDATETIME()
    WHERE IdRol = @IdRol
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Rol_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Rol_EliminarLogico]
(
    @IdRol UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Rol
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdRol = @IdRol
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Rol_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   ROL
   ========================================================= */

CREATE   PROCEDURE [dbo].[sp_Rol_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdRol,
        CodigoRol,
        Nombre,
        Descripcion,
        Estado,
        FechaCreacion,
        FechaActualizacion,
        FechaEliminacion
    FROM Rol
    WHERE FechaEliminacion IS NULL
    ORDER BY Nombre;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Rol_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Rol_ObtenerPorId]
(
    @IdRol UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdRol,
        CodigoRol,
        Nombre,
        Descripcion,
        Estado,
        FechaCreacion,
        FechaActualizacion,
        FechaEliminacion
    FROM Rol
    WHERE IdRol = @IdRol
      AND FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Rol_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   ROL
   ========================================================= */

CREATE PROCEDURE [dbo].[sp_Rol_Registrar]
(
    @CodigoRol VARCHAR(20),
    @Nombre VARCHAR(50),
    @Descripcion VARCHAR(150) = NULL,
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdRol UNIQUEIDENTIFIER;

    SET @IdRol = NEWID();

    INSERT INTO Rol
    (
        IdRol,
        CodigoRol,
        Nombre,
        Descripcion,
        Estado,
        FechaCreacion
    )
    VALUES
    (
        @IdRol,
        @CodigoRol,
        @Nombre,
        @Descripcion,
        @Estado,
        SYSDATETIME()
    );

    SELECT
        @@ROWCOUNT AS FilasAfectadas,
        @IdRol AS IdGenerado,
        @CodigoRol AS CodigoGenerado;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Ruta_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Ruta_Actualizar]
(
    @IdRuta UNIQUEIDENTIFIER,
    @Nombre VARCHAR(100),
    @Descripcion VARCHAR(250) = NULL,
    @Turno VARCHAR(20),
    @HoraInicio TIME,
    @HoraFin TIME,
    @PuntoInicio VARCHAR(200) = NULL,
    @PuntoFin VARCHAR(200) = NULL,
    @EstadoRuta VARCHAR(20),
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Ruta
    SET
        Nombre = @Nombre,
        Descripcion = @Descripcion,
        Turno = @Turno,
        HoraInicio = @HoraInicio,
        HoraFin = @HoraFin,
        PuntoInicio = @PuntoInicio,
        PuntoFin = @PuntoFin,
        EstadoRuta = @EstadoRuta,
        Estado = @Estado,
        FechaActualizacion = SYSDATETIME()
    WHERE IdRuta = @IdRuta
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Ruta_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[sp_Ruta_EliminarLogico]
(
    @IdRuta UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Ruta
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdRuta = @IdRuta
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Ruta_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Ruta_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdRuta,
        CodigoRuta,
        Nombre,
        Descripcion,
        Turno,
        HoraInicio,
        HoraFin,
        PuntoInicio,
        PuntoFin,
        EstadoRuta,
        Estado,
        FechaCreacion,
        FechaActualizacion,
        FechaEliminacion
    FROM Ruta
    WHERE FechaEliminacion IS NULL
    ORDER BY FechaCreacion DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Ruta_ListarActivas]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Ruta_ListarActivas]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdRuta,
        CodigoRuta,
        Nombre
    FROM Ruta
    WHERE FechaEliminacion IS NULL
      AND Estado = 1
      AND EstadoRuta = 'ACTIVA'
    ORDER BY Nombre;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Ruta_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Ruta_ObtenerPorId]
(
    @IdRuta UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdRuta,
        CodigoRuta,
        Nombre,
        Descripcion,
        Turno,
        HoraInicio,
        HoraFin,
        PuntoInicio,
        PuntoFin,
        EstadoRuta,
        Estado,
        FechaCreacion,
        FechaActualizacion,
        FechaEliminacion
    FROM Ruta
    WHERE IdRuta = @IdRuta
      AND FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Ruta_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   TRANSPORTE
   ========================================================= */
CREATE   PROCEDURE [dbo].[sp_Ruta_Registrar]
    @Nombre VARCHAR(120),
    @Descripcion VARCHAR(250) = NULL,
    @Turno VARCHAR(20),
    @HoraInicio TIME,
    @HoraFin TIME,
    @PuntoInicio VARCHAR(200) = NULL,
    @PuntoFin VARCHAR(200) = NULL,
    @EstadoRuta VARCHAR(20),
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @Fragmento VARCHAR(6);
    DECLARE @CodigoGenerado VARCHAR(20);

    SET @Fragmento =
        dbo.fn_Codigo_Fragmento(@Nombre, 3, 'RUT') +
        dbo.fn_Codigo_Fragmento(@Turno, 3, 'TUR');

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'RUT')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('RUT', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'RUT';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'RUT';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoRuta, 4) AS INT)), 0) + 1
            FROM dbo.Ruta
            WHERE CodigoRuta LIKE 'RUT-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('RUT-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Ruta
        (
            IdRuta, CodigoRuta, Nombre, Descripcion, Turno, HoraInicio, HoraFin,
            PuntoInicio, PuntoFin, EstadoRuta, Estado, FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            NEWID(), @CodigoGenerado, @Nombre, NULLIF(@Descripcion, ''), @Turno, @HoraInicio, @HoraFin,
            NULLIF(@PuntoInicio, ''), NULLIF(@PuntoFin, ''), @EstadoRuta, @Estado,
            SYSUTCDATETIME(), NULL, NULL
        );

        COMMIT TRANSACTION;
        SELECT CAST(1 AS INT) AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT CAST(0 AS INT) AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_RutaEstudiante_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE   PROCEDURE [dbo].[sp_RutaEstudiante_Actualizar]
(
    @IdRutaEstudiante UNIQUEIDENTIFIER,
    @IdRuta UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER,
    @IdParaderoSubida UNIQUEIDENTIFIER = NULL,
    @IdParaderoBajada UNIQUEIDENTIFIER = NULL,
    @FechaInicioVigencia DATE,
    @FechaFinVigencia DATE = NULL,
    @EstadoAsignacion VARCHAR(20),
    @Observaciones VARCHAR(250) = NULL,
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE RutaEstudiante
    SET
        IdRuta = @IdRuta,
        IdEstudiante = @IdEstudiante,
        IdParaderoSubida = @IdParaderoSubida,
        IdParaderoBajada = @IdParaderoBajada,
        FechaInicioVigencia = @FechaInicioVigencia,
        FechaFinVigencia = @FechaFinVigencia,
        EstadoAsignacion = @EstadoAsignacion,
        Observaciones = @Observaciones,
        Estado = @Estado,
        FechaActualizacion = SYSDATETIME()
    WHERE IdRutaEstudiante = @IdRutaEstudiante
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_RutaEstudiante_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_RutaEstudiante_EliminarLogico]
(
    @IdRutaEstudiante UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE RutaEstudiante
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdRutaEstudiante = @IdRutaEstudiante
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_RutaEstudiante_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_RutaEstudiante_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        re.IdRutaEstudiante,
        re.IdRuta,
        re.IdEstudiante,
        re.IdParaderoSubida,
        re.IdParaderoBajada,
        re.CodigoRutaEstudiante,
        re.FechaInicioVigencia,
        re.FechaFinVigencia,
        re.EstadoAsignacion,
        re.Observaciones,
        re.Estado,
        re.FechaCreacion,
        re.FechaActualizacion,
        re.FechaEliminacion,
        r.CodigoRuta,
        r.Nombre AS NombreRuta,
        e.CodigoEstudiante,
        e.Nombres AS NombresEstudiante,
        e.ApellidoPaterno AS ApellidoPaternoEstudiante,
        e.ApellidoMaterno AS ApellidoMaternoEstudiante
    FROM RutaEstudiante re
    INNER JOIN Ruta r ON re.IdRuta = r.IdRuta
    INNER JOIN Estudiante e ON re.IdEstudiante = e.IdEstudiante
    WHERE re.FechaEliminacion IS NULL
    ORDER BY re.FechaCreacion DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_RutaEstudiante_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_RutaEstudiante_ObtenerPorId]
(
    @IdRutaEstudiante UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdRutaEstudiante,
        IdRuta,
        IdEstudiante,
        IdParaderoSubida,
        IdParaderoBajada,
        CodigoRutaEstudiante,
        FechaInicioVigencia,
        FechaFinVigencia,
        EstadoAsignacion,
        Observaciones,
        Estado
    FROM RutaEstudiante
    WHERE IdRutaEstudiante = @IdRutaEstudiante
      AND FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_RutaEstudiante_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_RutaEstudiante_Registrar]
    @IdRuta UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER,
    @IdParaderoSubida UNIQUEIDENTIFIER = NULL,
    @IdParaderoBajada UNIQUEIDENTIFIER = NULL,
    @FechaInicioVigencia DATE,
    @FechaFinVigencia DATE = NULL,
    @EstadoAsignacion VARCHAR(20),
    @Observaciones VARCHAR(300) = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @RutaNombre VARCHAR(120);
    DECLARE @EstudianteNombre VARCHAR(80);
    DECLARE @Fragmento VARCHAR(6);
    DECLARE @CodigoGenerado VARCHAR(20);

    SELECT @RutaNombre = r.Nombre FROM dbo.Ruta r WHERE r.IdRuta = @IdRuta;
    SELECT @EstudianteNombre = e.Nombres FROM dbo.Estudiante e WHERE e.IdEstudiante = @IdEstudiante;

    SET @Fragmento =
        dbo.fn_Codigo_Fragmento(@EstudianteNombre, 2, 'ES') +
        dbo.fn_Codigo_Fragmento(@RutaNombre, 4, 'RUTA');

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'RAS')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('RAS', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'RAS';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'RAS';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoRutaEstudiante, 4) AS INT)), 0) + 1
            FROM dbo.RutaEstudiante
            WHERE CodigoRutaEstudiante LIKE 'RAS-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('RAS-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.RutaEstudiante
        (
            IdRutaEstudiante, IdRuta, IdEstudiante, IdParaderoSubida, IdParaderoBajada,
            CodigoRutaEstudiante, FechaInicioVigencia, FechaFinVigencia, EstadoAsignacion,
            Observaciones, Estado, FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            NEWID(), @IdRuta, @IdEstudiante, @IdParaderoSubida, @IdParaderoBajada,
            @CodigoGenerado, @FechaInicioVigencia, @FechaFinVigencia, @EstadoAsignacion,
            NULLIF(@Observaciones, ''), @Estado, SYSUTCDATETIME(), NULL, NULL
        );

        COMMIT TRANSACTION;
        SELECT CAST(1 AS INT) AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT CAST(0 AS INT) AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_UbicacionBus_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_UbicacionBus_Actualizar]
(
    @IdUbicacion UNIQUEIDENTIFIER,
    @IdRecorrido UNIQUEIDENTIFIER,
    @Latitud DECIMAL(10,7),
    @Longitud DECIMAL(10,7),
    @Velocidad DECIMAL(6,2) = NULL,
    @PrecisionMetros DECIMAL(6,2) = NULL,
    @FechaHora DATETIME2,
    @Fuente VARCHAR(20) = NULL,
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE UbicacionBus
    SET
        IdRecorrido = @IdRecorrido,
        Latitud = @Latitud,
        Longitud = @Longitud,
        Velocidad = @Velocidad,
        PrecisionMetros = @PrecisionMetros,
        FechaHora = @FechaHora,
        Fuente = @Fuente,
        Estado = @Estado,
        FechaActualizacion = SYSDATETIME()
    WHERE IdUbicacion = @IdUbicacion
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_UbicacionBus_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_UbicacionBus_EliminarLogico]
(
    @IdUbicacion UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE UbicacionBus
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdUbicacion = @IdUbicacion
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_UbicacionBus_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_UbicacionBus_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.IdUbicacion,
        u.IdRecorrido,
        u.CodigoUbicacion,
        u.Latitud,
        u.Longitud,
        u.Velocidad,
        u.PrecisionMetros,
        u.FechaHora,
        u.Fuente,
        u.Estado,
        u.FechaCreacion,
        u.FechaActualizacion,
        u.FechaEliminacion,
        r.CodigoRecorrido,
        r.Fecha AS FechaRecorrido
    FROM UbicacionBus u
    INNER JOIN Recorrido r ON u.IdRecorrido = r.IdRecorrido
    WHERE u.FechaEliminacion IS NULL
    ORDER BY u.FechaHora DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_UbicacionBus_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_UbicacionBus_ObtenerPorId]
(
    @IdUbicacion UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdUbicacion,
        IdRecorrido,
        CodigoUbicacion,
        Latitud,
        Longitud,
        Velocidad,
        PrecisionMetros,
        FechaHora,
        Fuente,
        Estado
    FROM UbicacionBus
    WHERE IdUbicacion = @IdUbicacion
      AND FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_UbicacionBus_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_UbicacionBus_Registrar]
    @IdRecorrido UNIQUEIDENTIFIER,
    @Latitud DECIMAL(10,7),
    @Longitud DECIMAL(10,7),
    @Velocidad DECIMAL(8,2) = NULL,
    @PrecisionMetros DECIMAL(8,2) = NULL,
    @FechaHora DATETIME,
    @Fuente VARCHAR(30) = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @CodigoRecorrido VARCHAR(20);
    DECLARE @Fragmento VARCHAR(4);
    DECLARE @CodigoGenerado VARCHAR(20);

    SELECT @CodigoRecorrido = r.CodigoRecorrido FROM dbo.Recorrido r WHERE r.IdRecorrido = @IdRecorrido;
    SET @Fragmento = dbo.fn_Codigo_Fragmento(REPLACE(@CodigoRecorrido, 'REC-', ''), 4, 'UBIC');

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'UBI')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('UBI', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'UBI';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'UBI';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoUbicacion, 4) AS INT)), 0) + 1
            FROM dbo.UbicacionBus
            WHERE CodigoUbicacion LIKE 'UBI-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('UBI-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.UbicacionBus
        (
            IdUbicacion, IdRecorrido, CodigoUbicacion, Latitud, Longitud,
            Velocidad, PrecisionMetros, FechaHora, Fuente, Estado,
            FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            NEWID(), @IdRecorrido, @CodigoGenerado, @Latitud, @Longitud,
            @Velocidad, @PrecisionMetros, @FechaHora, NULLIF(@Fuente, ''), @Estado,
            SYSUTCDATETIME(), NULL, NULL
        );

        COMMIT TRANSACTION;
        SELECT CAST(1 AS INT) AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT CAST(0 AS INT) AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Usuario_Actualizar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Usuario_Actualizar]
(
    @IdUsuario UNIQUEIDENTIFIER,
    @IdRol UNIQUEIDENTIFIER,
    @Username VARCHAR(50),
    @Correo VARCHAR(120),
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Usuario
    SET
        IdRol = @IdRol,
        Username = @Username,
        Correo = @Correo,
        Estado = @Estado,
        FechaActualizacion = SYSDATETIME()
    WHERE IdUsuario = @IdUsuario
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Usuario_ActualizarFotoPerfil]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Usuario_ActualizarFotoPerfil]
    @IdUsuario UNIQUEIDENTIFIER,
    @FotoPerfilUrl VARCHAR(260) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Usuario
       SET FotoPerfilUrl = NULLIF(LTRIM(RTRIM(@FotoPerfilUrl)), ''),
           FechaActualizacion = GETDATE()
     WHERE IdUsuario = @IdUsuario
       AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Usuario_ActualizarUltimoAcceso]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Usuario_ActualizarUltimoAcceso]
(
    @IdUsuario UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Usuario
    SET
        UltimoAcceso = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdUsuario = @IdUsuario
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Usuario_CambiarPassword]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Usuario_CambiarPassword]
(
    @IdUsuario UNIQUEIDENTIFIER,
    @PasswordHash VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Usuario
    SET
        PasswordHash = @PasswordHash,
        FechaActualizacion = SYSDATETIME()
    WHERE IdUsuario = @IdUsuario
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Usuario_EliminarLogico]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Usuario_EliminarLogico]
(
    @IdUsuario UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Usuario
    SET
        Estado = 0,
        FechaEliminacion = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdUsuario = @IdUsuario
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Usuario_Listar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   USUARIO
   ========================================================= */

CREATE   PROCEDURE [dbo].[sp_Usuario_Listar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.IdUsuario,
        u.IdRol,
        r.Nombre AS NombreRol,
        r.CodigoRol,
        u.CodigoUsuario,
        u.Username,
        u.Correo,
        u.PasswordHash,
        u.UltimoAcceso,
        u.Estado,
        u.FechaCreacion,
        u.FechaActualizacion,
        u.FechaEliminacion
    FROM Usuario u
    INNER JOIN Rol r ON u.IdRol = r.IdRol
    WHERE u.FechaEliminacion IS NULL
    ORDER BY u.Username;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Usuario_ListarDisponiblesParaConductor]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Usuario_ListarDisponiblesParaConductor]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.IdUsuario,
        U.Username,
        U.Correo,
        U.Estado
    FROM Usuario U
    WHERE U.Estado = 1
      AND U.FechaEliminacion IS NULL
      AND NOT EXISTS
      (
          SELECT 1
          FROM Conductor C
          WHERE C.IdUsuario = U.IdUsuario
            AND C.FechaEliminacion IS NULL
      )
    ORDER BY U.Username;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Usuario_ListarDisponiblesParaPadre]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Usuario_ListarDisponiblesParaPadre]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.IdUsuario,
        U.Username,
        U.Correo,
        U.Estado
    FROM Usuario U
    WHERE U.Estado = 1
      AND U.FechaEliminacion IS NULL
      AND NOT EXISTS
      (
          SELECT 1
          FROM PadreFamilia P
          WHERE P.IdUsuario = U.IdUsuario
            AND P.FechaEliminacion IS NULL
      )
    ORDER BY U.Username;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Usuario_Login]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Usuario_Login]
(
    @UsuarioOCorreo VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.IdUsuario,
        u.CodigoUsuario,
        u.Username,
        u.Correo,
        u.PasswordHash,
        u.Estado,
        r.IdRol,
        r.CodigoRol,
        r.Nombre AS NombreRol,
        r.Estado AS RolEstado
    FROM Usuario u
    INNER JOIN Rol r ON u.IdRol = r.IdRol
    WHERE (u.Username = @UsuarioOCorreo OR u.Correo = @UsuarioOCorreo)
      AND u.Estado = 1;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Usuario_ObtenerPorId]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_Usuario_ObtenerPorId]
(
    @IdUsuario UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.IdUsuario,
        u.IdRol,
        r.Nombre AS NombreRol,
        r.CodigoRol,
        u.CodigoUsuario,
        u.Username,
        u.Correo,
        u.PasswordHash,
        u.UltimoAcceso,
        u.Estado,
        u.FechaCreacion,
        u.FechaActualizacion,
        u.FechaEliminacion
    FROM Usuario u
    INNER JOIN Rol r ON u.IdRol = r.IdRol
    WHERE u.IdUsuario = @IdUsuario
      AND u.FechaEliminacion IS NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Usuario_Registrar]    Script Date: 24/04/2026 08:17:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Usuario_Registrar]
(
    @IdRol UNIQUEIDENTIFIER,
    @Username VARCHAR(50),
    @Correo VARCHAR(120),
    @PasswordHash VARCHAR(255),
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CodigoRol VARCHAR(4);
    DECLARE @TipoCodigo VARCHAR(10);
    DECLARE @NuevoNumero INT;
    DECLARE @CodigoUsuario VARCHAR(20);
    DECLARE @UltimoExistente INT;

    BEGIN TRANSACTION;

    BEGIN TRY
        SELECT @CodigoRol = UPPER(SUBSTRING(CodigoRol, 5, 4))
        FROM Rol
        WHERE IdRol = @IdRol;

        IF @CodigoRol IS NULL
        BEGIN
            RAISERROR('No se encontró el rol asociado al usuario.', 16, 1);
        END

        SET @TipoCodigo = 'USU-' + @CodigoRol;

        IF NOT EXISTS (
            SELECT 1
            FROM CorrelativoDocumento
            WHERE TipoCodigo = @TipoCodigo
        )
        BEGIN
            SELECT @UltimoExistente = ISNULL(MAX(CAST(RIGHT(CodigoUsuario, 4) AS INT)), 0)
            FROM Usuario
            WHERE CodigoUsuario LIKE @TipoCodigo + '[0-9][0-9][0-9][0-9]';

            INSERT INTO CorrelativoDocumento (TipoCodigo, UltimoNumero)
            VALUES (@TipoCodigo, @UltimoExistente);
        END

        UPDATE CorrelativoDocumento
        SET UltimoNumero = UltimoNumero + 1
        WHERE TipoCodigo = @TipoCodigo;

        SELECT @NuevoNumero = UltimoNumero
        FROM CorrelativoDocumento
        WHERE TipoCodigo = @TipoCodigo;

        SET @CodigoUsuario = @TipoCodigo + RIGHT('0000' + CAST(@NuevoNumero AS VARCHAR(4)), 4);

        INSERT INTO Usuario
        (
            IdRol,
            CodigoUsuario,
            Username,
            Correo,
            PasswordHash,
            UltimoAcceso,
            Estado,
            FechaCreacion
        )
        VALUES
        (
            @IdRol,
            @CodigoUsuario,
            @Username,
            @Correo,
            @PasswordHash,
            NULL,
            @Estado,
            SYSDATETIME()
        );

        COMMIT TRANSACTION;

        SELECT 1 AS FilasAfectadas, @CodigoUsuario AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/* ===== 20_Reglas_Negocio_Operaciones.sql ===== */
USE CapiMovilDB_Reconstruida;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.sp_Estudiante_Registrar
    @IdPadre UNIQUEIDENTIFIER,
    @Nombres VARCHAR(80),
    @ApellidoPaterno VARCHAR(60),
    @ApellidoMaterno VARCHAR(60),
    @DNI VARCHAR(8) = NULL,
    @FechaNacimiento DATE = NULL,
    @Genero VARCHAR(1) = NULL,
    @Grado VARCHAR(30) = NULL,
    @Seccion VARCHAR(20) = NULL,
    @Direccion VARCHAR(200) = NULL,
    @LatitudCasa DECIMAL(10,7) = NULL,
    @LongitudCasa DECIMAL(10,7) = NULL,
    @FotoUrl VARCHAR(250) = NULL,
    @Observaciones VARCHAR(300) = NULL,
    @Estado BIT,
    @CodigoGenerado VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @IdPadre IS NULL OR @IdPadre = '00000000-0000-0000-0000-000000000000'
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Debe indicar el padre de familia.' AS Mensaje;
        RETURN;
    END

    IF @DNI IS NOT NULL
    BEGIN
        SET @DNI = LTRIM(RTRIM(@DNI));
        IF LEN(@DNI) <> 8 OR @DNI LIKE '%[^0-9]%'
        BEGIN
            SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'El DNI del estudiante debe tener 8 dígitos.' AS Mensaje;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM dbo.Estudiante e
            WHERE e.DNI = @DNI
              AND e.FechaEliminacion IS NULL)
        BEGIN
            SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Ya existe un estudiante con el DNI ingresado.' AS Mensaje;
            RETURN;
        END
    END

    IF @Estado = 0
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'El estudiante debe registrarse en estado ACTIVO.' AS Mensaje;
        RETURN;
    END

    DECLARE @Correlativo INT;
    DECLARE @Fragmento NVARCHAR(6);

    SET @Fragmento =
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@Nombres, 'X'))), 2)) +
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@ApellidoPaterno, 'X'))), 2)) +
        UPPER(LEFT(LTRIM(RTRIM(ISNULL(@ApellidoMaterno, 'X'))), 2));

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'ESTUDIANTE')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('ESTUDIANTE', 0);

            UPDATE dbo.CorrelativoDocumento
            SET UltimoNumero = UltimoNumero + 1
            WHERE TipoCodigo = 'ESTUDIANTE';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'ESTUDIANTE';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoEstudiante, 4) AS INT)), 0) + 1
            FROM dbo.Estudiante
            WHERE CodigoEstudiante LIKE 'EST-%[0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('EST-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Estudiante
        (
            IdPadre, CodigoEstudiante, Nombres, ApellidoPaterno, ApellidoMaterno,
            DNI, FechaNacimiento, Genero, Grado, Seccion, Direccion,
            LatitudCasa, LongitudCasa, FotoUrl, Observaciones, Estado
        )
        VALUES
        (
            @IdPadre, @CodigoGenerado, @Nombres, @ApellidoPaterno, @ApellidoMaterno,
            @DNI, @FechaNacimiento, @Genero, @Grado, @Seccion, @Direccion,
            @LatitudCasa, @LongitudCasa, @FotoUrl, @Observaciones, 1
        );

        COMMIT TRANSACTION;
        SELECT 1 AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado, CAST(NULL AS VARCHAR(200)) AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_RutaEstudiante_Registrar
    @IdRuta UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER,
    @IdParaderoSubida UNIQUEIDENTIFIER = NULL,
    @IdParaderoBajada UNIQUEIDENTIFIER = NULL,
    @FechaInicioVigencia DATE,
    @FechaFinVigencia DATE = NULL,
    @EstadoAsignacion VARCHAR(20),
    @Observaciones VARCHAR(300) = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF EXISTS (SELECT 1 FROM dbo.Ruta WHERE IdRuta = @IdRuta AND (FechaEliminacion IS NOT NULL OR Estado = 0))
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'No se puede asignar estudiantes a una ruta inactiva.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Estudiante WHERE IdEstudiante = @IdEstudiante AND (FechaEliminacion IS NOT NULL OR Estado = 0))
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'No se puede asignar un estudiante inactivo.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM dbo.RutaEstudiante re
        WHERE re.IdRuta = @IdRuta
          AND re.IdEstudiante = @IdEstudiante
          AND re.FechaEliminacion IS NULL
          AND re.Estado = 1)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'El estudiante ya tiene una asignación activa en la ruta.' AS Mensaje;
        RETURN;
    END

    DECLARE @Correlativo INT;
    DECLARE @CodigoGenerado VARCHAR(20);
    DECLARE @Fragmento VARCHAR(6);
    DECLARE @RutaNombre VARCHAR(120);
    DECLARE @EstudianteNombre VARCHAR(80);

    SELECT @RutaNombre = r.Nombre FROM dbo.Ruta r WHERE r.IdRuta = @IdRuta;
    SELECT @EstudianteNombre = e.Nombres FROM dbo.Estudiante e WHERE e.IdEstudiante = @IdEstudiante;
    SET @Fragmento =
        dbo.fn_Codigo_Fragmento(@EstudianteNombre, 2, 'ES') +
        dbo.fn_Codigo_Fragmento(@RutaNombre, 4, 'RUTA');

    BEGIN TRY
        BEGIN TRAN;

        SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoRutaEstudiante, 4) AS INT)), 0) + 1
        FROM dbo.RutaEstudiante
        WHERE CodigoRutaEstudiante LIKE 'RAS-%[0-9][0-9][0-9][0-9]';

        SET @CodigoGenerado = CONCAT('RAS-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.RutaEstudiante
        (
            IdRutaEstudiante, IdRuta, IdEstudiante, IdParaderoSubida, IdParaderoBajada,
            CodigoRutaEstudiante, FechaInicioVigencia, FechaFinVigencia, EstadoAsignacion,
            Observaciones, Estado, FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            NEWID(), @IdRuta, @IdEstudiante, @IdParaderoSubida, @IdParaderoBajada,
            @CodigoGenerado, @FechaInicioVigencia, @FechaFinVigencia, UPPER(LTRIM(RTRIM(@EstadoAsignacion))),
            NULLIF(@Observaciones, ''), @Estado, SYSUTCDATETIME(), NULL, NULL
        );

        COMMIT;
        SELECT 1 AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado, CAST(NULL AS VARCHAR(200)) AS Mensaje;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Recorrido_Iniciar
(
    @IdRecorrido UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdRuta UNIQUEIDENTIFIER;
    DECLARE @IdBus UNIQUEIDENTIFIER;
    DECLARE @IdConductor UNIQUEIDENTIFIER;

    SELECT
        @IdRuta = r.IdRuta,
        @IdBus = r.IdBus,
        @IdConductor = r.IdConductor
    FROM dbo.Recorrido r
    WHERE r.IdRecorrido = @IdRecorrido
      AND r.FechaEliminacion IS NULL
      AND r.EstadoRecorrido = 'PROGRAMADO';

    IF @IdRuta IS NULL
    BEGIN
        SELECT 0 AS FilasAfectadas, 'Solo se pueden iniciar recorridos PROGRAMADOS y activos.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Ruta WHERE IdRuta = @IdRuta AND (Estado = 0 OR FechaEliminacion IS NOT NULL))
    BEGIN
        SELECT 0 AS FilasAfectadas, 'No se puede iniciar: la ruta está inactiva.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Bus WHERE IdBus = @IdBus AND (Estado = 0 OR FechaEliminacion IS NOT NULL))
    BEGIN
        SELECT 0 AS FilasAfectadas, 'No se puede iniciar: el bus está inactivo.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Conductor WHERE IdConductor = @IdConductor AND (Estado = 0 OR FechaEliminacion IS NOT NULL))
    BEGIN
        SELECT 0 AS FilasAfectadas, 'No se puede iniciar: el conductor está inactivo.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM dbo.Recorrido r
        WHERE r.IdConductor = @IdConductor
          AND r.IdRecorrido <> @IdRecorrido
          AND r.FechaEliminacion IS NULL
          AND r.EstadoRecorrido = 'EN_CURSO')
    BEGIN
        SELECT 0 AS FilasAfectadas, 'No se puede iniciar: el conductor ya tiene un recorrido EN_CURSO.' AS Mensaje;
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.RutaEstudiante re
        INNER JOIN dbo.Estudiante e ON e.IdEstudiante = re.IdEstudiante
        WHERE re.IdRuta = @IdRuta
          AND re.Estado = 1
          AND re.FechaEliminacion IS NULL
          AND e.Estado = 1
          AND e.FechaEliminacion IS NULL)
    BEGIN
        SELECT 0 AS FilasAfectadas, 'No se puede iniciar: la ruta no tiene estudiantes activos asignados.' AS Mensaje;
        RETURN;
    END

    UPDATE dbo.Recorrido
    SET EstadoRecorrido = 'EN_CURSO',
        HoraInicioReal = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdRecorrido = @IdRecorrido
      AND FechaEliminacion IS NULL
      AND EstadoRecorrido = 'PROGRAMADO';

    SELECT @@ROWCOUNT AS FilasAfectadas, CAST(NULL AS VARCHAR(200)) AS Mensaje;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Recorrido_Finalizar
(
    @IdRecorrido UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.EventoAbordaje ea
        WHERE ea.IdRecorrido = @IdRecorrido
          AND ea.FechaEliminacion IS NULL
          AND ea.TipoEvento = 'SUBIDA'
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.EventoAbordaje eb
              WHERE eb.IdRecorrido = ea.IdRecorrido
                AND eb.IdEstudiante = ea.IdEstudiante
                AND eb.TipoEvento = 'BAJADA'
                AND eb.FechaEliminacion IS NULL))
    BEGIN
        SELECT 0 AS FilasAfectadas, 'No se puede finalizar: existen estudiantes con SUBIDA sin BAJADA.' AS Mensaje;
        RETURN;
    END

    UPDATE dbo.Recorrido
    SET EstadoRecorrido = 'FINALIZADO',
        HoraFinReal = SYSDATETIME(),
        FechaActualizacion = SYSDATETIME()
    WHERE IdRecorrido = @IdRecorrido
      AND FechaEliminacion IS NULL
      AND EstadoRecorrido = 'EN_CURSO';

    SELECT @@ROWCOUNT AS FilasAfectadas, CAST(NULL AS VARCHAR(200)) AS Mensaje;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_EventoAbordaje_Registrar
    @IdRecorrido UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER,
    @IdParadero UNIQUEIDENTIFIER = NULL,
    @RegistradoPor UNIQUEIDENTIFIER = NULL,
    @TipoEvento VARCHAR(20),
    @FechaHora DATETIME,
    @Observacion VARCHAR(300) = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @TipoEvento = UPPER(LTRIM(RTRIM(@TipoEvento)));

    IF @TipoEvento NOT IN ('SUBIDA', 'BAJADA', 'AUSENTE', 'NO_ABORDO')
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Tipo de evento no permitido.' AS Mensaje;
        RETURN;
    END

    DECLARE @IdRuta UNIQUEIDENTIFIER;

    SELECT @IdRuta = r.IdRuta
    FROM dbo.Recorrido r
    WHERE r.IdRecorrido = @IdRecorrido
      AND r.FechaEliminacion IS NULL
      AND r.EstadoRecorrido = 'EN_CURSO';

    IF @IdRuta IS NULL
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Solo se pueden registrar eventos en recorridos EN_CURSO.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Estudiante e WHERE e.IdEstudiante = @IdEstudiante AND (e.Estado = 0 OR e.FechaEliminacion IS NOT NULL))
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'No se puede registrar evento para un estudiante inactivo.' AS Mensaje;
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.RutaEstudiante re
        WHERE re.IdRuta = @IdRuta
          AND re.IdEstudiante = @IdEstudiante
          AND re.Estado = 1
          AND re.FechaEliminacion IS NULL)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'El estudiante no pertenece al recorrido indicado.' AS Mensaje;
        RETURN;
    END

    DECLARE @Subidas INT = 0;
    DECLARE @Bajadas INT = 0;
    DECLARE @Ausentes INT = 0;
    DECLARE @NoAbordo INT = 0;

    SELECT
        @Subidas = SUM(CASE WHEN TipoEvento = 'SUBIDA' THEN 1 ELSE 0 END),
        @Bajadas = SUM(CASE WHEN TipoEvento = 'BAJADA' THEN 1 ELSE 0 END),
        @Ausentes = SUM(CASE WHEN TipoEvento = 'AUSENTE' THEN 1 ELSE 0 END),
        @NoAbordo = SUM(CASE WHEN TipoEvento = 'NO_ABORDO' THEN 1 ELSE 0 END)
    FROM dbo.EventoAbordaje
    WHERE IdRecorrido = @IdRecorrido
      AND IdEstudiante = @IdEstudiante
      AND FechaEliminacion IS NULL;

    IF (@Ausentes > 0 OR @NoAbordo > 0)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'El estudiante ya tiene un estado final en este recorrido.' AS Mensaje;
        RETURN;
    END

    IF (@Subidas > 0 AND @Bajadas > 0)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'El estudiante ya completó su ciclo de abordaje en este recorrido.' AS Mensaje;
        RETURN;
    END

    IF (@TipoEvento = 'SUBIDA' AND (@Subidas > 0 OR @Bajadas > 0 OR @Ausentes > 0 OR @NoAbordo > 0))
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'No se puede registrar SUBIDA en el estado actual del estudiante.' AS Mensaje;
        RETURN;
    END

    IF (@TipoEvento = 'BAJADA' AND (@Subidas = 0 OR @Bajadas > 0 OR @Ausentes > 0 OR @NoAbordo > 0))
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'No se puede registrar BAJADA sin una SUBIDA previa válida.' AS Mensaje;
        RETURN;
    END

    IF (@TipoEvento IN ('AUSENTE', 'NO_ABORDO') AND (@Subidas > 0 OR @Bajadas > 0 OR @Ausentes > 0 OR @NoAbordo > 0))
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'No se puede registrar un estado final porque ya existen eventos previos.' AS Mensaje;
        RETURN;
    END

    DECLARE @Correlativo INT;
    DECLARE @CodigoGenerado VARCHAR(20);

    SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoEvento, 4) AS INT)), 0) + 1
    FROM dbo.EventoAbordaje
    WHERE CodigoEvento LIKE 'EVE-%[0-9][0-9][0-9][0-9]';

    SET @CodigoGenerado = CONCAT('EVE-', RIGHT(CONCAT('0000', @Correlativo), 4));

    INSERT INTO dbo.EventoAbordaje
    (
        IdEvento, IdRecorrido, IdEstudiante, IdParadero, RegistradoPor,
        CodigoEvento, TipoEvento, FechaHora, Observacion, Estado,
        FechaCreacion, FechaActualizacion, FechaEliminacion
    )
    VALUES
    (
        NEWID(), @IdRecorrido, @IdEstudiante, @IdParadero, @RegistradoPor,
        @CodigoGenerado, @TipoEvento, @FechaHora, NULLIF(@Observacion, ''), @Estado,
        SYSUTCDATETIME(), NULL, NULL
    );

    SELECT 1 AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado, CAST(NULL AS VARCHAR(200)) AS Mensaje;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UbicacionBus_Registrar
    @IdRecorrido UNIQUEIDENTIFIER,
    @Latitud DECIMAL(10,7),
    @Longitud DECIMAL(10,7),
    @Velocidad DECIMAL(8,2) = NULL,
    @PrecisionMetros DECIMAL(8,2) = NULL,
    @FechaHora DATETIME,
    @Fuente VARCHAR(30) = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Latitud < -90 OR @Latitud > 90 OR @Longitud < -180 OR @Longitud > 180
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Coordenadas fuera de rango.' AS Mensaje;
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Recorrido r
        WHERE r.IdRecorrido = @IdRecorrido
          AND r.EstadoRecorrido = 'EN_CURSO'
          AND r.FechaEliminacion IS NULL)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Solo se puede registrar ubicación en recorridos EN_CURSO.' AS Mensaje;
        RETURN;
    END

    DECLARE @Correlativo INT;
    DECLARE @CodigoGenerado VARCHAR(20);

    SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoUbicacion, 4) AS INT)), 0) + 1
    FROM dbo.UbicacionBus
    WHERE CodigoUbicacion LIKE 'UBI-%[0-9][0-9][0-9][0-9]';

    SET @CodigoGenerado = CONCAT('UBI-', RIGHT(CONCAT('0000', @Correlativo), 4));

    INSERT INTO dbo.UbicacionBus
    (
        IdUbicacion, IdRecorrido, CodigoUbicacion, Latitud, Longitud,
        Velocidad, PrecisionMetros, FechaHora, Fuente, Estado,
        FechaCreacion, FechaActualizacion, FechaEliminacion
    )
    VALUES
    (
        NEWID(), @IdRecorrido, @CodigoGenerado, @Latitud, @Longitud,
        @Velocidad, @PrecisionMetros, @FechaHora, NULLIF(@Fuente, ''), @Estado,
        SYSUTCDATETIME(), NULL, NULL
    );

    SELECT 1 AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado, CAST(NULL AS VARCHAR(200)) AS Mensaje;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Incidencia_Registrar
(
    @IdRecorrido UNIQUEIDENTIFIER,
    @IdConductor UNIQUEIDENTIFIER,
    @ReportadoPor UNIQUEIDENTIFIER = NULL,
    @TipoIncidencia VARCHAR(50),
    @Descripcion VARCHAR(300),
    @FechaHora DATETIME,
    @EstadoIncidencia VARCHAR(20),
    @Prioridad VARCHAR(20),
    @Solucion VARCHAR(300) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Recorrido r
        WHERE r.IdRecorrido = @IdRecorrido
          AND r.IdConductor = @IdConductor
          AND r.EstadoRecorrido = 'EN_CURSO'
          AND r.FechaEliminacion IS NULL)
    BEGIN
        SELECT
            0 AS FilasAfectadas,
            CAST(NULL AS UNIQUEIDENTIFIER) AS IdIncidencia,
            CAST(NULL AS VARCHAR(20)) AS CodigoGenerado,
            'Solo se pueden registrar incidencias en recorridos EN_CURSO del conductor autenticado.' AS Mensaje;
        RETURN;
    END

    DECLARE @IdIncidencia UNIQUEIDENTIFIER = NEWID();
    DECLARE @Correlativo INT;
    DECLARE @CodigoGenerado VARCHAR(20);
    DECLARE @Fragmento VARCHAR(6) = dbo.fn_Codigo_Fragmento(@TipoIncidencia, 6, 'INCIDE');

    BEGIN TRY
        BEGIN TRAN;

        SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoIncidencia, 4) AS INT)), 0) + 1
        FROM dbo.Incidencia
        WHERE CodigoIncidencia LIKE 'INC-%[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][0-9][0-9][0-9][0-9]';

        SET @CodigoGenerado = CONCAT('INC-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Incidencia
        (
            IdIncidencia, IdRecorrido, IdConductor, ReportadoPor, CodigoIncidencia,
            TipoIncidencia, Descripcion, FechaHora, EstadoIncidencia, Prioridad,
            FechaCierre, Solucion, Estado, FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            @IdIncidencia, @IdRecorrido, @IdConductor, @ReportadoPor, @CodigoGenerado,
            UPPER(LTRIM(RTRIM(@TipoIncidencia))), LTRIM(RTRIM(@Descripcion)), @FechaHora,
            UPPER(LTRIM(RTRIM(@EstadoIncidencia))), UPPER(LTRIM(RTRIM(@Prioridad))),
            NULL, NULLIF(LTRIM(RTRIM(@Solucion)), ''), 1, GETDATE(), NULL, NULL
        );

        COMMIT;

        SELECT
            1 AS FilasAfectadas,
            @IdIncidencia AS IdIncidencia,
            @CodigoGenerado AS CodigoGenerado,
            CAST(NULL AS VARCHAR(200)) AS Mensaje;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;

        SELECT
            0 AS FilasAfectadas,
            CAST(NULL AS UNIQUEIDENTIFIER) AS IdIncidencia,
            CAST(NULL AS VARCHAR(20)) AS CodigoGenerado,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

/* ===== 30_Ruta_Mapa.sql ===== */
USE CapiMovilDB_Reconstruida;
GO
/*
    CapiMovil - Consolidado RUTA (Mapa Inicio/Fin)
    Incluye:
    1) ALTER TABLE Ruta para coordenadas/direcciones de inicio y fin
    2) Funciones auxiliares para fragmento de código
    3) CREATE OR ALTER SPs de Ruta para listar/obtener/registrar/actualizar
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   1) ESTRUCTURA TABLA RUTA
   ========================================================= */
IF COL_LENGTH('dbo.Ruta', 'LatitudInicio') IS NULL
    ALTER TABLE dbo.Ruta ADD LatitudInicio DECIMAL(10,7) NULL;
GO
IF COL_LENGTH('dbo.Ruta', 'LongitudInicio') IS NULL
    ALTER TABLE dbo.Ruta ADD LongitudInicio DECIMAL(10,7) NULL;
GO
IF COL_LENGTH('dbo.Ruta', 'DireccionInicio') IS NULL
    ALTER TABLE dbo.Ruta ADD DireccionInicio VARCHAR(250) NULL;
GO
IF COL_LENGTH('dbo.Ruta', 'LatitudFin') IS NULL
    ALTER TABLE dbo.Ruta ADD LatitudFin DECIMAL(10,7) NULL;
GO
IF COL_LENGTH('dbo.Ruta', 'LongitudFin') IS NULL
    ALTER TABLE dbo.Ruta ADD LongitudFin DECIMAL(10,7) NULL;
GO
IF COL_LENGTH('dbo.Ruta', 'DireccionFin') IS NULL
    ALTER TABLE dbo.Ruta ADD DireccionFin VARCHAR(250) NULL;
GO

/* =========================================================
   2) FUNCIONES AUXILIARES CÓDIGO RUTA
   ========================================================= */
CREATE OR ALTER FUNCTION dbo.fn_Codigo_SoloAlfanumerico
(
    @Texto NVARCHAR(200)
)
RETURNS VARCHAR(200)
AS
BEGIN
    DECLARE @I INT = 1;
    DECLARE @Len INT = LEN(ISNULL(@Texto, ''));
    DECLARE @Salida VARCHAR(200) = '';
    DECLARE @Ch NCHAR(1);
    DECLARE @Ascii INT;

    WHILE @I <= @Len
    BEGIN
        SET @Ch = SUBSTRING(@Texto, @I, 1);
        SET @Ascii = UNICODE(@Ch);

        IF (@Ascii BETWEEN 48 AND 57) OR (@Ascii BETWEEN 65 AND 90) OR (@Ascii BETWEEN 97 AND 122)
            SET @Salida += CONVERT(VARCHAR(1), @Ch);

        SET @I += 1;
    END

    RETURN UPPER(@Salida);
END
GO

CREATE OR ALTER FUNCTION dbo.fn_Codigo_Fragmento
(
    @Texto NVARCHAR(200),
    @Longitud INT,
    @Fallback VARCHAR(20)
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Limpio VARCHAR(200) = dbo.fn_Codigo_SoloAlfanumerico(@Texto);

    IF @Longitud IS NULL OR @Longitud <= 0
        SET @Longitud = 6;

    IF LEN(@Limpio) = 0
        SET @Limpio = dbo.fn_Codigo_SoloAlfanumerico(@Fallback);

    IF LEN(@Limpio) = 0
        SET @Limpio = 'RUTA';

    RETURN LEFT(@Limpio + REPLICATE('X', @Longitud), @Longitud);
END
GO

/* =========================================================
   3) SP_RUTA_LISTAR
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Ruta_Listar
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdRuta,
        CodigoRuta,
        Nombre,
        Descripcion,
        Turno,
        HoraInicio,
        HoraFin,
        PuntoInicio,
        PuntoFin,
        LatitudInicio,
        LongitudInicio,
        DireccionInicio,
        LatitudFin,
        LongitudFin,
        DireccionFin,
        EstadoRuta,
        Estado,
        FechaCreacion,
        FechaActualizacion,
        FechaEliminacion
    FROM dbo.Ruta
    WHERE FechaEliminacion IS NULL
    ORDER BY Nombre;
END
GO

/* =========================================================
   4) SP_RUTA_OBTENERPORID
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Ruta_ObtenerPorId
(
    @IdRuta UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdRuta,
        CodigoRuta,
        Nombre,
        Descripcion,
        Turno,
        HoraInicio,
        HoraFin,
        PuntoInicio,
        PuntoFin,
        LatitudInicio,
        LongitudInicio,
        DireccionInicio,
        LatitudFin,
        LongitudFin,
        DireccionFin,
        EstadoRuta,
        Estado,
        FechaCreacion,
        FechaActualizacion,
        FechaEliminacion
    FROM dbo.Ruta
    WHERE IdRuta = @IdRuta
      AND FechaEliminacion IS NULL;
END
GO

/* =========================================================
   5) SP_RUTA_REGISTRAR
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Ruta_Registrar
(
    @Nombre VARCHAR(120),
    @Descripcion VARCHAR(300) = NULL,
    @Turno VARCHAR(20),
    @HoraInicio TIME,
    @HoraFin TIME,
    @PuntoInicio VARCHAR(200) = NULL,
    @PuntoFin VARCHAR(200) = NULL,
    @LatitudInicio DECIMAL(10,7) = NULL,
    @LongitudInicio DECIMAL(10,7) = NULL,
    @DireccionInicio VARCHAR(250) = NULL,
    @LatitudFin DECIMAL(10,7) = NULL,
    @LongitudFin DECIMAL(10,7) = NULL,
    @DireccionFin VARCHAR(250) = NULL,
    @EstadoRuta VARCHAR(20),
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @HoraInicio >= @HoraFin
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'La hora de inicio debe ser menor a la hora de fin.' AS Mensaje;
        RETURN;
    END

    IF @LatitudInicio IS NOT NULL AND (@LatitudInicio < -90 OR @LatitudInicio > 90)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Latitud de inicio fuera de rango.' AS Mensaje;
        RETURN;
    END

    IF @LongitudInicio IS NOT NULL AND (@LongitudInicio < -180 OR @LongitudInicio > 180)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Longitud de inicio fuera de rango.' AS Mensaje;
        RETURN;
    END

    IF @LatitudFin IS NOT NULL AND (@LatitudFin < -90 OR @LatitudFin > 90)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Latitud de fin fuera de rango.' AS Mensaje;
        RETURN;
    END

    IF @LongitudFin IS NOT NULL AND (@LongitudFin < -180 OR @LongitudFin > 180)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Longitud de fin fuera de rango.' AS Mensaje;
        RETURN;
    END

    IF ((@LatitudInicio IS NULL AND @LongitudInicio IS NOT NULL) OR (@LatitudInicio IS NOT NULL AND @LongitudInicio IS NULL)
        OR (@LatitudFin IS NULL AND @LongitudFin IS NOT NULL) OR (@LatitudFin IS NOT NULL AND @LongitudFin IS NULL))
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Debe registrar latitud y longitud completas por cada punto.' AS Mensaje;
        RETURN;
    END

    IF ((@LatitudInicio IS NULL AND @LatitudFin IS NOT NULL) OR (@LatitudInicio IS NOT NULL AND @LatitudFin IS NULL))
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Debe definir inicio y fin de la ruta.' AS Mensaje;
        RETURN;
    END

    DECLARE @Correlativo INT;
    DECLARE @Fragmento VARCHAR(6);
    DECLARE @CodigoGenerado VARCHAR(20);

    BEGIN TRY
        BEGIN TRAN;

        SET @Fragmento = dbo.fn_Codigo_Fragmento(@Nombre, 6, 'RUTA');

        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'RUT')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('RUT', 0);

            UPDATE dbo.CorrelativoDocumento
               SET UltimoNumero = UltimoNumero + 1
             WHERE TipoCodigo = 'RUT';

            SELECT @Correlativo = UltimoNumero
            FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
            WHERE TipoCodigo = 'RUT';
        END
        ELSE
        BEGIN
            SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoRuta, 4) AS INT)), 0) + 1
            FROM dbo.Ruta
            WHERE CodigoRuta LIKE 'RUT-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][0-9][0-9][0-9][0-9]';
        END

        SET @CodigoGenerado = CONCAT('RUT-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Ruta
        (
            IdRuta,
            CodigoRuta,
            Nombre,
            Descripcion,
            Turno,
            HoraInicio,
            HoraFin,
            PuntoInicio,
            PuntoFin,
            LatitudInicio,
            LongitudInicio,
            DireccionInicio,
            LatitudFin,
            LongitudFin,
            DireccionFin,
            EstadoRuta,
            Estado,
            FechaCreacion,
            FechaActualizacion,
            FechaEliminacion
        )
        VALUES
        (
            NEWID(),
            @CodigoGenerado,
            @Nombre,
            NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            UPPER(LTRIM(RTRIM(@Turno))),
            @HoraInicio,
            @HoraFin,
            NULLIF(LTRIM(RTRIM(@PuntoInicio)), ''),
            NULLIF(LTRIM(RTRIM(@PuntoFin)), ''),
            @LatitudInicio,
            @LongitudInicio,
            NULLIF(LTRIM(RTRIM(@DireccionInicio)), ''),
            @LatitudFin,
            @LongitudFin,
            NULLIF(LTRIM(RTRIM(@DireccionFin)), ''),
            UPPER(LTRIM(RTRIM(@EstadoRuta))),
            @Estado,
            SYSUTCDATETIME(),
            NULL,
            NULL
        );

        COMMIT;

        SELECT 1 AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado, CAST(NULL AS VARCHAR(200)) AS Mensaje;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

/* =========================================================
   6) SP_RUTA_ACTUALIZAR
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Ruta_Actualizar
(
    @IdRuta UNIQUEIDENTIFIER,
    @Nombre VARCHAR(120),
    @Descripcion VARCHAR(300) = NULL,
    @Turno VARCHAR(20),
    @HoraInicio TIME,
    @HoraFin TIME,
    @PuntoInicio VARCHAR(200) = NULL,
    @PuntoFin VARCHAR(200) = NULL,
    @LatitudInicio DECIMAL(10,7) = NULL,
    @LongitudInicio DECIMAL(10,7) = NULL,
    @DireccionInicio VARCHAR(250) = NULL,
    @LatitudFin DECIMAL(10,7) = NULL,
    @LongitudFin DECIMAL(10,7) = NULL,
    @DireccionFin VARCHAR(250) = NULL,
    @EstadoRuta VARCHAR(20),
    @Estado BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @HoraInicio >= @HoraFin
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'La hora de inicio debe ser menor a la hora de fin.' AS Mensaje;
        RETURN;
    END

    IF @LatitudInicio IS NOT NULL AND (@LatitudInicio < -90 OR @LatitudInicio > 90)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Latitud de inicio fuera de rango.' AS Mensaje;
        RETURN;
    END

    IF @LongitudInicio IS NOT NULL AND (@LongitudInicio < -180 OR @LongitudInicio > 180)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Longitud de inicio fuera de rango.' AS Mensaje;
        RETURN;
    END

    IF @LatitudFin IS NOT NULL AND (@LatitudFin < -90 OR @LatitudFin > 90)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Latitud de fin fuera de rango.' AS Mensaje;
        RETURN;
    END

    IF @LongitudFin IS NOT NULL AND (@LongitudFin < -180 OR @LongitudFin > 180)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Longitud de fin fuera de rango.' AS Mensaje;
        RETURN;
    END

    UPDATE dbo.Ruta
    SET
        Nombre = @Nombre,
        Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
        Turno = UPPER(LTRIM(RTRIM(@Turno))),
        HoraInicio = @HoraInicio,
        HoraFin = @HoraFin,
        PuntoInicio = NULLIF(LTRIM(RTRIM(@PuntoInicio)), ''),
        PuntoFin = NULLIF(LTRIM(RTRIM(@PuntoFin)), ''),
        LatitudInicio = @LatitudInicio,
        LongitudInicio = @LongitudInicio,
        DireccionInicio = NULLIF(LTRIM(RTRIM(@DireccionInicio)), ''),
        LatitudFin = @LatitudFin,
        LongitudFin = @LongitudFin,
        DireccionFin = NULLIF(LTRIM(RTRIM(@DireccionFin)), ''),
        EstadoRuta = UPPER(LTRIM(RTRIM(@EstadoRuta))),
        Estado = @Estado,
        FechaActualizacion = SYSUTCDATETIME()
    WHERE IdRuta = @IdRuta
      AND FechaEliminacion IS NULL;

    SELECT @@ROWCOUNT AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, CAST(NULL AS VARCHAR(200)) AS Mensaje;
END
GO

/* ===== 40_Unificar_CodigoRecorrido.sql ===== */
USE CapiMovilDB_Reconstruida;
GO
/*
    CapiMovil - Unificación de CódigoRecorrido
    Regla única:
      REC- + LEFT(UPPER(REPLACE(REPLACE(Ruta.CodigoRuta,' ',''),'-','')) + 'XXXX', 4) + correlativo global de 4 dígitos

    Ejemplos:
      CodigoRuta = 'RUTA-01' => REC-RUTA0001
      CodigoRuta = 'RT-07'   => REC-RT070002

    Diagnóstico recomendado previo/post despliegue:
      SELECT
          CorrelativoREC = cd.UltimoNumero,
          MaxRecorrido = mx.MaxRec,
          Desfase = mx.MaxRec - ISNULL(cd.UltimoNumero, 0)
      FROM (SELECT ISNULL(MAX(TRY_CAST(RIGHT(CodigoRecorrido, 4) AS INT)), 0) AS MaxRec
            FROM dbo.Recorrido
            WHERE CodigoRecorrido LIKE 'REC-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][0-9][0-9][0-9][0-9]') mx
      LEFT JOIN dbo.CorrelativoDocumento cd ON cd.TipoCodigo = 'REC';
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.sp_Recorrido_Registrar
    @IdRuta UNIQUEIDENTIFIER,
    @IdBus UNIQUEIDENTIFIER,
    @IdConductor UNIQUEIDENTIFIER,
    @Fecha DATE,
    @HoraInicioProgramada TIME = NULL,
    @HoraFinProgramada TIME = NULL,
    @EstadoRecorrido VARCHAR(20),
    @Observaciones VARCHAR(300) = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Correlativo INT;
    DECLARE @CorrelativoActual INT = 0;
    DECLARE @MaxTabla INT = 0;
    DECLARE @Intentos INT = 0;
    DECLARE @CodigoRuta VARCHAR(20);
    DECLARE @Fragmento VARCHAR(4);
    DECLARE @CodigoGenerado VARCHAR(20);
    DECLARE @TmpCorrelativo TABLE (Valor INT);

    SELECT @CodigoRuta = r.CodigoRuta
    FROM dbo.Ruta r
    WHERE r.IdRuta = @IdRuta;

    SET @Fragmento = LEFT(
        UPPER(REPLACE(REPLACE(ISNULL(@CodigoRuta, 'RUTA'), ' ', ''), '-', '')) + 'XXXX',
        4
    );

    SELECT @MaxTabla = ISNULL(MAX(TRY_CAST(RIGHT(CodigoRecorrido, 4) AS INT)), 0)
    FROM dbo.Recorrido
    WHERE CodigoRecorrido LIKE 'REC-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][0-9][0-9][0-9][0-9]';

    BEGIN TRANSACTION;
    BEGIN TRY
        IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK) WHERE TipoCodigo = 'REC')
                INSERT INTO dbo.CorrelativoDocumento (TipoCodigo, UltimoNumero) VALUES ('REC', @MaxTabla);
            ELSE
            BEGIN
                SELECT @CorrelativoActual = UltimoNumero
                FROM dbo.CorrelativoDocumento WITH (UPDLOCK, HOLDLOCK)
                WHERE TipoCodigo = 'REC';

                IF ISNULL(@CorrelativoActual, 0) < @MaxTabla
                    UPDATE dbo.CorrelativoDocumento
                       SET UltimoNumero = @MaxTabla
                     WHERE TipoCodigo = 'REC';
            END
        END
        ELSE
        BEGIN
            SET @CorrelativoActual = @MaxTabla;
        END

        WHILE (1 = 1)
        BEGIN
            IF OBJECT_ID('dbo.CorrelativoDocumento', 'U') IS NOT NULL
            BEGIN
                DELETE FROM @TmpCorrelativo;
                UPDATE dbo.CorrelativoDocumento
                   SET UltimoNumero = UltimoNumero + 1
                OUTPUT inserted.UltimoNumero INTO @TmpCorrelativo(Valor)
                 WHERE TipoCodigo = 'REC';

                SELECT TOP 1 @Correlativo = Valor FROM @TmpCorrelativo;
            END
            ELSE
            BEGIN
                SET @CorrelativoActual = @CorrelativoActual + 1;
                SET @Correlativo = @CorrelativoActual;
            END

            SET @CodigoGenerado = CONCAT('REC-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

            IF NOT EXISTS (
                SELECT 1
                FROM dbo.Recorrido WITH (UPDLOCK, HOLDLOCK)
                WHERE CodigoRecorrido = @CodigoGenerado
            )
                BREAK;

            SET @Intentos += 1;
            IF @Intentos >= 50
                THROW 50001, 'No se pudo generar un CodigoRecorrido único luego de 50 intentos.', 1;
        END

        INSERT INTO dbo.Recorrido
        (
            IdRecorrido, IdRuta, IdBus, IdConductor, CodigoRecorrido, Fecha,
            HoraInicioProgramada, HoraFinProgramada, HoraInicioReal, HoraFinReal,
            EstadoRecorrido, Observaciones, Estado, FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            NEWID(), @IdRuta, @IdBus, @IdConductor, @CodigoGenerado, @Fecha,
            @HoraInicioProgramada, @HoraFinProgramada, NULL, NULL,
            @EstadoRecorrido, NULLIF(@Observaciones, ''), @Estado,
            SYSUTCDATETIME(), NULL, NULL
        );

        COMMIT TRANSACTION;
        SELECT CAST(1 AS INT) AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT CAST(0 AS INT) AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

/*
-- OPCIONAL: normalización histórica (solo si decides estandarizar legado)
;WITH Base AS (
    SELECT r.IdRecorrido,
           ROW_NUMBER() OVER (ORDER BY r.FechaCreacion, r.IdRecorrido) AS Nro,
           LEFT(UPPER(REPLACE(REPLACE(ISNULL(ru.CodigoRuta, 'RUTA'), ' ', ''), '-', '')) + 'XXXX', 4) AS Fragmento
    FROM dbo.Recorrido r
    INNER JOIN dbo.Ruta ru ON ru.IdRuta = r.IdRuta
)
UPDATE r
   SET r.CodigoRecorrido = CONCAT('REC-', b.Fragmento, RIGHT(CONCAT('0000', b.Nro), 4))
FROM dbo.Recorrido r
INNER JOIN Base b ON b.IdRecorrido = r.IdRecorrido;
*/

/* ===== 50_Correcciones_Operativas.sql ===== */
USE CapiMovilDB_Reconstruida;
GO
/*
    Script consolidado - CapiMovil
    Fecha: 2026-04-27
    Incluye:
      1) Normalización de código de auditoría (AUD-YYYY-000001)
      2) Detalle de notificación con código de estudiante
      3) Módulo de calificación de conductor (tabla + SP)
*/

SET NOCOUNT ON;
GO

/* ============================================================
   1) AUDITORÍA - código consistente
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.sp_Auditoria_Registrar
    @Tabla NVARCHAR(100),
    @IdRegistro UNIQUEIDENTIFIER = NULL,
    @Accion NVARCHAR(20),
    @DatosAntes NVARCHAR(MAX) = NULL,
    @DatosDespues NVARCHAR(MAX) = NULL,
    @UsuarioId UNIQUEIDENTIFIER = NULL,
    @NombreUsuario NVARCHAR(120) = NULL,
    @Ip NVARCHAR(50) = NULL,
    @UserAgent NVARCHAR(300) = NULL,
    @Modulo NVARCHAR(100) = NULL,
    @Observacion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @IdAuditoria UNIQUEIDENTIFIER = NEWID();
        DECLARE @Correlativo INT;
        DECLARE @CodigoAuditoria NVARCHAR(25);
        DECLARE @Fecha DATE = CAST(GETDATE() AS DATE);
        DECLARE @Anio CHAR(4) = CONVERT(CHAR(4), YEAR(@Fecha));

        SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoAuditoria, 6) AS INT)), 0) + 1
        FROM dbo.Auditoria
        WHERE CodigoAuditoria LIKE CONCAT('AUD-', @Anio, '-%');

        SET @CodigoAuditoria = CONCAT('AUD-', @Anio, '-', RIGHT(CONCAT('000000', @Correlativo), 6));

        INSERT INTO dbo.Auditoria
        (
            IdAuditoria, CodigoAuditoria, Tabla, IdRegistro, Accion,
            DatosAntes, DatosDespues, UsuarioId, NombreUsuario, Ip,
            UserAgent, Modulo, Observacion, Fecha, Estado
        )
        VALUES
        (
            @IdAuditoria, @CodigoAuditoria, @Tabla, @IdRegistro, @Accion,
            @DatosAntes, @DatosDespues, @UsuarioId, @NombreUsuario, @Ip,
            @UserAgent, @Modulo, @Observacion, GETDATE(), 1
        );

        SELECT
            CAST(1 AS BIT) AS Exito,
            1 AS FilasAfectadas,
            @CodigoAuditoria AS CodigoGenerado,
            CAST(NULL AS NVARCHAR(400)) AS Mensaje;
    END TRY
    BEGIN CATCH
        SELECT
            CAST(0 AS BIT) AS Exito,
            0 AS FilasAfectadas,
            CAST('' AS NVARCHAR(30)) AS CodigoGenerado,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

/* ============================================================
   4) EVENTO ABORDAJE - fecha/hora automática en servidor
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.sp_EventoAbordaje_Registrar
    @IdRecorrido UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER,
    @IdParadero UNIQUEIDENTIFIER = NULL,
    @RegistradoPor UNIQUEIDENTIFIER = NULL,
    @TipoEvento VARCHAR(20),
    @FechaHora DATETIME,
    @Observacion VARCHAR(300) = NULL,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @TipoEvento = UPPER(LTRIM(RTRIM(@TipoEvento)));
    SET @FechaHora = GETDATE();

    IF @TipoEvento NOT IN ('SUBIDA', 'BAJADA', 'AUSENTE', 'NO_ABORDO')
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Tipo de evento no permitido.' AS Mensaje;
        RETURN;
    END

    DECLARE @IdRuta UNIQUEIDENTIFIER;
    SELECT @IdRuta = r.IdRuta
    FROM dbo.Recorrido r
    WHERE r.IdRecorrido = @IdRecorrido
      AND r.FechaEliminacion IS NULL
      AND r.EstadoRecorrido = 'EN_CURSO';

    IF @IdRuta IS NULL
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'Solo se pueden registrar eventos en recorridos EN_CURSO.' AS Mensaje;
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.RutaEstudiante re
        WHERE re.IdRuta = @IdRuta
          AND re.IdEstudiante = @IdEstudiante
          AND re.Estado = 1
          AND re.FechaEliminacion IS NULL)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'El estudiante no pertenece al recorrido indicado.' AS Mensaje;
        RETURN;
    END

    DECLARE @Subidas INT = 0, @Bajadas INT = 0, @Ausentes INT = 0, @NoAbordo INT = 0;
    SELECT
        @Subidas = SUM(CASE WHEN TipoEvento = 'SUBIDA' THEN 1 ELSE 0 END),
        @Bajadas = SUM(CASE WHEN TipoEvento = 'BAJADA' THEN 1 ELSE 0 END),
        @Ausentes = SUM(CASE WHEN TipoEvento = 'AUSENTE' THEN 1 ELSE 0 END),
        @NoAbordo = SUM(CASE WHEN TipoEvento = 'NO_ABORDO' THEN 1 ELSE 0 END)
    FROM dbo.EventoAbordaje
    WHERE IdRecorrido = @IdRecorrido
      AND IdEstudiante = @IdEstudiante
      AND FechaEliminacion IS NULL;

    IF (@Ausentes > 0 OR @NoAbordo > 0)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'El estudiante ya tiene un estado final en este recorrido.' AS Mensaje;
        RETURN;
    END

    IF (@Subidas > 0 AND @Bajadas > 0)
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'El estudiante ya completó su ciclo de abordaje en este recorrido.' AS Mensaje;
        RETURN;
    END

    IF (@TipoEvento = 'SUBIDA' AND (@Subidas > 0 OR @Bajadas > 0))
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'No se puede registrar SUBIDA porque ya existe un evento de abordaje previo.' AS Mensaje;
        RETURN;
    END

    IF (@TipoEvento = 'BAJADA' AND (@Subidas = 0 OR @Bajadas > 0))
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'No se puede registrar BAJADA sin una SUBIDA previa válida.' AS Mensaje;
        RETURN;
    END

    IF (@TipoEvento IN ('AUSENTE', 'NO_ABORDO') AND (@Subidas > 0 OR @Bajadas > 0 OR @Ausentes > 0 OR @NoAbordo > 0))
    BEGIN
        SELECT 0 AS FilasAfectadas, CAST(NULL AS VARCHAR(20)) AS CodigoGenerado, 'No se puede registrar estado final porque ya existen eventos previos en el recorrido.' AS Mensaje;
        RETURN;
    END

    DECLARE @Correlativo INT, @CodigoGenerado VARCHAR(20);
    SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoEvento, 4) AS INT)), 0) + 1
    FROM dbo.EventoAbordaje
    WHERE CodigoEvento LIKE 'EVE-%[0-9][0-9][0-9][0-9]';

    SET @CodigoGenerado = CONCAT('EVE-', RIGHT(CONCAT('0000', @Correlativo), 4));

    INSERT INTO dbo.EventoAbordaje
    (
        IdEvento, IdRecorrido, IdEstudiante, IdParadero, RegistradoPor,
        CodigoEvento, TipoEvento, FechaHora, Observacion, Estado,
        FechaCreacion, FechaActualizacion, FechaEliminacion
    )
    VALUES
    (
        NEWID(), @IdRecorrido, @IdEstudiante, @IdParadero, @RegistradoPor,
        @CodigoGenerado, @TipoEvento, @FechaHora, NULLIF(@Observacion, ''), @Estado,
        GETDATE(), NULL, NULL
    );

    SELECT 1 AS FilasAfectadas, @CodigoGenerado AS CodigoGenerado, CAST(NULL AS VARCHAR(200)) AS Mensaje;
END
GO

/* ============================================================
   5) INCIDENCIA - fecha/hora automática en servidor
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.sp_Incidencia_Registrar
(
    @IdRecorrido UNIQUEIDENTIFIER,
    @IdConductor UNIQUEIDENTIFIER,
    @ReportadoPor UNIQUEIDENTIFIER = NULL,
    @TipoIncidencia VARCHAR(50),
    @Descripcion VARCHAR(300),
    @FechaHora DATETIME,
    @EstadoIncidencia VARCHAR(20),
    @Prioridad VARCHAR(20),
    @Solucion VARCHAR(300) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @FechaHora = GETDATE();

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Recorrido r
        WHERE r.IdRecorrido = @IdRecorrido
          AND r.IdConductor = @IdConductor
          AND r.EstadoRecorrido = 'EN_CURSO'
          AND r.FechaEliminacion IS NULL)
    BEGIN
        SELECT
            0 AS FilasAfectadas,
            CAST(NULL AS UNIQUEIDENTIFIER) AS IdIncidencia,
            CAST(NULL AS VARCHAR(20)) AS CodigoGenerado,
            'Solo se pueden registrar incidencias en recorridos EN_CURSO del conductor autenticado.' AS Mensaje;
        RETURN;
    END

    DECLARE @IdIncidencia UNIQUEIDENTIFIER = NEWID();
    DECLARE @Correlativo INT;
    DECLARE @CodigoGenerado VARCHAR(20);
    DECLARE @Fragmento VARCHAR(6) = dbo.fn_Codigo_Fragmento(@TipoIncidencia, 6, 'INCIDE');

    BEGIN TRY
        BEGIN TRAN;

        SELECT @Correlativo = ISNULL(MAX(TRY_CAST(RIGHT(CodigoIncidencia, 4) AS INT)), 0) + 1
        FROM dbo.Incidencia
        WHERE CodigoIncidencia LIKE 'INC-%[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][0-9][0-9][0-9][0-9]';

        SET @CodigoGenerado = CONCAT('INC-', @Fragmento, RIGHT(CONCAT('0000', @Correlativo), 4));

        INSERT INTO dbo.Incidencia
        (
            IdIncidencia, IdRecorrido, IdConductor, ReportadoPor, CodigoIncidencia,
            TipoIncidencia, Descripcion, FechaHora, EstadoIncidencia, Prioridad,
            FechaCierre, Solucion, Estado, FechaCreacion, FechaActualizacion, FechaEliminacion
        )
        VALUES
        (
            @IdIncidencia, @IdRecorrido, @IdConductor, @ReportadoPor, @CodigoGenerado,
            UPPER(LTRIM(RTRIM(@TipoIncidencia))), LTRIM(RTRIM(@Descripcion)), @FechaHora,
            UPPER(LTRIM(RTRIM(@EstadoIncidencia))), UPPER(LTRIM(RTRIM(@Prioridad))),
            NULL, NULLIF(LTRIM(RTRIM(@Solucion)), ''), 1, GETDATE(), NULL, NULL
        );

        COMMIT;

        SELECT
            1 AS FilasAfectadas,
            @IdIncidencia AS IdIncidencia,
            @CodigoGenerado AS CodigoGenerado,
            CAST(NULL AS VARCHAR(200)) AS Mensaje;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;

        SELECT
            0 AS FilasAfectadas,
            CAST(NULL AS UNIQUEIDENTIFIER) AS IdIncidencia,
            CAST(NULL AS VARCHAR(20)) AS CodigoGenerado,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

/* ============================================================
   2) NOTIFICACIONES - incluir código de estudiante
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.sp_Notificacion_ObtenerPorId
    @IdNotificacion UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        n.*,
        CONCAT(p.Nombres, ' ', p.ApellidoPaterno, ' ', ISNULL(p.ApellidoMaterno, '')) AS NombrePadre,
        CONCAT(e.Nombres, ' ', e.ApellidoPaterno, ' ', ISNULL(e.ApellidoMaterno, '')) AS NombreEstudiante,
        e.CodigoEstudiante
    FROM dbo.Notificacion n
    INNER JOIN dbo.PadreFamilia p ON p.IdPadre = n.IdPadre
    LEFT JOIN dbo.Estudiante e ON e.IdEstudiante = n.IdEstudiante
    WHERE n.IdNotificacion = @IdNotificacion
      AND n.Estado = 1;
END
GO

/* ============================================================
   3) CALIFICACIÓN DE CONDUCTOR (Padre)
   ============================================================ */
IF OBJECT_ID('dbo.CalificacionConductor', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CalificacionConductor
    (
        IdCalificacion UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
        IdPadre UNIQUEIDENTIFIER NOT NULL,
        IdConductor UNIQUEIDENTIFIER NOT NULL,
        IdEstudiante UNIQUEIDENTIFIER NULL,
        Puntaje INT NOT NULL,
        Comentario NVARCHAR(250) NULL,
        FechaRegistro DATETIME NOT NULL CONSTRAINT DF_CalificacionConductor_FechaRegistro DEFAULT(GETDATE()),
        Estado BIT NOT NULL CONSTRAINT DF_CalificacionConductor_Estado DEFAULT(1)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CalificacionConductor_Padre')
BEGIN
    ALTER TABLE dbo.CalificacionConductor
    ADD CONSTRAINT FK_CalificacionConductor_Padre FOREIGN KEY (IdPadre) REFERENCES dbo.PadreFamilia(IdPadre);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CalificacionConductor_Conductor')
BEGIN
    ALTER TABLE dbo.CalificacionConductor
    ADD CONSTRAINT FK_CalificacionConductor_Conductor FOREIGN KEY (IdConductor) REFERENCES dbo.Conductor(IdConductor);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CalificacionConductor_Estudiante')
BEGIN
    ALTER TABLE dbo.CalificacionConductor
    ADD CONSTRAINT FK_CalificacionConductor_Estudiante FOREIGN KEY (IdEstudiante) REFERENCES dbo.Estudiante(IdEstudiante);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_CalificacionConductor_Registrar
    @IdPadre UNIQUEIDENTIFIER,
    @IdConductor UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER = NULL,
    @Puntaje INT,
    @Comentario NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Puntaje < 1 OR @Puntaje > 5
    BEGIN
        SELECT 0;
        RETURN;
    END

    INSERT INTO dbo.CalificacionConductor
    (
        IdCalificacion, IdPadre, IdConductor, IdEstudiante, Puntaje, Comentario, FechaRegistro, Estado
    )
    VALUES
    (
        NEWID(), @IdPadre, @IdConductor, @IdEstudiante, @Puntaje, NULLIF(LTRIM(RTRIM(@Comentario)), ''), GETDATE(), 1
    );

    SELECT 1;
END
GO

/* ===== 60_Usuarios_Disponibles.sql ===== */
USE CapiMovilDB_Reconstruida;
GO
/*
    CapiMovil - Corrección de combos de usuario por rol
    Objetivo:
      - PadreFamilia: solo usuarios rol PADRE / PADRE DE FAMILIA no vinculados
      - Conductor: solo usuarios rol CONDUCTOR no vinculados
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.sp_Usuario_ListarDisponiblesParaPadre
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.IdUsuario,
        U.Username,
        U.Correo,
        U.Estado
    FROM dbo.Usuario U
    INNER JOIN dbo.Rol R ON R.IdRol = U.IdRol
    WHERE U.Estado = 1
      AND U.FechaEliminacion IS NULL
      AND R.FechaEliminacion IS NULL
      AND R.Estado = 1
      AND (
            UPPER(LTRIM(RTRIM(R.Nombre))) IN ('PADRE', 'PADRE DE FAMILIA')
            OR UPPER(LTRIM(RTRIM(R.CodigoRol))) LIKE '%PAD%'
          )
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.PadreFamilia P
          WHERE P.IdUsuario = U.IdUsuario
            AND P.FechaEliminacion IS NULL
      )
    ORDER BY U.Username;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Usuario_ListarDisponiblesParaConductor
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.IdUsuario,
        U.Username,
        U.Correo,
        U.Estado
    FROM dbo.Usuario U
    INNER JOIN dbo.Rol R ON R.IdRol = U.IdRol
    WHERE U.Estado = 1
      AND U.FechaEliminacion IS NULL
      AND R.FechaEliminacion IS NULL
      AND R.Estado = 1
      AND (
            UPPER(LTRIM(RTRIM(R.Nombre))) = 'CONDUCTOR'
            OR UPPER(LTRIM(RTRIM(R.CodigoRol))) LIKE '%COND%'
          )
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.Conductor C
          WHERE C.IdUsuario = U.IdUsuario
            AND C.FechaEliminacion IS NULL
      )
    ORDER BY U.Username;
END
GO

/* ===== 90_Procedimientos_Conductor_Faltantes.sql ===== */
USE CapiMovilDB_Reconstruida;
GO

/* Procedimientos invocados por RecorridoDALC que no estaban incluidos en los scripts del ZIP. */

CREATE OR ALTER PROCEDURE dbo.sp_Conductor_ObtenerPorIdUsuario
    @IdUsuario UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.IdConductor, c.IdUsuario, c.CodigoConductor, c.Nombres,
        c.ApellidoPaterno, c.ApellidoMaterno, c.DNI, c.Licencia,
        c.CategoriaLicencia, c.Telefono, c.Direccion, c.Estado,
        c.FechaCreacion, c.FechaActualizacion, c.FechaEliminacion
    FROM dbo.Conductor c
    WHERE c.IdUsuario = @IdUsuario
      AND c.FechaEliminacion IS NULL;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Conductor_ListarRecorridosHoy
    @IdConductor UNIQUEIDENTIFIER,
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.IdRecorrido, r.IdRuta, r.IdBus, r.IdConductor, r.CodigoRecorrido, r.Fecha,
        r.HoraInicioProgramada, r.HoraFinProgramada, r.HoraInicioReal, r.HoraFinReal,
        r.EstadoRecorrido, r.Observaciones, r.Estado, r.FechaCreacion,
        r.FechaActualizacion, r.FechaEliminacion,
        ru.CodigoRuta, ru.Nombre AS NombreRuta,
        b.CodigoBus, b.Placa, b.Marca, b.Modelo, b.Color, b.Anio, b.Capacidad,
        b.EstadoOperacion, b.SeguroVigente, b.FechaVencimientoSOAT, b.FechaRevisionTecnica,
        c.CodigoConductor, c.Nombres AS NombresConductor,
        c.ApellidoPaterno AS ApellidoPaternoConductor
    FROM dbo.Recorrido r
    INNER JOIN dbo.Ruta ru ON ru.IdRuta = r.IdRuta
    INNER JOIN dbo.Bus b ON b.IdBus = r.IdBus
    INNER JOIN dbo.Conductor c ON c.IdConductor = r.IdConductor
    WHERE r.IdConductor = @IdConductor
      AND r.Fecha = @Fecha
      AND r.Estado = 1
    ORDER BY r.HoraInicioProgramada, r.FechaCreacion;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Conductor_ListarEstudiantesPorRecorrido
    @IdRecorrido UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH UltimoEvento AS
    (
        SELECT ea.IdEstudiante, ea.TipoEvento,
               ROW_NUMBER() OVER
               (
                   PARTITION BY ea.IdEstudiante
                   ORDER BY ea.FechaHora DESC, ea.FechaCreacion DESC
               ) AS rn
        FROM dbo.EventoAbordaje ea
        WHERE ea.IdRecorrido = @IdRecorrido AND ea.Estado = 1
    )
    SELECT
        e.IdEstudiante, e.IdPadre, e.CodigoEstudiante, e.Nombres,
        e.ApellidoPaterno, e.ApellidoMaterno, e.DNI, e.FechaNacimiento,
        e.Genero, e.Grado, e.Seccion, e.Direccion, e.Estado,
        CONCAT(p.Nombres, ' ', p.ApellidoPaterno, ' ', p.ApellidoMaterno) AS NombrePadre,
        p.Telefono AS TelefonoPadre,
        ps.Nombre AS ParaderoSubidaNombre, ps.Direccion AS ParaderoSubidaDireccion,
        pb.Nombre AS ParaderoBajadaNombre, pb.Direccion AS ParaderoBajadaDireccion,
        COALESCE(ue.TipoEvento, 'PENDIENTE') AS EstadoEvento
    FROM dbo.Recorrido r
    INNER JOIN dbo.RutaEstudiante re
        ON re.IdRuta = r.IdRuta AND re.Estado = 1 AND re.EstadoAsignacion = 'ACTIVO'
       AND re.FechaInicioVigencia <= r.Fecha
       AND (re.FechaFinVigencia IS NULL OR re.FechaFinVigencia >= r.Fecha)
    INNER JOIN dbo.Estudiante e ON e.IdEstudiante = re.IdEstudiante AND e.Estado = 1
    INNER JOIN dbo.PadreFamilia p ON p.IdPadre = e.IdPadre AND p.Estado = 1
    LEFT JOIN dbo.Paradero ps ON ps.IdParadero = re.IdParaderoSubida
    LEFT JOIN dbo.Paradero pb ON pb.IdParadero = re.IdParaderoBajada
    LEFT JOIN UltimoEvento ue ON ue.IdEstudiante = e.IdEstudiante AND ue.rn = 1
    WHERE r.IdRecorrido = @IdRecorrido AND r.Estado = 1
    ORDER BY e.ApellidoPaterno, e.ApellidoMaterno, e.Nombres;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Conductor_ListarParaderosPorRecorrido
    @IdRecorrido UNIQUEIDENTIFIER,
    @TipoParadero VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tipo VARCHAR(10) = UPPER(LTRIM(RTRIM(@TipoParadero)));
    IF @Tipo NOT IN ('SUBIDA', 'BAJADA')
        THROW 50020, 'TipoParadero debe ser SUBIDA o BAJADA.', 1;

    SELECT
        p.IdParadero, p.IdRuta, p.CodigoParadero, p.Nombre, p.Direccion,
        p.OrdenParada, p.HoraEstimada,
        COUNT(DISTINCT re.IdEstudiante) AS TotalAlumnos,
        COUNT(DISTINCT ea.IdEstudiante) AS TotalRegistrados,
        CONVERT(BIT, CASE
            WHEN COUNT(DISTINCT re.IdEstudiante) > 0
             AND COUNT(DISTINCT ea.IdEstudiante) >= COUNT(DISTINCT re.IdEstudiante)
            THEN 1 ELSE 0 END) AS Completado
    FROM dbo.Recorrido r
    INNER JOIN dbo.Paradero p ON p.IdRuta = r.IdRuta AND p.Estado = 1
    LEFT JOIN dbo.RutaEstudiante re
        ON re.IdRuta = r.IdRuta AND re.Estado = 1 AND re.EstadoAsignacion = 'ACTIVO'
       AND ((@Tipo = 'SUBIDA' AND re.IdParaderoSubida = p.IdParadero)
         OR (@Tipo = 'BAJADA' AND re.IdParaderoBajada = p.IdParadero))
    LEFT JOIN dbo.EventoAbordaje ea
        ON ea.IdRecorrido = r.IdRecorrido
       AND ea.IdEstudiante = re.IdEstudiante
       AND ea.IdParadero = p.IdParadero
       AND ea.TipoEvento = @Tipo
       AND ea.Estado = 1
    WHERE r.IdRecorrido = @IdRecorrido AND r.Estado = 1
      AND EXISTS
      (
          SELECT 1
          FROM dbo.RutaEstudiante rx
          WHERE rx.IdRuta = r.IdRuta AND rx.Estado = 1 AND rx.EstadoAsignacion = 'ACTIVO'
            AND ((@Tipo = 'SUBIDA' AND rx.IdParaderoSubida = p.IdParadero)
              OR (@Tipo = 'BAJADA' AND rx.IdParaderoBajada = p.IdParadero))
      )
    GROUP BY p.IdParadero, p.IdRuta, p.CodigoParadero, p.Nombre,
             p.Direccion, p.OrdenParada, p.HoraEstimada
    ORDER BY p.OrdenParada;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Conductor_ListarEstudiantesPorParadero
    @IdRecorrido UNIQUEIDENTIFIER,
    @IdParadero UNIQUEIDENTIFIER,
    @TipoParadero VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tipo VARCHAR(10) = UPPER(LTRIM(RTRIM(@TipoParadero)));
    IF @Tipo NOT IN ('SUBIDA', 'BAJADA')
        THROW 50021, 'TipoParadero debe ser SUBIDA o BAJADA.', 1;

    SELECT DISTINCT
        e.IdEstudiante, e.IdPadre, e.CodigoEstudiante, e.Nombres,
        e.ApellidoPaterno, e.ApellidoMaterno, e.DNI, e.FechaNacimiento,
        e.Genero, e.Grado, e.Seccion, e.Direccion, e.Estado
    FROM dbo.Recorrido r
    INNER JOIN dbo.RutaEstudiante re ON re.IdRuta = r.IdRuta
    INNER JOIN dbo.Estudiante e ON e.IdEstudiante = re.IdEstudiante
    WHERE r.IdRecorrido = @IdRecorrido
      AND r.Estado = 1 AND re.Estado = 1 AND e.Estado = 1
      AND re.EstadoAsignacion = 'ACTIVO'
      AND ((@Tipo = 'SUBIDA' AND re.IdParaderoSubida = @IdParadero)
        OR (@Tipo = 'BAJADA' AND re.IdParaderoBajada = @IdParadero))
    ORDER BY e.ApellidoPaterno, e.ApellidoMaterno, e.Nombres;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Conductor_ListarIncidenciasPendientes
    @IdRecorrido UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        i.IdIncidencia, i.IdRecorrido, i.IdConductor, i.ReportadoPor,
        i.CodigoIncidencia, i.TipoIncidencia, i.Descripcion, i.FechaHora,
        i.EstadoIncidencia, i.Prioridad, i.FechaCierre, i.Solucion,
        i.Estado, i.FechaCreacion, i.FechaActualizacion, i.FechaEliminacion
    FROM dbo.Incidencia i
    WHERE i.IdRecorrido = @IdRecorrido
      AND i.Estado = 1
      AND UPPER(i.EstadoIncidencia) NOT IN ('CERRADA', 'RESUELTA', 'CANCELADA')
    ORDER BY
        CASE UPPER(i.Prioridad) WHEN 'ALTA' THEN 1 WHEN 'MEDIA' THEN 2 ELSE 3 END,
        i.FechaHora DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_EventoAbordaje_ObtenerResumenEstudianteRecorrido
    @IdRecorrido UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Eventos AS
    (
        SELECT UPPER(LTRIM(RTRIM(e.TipoEvento))) AS TipoEvento, e.FechaHora
        FROM dbo.EventoAbordaje e
        WHERE e.IdRecorrido = @IdRecorrido
          AND e.IdEstudiante = @IdEstudiante
          AND e.FechaEliminacion IS NULL
          AND e.Estado = 1
    )
    SELECT
        @IdRecorrido AS IdRecorrido,
        @IdEstudiante AS IdEstudiante,
        COUNT(1) AS TotalEventos,
        SUM(CASE WHEN TipoEvento = 'SUBIDA' THEN 1 ELSE 0 END) AS TotalSubidas,
        SUM(CASE WHEN TipoEvento = 'BAJADA' THEN 1 ELSE 0 END) AS TotalBajadas,
        SUM(CASE WHEN TipoEvento = 'AUSENTE' THEN 1 ELSE 0 END) AS TotalAusentes,
        SUM(CASE WHEN TipoEvento = 'NO_ABORDO' THEN 1 ELSE 0 END) AS TotalNoAbordo,
        (SELECT TOP (1) TipoEvento FROM Eventos ORDER BY FechaHora DESC) AS UltimoTipoEvento
    FROM Eventos;
END;
GO

/* Version final del registro de calificaciones; coincide con ExecuteScalar de C#. */
CREATE OR ALTER PROCEDURE dbo.sp_CalificacionConductor_Registrar
    @IdPadre UNIQUEIDENTIFIER,
    @IdConductor UNIQUEIDENTIFIER,
    @IdEstudiante UNIQUEIDENTIFIER = NULL,
    @Puntaje INT,
    @Comentario NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Puntaje NOT BETWEEN 1 AND 5
    BEGIN
        SELECT 0;
        RETURN;
    END;

    INSERT INTO dbo.CalificacionConductor
        (IdCalificacion, IdPadre, IdConductor, IdEstudiante, Puntaje, Comentario, FechaRegistro, Estado)
    VALUES
        (NEWID(), @IdPadre, @IdConductor, @IdEstudiante, @Puntaje,
         NULLIF(LTRIM(RTRIM(@Comentario)), ''), GETDATE(), 1);

    SELECT 1;
END;
GO

/* ===== 95_Datos_Iniciales.sql ===== */
USE CapiMovilDB_Reconstruida;
GO

/* Roles requeridos por AutenticacionSesion.cs */
DECLARE @RolAdmin UNIQUEIDENTIFIER = '11111111-1111-1111-1111-111111111111';
DECLARE @RolConductor UNIQUEIDENTIFIER = '22222222-2222-2222-2222-222222222222';
DECLARE @RolPadre UNIQUEIDENTIFIER = '33333333-3333-3333-3333-333333333333';

IF NOT EXISTS (SELECT 1 FROM dbo.Rol WHERE Nombre = 'ADMINISTRADOR')
    INSERT dbo.Rol (IdRol, CodigoRol, Nombre, Descripcion, Estado, FechaCreacion)
    VALUES (@RolAdmin, 'ROL-ADMI', 'ADMINISTRADOR', 'Gestion completa del sistema', 1, SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM dbo.Rol WHERE Nombre = 'CONDUCTOR')
    INSERT dbo.Rol (IdRol, CodigoRol, Nombre, Descripcion, Estado, FechaCreacion)
    VALUES (@RolConductor, 'ROL-COND', 'CONDUCTOR', 'Operacion del transporte escolar', 1, SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM dbo.Rol WHERE Nombre = 'PADRE DE FAMILIA')
    INSERT dbo.Rol (IdRol, CodigoRol, Nombre, Descripcion, Estado, FechaCreacion)
    VALUES (@RolPadre, 'ROL-PADR', 'PADRE DE FAMILIA', 'Seguimiento de estudiantes y notificaciones', 1, SYSDATETIME());
GO

/*
  Conserva el acceso conocido copiando el hash BCrypt del usuario admin de la BD original.
  El hash no revela la contrasena; solo permite usar la misma credencial que ya funciona.
*/
IF DB_ID(N'CapiMovilDB') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE Username = 'admin')
BEGIN
    DECLARE @Hash VARCHAR(255);
    DECLARE @Correo VARCHAR(120);
    DECLARE @Sql NVARCHAR(MAX) = N'
        SELECT TOP (1)
            @HashOut = PasswordHash,
            @CorreoOut = Correo
        FROM CapiMovilDB.dbo.Usuario
        WHERE Username = ''admin'' AND Estado = 1
        ORDER BY FechaCreacion;';

    EXEC sys.sp_executesql
        @Sql,
        N'@HashOut VARCHAR(255) OUTPUT, @CorreoOut VARCHAR(120) OUTPUT',
        @HashOut = @Hash OUTPUT,
        @CorreoOut = @Correo OUTPUT;

    IF @Hash IS NOT NULL
    BEGIN
        INSERT dbo.Usuario
        (
            IdUsuario, IdRol, CodigoUsuario, Username, Correo, PasswordHash,
            UltimoAcceso, Estado, FechaCreacion
        )
        VALUES
        (
            'AAAAAAAA-0000-0000-0000-000000000001',
            '11111111-1111-1111-1111-111111111111',
            'USU-ADMI0001', 'admin', COALESCE(NULLIF(@Correo, ''), 'admin@capimovil.local'),
            @Hash, NULL, 1, SYSDATETIME()
        );
    END;
END;
GO

MERGE dbo.CorrelativoDocumento AS destino
USING
(
    VALUES
      ('ROL', 3), ('USU-ADMI', 1), ('USU-COND', 0), ('USU-PADR', 0),
      ('PADRE', 0), ('CONDUCTOR', 0), ('ESTUDIANTE', 0),
      ('BUS', 0), ('RUT', 0), ('PAR', 0), ('RAS', 0),
      ('REC', 0), ('UBI', 0), ('EVE', 0), ('NOT', 0), ('INC', 0), ('AUD', 0)
) AS origen(TipoCodigo, UltimoNumero)
ON destino.TipoCodigo = origen.TipoCodigo
WHEN NOT MATCHED THEN
    INSERT (TipoCodigo, UltimoNumero) VALUES (origen.TipoCodigo, origen.UltimoNumero);
GO

/* ===== 99_Validar_Instalacion.sql ===== */
USE CapiMovilDB_Reconstruida;
GO

SET NOCOUNT ON;

DECLARE @TablasEsperadas TABLE (Nombre SYSNAME PRIMARY KEY);
INSERT @TablasEsperadas (Nombre) VALUES
('Auditoria'), ('Bus'), ('CalificacionConductor'), ('Conductor'),
('CorrelativoDocumento'), ('Estudiante'), ('EventoAbordaje'), ('IA_Consulta'),
('IA_Prediccion'), ('Incidencia'), ('Notificacion'), ('PadreFamilia'),
('Paradero'), ('Recorrido'), ('Rol'), ('Ruta'), ('RutaEstudiante'),
('UbicacionBus'), ('Usuario');

IF EXISTS
(
    SELECT 1 FROM @TablasEsperadas e
    WHERE OBJECT_ID(N'dbo.' + e.Nombre, 'U') IS NULL
)
BEGIN
    SELECT e.Nombre AS TablaFaltante
    FROM @TablasEsperadas e
    WHERE OBJECT_ID(N'dbo.' + e.Nombre, 'U') IS NULL;
    THROW 50100, 'La instalacion termino con tablas faltantes.', 1;
END;

DECLARE @ProcedimientosEsperados TABLE (Nombre SYSNAME PRIMARY KEY);
INSERT @ProcedimientosEsperados (Nombre) VALUES
('sp_Auditoria_Listar'), ('sp_Auditoria_ListarPorAccion'),
('sp_Auditoria_ListarPorTabla'), ('sp_Auditoria_ListarPorUsuario'),
('sp_Auditoria_ObtenerPorId'), ('sp_Auditoria_Registrar'),
('sp_Bus_Actualizar'), ('sp_Bus_EliminarLogico'), ('sp_Bus_Listar'),
('sp_Bus_ListarActivos'), ('sp_Bus_ObtenerPorId'), ('sp_Bus_Registrar'),
('sp_CalificacionConductor_Registrar'),
('sp_Conductor_Actualizar'), ('sp_Conductor_Eliminar'),
('sp_Conductor_ExistePorDni'), ('sp_Conductor_ExistePorIdUsuario'),
('sp_Conductor_ExistePorLicencia'), ('sp_Conductor_Listar'),
('sp_Conductor_ListarActivos'), ('sp_Conductor_ObtenerPorId'),
('sp_Conductor_ObtenerPorIdUsuario'), ('sp_Conductor_Registrar'),
('sp_Conductor_ListarEstudiantesPorParadero'),
('sp_Conductor_ListarEstudiantesPorRecorrido'),
('sp_Conductor_ListarIncidenciasPendientes'),
('sp_Conductor_ListarParaderosPorRecorrido'),
('sp_Conductor_ListarRecorridosHoy'),
('sp_Estudiante_Actualizar'), ('sp_Estudiante_EliminarLogico'),
('sp_Estudiante_Listar'), ('sp_Estudiante_ListarActivos'),
('sp_Estudiante_ObtenerPadrePorEstudiante'), ('sp_Estudiante_ObtenerPorId'),
('sp_Estudiante_Registrar'), ('sp_EventoAbordaje_Actualizar'),
('sp_EventoAbordaje_EliminarLogico'), ('sp_EventoAbordaje_Listar'),
('sp_EventoAbordaje_ObtenerPorId'),
('sp_EventoAbordaje_ObtenerResumenEstudianteRecorrido'),
('sp_EventoAbordaje_Registrar'), ('sp_Incidencia_Actualizar'),
('sp_Incidencia_CambiarEstado'), ('sp_Incidencia_Cerrar'),
('sp_Incidencia_Eliminar'), ('sp_Incidencia_Listar'),
('sp_Incidencia_ListarPorConductor'), ('sp_Incidencia_ListarPorId'),
('sp_Incidencia_ListarPorPadre'), ('sp_Incidencia_Registrar'),
('sp_Notificacion_Actualizar'), ('sp_Notificacion_EliminarLogico'),
('sp_Notificacion_Listar'), ('sp_Notificacion_ListarNoLeidasPorPadre'),
('sp_Notificacion_ListarPorPadre'), ('sp_Notificacion_MarcarLeida'),
('sp_Notificacion_ObtenerPorId'), ('sp_Notificacion_Registrar'),
('sp_PadreFamilia_Actualizar'), ('sp_PadreFamilia_Eliminar'),
('sp_PadreFamilia_ExistePorDni'), ('sp_PadreFamilia_ExistePorIdUsuario'),
('sp_PadreFamilia_Listar'), ('sp_PadreFamilia_ListarParaCombo'),
('sp_PadreFamilia_ListarPorIdUsuario'), ('sp_PadreFamilia_ObtenerPorId'),
('sp_PadreFamilia_Registrar'),
('sp_Paradero_Actualizar'), ('sp_Paradero_EliminarLogico'),
('sp_Paradero_Listar'), ('sp_Paradero_ListarActivos'),
('sp_Paradero_ListarPorRuta'), ('sp_Paradero_ObtenerPorId'),
('sp_Paradero_Registrar'), ('sp_Recorrido_Actualizar'),
('sp_Recorrido_Cancelar'), ('sp_Recorrido_EliminarLogico'),
('sp_Recorrido_Finalizar'), ('sp_Recorrido_Iniciar'),
('sp_Recorrido_Listar'), ('sp_Recorrido_ListarActivosParaOperacion'),
('sp_Recorrido_ListarDestinatariosNotificacion'),
('sp_Recorrido_ListarPorConductor'),
('sp_Recorrido_ObtenerActivoPorConductor'), ('sp_Recorrido_ObtenerPorId'),
('sp_Recorrido_Registrar'), ('sp_Rol_Actualizar'),
('sp_Rol_EliminarLogico'), ('sp_Rol_Listar'), ('sp_Rol_ObtenerPorId'),
('sp_Rol_Registrar'), ('sp_RutaEstudiante_Actualizar'),
('sp_RutaEstudiante_EliminarLogico'), ('sp_RutaEstudiante_Listar'),
('sp_RutaEstudiante_ObtenerPorId'), ('sp_RutaEstudiante_Registrar'),
('sp_Ruta_Actualizar'), ('sp_Ruta_EliminarLogico'), ('sp_Ruta_Listar'),
('sp_Ruta_ListarActivas'), ('sp_Ruta_ObtenerPorId'), ('sp_Ruta_Registrar'),
('sp_UbicacionBus_Actualizar'), ('sp_UbicacionBus_EliminarLogico'),
('sp_UbicacionBus_Listar'), ('sp_UbicacionBus_ObtenerPorId'),
('sp_UbicacionBus_Registrar'), ('sp_Usuario_Actualizar'),
('sp_Usuario_ActualizarFotoPerfil'), ('sp_Usuario_ActualizarUltimoAcceso'),
('sp_Usuario_CambiarPassword'), ('sp_Usuario_EliminarLogico'),
('sp_Usuario_Listar'), ('sp_Usuario_ListarDisponiblesParaConductor'),
('sp_Usuario_ListarDisponiblesParaPadre'), ('sp_Usuario_Login'), ('sp_Usuario_ObtenerPorId'),
('sp_Usuario_Registrar');

IF EXISTS
(
    SELECT 1 FROM @ProcedimientosEsperados e
    WHERE OBJECT_ID(N'dbo.' + e.Nombre, 'P') IS NULL
)
BEGIN
    SELECT e.Nombre AS ProcedimientoFaltante
    FROM @ProcedimientosEsperados e
    WHERE OBJECT_ID(N'dbo.' + e.Nombre, 'P') IS NULL;
    THROW 50101, 'La instalacion termino con procedimientos requeridos faltantes.', 1;
END;

IF OBJECT_ID(N'dbo.fn_Codigo_Sanitizar', 'FN') IS NULL
    THROW 50102, 'Falta la funcion dbo.fn_Codigo_Sanitizar.', 1;

IF OBJECT_ID(N'dbo.fn_Bus_Codigo_Fragmento', 'FN') IS NULL
    THROW 50103, 'Falta la funcion dbo.fn_Bus_Codigo_Fragmento.', 1;

/* Fuerza a SQL Server a recompilar metadatos y detectar columnas u objetos inexistentes. */
DECLARE @ErroresModulos TABLE
(
    Objeto SYSNAME NOT NULL,
    Mensaje NVARCHAR(4000) NOT NULL
);

DECLARE @Objeto SYSNAME;
DECLARE modulos CURSOR LOCAL FAST_FORWARD FOR
    SELECT QUOTENAME(SCHEMA_NAME(o.schema_id)) + N'.' + QUOTENAME(o.name)
    FROM sys.objects o
    WHERE o.type IN ('P', 'FN')
      AND o.is_ms_shipped = 0;

OPEN modulos;
FETCH NEXT FROM modulos INTO @Objeto;
WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        EXEC sys.sp_refreshsqlmodule @name = @Objeto;
    END TRY
    BEGIN CATCH
        INSERT @ErroresModulos (Objeto, Mensaje)
        VALUES (@Objeto, ERROR_MESSAGE());
    END CATCH;

    FETCH NEXT FROM modulos INTO @Objeto;
END;
CLOSE modulos;
DEALLOCATE modulos;

IF EXISTS (SELECT 1 FROM @ErroresModulos)
BEGIN
    SELECT Objeto, Mensaje FROM @ErroresModulos ORDER BY Objeto;
    THROW 50104, 'Existen procedimientos o funciones con dependencias invalidas.', 1;
END;

SELECT
    DB_NAME() AS BaseValidada,
    (SELECT COUNT(*) FROM @TablasEsperadas) AS TablasRequeridas,
    (SELECT COUNT(*) FROM @ProcedimientosEsperados) AS ProcedimientosRequeridos,
    (SELECT COUNT(*) FROM dbo.Rol WHERE Estado = 1) AS RolesActivos,
    (SELECT COUNT(*) FROM dbo.Usuario WHERE Estado = 1) AS UsuariosActivos,
    'INSTALACION VALIDADA' AS Resultado;
GO
