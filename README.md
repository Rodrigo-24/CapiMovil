# CapiMovil

Aplicación web académica para gestionar transporte escolar. Incluye módulos para administración, padres de familia y conductores: usuarios y perfiles, estudiantes, buses, rutas, paraderos, recorridos, abordajes, ubicación, incidencias y notificaciones.

## Tecnologías

- ASP.NET Core MVC sobre .NET 8
- C# y ADO.NET (`System.Data.SqlClient`)
- SQL Server y procedimientos almacenados
- Razor, Bootstrap y JavaScript
- Sesiones para autenticación y control de roles

## Preparación de la base de datos

Los archivos vigentes están en `Database/Instalacion`. No ejecute directamente los archivos de `Database/Historico`; se conservaron solo como referencia y algunos contienen migraciones antiguas o destructivas.

### Instalación limpia recomendada

1. Abra `Database/Instalacion/CapiMovilDB_Completa.sql` en SQL Server Management Studio.
2. Conéctese a la instancia correcta de SQL Server.
3. Ejecute el archivo completo. No necesita activar SQLCMD Mode ni colocar el proyecto en una carpeta específica.
4. Compruebe que el resultado final muestre `INSTALACION VALIDADA`.

El script crea `CapiMovilDB_Reconstruida` sin borrar `CapiMovilDB`. Si la base original existe y contiene el usuario `admin`, conserva su acceso copiando únicamente el hash BCrypt.

### Actualizar la base reconstruida existente

Si ya tiene datos en `CapiMovilDB_Reconstruida`, haga primero un respaldo y ejecute `Database/Instalacion/CapiMovilDB_Actualizar.sql`. Este archivo reaplica las correcciones compatibles sin recrear las tablas ni borrar la información.

## Conexión de la aplicación

La cadena está en `CapiMovil.PL.Gui/appsettings.json`:

```json
"cn": "Server=.;Database=CapiMovilDB_Reconstruida;Trusted_Connection=True;TrustServerCertificate=True;"
```

- `Server=.` usa la instancia predeterminada local de SQL Server.
- `Trusted_Connection=True` usa la cuenta de Windows; no requiere usuario ni contraseña de SQL.
- Si utiliza otra instancia, cambie solo `Server`, por ejemplo `Server=.\\SQLEXPRESS`.

## Primer administrador sin una base anterior

Si la instalación no pudo copiar un administrador desde `CapiMovilDB`, inicialice uno una sola vez desde PowerShell:

```powershell
$env:CAPIMOVIL_ADMIN_PASSWORD="UnaClaveSegura123!"
dotnet run --project .\CapiMovil.PL.Gui\CapiMovil.PL.Gui.csproj
Remove-Item Env:CAPIMOVIL_ADMIN_PASSWORD
```

La aplicación crea el usuario `admin`, guarda solamente su hash BCrypt y no escribe la contraseña en `appsettings.json`. Use al menos ocho caracteres y retire la variable después del primer inicio.

## Flujo coherente para registrar un conductor

1. El administrador crea un `Usuario` con rol `CONDUCTOR`.
2. Después crea el perfil `Conductor` y selecciona ese usuario disponible.
3. Se registran bus, ruta, paraderos y asignación de estudiantes.
4. Se programa un recorrido vinculando ruta, bus y conductor.
5. El conductor ya puede iniciar sesión y operar su recorrido.

Crear únicamente el usuario no crea automáticamente el perfil del conductor; ambas entidades están separadas y relacionadas por `IdUsuario`.

## Validaciones importantes

- Contraseñas: mínimo 8 caracteres.
- DNI: 8 dígitos donde corresponda.
- Latitud: de -90 a 90.
- Longitud: de -180 a 180.
- Las coordenadas usan punto decimal, por ejemplo Lima: latitud `-12.0464`, longitud `-77.0428`.
- Una ruta con coordenadas debe tener el par completo de inicio y el par completo de fin.

## Verificación técnica incluida

`99_Validar_Instalacion.sql` comprueba las tablas, funciones y los 118 procedimientos invocados por el código, y solicita a SQL Server que vuelva a validar las dependencias internas de cada módulo.

