/*
  EJECUTAR EN SSMS CON SQLCMD MODE.

  Esta ruta conserva los datos de CapiMovilDB_Reconstruida y vuelve a aplicar
  unicamente correcciones idempotentes. No ejecuta el esquema inicial ni los
  scripts historicos destructivos.
*/
:on error exit
:r .\01_Corregir_Claves_Default.sql
:r .\05_Funciones_Auxiliares.sql
:r .\20_Reglas_Negocio_Operaciones.sql
:r .\30_Ruta_Mapa.sql
:r .\40_Unificar_CodigoRecorrido.sql
:r .\50_Correcciones_Operativas.sql
:r .\60_Usuarios_Disponibles.sql
:r .\90_Procedimientos_Conductor_Faltantes.sql
:r .\99_Validar_Instalacion.sql
