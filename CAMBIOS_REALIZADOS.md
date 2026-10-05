# Cambios y correcciones realizadas

## Base de datos

* Se reconstruyó una instalación limpia para `CapiMovilDB_Reconstruida`.

* Se añadieron valores predeterminados `NEWID()` para `Usuario.IdUsuario` y `Estudiante.IdEstudiante`.

* Se incorporaron `dbo.fn_Codigo_Sanitizar` y `dbo.fn_Bus_Codigo_Fragmento`.

* Se incorporó `dbo.sp_Conductor_ObtenerPorIdUsuario` y los procedimientos operativos del panel del conductor que faltaban.

* Se alineó `sp_CalificacionConductor_Registrar` con el valor escalar que espera C#.

* Se validaron los 118 procedimientos distintos invocados por la capa DALC: todos cuentan con definición y no se detectaron parámetros enviados desde C# que estén ausentes en sus firmas finales.

* Se añadió validación de tablas, funciones, procedimientos y dependencias internas mediante `sys.sp_refreshsqlmodule`.

* Se separaron los scripts históricos para evitar que una migración antigua o destructiva se ejecute accidentalmente.

* Se generaron dos archivos autónomos que no dependen de SQLCMD Mode:

  * `Database/Instalacion/CapiMovilDB_Completa.sql`
  * `Database/Instalacion/CapiMovilDB_Actualizar.sql`

## Aplicación C#

* La conexión apunta a `CapiMovilDB_Reconstruida` utilizando autenticación integrada de Windows.

* Se fijó la cultura numérica para interpretar correctamente las coordenadas con punto decimal.

* Se añadieron rangos de latitud y longitud a los formularios de rutas y ubicaciones.

* Se unificó la longitud mínima de contraseña en 8 caracteres y se reforzó la confirmación de contraseña.

* Se corrigieron `ActualizarUltimoAcceso` y `Eliminar` para leer el valor devuelto por sus procedimientos en lugar de interpretar incorrectamente `ExecuteNonQuery()`.

* Se eliminó un mensaje de depuración que sobrescribía el error real al editar usuarios.

* Se añadió protección de sesión y rol a módulos administrativos que podían alcanzarse directamente mediante URL.

* Se añadió la inicialización opcional y segura del primer administrador mediante la variable temporal `CAPIMOVIL_ADMIN_PASSWORD`.

## Limpieza

* Se eliminaron `.vs`, `bin`, `obj` y el archivo local `.csproj.user`, ya que Visual Studio los regenera durante el desarrollo y la compilación.

* Los scripts anteriores se conservaron en `Database/Historico` únicamente como referencia.

## Alcance de la validación

La revisión de los contratos entre C# y SQL, la estructura de archivos, los archivos JSON y los proyectos XML fue realizada de forma estática.

Este entorno no dispone del SDK de .NET ni de una instancia de SQL Server, por lo que la compilación y ejecución final deben validarse en Visual Studio y SQL Server Management Studio (SSMS).

El instalador incluye una validación automática que debe finalizar mostrando:

`INSTALACION VALIDADA`
