/*
  EJECUTAR ESTE ARCHIVO EN SSMS CON SQLCMD MODE ACTIVADO.
  Ruta: Query > SQLCMD Mode.

  Los :r se resuelven desde el directorio de trabajo de SSMS/sqlcmd.
  Abra este archivo desde su propia carpeta y ejecute el contenido completo.
*/
:on error exit
:r .\00_Crear_Esquema.sql
:r .\01_Corregir_Claves_Default.sql
:r .\05_Funciones_Auxiliares.sql
:r .\10_Procedimientos_Base.sql
:r .\20_Reglas_Negocio_Operaciones.sql
:r .\30_Ruta_Mapa.sql
:r .\40_Unificar_CodigoRecorrido.sql
:r .\50_Correcciones_Operativas.sql
:r .\60_Usuarios_Disponibles.sql
:r .\90_Procedimientos_Conductor_Faltantes.sql
:r .\95_Datos_Iniciales.sql
:r .\99_Validar_Instalacion.sql
