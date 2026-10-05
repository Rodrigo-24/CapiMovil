/* CapiMovilDB_Reconstruida - actualizacion segura sin SQLCMD Mode */

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
