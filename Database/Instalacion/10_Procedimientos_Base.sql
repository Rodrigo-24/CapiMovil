USE [CapiMovilDB_Reconstruida]
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
