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
