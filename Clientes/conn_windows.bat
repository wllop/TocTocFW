@echo off
SETLOCAL EnableDelayedExpansion
rem Regulamos parametros
set i=0
set servidor=%1
shift
:ini
set /a i+=1
set param_%i%=%1
rem echo %param_%%i%%
shift
if NOT "%1" == "" goto ini
if NOT !i! GEQ 2 (
 set /p servidor="Introduzca el nombre del servidor: "
 set /p pass="Introduzca la secuencia separada por comas (ej.: 40,50,60): "
) else (
  for /l %%n in (1,1,!i!) do (
    if "!pass!" == "" (
      set pass=!param_%%n%!
     ) else (
      set pass=!pass!,!param_%%n%!
    )
  )
)
curl 2>nul
if %errorlevel% EQU 9009 (
  rem NO existe
  for /F "delims=, usebackq" %%p in ('%pass%') do (
   for %%a in (%%p) do (
      start .\curl\curl.exe --connect-timeout 0,300 -s http://%servidor%:%%a
   )
  )
) else (
  rem Curl está en el sistema
  for /F "delims=, usebackq" %%p in ('%pass%') do (
   for %%a in (%%p) do (
      curl.exe --connect-timeout 0.300 -s http://%servidor%:%%a
   )
  )
)

:fin
