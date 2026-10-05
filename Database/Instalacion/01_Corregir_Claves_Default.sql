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

