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
