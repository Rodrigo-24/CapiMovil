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
