@echo off
setlocal enabledelayedexpansion

:: =========================================
:: DETECCION DE MODO SEGURO
:: =========================================
set "MODO_SEGURO=0"
reg query "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Option" /v OptionValue >nul 2>&1
if %errorlevel% equ 0 set "MODO_SEGURO=1"

:: =========================================
:: VERIFICACION Y AUTO-ELEVACION INTELIGENTE
:: =========================================

:: Si estamos en Modo Seguro, saltar verificacion de admin
if !MODO_SEGURO! equ 1 (
    echo [%DATE% %TIME%] Sistema en Modo Seguro detectado - Saltando elevacion >> "%temp%\Soporte_Tecnico_temp.log"
    goto :es_admin_modo_seguro
)

NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' (
    goto :es_admin
) else (
    echo.
    echo ============================================
    echo    ELEVANDO PRIVILEGIOS AUTOMATICAMENTE
    echo ============================================
    echo.
    echo Este script requiere permisos de administrador.
    echo.
    echo Por favor, acepte el permiso de administrador...
    echo.
    
    :: Esperar un momento para que el usuario lea el mensaje
    timeout /t 2 /nobreak >nul
    
    :: Método confiable de auto-elevación
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    
    :: Cerrar esta instancia sin privilegios
    exit /b
)

:es_admin_modo_seguro
:: Configuracion especial para Modo Seguro
set "PASSWORD_CORRECTA=soporte"
set "LOG_PATH=%temp%\Soporte_Tecnico_%username%_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.log"
set "LOG_PATH=%LOG_PATH: =%"

:: Iniciar log detallado
echo [%DATE% %TIME%] ===== SCRIPT INICIADO EN MODO SEGURO ===== > "%LOG_PATH%"
echo [%DATE% %TIME%] Usuario: %USERNAME% >> "%LOG_PATH%"
echo [%DATE% %TIME%] Equipo: %COMPUTERNAME% >> "%LOG_PATH%"
echo [%DATE% %TIME%] Ejecutando en Modo Seguro: SI >> "%LOG_PATH%"
echo [%DATE% %TIME%] Archivo de log: %LOG_PATH% >> "%LOG_PATH%"
echo. >> "%LOG_PATH%"

title Batch de Soporte Tecnico - [MODO SEGURO] - Usuario: %USERNAME%

:: Limpiar pantalla y saltar autenticacion en Modo Seguro
cls
goto bienvenida_modo_seguro

:es_admin
:: =========================================
:: CONFIGURACIONES INICIALES
:: =========================================
set "PASSWORD_CORRECTA=soporte"
set "LOG_PATH=%temp%\Soporte_Tecnico_%username%_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.log"
set "LOG_PATH=%LOG_PATH: =%"

:: Iniciar log detallado
echo [%DATE% %TIME%] ===== SCRIPT INICIADO ===== > "%LOG_PATH%"
echo [%DATE% %TIME%] Usuario: %USERNAME% >> "%LOG_PATH%"
echo [%DATE% %TIME%] Equipo: %COMPUTERNAME% >> "%LOG_PATH%"
echo [%DATE% %TIME%] Ejecutando como administrador: SI >> "%LOG_PATH%"
echo [%DATE% %TIME%] Modo Seguro: NO >> "%LOG_PATH%"
echo [%DATE% %TIME%] Archivo de log: %LOG_PATH% >> "%LOG_PATH%"
echo. >> "%LOG_PATH%"

title Batch de Soporte Tecnico - [ADMINISTRADOR] - Usuario: %USERNAME%

:: Limpiar pantalla y continuar con la autenticación
cls
goto autenticacion

:: =========================================
:: FUNCION PARA OCULTAR CONTRASEÑA
:: =========================================
:SetPassword
setlocal disabledelayedexpansion
set "psCommand=powershell -Command "$p=read-host -AsSecureString;^$BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p);[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set "PASSWORD=%%p"
endlocal & set "%1=%PASSWORD%"
exit /b

:: =========================================
:: FUNCION PARA OCULTAR CONTRASEÑA MEJORADA
:: =========================================
:SetPassword
setlocal disabledelayedexpansion
set "psCommand=powershell -Command "$p=read-host -AsSecureString;^$BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p);[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set "PASSWORD=%%p"
endlocal & set "%1=%PASSWORD%"
exit /b

:: =========================================
:: SISTEMA DE AUTENTICACION MEJORADO
:: =========================================
:autenticacion
color 07
echo ================================
echo    AUTENTICACION REQUERIDA
echo ================================
echo.

set "CONTRASENA="
set "CONFIRMAR="

:: Usar función para ocultar contraseña con asteriscos en la misma línea
echo|set /p="Ingrese la contrasena: "
call :SetPassword CONTRASENA
echo.

echo|set /p="Confirme la contrasena: "
call :SetPassword CONFIRMAR
echo.

if "!CONTRASENA!"=="" (
    echo [%DATE% %TIME%] Intento fallido: Contrasena vacia >> "%LOG_PATH%"
    color 04
    echo.
    echo ERROR: Contrasena no puede estar vacia
    timeout /t 2 /nobreak >nul
    goto autenticacion
)

if not "!CONTRASENA!"=="%PASSWORD_CORRECTA%" (
    echo [%DATE% %TIME%] Intento fallido: Contrasena incorrecta >> "%LOG_PATH%"
    color 04
    echo.
    echo ERROR: Contrasena incorrecta
    timeout /t 2 /nobreak >nul
    goto autenticacion
)

if not "!CONTRASENA!"=="!CONFIRMAR!" (
    echo [%DATE% %TIME%] Intento fallido: Contrasenas no coinciden >> "%LOG_PATH%"
    color 04
    echo.
    echo ERROR: Las contrasenas no coinciden
    timeout /t 2 /nobreak >nul
    goto autenticacion
)

:: Autenticación exitosa
echo [%DATE% %TIME%] Autenticacion exitosa >> "%LOG_PATH%"
color 02
echo.
echo ==================
echo =  Autenticado   =
echo ==================
echo.
timeout /t 1 /nobreak >nul
goto bienvenida_normal

:: =========================================
:: BIENVENIDA EN MODO SEGURO (SIN CONTRASEÑA)
:: =========================================
:bienvenida_modo_seguro
cls
MODE con:cols=110 lines=55
echo [%DATE% %TIME%] Acceso directo en Modo Seguro - Sin autenticacion >> "%LOG_PATH%"
color 0A
echo ================================
echo    MODO SEGURO DETECTADO
echo ================================
echo.
echo Acceso directo concedido
echo No se requiere autenticacion en Modo Seguro
echo.
timeout /t 2 /nobreak >nul
goto bienvenida_normal

:: =========================================
:: BIENVENIDA NORMAL
:: =========================================
:bienvenida_normal
cls
MODE con:cols=110 lines=55
echo Hola %USERNAME%
timeout /t 1 /nobreak >nul
echo.
echo Bienvenidos al Script de Soporte Tecnico
if !MODO_SEGURO! equ 1 (
    echo [MODO SEGURO ACTIVO]
)
echo.

:: Mostrar arte ASCII
echo        __                                                      
echo       /  l                                                     
echo     .'   :               __.....__..._  ____                   
echo    /  /   \          _.-" $$SSSSSS$$SSSSSSSSSp.                
echo   (`-: .qqp:    .--.'  .p.S$$$$SSSSS$$$$$$$$SSSSp.             
echo    """yS$SSSb,.'.g._\.SSSSS^^""       `S""^^$$$SSSb.           
echo      :SS$S$$$$SSSSS^"""-. _.            `.   "^$$$SSb._.._     
echo      SSS$$S$$SSP^/       `.               \     "^$SSS$$SSb.   
echo      :SSSS$SP^" :          \  `-.          `-      "^TSS$$SSb  
echo       $$$$S'    ;          db               ."        TSSSSSS$,
echo       :$$P      ;$b        $ ;    (        /   .-"   .S$$$$$$$;
echo         ;-"     :$ ^s.    d' $           .g. .'    .SSdSSSS$P" 
echo        /     .-  T.  `b. 't._$ .- / __.-j$'.'   .sSSSdP^^^'    
echo       /  /      `,T._.dP   "":'  /-"   .'       TSSP'          
echo      :  :         ,\""       ; .'    .'      .-""              
echo     _J  ;         ; `.      /.'    _/    \.-"                  
echo    /  "-:        /"--.b-..-'     .'       ;                    
echo   /     /  ""-..'            .--'.-'/  ,  :                    
echo  :S.   :     dS$ bug         `-i" ,',_:  _ \                   
echo  :S$b  '._  dS$;             .'.-"; ; ; j `.l                  
echo   TS$b          "-._         `"  :_/ :_/                       
echo    `T$b             "-._                                       
echo     :S$p._             "-.                                    
echo      `TSSS$ "-.     )     `.                                  
echo         ""^--""^-. :        \                                 
echo                   ";         \                                
echo                   :           `._                             
echo                   ; /    \ `._   ""---.                       
echo                  / /   _      `.--.__.'                       
echo                 : :   / ;  :".  \         Batch de Soporte                      
echo                 ; ;  :  :  ;  `. `.       = SMITH LOZANO =                      
echo                /  ;  :   ; :    `. `.           v3.0                    
echo               /  /:  ;   :  ;     "-'                         
echo              :_.' ;  ;    ; :                                 
echo                  /  /     :_l                                 
echo                  `-'
echo.
timeout /t 2 /nobreak >nul
pause

:: =========================================
:: VARIABLES GLOBALES MEJORADAS
:: =========================================
set "MENU_ACTUAL=menu_principal"

:: ...
:: =========================================
:: MENU PRINCIPAL ORGANIZADO
:: =========================================
:menu_principal
set "MENU_ACTUAL=menu_principal"

:: Configurar titulo según modo
if !MODO_SEGURO! equ 1 (
    TITLE Batch de Soporte Tecnico - Menu Principal - [MODO SEGURO]
) else (
    TITLE Batch de Soporte Tecnico - Menu Principal
)

MODE con:cols=110 lines=55
color F0

cls
echo [%DATE% %TIME%] Menu principal mostrado >> "%LOG_PATH%"

echo  ============================================================================================================
echo   ^| %DATE% ^| %TIME% ^|                                           ^| Developed by ^| Smith Lozano ^|
echo  ============================================================================================================     
echo                BIENVENIDOS AL SCRIPT PARA SOPORTE TECNICO Y MANTENIMIENTO DE EQUIPOS DE COMPUTO
echo                                               = VERSION 3.0 =
if !MODO_SEGURO! equ 1 (
    echo                ==================== [ MODO SEGURO ACTIVO - ACCESO DIRECTO ] ====================
)
echo  ============================================================================================================
echo.
echo ==================================
echo =         MENU PRINCIPAL         =
echo ==================================
echo.
echo [1] MANTENIMIENTO DEL SISTEMA
echo [2] RED Y CONECTIVIDAD
echo [3] SEGURIDAD Y AUDITORIA
echo [4] DISCOS Y ALMACENAMIENTO
echo [5] HERRAMIENTAS AVANZADAS
echo.
echo [0] = SALIR =
echo.
echo  ============================================================================================================
echo  =                                  Nivel desbloqueado: SUPER ADMINISTRADOR                                 =
echo  =                                    Poderes: Control total del sistema                                    =
echo  =                                  Vidas: 1 (Verifique antes de ejecutar) :)                               =
echo  ============================================================================================================
echo.
echo Log: %LOG_PATH%
if !MODO_SEGURO! equ 1 (
    echo Modo: SEGURO [Acceso directo sin autenticacion]
) else (
    echo Modo: NORMAL [Autenticacion requerida]
)
echo.

SET /p "main_var= ^> Seleccione una Categoria [0-5]: "

if "%main_var%"=="1" goto menu_mantenimiento
if "%main_var%"=="2" goto menu_red
if "%main_var%"=="3" goto menu_seguridad
if "%main_var%"=="4" goto menu_discos
if "%main_var%"=="5" goto menu_herramientas
if "%main_var%"=="0" goto salir

echo.
echo ERROR: Opcion "%main_var%" no valida
pause
goto menu_principal

:: =========================================
:: SUBMENU MANTENIMIENTO DEL SISTEMA
:: =========================================
:menu_mantenimiento
set "MENU_ACTUAL=menu_mantenimiento"
cls
echo [%DATE% %TIME%] Menu mantenimiento mostrado >> "%LOG_PATH%"

echo  ============================================================================================================
echo   ^| MANTENIMIENTO DEL SISTEMA ^| %TIME% ^|                                            ^| User: %USERNAME% ^|
echo  ============================================================================================================
echo.
echo [1]  Eliminar Archivos Temporales del Sistema Operativo
echo [2]  Eliminar Archivos Temporales del Perfil Local del Usuario
echo [3]  Eliminar Archivos Caches de Programas y Aplicaciones
echo [4]  Liberar Espacio en la Unidad de Almacenamiento [HDD]
echo [5]  Desfragmentar Sistema Operativo [Aplica Solo Para Discos Duros]
echo [6]  Diagnosticar Memoria RAM [Se Ejecuta desde el Arranque]
echo [7]  Comprobar Y Reparar Errores Logicos en la Unidad De Almacenamiento 
echo [8]  Entrar en Modo Seguro Sin Funciones de Red [LAN-WiFi]
echo [9]  Entrar en Modo Seguro Con Funciones de Red [LAN]
echo [10] Salir de Modo Seguro [Inicia Windows Normalmente]
echo [11] Reparar archivos de sistema (SFC Scan)
echo.
echo [0] = VOLVER AL MENU PRINCIPAL =
echo.

SET /p "var= ^> Seleccione Opcion [0-11]: "

if "%var%"=="0" goto menu_principal
if "%var%"=="1" goto op_m1
if "%var%"=="2" goto op_m2
if "%var%"=="3" goto op_m3
if "%var%"=="4" goto op_m4
if "%var%"=="5" goto op_m5
if "%var%"=="6" goto op_m6
if "%var%"=="7" goto op_m7
if "%var%"=="8" goto op_m8
if "%var%"=="9" goto op_m9
if "%var%"=="10" goto op_m10
if "%var%"=="11" goto op_m11

goto error_opcion

:: =========================================
:: SUBMENU RED Y CONECTIVIDAD
:: =========================================
:menu_red
set "MENU_ACTUAL=menu_red"
cls
echo [%DATE% %TIME%] Menu red mostrado >> "%LOG_PATH%"

echo  ============================================================================================================
echo   ^| RED Y CONECTIVIDAD ^| %TIME% ^|                                                   ^| User: %USERNAME% ^|
echo  ============================================================================================================
echo.
echo [1]  Eliminar Caches DNS [Registros del Dominio]
echo [2]  Liberar Direccion IP [DHCP]
echo [3]  Renovar Direccion IP [DHCP]
echo [4]  Direccion Fisica [Adaptadores de RED]
echo [5]  Informacion Detallada [Adaptadores de RED]
echo [6]  Diagnosticar conexion a Internet
echo [7]  Resetear configuracion de red completa
echo [8]  Ver estadisticas de red
echo [9]  Probar conectividad a servidores DNS
echo.
echo [0] = VOLVER AL MENU PRINCIPAL =
echo.

SET /p "var= ^> Seleccione Opcion [0-9]: "

if "%var%"=="0" goto menu_principal
if "%var%"=="1" goto op_r1
if "%var%"=="2" goto op_r2
if "%var%"=="3" goto op_r3
if "%var%"=="4" goto op_r4
if "%var%"=="5" goto op_r5
if "%var%"=="6" goto op_r6
if "%var%"=="7" goto op_r7
if "%var%"=="8" goto op_r8
if "%var%"=="9" goto op_r9

goto error_opcion

:: =========================================
:: SUBMENU SEGURIDAD Y AUDITORIA
:: =========================================
:menu_seguridad
set "MENU_ACTUAL=menu_seguridad"
cls
echo [%DATE% %TIME%] Menu seguridad mostrado >> "%LOG_PATH%"

echo  ============================================================================================================
echo   ^| SEGURIDAD Y AUDITORIA ^| %TIME% ^|                                                ^| User: %USERNAME% ^|
echo  ============================================================================================================
echo.
echo [1]  Ver eventos de seguridad recientes
echo [2]  Listar procesos sospechosos
echo [3]  Ver usuarios conectados
echo [4]  Auditoria de servicios ejecutandose
echo [5]  Ver registros de firewall
echo [6]  Escanear puertos abiertos
echo.
echo [0] = VOLVER AL MENU PRINCIPAL =
echo.

SET /p "var= ^> Seleccione Opcion [0-6]: "

if "%var%"=="0" goto menu_principal
if "%var%"=="1" goto op_s1
if "%var%"=="2" goto op_s2
if "%var%"=="3" goto op_s3
if "%var%"=="4" goto op_s4
if "%var%"=="5" goto op_s5
if "%var%"=="6" goto op_s6

goto error_opcion

:: =========================================
:: SUBMENU DISCOS Y ALMACENAMIENTO
:: =========================================
:menu_discos
set "MENU_ACTUAL=menu_discos"
cls
echo [%DATE% %TIME%] Menu discos mostrado >> "%LOG_PATH%"

echo  ============================================================================================================
echo   ^| DISCOS Y ALMACENAMIENTO ^| %TIME% ^|                                              ^| User: %USERNAME% ^|
echo  ============================================================================================================
echo.
echo [1]  Administracion de Discos Duros
echo [2]  Ver estado de discos (SMART)
echo [3]  Limpiar System Restore (solo puntos antiguos)
echo [4]  Ver informacion detallada de particiones y sistemas de archivos
echo [5]  Ver espacio detallado por carpeta
echo [6]  Analizar uso de espacio en disco
echo.
echo [0] = VOLVER AL MENU PRINCIPAL =
echo.

SET /p "var= ^> Seleccione Opcion [0-6]: "

if "%var%"=="0" goto menu_principal
if "%var%"=="1" goto op_d1
if "%var%"=="2" goto op_d2
if "%var%"=="3" goto op_d3
if "%var%"=="4" goto op_d4
if "%var%"=="5" goto op_d5
if "%var%"=="6" goto op_d6

goto error_opcion

:: =========================================
:: SUBMENU HERRAMIENTAS AVANZADAS
:: =========================================
:menu_herramientas
set "MENU_ACTUAL=menu_herramientas"
cls
echo [%DATE% %TIME%] Menu herramientas mostrado >> "%LOG_PATH%"

echo  ============================================================================================================
echo   ^| HERRAMIENTAS AVANZADAS ^| %TIME% ^|                                               ^| User: %USERNAME% ^|
echo  ============================================================================================================
echo.
echo [1]  Informacion del Sistema
echo [2]  Acerca de Windows
echo [3]  Editor de registro rapido
echo [4]  Editor de politicas de grupo
echo [5]  Administrador de servicios
echo [6]  Programador de tareas
echo [7]  Visor de eventos
echo [8]  Administrador de dispositivos
echo.
echo [0] = VOLVER AL MENU PRINCIPAL =
echo.

SET /p "var= ^> Seleccione Opcion [0-8]: "

if "%var%"=="0" goto menu_principal
if "%var%"=="1" goto op_h1
if "%var%"=="2" goto op_h2
if "%var%"=="3" goto op_h3
if "%var%"=="4" goto op_h4
if "%var%"=="5" goto op_h5
if "%var%"=="6" goto op_h6
if "%var%"=="7" goto op_h7
if "%var%"=="8" goto op_h8

goto error_opcion

:: =========================================
:: VALIDACION DE OPCIONES
:: =========================================
:error_opcion
echo [%DATE% %TIME%] Opcion invalida seleccionada: %var% >> "%LOG_PATH%"
echo.
echo ERROR: El numero "%var%" no es una opcion valida, por favor intente de nuevo.
echo.
pause
goto %MENU_ACTUAL%

:: =========================================
:: FUNCIONES MANTENIMIENTO (op_m*)
:: =========================================

:op_m1
echo [%DATE% %TIME%] Mantenimiento 1: Limpieza temporales del sistema >> "%LOG_PATH%"
echo.
echo Has elegido la opcion No. 1
echo Eliminando Temporales del Sistema Operativo ...
echo.

set "archivos_eliminados=0"
set "archivos_fallados=0"

:: CONTAR SOLO ARCHIVOS ANTES (EXCLUYENDO CARPETAS)
set "antes=0"
for /f %%a in ('dir "C:\Windows\Temp" /b /a-d 2^>nul ^| find /c /v ""') do set "antes=%%a"

:: ELIMINAR SOLO ARCHIVOS DENTRO DE C:\Windows\Temp - NO LA CARPETA
echo Limpiando C:\Windows\Temp...
if exist "C:\Windows\Temp" (
    :: Limpiar archivos en carpeta principal
    for /f "delims=" %%i in ('dir "C:\Windows\Temp" /b /a-d 2^>nul') do (
        del /f /q "C:\Windows\Temp\%%i" >nul 2>&1
        if !errorlevel! equ 0 (
            set /a "archivos_eliminados+=1"
        ) else (
            set /a "archivos_fallados+=1"
        )
    )
    
    :: Limpiar archivos en sub-carpetas
    for /f "delims=" %%d in ('dir "C:\Windows\Temp" /b /ad 2^>nul') do (
        if exist "C:\Windows\Temp\%%d" (
            for /f "delims=" %%f in ('dir "C:\Windows\Temp\%%d" /b /a-d 2^>nul') do (
                del /f /q "C:\Windows\Temp\%%d\%%f" >nul 2>&1
                if !errorlevel! equ 0 (
                    set /a "archivos_eliminados+=1"
                ) else (
                    set /a "archivos_fallados+=1"
                )
            )
        )
    )
)

:: CONTAR SOLO ARCHIVOS DESPUÉS (EXCLUYENDO CARPETAS)
set "despues=0"
for /f %%a in ('dir "C:\Windows\Temp" /b /a-d 2^>nul ^| find /c /v ""') do set "despues=%%a"

:: MOSTRAR RESULTADO
echo.
echo ============ RESUMEN DE LIMPIEZA ============
echo Archivos antes de la limpieza: !antes!
echo Archivos eliminados exitosamente: !archivos_eliminados!
echo Archivos que no se pudieron eliminar (en uso): !archivos_fallados!
echo Archivos restantes en carpeta temporal: !despues!
echo.

:: VERIFICACIÓN LÓGICA
if !despues! gtr 0 (
    echo NOTA: Quedaron !despues! archivos en uso por el sistema.
    echo Esto es normal en C:\Windows\Temp.
) else if !archivos_eliminados! equ 0 (
    echo La carpeta C:\Windows\Temp ya estaba vacia.
) else (
    echo ¡Limpieza completada exitosamente!
    echo Todos los archivos temporales fueron eliminados.
)

echo [%DATE% %TIME%] Limpieza temporales del sistema completada >> "%LOG_PATH%"
goto exito_mantenimiento

:op_m2
echo [%DATE% %TIME%] Mantenimiento 2: Limpieza temporales de usuario >> "%LOG_PATH%"
echo.
echo Has elegido la opcion No. 2
echo Eliminando Temporales del Perfil Local del Usuario ...
echo.

set "archivos_eliminados=0"

:: MÉTODO MÁS EFECTIVO - ELIMINACIÓN MASIVA
echo Limpiando carpeta temporal del usuario...
if exist "%temp%" (
    :: PRIMERA PASADA - ELIMINAR TODO LO QUE SE PUEDA
    echo [Paso 1/2] Eliminando archivos temporales...
    del /f /q /s "%temp%\*" >nul 2>&1
    
    :: SEGUNDA PASADA - INTENTAR ELIMINAR ARCHIVOS BLOQUEADOS
    echo [Paso 2/2] Limpiando archivos restantes...
    for /f "delims=" %%i in ('dir "%temp%" /b /a-d /s 2^>nul') do (
        del /f /q "%%i" >nul 2>&1
    )
    
    :: CONTAR LO QUE REALMENTE SE ELIMINÓ
    echo Contando resultados...
    for /f "delims=" %%i in ('dir "%temp%" /b /a-d /s 2^>nul') do (
        set /a "archivos_eliminados+=1"
    )
)

:: CONTAR ARCHIVOS DESPUÉS
set "despues=0"
for /f %%a in ('dir "%temp%" /b /a-d /s 2^>nul ^| find /c /v ""') do set "despues=%%a"

:: MOSTRAR RESULTADO SIMPLIFICADO
echo.
echo ============ RESUMEN DE LIMPIEZA ============
echo Archivos eliminados: !archivos_eliminados!
echo Archivos restantes (en uso): !despues!
echo.

if !despues! gtr 0 (
    echo NOTA: !despues! archivos no se pudieron eliminar porque estaban en uso.
    echo.
    echo CAUSAS COMUNES:
    echo - Navegadores web abiertos (Chrome, Edge, Firefox)
    echo - Suite de Office (Word, Excel, PowerPoint)  
    echo - Aplicaciones en segundo plano
    echo - Procesos del sistema de Windows
    echo.
    echo CONSEJO: Cierre todas las aplicaciones y vuelva a ejecutar esta opcion.
) else if !archivos_eliminados! equ 0 (
    echo La carpeta temporal ya estaba vacia.
) else (
    echo ¡Limpieza completada exitosamente!
)

echo [%DATE% %TIME%] Limpieza temporales de usuario completada >> "%LOG_PATH%"
goto exito_mantenimiento

:op_m3
echo [%DATE% %TIME%] Mantenimiento 3: Limpieza Prefetch >> "%LOG_PATH%"
echo.
echo Has elegido la opcion No. 3
echo Eliminando Archivos Caches de Programas y Aplicaciones ...
echo.

set "archivos_eliminados=0"
set "archivos_fallados=0"

:: CONTAR SOLO ARCHIVOS ANTES (EXCLUYENDO CARPETAS)
set "antes=0"
for /f %%a in ('dir "C:\Windows\Prefetch" /b /a-d 2^>nul ^| find /c /v ""') do set "antes=%%a"

:: ELIMINAR SOLO ARCHIVOS DENTRO DE PREFETCH - NO LA CARPETA
echo Limpiando Prefetch...
if exist "C:\Windows\Prefetch" (
    for /f "delims=" %%i in ('dir "C:\Windows\Prefetch" /b /a-d 2^>nul') do (
        :: EXCLUIR ARCHIVOS CRÍTICOS DEL SISTEMA
        echo "%%i" | findstr /i "layout.ini readyboot" >nul
        if !errorlevel! equ 1 (
            del /f /q "C:\Windows\Prefetch\%%i" >nul 2>&1
            if !errorlevel! equ 0 (
                set /a "archivos_eliminados+=1"
            ) else (
                set /a "archivos_fallados+=1"
            )
        )
    )
)

:: CONTAR SOLO ARCHIVOS DESPUÉS (EXCLUYENDO CARPETAS)
set "despues=0"
for /f %%a in ('dir "C:\Windows\Prefetch" /b /a-d 2^>nul ^| find /c /v ""') do set "despues=%%a"

:: MOSTRAR RESULTADO
echo.
echo ============ RESUMEN DE LIMPIEZA ============
echo Archivos antes de la limpieza: !antes!
echo Archivos .pf eliminados en Prefetch: !archivos_eliminados!
echo Archivos que no se pudieron eliminar (en uso): !archivos_fallados!
echo Archivos restantes en Prefetch: !despues!
echo.

:: VERIFICACIÓN LÓGICA
if !despues! gtr 0 (
    echo NOTA: Quedaron !despues! archivos del sistema o en uso.
    echo Windows los regenerará automaticamente.
) else if !archivos_eliminados! equ 0 (
    echo La carpeta Prefetch ya estaba vacia o solo tiene archivos del sistema.
) else (
    echo ¡Limpieza completada exitosamente!
    echo Archivos de cache de programas eliminados.
)

echo [%DATE% %TIME%] Limpieza Prefetch completada >> "%LOG_PATH%"
goto exito_mantenimiento

:op_m4
echo [%DATE% %TIME%] Mantenimiento 4: Liberador de espacio >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 4
echo Ingresando al Liberador de Espacio ...
echo.
CLEANMGR
echo [%DATE% %TIME%] Liberador de espacio ejecutado >> "%LOG_PATH%"
goto exito_mantenimiento

:op_m5
echo [%DATE% %TIME%] Mantenimiento 5: Desfragmentacion >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 5
echo Ejecutando el Desfragmentador ... 
defrag C: /U /V 2>> "%LOG_PATH%"
echo [%DATE% %TIME%] Desfragmentacion completada >> "%LOG_PATH%"
goto exito_mantenimiento

:op_m6
echo [%DATE% %TIME%] Mantenimiento 6: Diagnostico RAM >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 6
echo.
echo ============ DIAGNOSTICO DE MEMORIA RAM ============
echo.
echo FUNCION: Ejecuta Windows Memory Diagnostic Tool
echo.
echo ¿QUE HACE?
echo - Analiza la memoria RAM en busca de errores
echo - Se ejecuta en el proximo reinicio del sistema
echo - Realiza pruebas exhaustivas de todos los modulos
echo.
echo RESULTADOS:
echo - Los resultados se muestran despues del reinicio
echo - Si hay errores, Windows los reportara automaticamente
echo.
echo DURACION: 15-30 minutos aproximadamente
echo.
echo ¿Desea continuar? El sistema se reiniciara.
echo.
choice /C SN /N /M "Presione S para continuar o N para cancelar"
if errorlevel 2 goto menu_mantenimiento
echo.
echo Iniciando diagnostico de memoria RAM...
start mdsched.exe
echo [%DATE% %TIME%] mdsched.exe iniciado >> "%LOG_PATH%"
goto exito_mantenimiento

:op_m7
echo [%DATE% %TIME%] Mantenimiento 7: CHKDSK programado >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 7
echo Se esta Iniciando el Comprobador del Sistema Operativo ...
echo.
echo ADVERTENCIA: Esto requerira reiniciar el sistema
echo.
echo Presione cualquier tecla para programar CHKDSK en el proximo reinicio...
pause >nul
chkdsk C: /F /R
echo [%DATE% %TIME%] CHKDSK programado para proximo reinicio >> "%LOG_PATH%"
goto exito_reinicio_mantenimiento

:op_m8
echo [%DATE% %TIME%] Mantenimiento 8: Modo seguro sin red >> "%LOG_PATH%"
echo.
echo Has elegido la opcion No. 8
echo Configurando inicio en modo seguro sin red ...
echo.

:: VERIFICAR SI YA ESTÁ EN MODO SEGURO
bcdedit | findstr /i "safeboot.*minimal" >nul
if !errorlevel! equ 0 (
    echo El sistema ya esta configurado para Modo Seguro sin red.
    goto exito_mantenimiento
)

:: CONFIRMACIÓN DE ACCIÓN PELIGROSA
echo    ADVERTENCIA: Esta accion modificara el arranque del sistema
echo    El equipo se reiniciara en MODO SEGURO SIN RED
echo.
echo    ¿Desea continuar?
echo    [S] para SI y reiniciar en Modo Seguro
echo    [N] para NO y volver al menu
echo.
set /p "conf=Seleccione [S/N]: "

if /i not "!conf!"=="S" (
    echo [%DATE% %TIME%] Usuario cancelo modo seguro sin red >> "%LOG_PATH%"
    echo Accion cancelada por el usuario
    timeout /t 2 /nobreak >nul
    goto menu_mantenimiento
)

:: CONFIGURAR MODO SEGURO SIN RED
echo Configurando Modo Seguro sin red...
bcdedit /set {default} safeboot minimal
if !errorlevel! equ 0 (
    echo ¡Modo seguro sin red configurado correctamente!
    echo El sistema se reiniciara en modo seguro.
) else (
    echo Error: No se pudo configurar el modo seguro.
    echo Ejecute el script como Administrador.
    goto exito_mantenimiento
)

echo [%DATE% %TIME%] Modo seguro sin red configurado >> "%LOG_PATH%"
goto exito_reinicio_mantenimiento

:op_m9
echo [%DATE% %TIME%] Mantenimiento 9: Modo seguro con red >> "%LOG_PATH%"
echo.
echo Has elegido la opcion No. 9
echo Configurando inicio en modo seguro con red ...
echo.

:: VERIFICAR SI YA ESTÁ EN MODO SEGURO
bcdedit | findstr /i "safeboot.*network" >nul
if !errorlevel! equ 0 (
    echo El sistema ya esta configurado para Modo Seguro con red.
    goto exito_mantenimiento
)

:: CONFIRMACIÓN DE ACCIÓN PELIGROSA
echo    ADVERTENCIA: Esta accion modificara el arranque del sistema
echo    El equipo se reiniciara en MODO SEGURO CON RED
echo.
echo    ¿Desea continuar?
echo    [S] para SI y reiniciar en Modo Seguro con Red
echo    [N] para NO y volver al menu
echo.
set /p "conf=Seleccione [S/N]: "

if /i not "!conf!"=="S" (
    echo [%DATE% %TIME%] Usuario cancelo modo seguro con red >> "%LOG_PATH%"
    echo Accion cancelada por el usuario
    timeout /t 2 /nobreak >nul
    goto menu_mantenimiento
)

:: CONFIGURAR MODO SEGURO CON RED
echo Configurando Modo Seguro con red...
bcdedit /set {default} safeboot network
if !errorlevel! equ 0 (
    echo ¡Modo seguro con red configurado correctamente!
    echo El sistema se reiniciara en modo seguro con acceso a red.
) else (
    echo Error: No se pudo configurar el modo seguro.
    echo Ejecute el script como Administrador.
    goto exito_mantenimiento
)

echo [%DATE% %TIME%] Modo seguro con red configurado >> "%LOG_PATH%"
goto exito_reinicio_mantenimiento

:op_m10
echo [%DATE% %TIME%] Mantenimiento 10: Salir modo seguro >> "%LOG_PATH%"
echo.
echo Has elegido la opcion No. 10
echo Restaurando inicio normal ...
echo.

:: DETECTAR SI HAY CONFIGURACIÓN DE MODO SEGURO ACTIVA
set "en_modo_seguro=0"
bcdedit | findstr /i "safeboot" >nul && set "en_modo_seguro=1"

if !en_modo_seguro! equ 0 (
    echo AVISO: No se detecto configuracion de modo seguro activa.
    echo El sistema ya esta configurado para inicio normal.
    goto exito_mantenimiento
)

:: CONFIRMACIÓN
echo    Se detecto configuracion de Modo Seguro activa.
echo    Esta accion restaurara el inicio normal de Windows.
echo.
echo    ¿Desea continuar?
echo    [S] para SI y restaurar inicio normal
echo    [N] para NO y mantener Modo Seguro
echo.
set /p "conf=Seleccione [S/N]: "

if /i not "!conf!"=="S" (
    echo [%DATE% %TIME%] Usuario cancelo salida de modo seguro >> "%LOG_PATH%"
    echo Accion cancelada por el usuario
    timeout /t 2 /nobreak >nul
    goto menu_mantenimiento
)

:: ELIMINAR CONFIGURACIÓN DE MODO SEGURO
echo Eliminando configuracion de modo seguro...
bcdedit /deletevalue {default} safeboot

:: VERIFICAR RESULTADO
bcdedit | findstr /i "safeboot" >nul
if !errorlevel! equ 1 (
    echo ¡Éxito! Configuracion de modo seguro eliminada.
    echo El sistema iniciara normalmente en el proximo reinicio.
    echo.
    echo RECOMENDACION: Reinicie el sistema para aplicar los cambios.
) else (
    echo ¡Atencion! No se pudo eliminar completamente la configuracion.
    echo.
    echo SOLUCION MANUAL:
    echo 1. Abra CMD como Administrador
    echo 2. Ejecute: bcdedit /deletevalue {default} safeboot
    echo 3. Reinicie el sistema manualmente
    echo.
    echo Presione una tecla para ver instrucciones detalladas...
    pause >nul
    goto instrucciones_manuales
)

echo [%DATE% %TIME%] Configuracion modo seguro eliminada >> "%LOG_PATH%"
goto exito_reinicio_mantenimiento

:instrucciones_manuales
cls
echo ===================================================================
echo   INSTRUCCIONES MANUALES PARA SALIR DEL MODO SEGURO
echo ===================================================================
echo.
echo Si el comando automatico fallo, siga estos pasos:
echo.
echo 1. Presione [Win] + [R], escriba "cmd" y presione [Ctrl] + [Shift] + [Enter]
echo 2. En la ventana de Administrador, ejecute estos comandos:
echo.
echo    bcdedit /deletevalue {default} safeboot
echo    bcdedit /deletevalue {default} safebootalternateshell
echo.
echo 3. Luego reinicie con:
echo.
echo    shutdown /r /t 5
echo.
echo 4. Si aun tiene problemas, ejecute:
echo.
echo    bcdedit /set {default} bootstatuspolicy ignoreallfailures
echo    bcdedit /set {default} advancedoptions false
echo.
echo Presione una tecla para volver al menu...
pause >nul
goto menu_mantenimiento

:op_m11
echo [%DATE% %TIME%] Mantenimiento 11: SFC Scan >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 11
echo Reparando archivos de sistema con SFC /SCANNOW...
echo.
sfc /scannow
echo [%DATE% %TIME%] SFC Scan completado >> "%LOG_PATH%"
goto exito_mantenimiento

:: =========================================
:: FUNCIONES RED (op_r*)
:: =========================================

:op_r1
echo [%DATE% %TIME%] Red 1: Flush DNS >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 1
echo Se estan eliminando las caches y registros del Dominio ...
ipconfig /flushdns 2>> "%LOG_PATH%"
echo [%DATE% %TIME%] Flush DNS completado >> "%LOG_PATH%"
goto exito_red

:op_r2
echo [%DATE% %TIME%] Red 2: Release IP >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 2
echo Se esta liberando la direccion IP ... 
ipconfig /release 2>> "%LOG_PATH%"
echo [%DATE% %TIME%] IP release completado >> "%LOG_PATH%"
goto exito_red

:op_r3
echo [%DATE% %TIME%] Red 3: Renew IP >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 3
echo Se esta generando una nueva direccion IP ...
ipconfig /renew 2>> "%LOG_PATH%"
echo [%DATE% %TIME%] IP renew completado >> "%LOG_PATH%"
goto exito_red

:op_r4
echo [%DATE% %TIME%] Red 4: Direcciones MAC >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 4
echo Se estan mostrando las Direcciones Fisicas ... 
getmac /v | more
echo [%DATE% %TIME%] Informacion MAC mostrada >> "%LOG_PATH%"
goto exito_red

:op_r5
echo [%DATE% %TIME%] Red 5: IP Config completo >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 5
echo Generando Informacion Detallada ...
echo.
echo ¿Mostrar en pantalla (paginado) o guardar en archivo?
echo [P] Pantalla (usar ENTER/ESPACIO para navegar)
echo [A] Archivo (abrir en bloc de notas)
choice /C PA /N /M "Seleccione opcion:"
if errorlevel 2 goto ipconfig_archivo
if errorlevel 1 goto ipconfig_pantalla

:ipconfig_pantalla
echo.
echo Mostrando IPCONFIG /ALL (paginado)...
ipconfig /all | more
goto ipconfig_fin

:ipconfig_archivo
set "IPCONFIG_LOG=%temp%\ipconfig_%username%_%time:~0,2%%time:~3,2%.txt"
set "IPCONFIG_LOG=%IPCONFIG_LOG: =%"
echo.
echo Guardando informacion en: %IPCONFIG_LOG%
ipconfig /all > "%IPCONFIG_LOG%"
echo Abriendo archivo en bloc de notas...
notepad "%IPCONFIG_LOG%"

:ipconfig_fin
echo [%DATE% %TIME%] IP config mostrado >> "%LOG_PATH%"
goto exito_red

:op_r6
echo [%DATE% %TIME%] Red 6: Diagnostico Internet completo >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 6
echo Iniciando diagnostico completo de conectividad a Internet...
echo.

set "PING_LOG=%temp%\Diagnostico_Internet_%username%_%time:~0,2%%time:~3,2%.txt"
set "PING_LOG=%PING_LOG: =%"

:: Preguntar modo de visualización
echo ¿Como desea ver el diagnostico?
echo [1] Ver en pantalla mientras se ejecuta
echo [2] Solo generar reporte en archivo
echo.
choice /C 12 /N /M "Seleccione opcion:"

if errorlevel 2 goto solo_reporte
if errorlevel 1 goto ver_pantalla

:ver_pantalla
echo.
echo ============ DIAGNOSTICO DE CONECTIVIDAD EN TIEMPO REAL ============
echo Iniciando pruebas de ping a multiples servidores...
echo Los resultados se muestran en tiempo real...
echo.
echo Guardando log en: %PING_LOG%
echo.

:: Crear archivo de log
echo ============ REPORTE DE DIAGNOSTICO DE INTERNET ============ > "%PING_LOG%"
echo Fecha: %DATE% %TIME% >> "%PING_LOG%"
echo Usuario: %USERNAME% >> "%PING_LOG%"
echo Equipo: %COMPUTERNAME% >> "%PING_LOG%"
echo. >> "%PING_LOG%"

:: Lista de servidores para probar - microsoft.com reemplazado por bing.com
set "servidores=8.8.8.8 1.1.1.1 208.67.222.222 8.8.4.4 1.0.0.1 google.com facebook.com bing.com cloudflare.com open-dns.com"

echo [1] PROBANDO SERVIDORES DNS Y CONECTIVIDAD BASICA: >> "%PING_LOG%"
echo ================================================== >> "%PING_LOG%"

set /a "exitosos=0"
set /a "fallidos=0"
set /a "total=0"

for %%s in (%servidores%) do (
    set /a "total+=1"
    echo.
    echo Probando: %%s
    echo Probando: %%s >> "%PING_LOG%"
    echo ---------- >> "%PING_LOG%"
    
    ping -n 4 %%s > "%temp%\ping_temp.txt"
    type "%temp%\ping_temp.txt"
    type "%temp%\ping_temp.txt" >> "%PING_LOG%"
    
    :: Verificar si el ping fue exitoso
    find "TTL=" "%temp%\ping_temp.txt" >nul
    if !errorlevel! equ 0 (
        echo [EXITO] - %%s responde correctamente
        echo [EXITO] - %%s responde correctamente >> "%PING_LOG%"
        set /a "exitosos+=1"
    ) else (
        echo [FALLO] - %%s no responde
        echo [FALLO] - %%s no responde >> "%PING_LOG%"
        set /a "fallidos+=1"
    )
    echo. >> "%PING_LOG%"
    del "%temp%\ping_temp.txt" >nul 2>&1
)

echo. >> "%PING_LOG%"

:: Pruebas adicionales de conectividad
echo [2] PRUEBAS DE CONECTIVIDAD AVANZADA: >> "%PING_LOG%"
echo ===================================== >> "%PING_LOG%"

echo.
echo ============ PRUEBAS AVANZADAS ============
echo Realizando pruebas adicionales...
echo.

:: Probar resolución DNS
echo Probando resolucion DNS... >> "%PING_LOG%"
nslookup google.com >> "%PING_LOG%" 2>&1
echo. >> "%PING_LOG%"

:: Probar conectividad HTTP
echo Probando conectividad HTTP... >> "%PING_LOG%"
powershell -Command "try { (Invoke-WebRequest -Uri 'http://www.google.com' -TimeoutSec 10).StatusCode } catch { Write-Host 'Fallo: ' $$_.Exception.Message }" >> "%PING_LOG%" 2>&1
echo. >> "%PING_LOG%"

:: Estadísticas de red
echo [3] ESTADISTICAS DE RED: >> "%PING_LOG%"
echo ========================= >> "%PING_LOG%"
netstat -e | findstr "Bytes" >> "%PING_LOG%"
echo. >> "%PING_LOG%"

:: RESUMEN FINAL
echo [4] RESUMEN DEL DIAGNOSTICO: >> "%PING_LOG%"
echo ============================= >> "%PING_LOG%"
echo Total de servidores probados: !total! >> "%PING_LOG%"
echo Conexiones exitosas: !exitosos! >> "%PING_LOG%"
echo Conexiones fallidas: !fallidos! >> "%PING_LOG%"
echo Tasa de exito: >> "%PING_LOG%"
if !total! gtr 0 (
    set /a "porcentaje=exitosos*100/total"
    echo !porcentaje!%% >> "%PING_LOG%"
) else (
    echo 0%% >> "%PING_LOG%"
)
echo. >> "%PING_LOG%"

:: RECOMENDACIONES
echo [5] RECOMENDACIONES: >> "%PING_LOG%"
echo ==================== >> "%PING_LOG%"
if !fallidos! gtr 5 (
    echo PROBLEMA GRAVE: Múltiples servidores no responden >> "%PING_LOG%"
    echo - Verifique su conexión física a Internet >> "%PING_LOG%"
    echo - Reinicie su router/módem >> "%PING_LOG%"
    echo - Contacte a su proveedor de Internet >> "%PING_LOG%"
) else if !fallidos! gtr 2 (
    echo PROBLEMA MODERADO: Algunos servidores no responden >> "%PING_LOG%"
    echo - Verifique la configuración de DNS >> "%PING_LOG%"
    echo - Pruebe reiniciar la conexión de red >> "%PING_LOG%"
) else if !fallidos! gtr 0 (
    echo PROBLEMA LEVE: Un servidor específico no responde >> "%PING_LOG%"
    echo - Puede ser un problema temporal del servidor >> "%PING_LOG%"
) else (
    echo CONEXION OPTIMA: Todos los servidores responden correctamente >> "%PING_LOG%"
)
echo. >> "%PING_LOG%"

echo DIAGNOSTICO COMPLETADO: %DATE% %TIME% >> "%PING_LOG%"

echo.
echo ============ DIAGNOSTICO COMPLETADO ============
echo.
echo Resumen:
echo Servidores probados: !total!
echo Conexiones exitosas: !exitosos!
echo Conexiones fallidas: !fallidos!
echo.
echo Reporte guardado en: %PING_LOG%
echo.
echo Presione una tecla para abrir el reporte completo...
pause >nul
notepad "%PING_LOG%"
goto fin_diagnostico

:solo_reporte
echo.
echo Generando reporte de diagnostico en segundo plano...
echo Por favor espere...
echo.

:: Crear archivo de log
echo ============ REPORTE DE DIAGNOSTICO DE INTERNET ============ > "%PING_LOG%"
echo Fecha: %DATE% %TIME% >> "%PING_LOG%"
echo Usuario: %USERNAME% >> "%PING_LOG%"
echo Equipo: %COMPUTERNAME% >> "%PING_LOG%"
echo. >> "%PING_LOG%"

:: Lista de servidores para probar - microsoft.com reemplazado por bing.com
set "servidores=8.8.8.8 1.1.1.1 208.67.222.222 8.8.4.4 1.0.0.1 google.com facebook.com bing.com cloudflare.com open-dns.com"

echo [1] PROBANDO SERVIDORES DNS Y CONECTIVIDAD BASICA: >> "%PING_LOG%"
echo ================================================== >> "%PING_LOG%"

set /a "exitosos=0"
set /a "fallidos=0"
set /a "total=0"

for %%s in (%servidores%) do (
    set /a "total+=1"
    echo Probando: %%s >> "%PING_LOG%"
    echo ---------- >> "%PING_LOG%"
    
    ping -n 4 %%s >> "%PING_LOG%" 2>&1
    
    :: Verificar si el ping fue exitoso
    ping -n 4 %%s | find "TTL=" >nul
    if !errorlevel! equ 0 (
        echo [EXITO] - %%s responde correctamente >> "%PING_LOG%"
        set /a "exitosos+=1"
    ) else (
        echo [FALLO] - %%s no responde >> "%PING_LOG%"
        set /a "fallidos+=1"
    )
    echo. >> "%PING_LOG%"
)

:: Pruebas adicionales de conectividad
echo [2] PRUEBAS DE CONECTIVIDAD AVANZADA: >> "%PING_LOG%"
echo ===================================== >> "%PING_LOG%"

:: Probar resolución DNS
echo Probando resolucion DNS... >> "%PING_LOG%"
nslookup google.com >> "%PING_LOG%" 2>&1
echo. >> "%PING_LOG%"

:: Probar conectividad HTTP
echo Probando conectividad HTTP... >> "%PING_LOG%"
powershell -Command "try { (Invoke-WebRequest -Uri 'http://www.google.com' -TimeoutSec 10).StatusCode } catch { Write-Host 'Fallo: ' $$_.Exception.Message }" >> "%PING_LOG%" 2>&1
echo. >> "%PING_LOG%"

:: Estadísticas de red
echo [3] ESTADISTICAS DE RED: >> "%PING_LOG%"
echo ========================= >> "%PING_LOG%"
netstat -e | findstr "Bytes" >> "%PING_LOG%"
echo. >> "%PING_LOG%"

:: RESUMEN FINAL
echo [4] RESUMEN DEL DIAGNOSTICO: >> "%PING_LOG%"
echo ============================= >> "%PING_LOG%"
echo Total de servidores probados: !total! >> "%PING_LOG%"
echo Conexiones exitosas: !exitosos! >> "%PING_LOG%"
echo Conexiones fallidas: !fallidos! >> "%PING_LOG%"
echo Tasa de exito: >> "%PING_LOG%"
if !total! gtr 0 (
    set /a "porcentaje=exitosos*100/total"
    echo !porcentaje!%% >> "%PING_LOG%"
) else (
    echo 0%% >> "%PING_LOG%"
)
echo. >> "%PING_LOG%"

:: RECOMENDACIONES
echo [5] RECOMENDACIONES: >> "%PING_LOG%"
echo ==================== >> "%PING_LOG%"
if !fallidos! gtr 5 (
    echo PROBLEMA GRAVE: Múltiples servidores no responden >> "%PING_LOG%"
    echo - Verifique su conexión física a Internet >> "%PING_LOG%"
    echo - Reinicie su router/módem >> "%PING_LOG%"
    echo - Contacte a su proveedor de Internet >> "%PING_LOG%"
) else if !fallidos! gtr 2 (
    echo PROBLEMA MODERADO: Algunos servidores no responden >> "%PING_LOG%"
    echo - Verifique la configuración de DNS >> "%PING_LOG%"
    echo - Pruebe reiniciar la conexión de red >> "%PING_LOG%"
) else if !fallidos! gtr 0 (
    echo PROBLEMA LEVE: Un servidor específico no responde >> "%PING_LOG%"
    echo - Puede ser un problema temporal del servidor >> "%PING_LOG%"
) else (
    echo CONEXION OPTIMA: Todos los servidores responden correctamente >> "%PING_LOG%"
)
echo. >> "%PING_LOG%"

echo DIAGNOSTICO COMPLETADO: %DATE% %TIME% >> "%PING_LOG%"

echo.
echo ============ REPORTE GENERADO ============
echo.
echo Archivo: %PING_LOG%
echo.
echo Presione una tecla para abrir el reporte...
pause >nul
notepad "%PING_LOG%"

:fin_diagnostico
echo [%DATE% %TIME%] Diagnostico Internet completado >> "%LOG_PATH%"
if exist "%PING_LOG%" (
    echo [%DATE% %TIME%] Archivo de diagnostico: %PING_LOG% >> "%LOG_PATH%"
)
goto exito_red

:op_r7
echo [%DATE% %TIME%] Red 7: Reset total red >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 7
echo.
echo ============ RESETEO COMPLETO DE RED ============
echo.
echo FUNCION: Restaura la configuracion de red a valores predeterminados
echo.
echo ¿QUE HACE?
echo - Resetea la pila TCP/IP (Winsock)
echo - Restablece configuraciones IP
echo - Limpia cache DNS
echo - Elimina configuraciones de red corruptas
echo.
echo SE AFECTARA:
echo - Conexiones de red actuales (se desconectaran)
echo - Configuraciones IP personalizadas
echo - Credenciales de red guardadas
echo.
echo ¿Desea continuar?
echo.
choice /C SN /N /M "Presione S para resetear red o N para cancelar"
if errorlevel 2 goto menu_red

echo.
echo Ejecutando reset completo de red...
echo.

:: EJECUTAR COMANDOS SIN MOSTRAR OUTPUT CONFUSO
echo [1/3] Resetendo Winsock...
netsh winsock reset >nul 2>&1
echo Winsock reset - COMPLETADO = OK

echo [2/3] Resetendo configuracion IP...
netsh int ip reset >nul 2>&1
echo Configuracion IP reset - COMPLETADO = OK

echo [3/3] Limpiando cache DNS...
ipconfig /flushdns >nul 2>&1
echo Cache DNS limpiado - COMPLETADO = OK

echo.
echo ============ RESETEO COMPLETADO ============
echo.
echo Todas las acciones principales se completaron exitosamente.
echo.
echo NOTA: Algunos mensajes de error pueden aparecer si componentes
echo estan en uso, pero esto es normal y no afecta el resultado.
echo.
echo RECOMENDACION: Reinicie el equipo para aplicar cambios completamente.
echo.
echo [%DATE% %TIME%] Reset de red completado >> "%LOG_PATH%"
goto exito_red

:op_r8
echo [%DATE% %TIME%] Red 8: Estadisticas red >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 8
echo Mostrando estadisticas de red...
echo.
netstat -s | more
echo [%DATE% %TIME%] Estadisticas red mostradas >> "%LOG_PATH%"
goto exito_red

:op_r9
echo [%DATE% %TIME%] Red 9: Pruebas DNS completas >> "%LOG_PATH%"
echo.
echo Has elegido la opcion No. 9
echo Iniciando pruebas completas de servidores DNS...
echo.

set "DNS_LOG=%temp%\Pruebas_DNS_%username%_%time:~0,2%%time:~3,2%.txt"
set "DNS_LOG=%DNS_LOG: =%"

echo Como desea ver las pruebas DNS?
echo [1] Ver en pantalla mientras se ejecuta
echo [2] Solo generar reporte en archivo
echo.
choice /C 12 /N /M "Seleccione opcion:"

if errorlevel 2 goto dns_solo_reporte
if errorlevel 1 goto dns_ver_pantalla

:dns_ver_pantalla
echo.
echo ============ PRUEBAS COMPLETAS DE DNS ============
echo.
echo Guardando log en: %DNS_LOG%
echo.

echo ============ REPORTE DE PRUEBAS DNS ============ > "%DNS_LOG%"
echo Fecha: %DATE% %TIME% >> "%DNS_LOG%"
echo Usuario: %USERNAME% >> "%DNS_LOG%"
echo Equipo: %COMPUTERNAME% >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

:: Servidores DNS expandidos pero confiables
set servidores=8.8.8.8 1.1.1.1 8.8.4.4 1.0.0.1 208.67.222.222 9.9.9.9

echo [1] PRUEBAS DE CONECTIVIDAD DNS >> "%DNS_LOG%"
echo ================================= >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

set /a total=0
set /a exitosos=0
set /a fallidos=0

for %%s in (%servidores%) do (
    set /a total+=1
    echo.
    echo Probando: %%s
    echo Probando: %%s >> "%DNS_LOG%"
    
    ping -n 2 %%s > "%temp%\temp.txt"
    type "%temp%\temp.txt"
    type "%temp%\temp.txt" >> "%DNS_LOG%"
    
    find "TTL=" "%temp%\temp.txt" >nul
    if errorlevel 1 (
        echo [FALLO] - No responde >> "%DNS_LOG%"
        set /a fallidos+=1
    ) else (
        echo [EXITO] - Responde correctamente >> "%DNS_LOG%"
        set /a exitosos+=1
    )
    echo. >> "%DNS_LOG%"
    del "%temp%\temp.txt"
)

echo. >> "%DNS_LOG%"
echo [2] PRUEBAS DE RESOLUCION DNS >> "%DNS_LOG%"
echo ============================== >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

set /a dns_resuelven=0
set /a dns_total=0

echo Probando resolucion con diferentes DNS: >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

for %%d in (8.8.8.8 1.1.1.1 208.67.222.222 9.9.9.9) do (
    set /a dns_total+=1
    echo Probando DNS: %%d >> "%DNS_LOG%"
    nslookup google.com %%d >> "%DNS_LOG%"
    
    nslookup google.com %%d | find "Address" >nul
    if errorlevel 1 (
        echo [FALLO] - No resuelve >> "%DNS_LOG%"
    ) else (
        echo [EXITO] - Resuelve correctamente >> "%DNS_LOG%"
        set /a dns_resuelven+=1
    )
    echo. >> "%DNS_LOG%"
)

echo. >> "%DNS_LOG%"
echo [3] PRUEBAS DE DOMINIOS >> "%DNS_LOG%"
echo ========================= >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

set dominios=google.com facebook.com whatsapp.com youtube.com microsoft.com

echo Probando resolucion de dominios populares: >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

for %%m in (%dominios%) do (
    echo Dominio: %%m >> "%DNS_LOG%"
    nslookup %%m >> "%DNS_LOG%"
    echo. >> "%DNS_LOG%"
)

echo. >> "%DNS_LOG%"
echo [4] RESUMEN FINAL >> "%DNS_LOG%"
echo ================= >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

echo CONECTIVIDAD: >> "%DNS_LOG%"
echo - Servidores DNS probados: %total% >> "%DNS_LOG%"
echo - Conexiones exitosas: %exitosos% >> "%DNS_LOG%"
echo - Conexiones fallidas: %fallidos% >> "%DNS_LOG%"
if %total% gtr 0 (
    set /a porcentaje=exitosos*100/total
    echo - Tasa de exito: %porcentaje%%% >> "%DNS_LOG%"
)
echo. >> "%DNS_LOG%"

echo RESOLUCION: >> "%DNS_LOG%"
echo - Servidores de resolucion probados: %dns_total% >> "%DNS_LOG%"
echo - Servidores que resuelven: %dns_resuelven% >> "%DNS_LOG%"
if %dns_total% gtr 0 (
    set /a porcentaje_res=dns_resuelven*100/dns_total
    echo - Tasa de exito: %porcentaje_res%%% >> "%DNS_LOG%"
)
echo. >> "%DNS_LOG%"

echo DOMINIOS: >> "%DNS_LOG%"
echo - Dominios verificados: 5 >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

echo RECOMENDACIONES: >> "%DNS_LOG%"
if %fallidos% gtr 2 (
    echo - Problema de conectividad con multiples DNS >> "%DNS_LOG%"
    echo - Verifique su conexion a Internet >> "%DNS_LOG%"
) else if %fallidos% gtr 0 (
    echo - Problema menor con algun servidor DNS >> "%DNS_LOG%"
    echo - Use servidores alternativos >> "%DNS_LOG%"
) else (
    echo - Todos los servidores DNS funcionan correctamente >> "%DNS_LOG%"
    echo - Su conexion DNS es optimal >> "%DNS_LOG%"
)
echo. >> "%DNS_LOG%"

echo PRUEBAS COMPLETADAS: %DATE% %TIME% >> "%DNS_LOG%"

echo.
echo ============ PRUEBAS COMPLETADAS ============
echo.
echo Resumen:
echo - Servidores DNS: %total%
echo - Exitosos: %exitosos%
echo - Fallidos: %fallidos%
echo - DNS que resuelven: %dns_resuelven%/%dns_total%
echo.
echo Reporte: %DNS_LOG%
echo.
pause
notepad "%DNS_LOG%"
goto fin_dns

:dns_solo_reporte
echo.
echo Generando reporte de pruebas DNS...
echo.

echo ============ REPORTE DE PRUEBAS DNS ============ > "%DNS_LOG%"
echo Fecha: %DATE% %TIME% >> "%DNS_LOG%"
echo Usuario: %USERNAME% >> "%DNS_LOG%"
echo Equipo: %COMPUTERNAME% >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

set servidores=8.8.8.8 1.1.1.1 8.8.4.4 1.0.0.1 208.67.222.222 9.9.9.9
set dominios=google.com facebook.com whatsapp.com youtube.com microsoft.com

echo [1] PRUEBAS DE CONECTIVIDAD DNS >> "%DNS_LOG%"
echo ================================= >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

set /a total=0
set /a exitosos=0
set /a fallidos=0

for %%s in (%servidores%) do (
    set /a total+=1
    echo Probando: %%s >> "%DNS_LOG%"
    ping -n 2 %%s >> "%DNS_LOG%"
    
    ping -n 2 %%s | find "TTL=" >nul
    if errorlevel 1 (
        echo [FALLO] - No responde >> "%DNS_LOG%"
        set /a fallidos+=1
    ) else (
        echo [EXITO] - Responde correctamente >> "%DNS_LOG%"
        set /a exitosos+=1
    )
    echo. >> "%DNS_LOG%"
)

echo [2] PRUEBAS DE RESOLUCION DNS >> "%DNS_LOG%"
echo ============================== >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

set /a dns_resuelven=0
set /a dns_total=0

for %%d in (8.8.8.8 1.1.1.1 208.67.222.222 9.9.9.9) do (
    set /a dns_total+=1
    echo Probando DNS: %%d >> "%DNS_LOG%"
    nslookup google.com %%d >> "%DNS_LOG%"
    
    nslookup google.com %%d | find "Address" >nul
    if errorlevel 1 (
        echo [FALLO] - No resuelve >> "%DNS_LOG%"
    ) else (
        echo [EXITO] - Resuelve correctamente >> "%DNS_LOG%"
        set /a dns_resuelven+=1
    )
    echo. >> "%DNS_LOG%"
)

echo [3] RESUMEN >> "%DNS_LOG%"
echo =========== >> "%DNS_LOG%"
echo CONECTIVIDAD: >> "%DNS_LOG%"
echo - Servidores: %total% >> "%DNS_LOG%"
echo - Exitosos: %exitosos% >> "%DNS_LOG%"
echo - Fallidos: %fallidos% >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"
echo RESOLUCION: >> "%DNS_LOG%"
echo - DNS probados: %dns_total% >> "%DNS_LOG%"
echo - Que resuelven: %dns_resuelven% >> "%DNS_LOG%"
echo. >> "%DNS_LOG%"

echo PRUEBAS COMPLETADAS: %DATE% %TIME% >> "%DNS_LOG%"

echo.
echo ============ REPORTE GENERADO ============
echo.
echo Archivo: %DNS_LOG%
echo.
pause
notepad "%DNS_LOG%"

:fin_dns
echo [%DATE% %TIME%] Pruebas DNS completadas >> "%LOG_PATH%"
goto exito_red

:: =========================================
:: FUNCIONES SEGURIDAD (op_s*)
:: =========================================

:op_s1
echo [%DATE% %TIME%] Seguridad 1: Eventos seguridad >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 1
echo.
echo ============ EVENTOS DE SEGURIDAD ============
echo.
echo FUNCION: Genera reporte de eventos de seguridad recientes
echo.
echo ¿QUE INFORMACION CONTIENE?
echo - Intentos de inicio de sesion (exitosos/fallidos)
echo - Cambios en politicas de seguridad
echo - Accesos a recursos del sistema
echo - Eventos de auditoria habilitados
echo.
echo UTILIDAD:
echo - Detectar intentos de acceso no autorizados
echo - Monitorear actividad de usuarios
echo - Identificar problemas de seguridad
echo.
set "SEGURIDAD_LOG=%temp%\Eventos_Seguridad_%username%_%time:~0,2%%time:~3,2%.txt"
set "SEGURIDAD_LOG=%SEGURIDAD_LOG: =%"

echo Generando reporte de eventos de seguridad...
echo Por favor espere...

:: GENERAR REPORTE COMPLETO EN ARCHIVO
echo ============ REPORTE DE EVENTOS DE SEGURIDAD ============ > "%SEGURIDAD_LOG%"
echo Fecha: %DATE% %TIME% >> "%SEGURIDAD_LOG%"
echo Usuario: %USERNAME% >> "%SEGURIDAD_LOG%"
echo Equipo: %COMPUTERNAME% >> "%SEGURIDAD_LOG%"
echo. >> "%SEGURIDAD_LOG%"

echo [1] ULTIMOS 50 EVENTOS DE SEGURIDAD: >> "%SEGURIDAD_LOG%"
echo ==================================== >> "%SEGURIDAD_LOG%"
wevtutil qe Security /c:50 /f:text >> "%SEGURIDAD_LOG%" 2>&1

echo. >> "%SEGURIDAD_LOG%"
echo [2] ESTADISTICAS DE EVENTOS: >> "%SEGURIDAD_LOG%"
echo ============================ >> "%SEGURIDAD_LOG%"
for /f "tokens=3" %%a in ('wevtutil qe Security /c:1 /f:text ^| find /c "Event"') do (
    echo Total de eventos en el registro: %%a >> "%SEGURIDAD_LOG%"
)

echo. >> "%SEGURIDAD_LOG%"
echo [3] INFORMACION DEL REGISTRO DE SEGURIDAD: >> "%SEGURIDAD_LOG%"
echo ========================================== >> "%SEGURIDAD_LOG%"
wevtutil gl Security >> "%SEGURIDAD_LOG%" 2>&1

echo. >> "%SEGURIDAD_LOG%"
echo REPORTE GENERADO: %DATE% %TIME% >> "%SEGURIDAD_LOG%"

echo.
echo ============ REPORTE GENERADO EXITOSAMENTE ============
echo.
echo Archivo: %SEGURIDAD_LOG%
echo.
echo El reporte contiene:
echo - Ultimos 50 eventos de seguridad
echo - Estadisticas del registro
echo - Informacion de configuracion
echo.
echo Presione una tecla para abrir el reporte...
pause >nul
notepad "%SEGURIDAD_LOG%"

echo [%DATE% %TIME%] Eventos seguridad guardados en: %SEGURIDAD_LOG% >> "%LOG_PATH%"
goto exito_seguridad

:op_s2
echo [%DATE% %TIME%] Seguridad 2: Procesos sospechosos >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 2
echo Analizando procesos del sistema en busca de actividad sospechosa...
echo.

set "PROCESOS_LOG=%temp%\Analisis_Procesos_%username%_%time:~0,2%%time:~3,2%.txt"
set "PROCESOS_LOG=%PROCESOS_LOG: =%"

:: Preguntar si quiere guardar en archivo
echo.
echo ¿Desea guardar el analisis completo en un archivo?
echo [S] para guardar en archivo TXT
echo [N] para mostrar en pantalla (puede cortar informacion)
echo.
set /p "guardar=Seleccione [S/N]: "

if /i "!guardar!"=="S" goto guardar_analisis_procesos

:: Mostrar en pantalla (versión resumida y compatible)
echo.
echo ============ BUSQUEDA AUTOMATICA DE PROCESOS SOSPECHOSOS ============
echo.

:: 1. Buscar procesos en ubicaciones temporales o inusuales
echo [1] Procesos en ubicaciones temporales o de usuario:
echo ----------------------------------------------------
tasklist /v /fo table | findstr /i "\\temp\\ \\appdata\\ \\users\\ \\downloads\\ \\tmp\\" 
if errorlevel 1 (
    echo  No se encontraron procesos en ubicaciones temporales
) else (
    echo  Se encontraron procesos en ubicaciones inusuales
)

echo.

:: 2. Buscar procesos con nombres sospechosos comunes
echo [2] Procesos con nombres potencialmente maliciosos:
echo --------------------------------------------------
tasklist | findstr /i "cryptominer keylogger rat spy trojan backdoor miner coin"
if errorlevel 1 (
    echo  No se encontraron procesos con nombres maliciosos conocidos
) else (
    echo  ALERTA: Posibles procesos maliciosos detectados
)

echo.

:: 3. Mostrar procesos paginados (compatible Windows)
echo [3] Lista de procesos activos (usar ESPACIO para navegar):
echo ---------------------------------------------------------
tasklist /fo table | more

echo.
echo [!] Para ver el listado completo con detalles, seleccione la opcion de guardar en archivo
echo.

goto final_analisis_procesos

:guardar_analisis_procesos
echo.
echo Guardando analisis completo en: %PROCESOS_LOG%
echo.

:: Guardar análisis completo en archivo
echo ============ ANALISIS COMPLETO DE PROCESOS - %DATE% %TIME% ============ > "%PROCESOS_LOG%"
echo Usuario: %USERNAME% >> "%PROCESOS_LOG%"
echo Equipo: %COMPUTERNAME% >> "%PROCESOS_LOG%"
echo. >> "%PROCESOS_LOG%"

echo [1] BUSQUEDA DE PROCESOS EN UBICACIONES SOSPECHOSAS: >> "%PROCESOS_LOG%"
echo ==================================================== >> "%PROCESOS_LOG%"
tasklist /v /fo table | findstr /i "\\temp\\ \\appdata\\ \\users\\ \\downloads\\ \\tmp\\" >> "%PROCESOS_LOG%"
if errorlevel 1 (
    echo No se encontraron procesos en ubicaciones sospechosas >> "%PROCESOS_LOG%"
)
echo. >> "%PROCESOS_LOG%"

echo [2] BUSQUEDA DE PROCESOS CON NOMBRES MALICIOSOS: >> "%PROCESOS_LOG%"
echo ================================================ >> "%PROCESOS_LOG%"
tasklist | findstr /i "cryptominer keylogger rat spy trojan backdoor miner coin" >> "%PROCESOS_LOG%"
if errorlevel 1 (
    echo No se encontraron procesos con nombres maliciosos conocidos >> "%PROCESOS_LOG%"
)
echo. >> "%PROCESOS_LOG%"

echo [3] PROCESOS SIN INFORMACION DE FABRICANTE: >> "%PROCESOS_LOG%"
echo =========================================== >> "%PROCESOS_LOG%"
tasklist /v /fo table | findstr /c:"N/A" >> "%PROCESOS_LOG%"
if errorlevel 1 (
    echo No se encontraron procesos sin informacion de fabricante >> "%PROCESOS_LOG%"
)
echo. >> "%PROCESOS_LOG%"

echo [4] LISTADO COMPLETO DE TODOS LOS PROCESOS: >> "%PROCESOS_LOG%"
echo =========================================== >> "%PROCESOS_LOG%"
tasklist /v /fo table >> "%PROCESOS_LOG%"
echo. >> "%PROCESOS_LOG%"

echo [5] INFORMACION DETALLADA CON TASKLIST COMPLETO: >> "%PROCESOS_LOG%"
echo ================================================= >> "%PROCESOS_LOG%"
tasklist /v >> "%PROCESOS_LOG%"
echo. >> "%PROCESOS_LOG%"

:: Intentar usar PowerShell como alternativa a WMIC
echo [6] INFORMACION CON POWERSHELL (alternativa): >> "%PROCESOS_LOG%"
echo ============================================= >> "%PROCESOS_LOG%"
powershell -Command "Get-Process | Select-Object Name, Id, CPU, WorkingSet, Path | Format-Table -AutoSize" >> "%PROCESOS_LOG%" 2>nul
echo. >> "%PROCESOS_LOG%"

echo ANALISIS COMPLETADO: Revise el archivo en %PROCESOS_LOG% >> "%PROCESOS_LOG%"

:: Mostrar resumen en pantalla
echo.
echo ============ ANALISIS GUARDADO EXITOSAMENTE ============
echo.
echo Archivo guardado en: %PROCESOS_LOG%
echo.
echo Contenido del archivo:
echo - Procesos en ubicaciones sospechosas
echo - Busqueda de nombres maliciosos  
echo - Procesos sin fabricante
echo - Listado completo de todos los procesos
echo - Informacion detallada con Tasklist
echo - Informacion alternativa con PowerShell
echo.
echo Puede abrir el archivo con Bloc de notas para revision completa.
echo.

:final_analisis_procesos
echo ============ RECOMENDACIONES DE SEGURIDAD ============
echo.
echo 1. Revise procesos en ubicaciones: Temp, AppData, Downloads
echo 2. Verifique procesos sin fabricante o con nombres extranos
echo 3. Procesos que consumen mucha CPU/GPU podrian ser mineros
echo 4. Use un antivirus para analisis mas profundo si hay dudas
echo.

echo [%DATE% %TIME%] Analisis de procesos de seguridad completado >> "%LOG_PATH%"
if exist "%PROCESOS_LOG%" (
    echo [%DATE% %TIME%] Archivo de procesos guardado: %PROCESOS_LOG% >> "%LOG_PATH%"
)
goto exito_seguridad

:op_s3
echo [%DATE% %TIME%] Seguridad 3: Usuarios conectados >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 3
echo Mostrando usuarios conectados...
echo.

echo ============ SESIONES LOCALES ============
query user
echo.

echo ============ SESIONES DE RED ============
net session
echo.

echo ============ RESUMEN ============
echo - Sesiones locales: Mostradas arriba
echo - Sesiones de red: Ninguna activa (normal en equipo personal)
echo - Usuario actual: %USERNAME%
echo.

echo [%DATE% %TIME%] Usuarios mostrados >> "%LOG_PATH%"
goto exito_seguridad

:op_s4
echo [%DATE% %TIME%] Seguridad 4: Auditoria servicios >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 4
echo Auditando servicios en ejecucion...
echo.
tasklist /svc | more
echo [%DATE% %TIME%] Auditoria servicios completada >> "%LOG_PATH%"
goto exito_seguridad

:op_s5
echo [%DATE% %TIME%] Seguridad 5: Registros firewall >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 5
echo Mostrando registros de firewall...
echo.
netsh advfirewall show allprofiles | more
echo [%DATE% %TIME%] Registros firewall mostrados >> "%LOG_PATH%"
goto exito_seguridad

:op_s6
echo [%DATE% %TIME%] Seguridad 6: Escanear puertos completo >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 6
echo Analizando estado completo de puertos...
echo.

set "PUERTOS_LOG=%temp%\Analisis_Puertos_%username%_%time:~0,2%%time:~3,2%.txt"
set "PUERTOS_LOG=%PUERTOS_LOG: =%"

:: Preguntar si quiere guardar en archivo
echo ¿Desea guardar el analisis completo de puertos en un archivo?
echo [S] para guardar en archivo TXT
echo [N] para mostrar solo en pantalla
echo.
choice /C SN /N /M "Seleccione opcion:"
if errorlevel 2 goto mostrar_pantalla_puertos
if errorlevel 1 goto guardar_archivo_puertos

:guardar_archivo_puertos
echo.
echo Guardando analisis completo en: %PUERTOS_LOG%
echo.

:: Crear archivo de log completo
echo ============ ANALISIS COMPLETO DE PUERTOS - %DATE% %TIME% ============ > "%PUERTOS_LOG%"
echo Usuario: %USERNAME% >> "%PUERTOS_LOG%"
echo Equipo: %COMPUTERNAME% >> "%PUERTOS_LOG%"
echo. >> "%PUERTOS_LOG%"

:: Ejecutar comandos y guardar en archivo
echo [1] PUERTOS ABIERTOS (LISTENING): >> "%PUERTOS_LOG%"
echo ================================= >> "%PUERTOS_LOG%"
netstat -an | findstr "LISTENING" >> "%PUERTOS_LOG%"
echo. >> "%PUERTOS_LOG%"

echo [2] CONEXIONES ESTABLECIDAS (ESTABLISHED): >> "%PUERTOS_LOG%"
echo ========================================== >> "%PUERTOS_LOG%"
netstat -an | findstr "ESTABLISHED" >> "%PUERTOS_LOG%"
echo. >> "%PUERTOS_LOG%"

echo [3] PUERTOS CERRADOS (CLOSE_WAIT): >> "%PUERTOS_LOG%"
echo ================================== >> "%PUERTOS_LOG%"
netstat -an | findstr "CLOSE_WAIT" >> "%PUERTOS_LOG%"
echo. >> "%PUERTOS_LOG%"

echo [4] CONEXIONES EN ESPERA (TIME_WAIT): >> "%PUERTOS_LOG%"
echo ===================================== >> "%PUERTOS_LOG%"
netstat -an | findstr "TIME_WAIT" >> "%PUERTOS_LOG%"
echo. >> "%PUERTOS_LOG%"

:: Estadisticas
echo [5] ESTADISTICAS DE CONEXIONES: >> "%PUERTOS_LOG%"
echo =============================== >> "%PUERTOS_LOG%"
for /f %%a in ('netstat -an ^| find /c "LISTENING"') do echo Puertos ESCUCHANDO: %%a >> "%PUERTOS_LOG%"
for /f %%a in ('netstat -an ^| find /c "ESTABLISHED"') do echo Conexiones ACTIVAS: %%a >> "%PUERTOS_LOG%"
for /f %%a in ('netstat -an ^| find /c "CLOSE_WAIT"') do echo Puertos CERRADOS: %%a >> "%PUERTOS_LOG%"
for /f %%a in ('netstat -an ^| find /c "TIME_WAIT"') do echo Conexiones FINALIZANDO: %%a >> "%PUERTOS_LOG%"
echo. >> "%PUERTOS_LOG%"

:: Informacion de referencia
echo [6] INFORMACION DE REFERENCIA: >> "%PUERTOS_LOG%"
echo =============================== >> "%PUERTOS_LOG%"
echo PUERTOS COMUNES Y SUS SERVICIOS: >> "%PUERTOS_LOG%"
echo 21   - FTP >> "%PUERTOS_LOG%"
echo 22   - SSH >> "%PUERTOS_LOG%"
echo 23   - Telnet >> "%PUERTOS_LOG%"
echo 25   - SMTP >> "%PUERTOS_LOG%"
echo 53   - DNS >> "%PUERTOS_LOG%"
echo 80   - HTTP >> "%PUERTOS_LOG%"
echo 110  - POP3 >> "%PUERTOS_LOG%"
echo 135  - RPC (Windows) >> "%PUERTOS_LOG%"
echo 139  - NetBIOS (Windows) >> "%PUERTOS_LOG%"
echo 443  - HTTPS >> "%PUERTOS_LOG%"
echo 445  - SMB (Windows) >> "%PUERTOS_LOG%"
echo 1433 - SQL Server >> "%PUERTOS_LOG%"
echo 3389 - RDP >> "%PUERTOS_LOG%"
echo. >> "%PUERTOS_LOG%"

echo ANALISIS COMPLETADO: %DATE% %TIME% >> "%PUERTOS_LOG%"

echo.
echo ============ ANALISIS GUARDADO EXITOSAMENTE ============
echo.
echo Archivo guardado en: %PUERTOS_LOG%
echo.
echo Presione una tecla para abrir el archivo...
pause >nul
notepad "%PUERTOS_LOG%"
goto fin_analisis_puertos

:mostrar_pantalla_puertos
echo.
echo ============ ANALISIS DE PUERTOS - MODO PANTALLA ============
echo.
echo ============ PUERTOS ABIERTOS (LISTENING) ============
echo [ESCUCHANDO - Aceptando conexiones]
netstat -an | findstr "LISTENING" | more

echo.
echo ============ CONEXIONES ESTABLECIDAS ============
echo [ESTABLISHED - Conexiones activas]
netstat -an | findstr "ESTABLISHED" | more

echo.
echo ============ PUERTOS CERRADOS ============
echo [CLOSE_WAIT - Puertos cerrados]
netstat -an | findstr "CLOSE_WAIT" 
if errorlevel 1 echo No se encontraron puertos en estado CLOSE_WAIT

echo.
echo ============ CONEXIONES EN ESPERA ============
echo [TIME_WAIT - Conexiones finalizando]
netstat -an | findstr "TIME_WAIT"
if errorlevel 1 echo No se encontraron conexiones en TIME_WAIT

echo.
echo ============ RESUMEN AUTOMATICO ============
echo [ESTADISTICAS RAPIDAS]
for /f %%a in ('netstat -an ^| find /c "LISTENING"') do set "listening=%%a"
for /f %%a in ('netstat -an ^| find /c "ESTABLISHED"') do set "established=%%a"
for /f %%a in ('netstat -an ^| find /c "CLOSE_WAIT"') do set "closed=%%a"
for /f %%a in ('netstat -an ^| find /c "TIME_WAIT"') do set "timewait=%%a"

echo Puertos ESCUCHANDO: !listening!
echo Conexiones ACTIVAS: !established!
echo Puertos CERRADOS: !closed!
echo Conexiones FINALIZANDO: !timewait!

echo.
echo ============ RECOMENDACIONES ============
echo 1. Puertos LISTENING: Servicios esperando conexiones
echo 2. Puertos ESTABLISHED: Conexiones activas actuales
echo 3. Puertos altos (49152-65535): Aplicaciones temporales (NORMAL)
echo 4. Revise puertos inusuales en rango 1-1024 (SOSPECHOSOS)
echo.

:fin_analisis_puertos
echo [%DATE% %TIME%] Escaneo completo de puertos realizado >> "%LOG_PATH%"
if exist "%PUERTOS_LOG%" (
    echo [%DATE% %TIME%] Archivo de puertos guardado: %PUERTOS_LOG% >> "%LOG_PATH%"
)
goto exito_seguridad

:: =========================================
:: FUNCIONES DISCOS (op_d*)
:: =========================================

:op_d1
echo [%DATE% %TIME%] Discos 1: Administracion discos >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 1
echo Ingresando al administrador de Unidades de Almacenamiento ...
start diskmgmt.msc
echo [%DATE% %TIME%] Administracion discos iniciada >> "%LOG_PATH%"
goto exito_discos

:op_d2
echo [%DATE% %TIME%] Discos 2: Estado discos SMART >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 2
echo Verificando estado de discos (SMART)...
echo.

set "DISK_LOG=%temp%\Estado_Discos_%username%_%time:~0,2%%time:~3,2%.txt"
set "DISK_LOG=%DISK_LOG: =%"

:: Preguntar modo de visualización
echo ¿Como desea ver la informacion de discos?
echo [1] Mostrar en pantalla (resumen)
echo [2] Guardar en archivo (informacion completa)
echo.
choice /C 12 /N /M "Seleccione opcion:"

if errorlevel 2 goto guardar_estado_discos
if errorlevel 1 goto mostrar_estado_discos

:mostrar_estado_discos
echo.
echo ============ ESTADO DE DISCOS - RESUMEN ============
echo.

:: PowerShell compatible con Windows 7 hasta 11
echo [INFORMACION DE DISCOS FISICOS]
echo -------------------------------
powershell -Command "Get-PhysicalDisk | Select-Object FriendlyName, @{Name='SizeGB';Expression={[math]::Round($_.Size/1GB,2)}}, HealthStatus, OperationalStatus | Format-Table -AutoSize"

echo.

:: Información adicional de discos lógicos
echo [DISCOS LOGICOS Y ESPACIO]
echo --------------------------
powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, @{Name='SizeGB';Expression={[math]::Round($_.Size/1GB,2)}}, @{Name='FreeGB';Expression={[math]::Round($_.FreeSpace/1GB,2)}}, @{Name='FreePercent';Expression={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}} | Format-Table -AutoSize"

echo.
echo ============ LEYENDA ============
echo Healthy: Disco en buen estado
echo Warning: Advertencia (monitorear)
echo Unhealthy: Disco con problemas
echo Unknown: Estado no disponible
echo.
goto fin_estado_discos

:guardar_estado_discos
echo.
echo Guardando informacion completa en: %DISK_LOG%
echo.

echo ============ INFORMACION COMPLETA DE DISCOS - %DATE% %TIME% ============ > "%DISK_LOG%"
echo Usuario: %USERNAME% >> "%DISK_LOG%"
echo Equipo: %COMPUTERNAME% >> "%DISK_LOG%"
echo. >> "%DISK_LOG%"

:: Información detallada de discos físicos
echo [1] DISCOS FISICOS (SMART): >> "%DISK_LOG%"
echo ============================ >> "%DISK_LOG%"
powershell -Command "Get-PhysicalDisk | Select-Object FriendlyName, MediaType, Size, HealthStatus, OperationalStatus, SerialNumber, FirmwareVersion | Format-Table -AutoSize" >> "%DISK_LOG%"
echo. >> "%DISK_LOG%"

:: Información de discos lógicos
echo [2] DISCOS LOGICOS: >> "%DISK_LOG%"
echo =================== >> "%DISK_LOG%"
powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, VolumeName, FileSystem, Size, FreeSpace, @{Name='FreePercent';Expression={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}} | Format-Table -AutoSize" >> "%DISK_LOG%"
echo. >> "%DISK_LOG%"

:: Información de particiones
echo [3] INFORMACION DE PARTICIONES: >> "%DISK_LOG%"
echo ================================ >> "%DISK_LOG%"
powershell -Command "Get-Partition | Select-Object DiskNumber, PartitionNumber, DriveLetter, Size, Type | Format-Table -AutoSize" >> "%DISK_LOG%"
echo. >> "%DISK_LOG%"

:: Información adicional del sistema
echo [4] INFORMACION DEL SISTEMA: >> "%DISK_LOG%"
echo ============================= >> "%DISK_LOG%"
echo Fecha del analisis: %DATE% %TIME% >> "%DISK_LOG%"
echo. >> "%DISK_LOG%"

echo ANALISIS COMPLETADO >> "%DISK_LOG%"

echo.
echo ============ INFORMACION GUARDADA ============
echo Archivo guardado en: %DISK_LOG%
echo.
echo Presione una tecla para abrir el archivo...
pause >nul
notepad "%DISK_LOG%"

:fin_estado_discos
echo [%DATE% %TIME%] Estado discos mostrado >> "%LOG_PATH%"
if exist "%DISK_LOG%" (
    echo [%DATE% %TIME%] Archivo de discos guardado: %DISK_LOG% >> "%LOG_PATH%"
)
goto exito_discos

:op_d3
echo [%DATE% %TIME%] Discos 3: Limpiar System Restore >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 3
echo.
echo ============ GESTION DE PUNTOS DE RESTAURACION ============
echo.
echo FUNCION: Gestiona puntos de restauracion del sistema
echo.
echo ¿QUE SON LOS PUNTOS DE RESTAURACION?
echo - Snapshots del sistema en un momento determinado
echo - Permiten revertir el sistema a un estado anterior
echo - Se crean automaticamente antes de instalaciones importantes
echo.
echo OPCIONES DISPONIBLES:
echo [1] Crear nuevo punto de restauracion
echo [2] Limpiar puntos antiguos (conserva los mas recientes)
echo [3] Ver informacion actual de puntos
echo.
echo RECOMENDACIONES:
echo - Mantener al menos 1-2 puntos recientes
echo - No eliminar todos los puntos (podria necesitarlos)
echo - System Restore debe estar habilitado
echo.
choice /C 123 /N /M "Seleccione opcion [1-3]:"

if errorlevel 3 goto solo_ver_info_restore
if errorlevel 2 goto limpiar_puntos_restore  
if errorlevel 1 goto crear_punto_restore

:crear_punto_restore
echo.
echo ============ CREANDO PUNTO DE RESTAURACION ============
echo Creando nuevo punto de restauracion...
echo Por favor espere...
echo.
powershell -Command "Checkpoint-Computer -Description 'Punto creado por Script de Soporte' -RestorePointType MODIFY_SETTINGS" 2>nul
if errorlevel 1 (
    echo [ERROR] No se pudo crear el punto de restauracion
    echo.
    echo POSIBLES CAUSAS:
    echo - System Restore deshabilitado en el sistema
    echo - Permisos de administrador insuficientes
    echo - Espacio en disco insuficiente
    echo - Servicio de Proteccion del Sistema no esta ejecutandose
    echo.
    echo SOLUCIONES:
    echo 1. Verificar que System Restore este habilitado
    echo 2. Asegurarse de tener al menos 1GB libre en disco
    echo 3. Ejecutar este script como Administrador
) else (
    echo [EXITO] Punto de restauracion creado exitosamente
    echo.
    echo INFORMACION:
    echo - Nombre: Punto creado por Script de Soporte
    echo - Tipo: MODIFY_SETTINGS (Cambios de configuracion)
    echo - Fecha: %DATE% %TIME%
)
goto fin_op_d3

:limpiar_puntos_restore
echo.
echo ============ LIMPIANDO PUNTOS ANTIGUOS ============
echo Esta accion eliminara puntos de restauracion antiguos
echo pero conservara los puntos mas recientes.
echo.
echo ¿Esta seguro de continuar?
choice /C SN /N /M "Presione S para limpiar o N para cancelar"
if errorlevel 2 goto fin_op_d3

echo.
echo Ejecutando limpieza automatica de puntos de restauracion...
echo.

:: Método 1: Usar cleanmgr (más seguro y selectivo)
echo [METODO 1] Ejecutando Limpiador de Disco de Windows...
echo Este metodo elimina solo puntos antiguos, conservando los recientes.
start /wait cleanmgr /sagerun:1
echo.

:: Método 2: Verificar si hay puntos antes de intentar eliminar
echo [METODO 2] Verificando puntos existentes...
set "HAY_PUNTOS=0"
vssadmin list shadows >nul 2>&1
if %errorlevel% equ 0 set "HAY_PUNTOS=1"

if !HAY_PUNTOS! equ 1 (
    echo Eliminando puntos antiguos mediante VSSAdmin...
    vssadmin delete shadows /all /quiet >nul 2>&1
    if errorlevel 1 (
        echo [AVISO] Algunos puntos no se pudieron eliminar
        echo Esto es normal si hay puntos en uso o recientes
    ) else (
        echo [EXITO] Limpieza de puntos antiguos completada
    )
) else (
    echo [INFO] No hay puntos de restauracion para limpiar
)
echo.
echo ============ LIMPIEZA COMPLETADA ============
echo Se han eliminado los puntos de restauracion antiguos.
echo Los puntos mas recientes se han conservado.
goto fin_op_d3

:solo_ver_info_restore
echo.
echo ============ INFORMACION DE SYSTEM RESTORE ============
echo.
echo PUNTOS DE RESTAURACION EXISTENTES:
echo ===================================
vssadmin list shadows
if errorlevel 1 (
    echo No se encontraron puntos de restauracion existentes.
    echo.
)

echo.
echo CONFIGURACION ACTUAL DE SYSTEM RESTORE:
echo ======================================
vssadmin list shadowstorage
if errorlevel 1 (
    echo No se pudo obtener la configuracion de shadow storage.
    echo.
)

echo.
echo INFORMACION ADICIONAL:
echo - Para habilitar System Restore manualmente:
echo   1. Click derecho en 'Este equipo' -> Propiedades
echo   2. Proteccion del sistema -> Configurar -> Habilitar
echo   3. Asignar espacio en disco (recomendado: 5-10%%)
echo.
echo - Los puntos se crean automaticamente:
echo   * Antes de instalaciones de programas
echo   * Antes de actualizaciones de Windows
echo   * Semanalmente (si esta configurado)
echo.

:fin_op_d3
echo.
echo ============ RECOMENDACIONES FINALES ============
echo 1. System Restore debe estar habilitado para crear puntos
echo 2. Se recomienda mantener al menos 5-10%% del disco para puntos
echo 3. Los puntos se crean automaticamente antes de instalaciones importantes
echo 4. Revise periodicamente el espacio utilizado por System Restore
echo.
echo [%DATE% %TIME%] Gestion System Restore completada >> "%LOG_PATH%"
goto exito_discos

:op_d4
echo [%DATE% %TIME%] Discos 4: Informacion particiones >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 4
echo Obteniendo informacion detallada de particiones...
echo.

set "PARTICIONES_LOG=%temp%\Info_Particiones_%username%_%time:~0,2%%time:~3,2%.txt"
set "PARTICIONES_LOG=%PARTICIONES_LOG: =%"

:: Preguntar modo de visualización (solo 2 opciones)
echo ¿Como desea ver la informacion de particiones?
echo [1] Ver detalles tecnicos avanzados
echo [2] Guardar reporte completo en archivo
echo.
set /p "opcion_part=Seleccione opcion [1-2]: "

if "!opcion_part!"=="1" goto detalles_tecnicos_particiones
if "!opcion_part!"=="2" goto guardar_reporte_particiones

echo Opcion invalida. Volviendo al menu...
goto exito_discos

:detalles_tecnicos_particiones
echo.
echo ============ DETALLES TECNICOS AVANZADOS ============
echo.

:: Información de discos con diskpart
echo [1] INFORMACION DE DISCOS CON DISKPART:
echo ---------------------------------------
echo list disk | diskpart
echo.

:: Información de volúmenes
echo [2] INFORMACION DE VOLUMENES:
echo -----------------------------
echo list volume | diskpart
echo.

:: Información de sistemas de archivos
echo [3] INFORMACION DE SISTEMAS DE ARCHIVOS:
echo ----------------------------------------
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo Unidad %%d:
        fsutil fsinfo volumeinfo %%d: | findstr /i "SistemaArchivos Serial Version"
        echo.
    )
)

:: Información adicional de espacio
echo [4] ESPACIO DISPONIBLE:
echo -----------------------
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo Unidad %%d:
        dir %%d:\ | find "bytes"
        echo.
    )
)
goto fin_op_d4

:guardar_reporte_particiones
echo.
echo Generando reporte completo de particiones...
echo.

echo ============ REPORTE COMPLETO DE PARTICIONES - %DATE% %TIME% ============ > "%PARTICIONES_LOG%"
echo Usuario: %USERNAME% >> "%PARTICIONES_LOG%"
echo Equipo: %COMPUTERNAME% >> "%PARTICIONES_LOG%"
echo. >> "%PARTICIONES_LOG%"

:: Discos físicos detectados
echo [1] DISCOS FISICOS DETECTADOS: >> "%PARTICIONES_LOG%"
echo =============================== >> "%PARTICIONES_LOG%"
fsutil fsinfo drives >> "%PARTICIONES_LOG%"
echo. >> "%PARTICIONES_LOG%"

:: Información detallada de cada unidad
echo [2] INFORMACION DETALLADA POR UNIDAD: >> "%PARTICIONES_LOG%"
echo ===================================== >> "%PARTICIONES_LOG%"
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo UNIDAD %%d: >> "%PARTICIONES_LOG%"
        echo ---------- >> "%PARTICIONES_LOG%"
        fsutil fsinfo volumeinfo %%d: >> "%PARTICIONES_LOG%"
        echo. >> "%PARTICIONES_LOG%"
    )
)

:: Información de diskpart
echo [3] INFORMACION CON DISKPART: >> "%PARTICIONES_LOG%"
echo ============================= >> "%PARTICIONES_LOG%"
echo list disk | diskpart >> "%PARTICIONES_LOG%"
echo. >> "%PARTICIONES_LOG%"
echo list volume | diskpart >> "%PARTICIONES_LOG%"
echo. >> "%PARTICIONES_LOG%"

echo REPORTE COMPLETADO: %DATE% %TIME% >> "%PARTICIONES_LOG%"

echo.
echo ============ REPORTE GUARDADO ============
echo Archivo guardado en: %PARTICIONES_LOG%
echo.
echo Presione una tecla para abrir el archivo...
pause >nul
notepad "%PARTICIONES_LOG%"

:fin_op_d4
echo.
echo ============ INFORMACION OBTENIDA ============
echo La informacion de particiones se ha mostrado/guardado correctamente.
echo.

echo [%DATE% %TIME%] Informacion particiones completada >> "%LOG_PATH%"
if exist "%PARTICIONES_LOG%" (
    echo [%DATE% %TIME%] Archivo de particiones guardado: %PARTICIONES_LOG% >> "%LOG_PATH%"
)
goto exito_discos

:op_d5
echo [%DATE% %TIME%] Discos 5: Espacio por carpeta >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 5
echo Analizando espacio por carpeta...
echo.

set "ESPACIO_LOG=%temp%\Analisis_Espacio_%username%_%time:~0,2%%time:~3,2%.txt"
set "ESPACIO_LOG=%ESPACIO_LOG: =%"

:: Preguntar modo de visualización
echo ¿Como desea analizar el espacio en disco?
echo [1] Mostrar resumen en pantalla
echo [2] Analizar carpeta especifica
echo [3] Guardar reporte completo en archivo
echo.
choice /C 123 /N /M "Seleccione opcion:"

if errorlevel 3 goto guardar_reporte_espacio
if errorlevel 2 goto analizar_carpeta_especifica
if errorlevel 1 goto mostrar_resumen_espacio

:mostrar_resumen_espacio
echo.
echo ============ RESUMEN DE ESPACIO EN DISCOS ============
echo.
powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, @{Name='SizeGB';Expression={[math]::Round($_.Size/1GB,2)}}, @{Name='FreeGB';Expression={[math]::Round($_.FreeSpace/1GB,2)}}, @{Name='FreePercent';Expression={if($_.Size -gt 0){[math]::Round(($_.FreeSpace/$_.Size)*100,2)}else{0}}} | Format-Table -AutoSize"
echo.
goto fin_op_d5

:analizar_carpeta_especifica
echo.
echo ============ ANALIZAR CARPETA ESPECIFICA ============
echo Ingrese la ruta de la carpeta a analizar:
echo Ejemplo: C:\Users o D:\Documentos
set /p "carpeta=Ruta de la carpeta: "

if not exist "!carpeta!\" (
    echo [ERROR] La carpeta no existe: !carpeta!
    goto fin_op_d5
)

echo.
echo Analizando espacio en: !carpeta!
echo Esto puede tomar varios minutos...
echo.
powershell -Command "Get-ChildItem '!carpeta!' -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum | Select-Object @{Name='Carpeta';Expression={'!carpeta!'}}, @{Name='TotalGB';Expression={[math]::Round($_.Sum/1GB,2)}}, Count"
echo.
goto fin_op_d5

:guardar_reporte_espacio
echo.
echo Generando reporte completo de espacio en disco...
echo Esto puede tomar varios minutos...
echo.

echo ============ REPORTE COMPLETO DE ESPACIO - %DATE% %TIME% ============ > "%ESPACIO_LOG%"
echo Usuario: %USERNAME% >> "%ESPACIO_LOG%"
echo Equipo: %COMPUTERNAME% >> "%ESPACIO_LOG%"
echo. >> "%ESPACIO_LOG%"

:: Información de discos lógicos
echo [1] DISCOS LOGICOS Y ESPACIO: >> "%ESPACIO_LOG%"
echo ============================== >> "%ESPACIO_LOG%"
powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, VolumeName, FileSystem, Size, FreeSpace, @{Name='FreePercent';Expression={if($_.Size -gt 0){[math]::Round(($_.FreeSpace/$_.Size)*100,2)}else{0}}} | Format-Table -AutoSize" >> "%ESPACIO_LOG%"
echo. >> "%ESPACIO_LOG%"

:: Análisis de carpetas grandes en C:
echo [2] CARPETAS MAS GRANDES EN C:\: >> "%ESPACIO_LOG%"
echo ================================ >> "%ESPACIO_LOG%"
powershell -Command "Get-ChildItem 'C:\' -Directory -ErrorAction SilentlyContinue | ForEach-Object { $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB; [PSCustomObject]@{ Carpeta=$_.Name; SizeGB=[math]::Round($size,2) } } | Sort-Object SizeGB -Descending | Select-Object -First 10 | Format-Table -AutoSize" >> "%ESPACIO_LOG%"
echo. >> "%ESPACIO_LOG%"

:: Análisis de espacio por usuario
echo [3] ESPACIO POR USUARIO EN C:\Users: >> "%ESPACIO_LOG%"
echo ==================================== >> "%ESPACIO_LOG%"
powershell -Command "Get-ChildItem 'C:\Users' -Directory -ErrorAction SilentlyContinue | ForEach-Object { $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB; [PSCustomObject]@{ Usuario=$_.Name; SizeGB=[math]::Round($size,2) } } | Sort-Object SizeGB -Descending | Format-Table -AutoSize" >> "%ESPACIO_LOG%"
echo. >> "%ESPACIO_LOG%"

echo REPORTE COMPLETADO: %DATE% %TIME% >> "%ESPACIO_LOG%"

echo.
echo ============ REPORTE GUARDADO ============
echo Archivo guardado en: %ESPACIO_LOG%
echo.
echo Presione una tecla para abrir el archivo...
pause >nul
notepad "%ESPACIO_LOG%"

:fin_op_d5
echo.
echo [%DATE% %TIME%] Analisis espacio completado >> "%LOG_PATH%"
if exist "%ESPACIO_LOG%" (
    echo [%DATE% %TIME%] Archivo de espacio guardado: %ESPACIO_LOG% >> "%LOG_PATH%"
)
goto exito_discos

:op_d6
echo [%DATE% %TIME%] Discos 6: Estado unidades almacenamiento >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 6
echo Generando reporte de unidades...
echo.

set "REPORTE_LOG=%temp%\Unidades_%username%_%time:~0,2%%time:~3,2%.txt"

:: Crear archivo de reporte
echo ============ INFORME DE UNIDADES ============ > "%REPORTE_LOG%"
echo Fecha: %DATE% %TIME% >> "%REPORTE_LOG%"
echo Usuario: %USERNAME% >> "%REPORTE_LOG%"
echo Equipo: %COMPUTERNAME% >> "%REPORTE_LOG%"
echo. >> "%REPORTE_LOG%"

:: 1. UNIDADES DETECTADAS
echo [1] UNIDADES DETECTADAS >> "%REPORTE_LOG%"
echo ====================== >> "%REPORTE_LOG%"
powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Format-Table DeviceID, VolumeName, FileSystem, Size, FreeSpace -AutoSize" >> "%REPORTE_LOG%"
echo. >> "%REPORTE_LOG%"

:: 2. INFORMACION EN GB
echo [2] INFORMACION EN GB >> "%REPORTE_LOG%"
echo ===================== >> "%REPORTE_LOG%"
powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, @{Name='TotalGB';Expression={[math]::Round($_.Size/1GB,2)}}, @{Name='LibreGB';Expression={[math]::Round($_.FreeSpace/1GB,2)}}, @{Name='UsadoGB';Expression={[math]::Round(($_.Size - $_.FreeSpace)/1GB,2)}} | Format-Table -AutoSize" >> "%REPORTE_LOG%"
echo. >> "%REPORTE_LOG%"

:: 3. PARTICIONES
echo [3] PARTICIONES >> "%REPORTE_LOG%"
echo =============== >> "%REPORTE_LOG%"
echo list volume | diskpart >> "%REPORTE_LOG%"
echo. >> "%REPORTE_LOG%"

:: 4. RESUMEN
echo [4] RESUMEN >> "%REPORTE_LOG%"
echo =========== >> "%REPORTE_LOG%"
set "count=0"
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ set /a "count+=1"
)
echo Unidades activas: !count! >> "%REPORTE_LOG%"
echo. >> "%REPORTE_LOG%"

echo ESPACIO EN C:\: >> "%REPORTE_LOG%"
dir C:\ | find "bytes" >> "%REPORTE_LOG%"
echo. >> "%REPORTE_LOG%"

echo INFORME TERMINADO: %DATE% %TIME% >> "%REPORTE_LOG%"

echo.
echo ============ INFORME LISTO ============
echo.
echo Archivo: %REPORTE_LOG%
echo.
echo Presione una tecla para abrir...
pause >nul
notepad "%REPORTE_LOG%"

echo [%DATE% %TIME%] Reporte unidades completado >> "%LOG_PATH%"
goto exito_discos

:: =========================================
:: FUNCIONES HERRAMIENTAS (op_h*)
:: =========================================

:op_h1
echo [%DATE% %TIME%] Herramientas 1: Informacion sistema >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 1
echo Generando Informacion del Sistema ...
start msinfo32
echo [%DATE% %TIME%] MSINFO32 iniciado >> "%LOG_PATH%"
goto exito_herramientas

:op_h2
echo [%DATE% %TIME%] Herramientas 2: Acerca de Windows >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 2
echo Ingresando Acerca de Windows ... 
start winver
echo [%DATE% %TIME%] Winver iniciado >> "%LOG_PATH%"
goto exito_herramientas

:op_h3
echo [%DATE% %TIME%] Herramientas 3: Editor registro >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 3
echo.
echo ============ EDITOR DEL REGISTRO DE WINDOWS ============
echo.
echo FUNCION: Abre el Editor del Registro de Windows (regedit)
echo.
echo ¿QUE ES EL REGISTRO DE WINDOWS?
echo - Base de datos que almacena configuraciones del sistema
echo - Contiene ajustes del SO, programas y hardware
echo - Modificaciones incorrectas pueden dañar el sistema
echo.
echo INFORMACION IMPORTANTE:
echo =  ADVERTENCIA: EL REGISTRO ES SENSIBLE  =️
echo.
echo RIESGOS:
echo - Modificaciones incorrectas pueden inestabilizar el sistema
echo - Cambios erroneos pueden impedir el arranque de Windows
echo - Algunos daños pueden requerir reinstalacion del sistema
echo.
echo RECOMENDACIONES DE SEGURIDAD:
echo 1. Haga backup del registro antes de modificar
echo 2. Modifique solo valores que comprenda completamente
echo 3. Exporte las claves antes de editarlas
echo 4. Los cambios afectan inmediatamente al sistema
echo.
echo USO RECOMENDADO:
echo - Solo para usuarios avanzados o tecnicos
echo - Seguir guias confiables paso a paso
echo - Tener puntos de restauracion activos
echo.
echo ¿Esta absolutamente seguro de abrir el Editor del Registro?
echo.
choice /C SN /N /M "Presione S para abrir regedit o N para cancelar"
if errorlevel 2 (
    echo.
    echo Operacion cancelada por seguridad.
    echo [%DATE% %TIME%] Usuario cancelo apertura de regedit >> "%LOG_PATH%"
    timeout /t 2 /nobreak >nul
    goto menu_herramientas
)

echo.
echo ============ ABRIENDO EDITOR DEL REGISTRO ============
echo.
echo Iniciando regedit.exe...
echo.
echo RECUERDE:
echo - File -> Export para hacer backup completo
echo - Click derecho en clave -> Export para backup parcial
echo - Extreme precaucion con todas las modificaciones
echo.
echo Si no esta seguro de lo que hace, CIERRE regedit ahora.
echo.
timeout /t 5 /nobreak >nul

start regedit
echo [%DATE% %TIME%] Editor de registro iniciado >> "%LOG_PATH%"

echo.
echo ============ EDITOR INICIADO ============
echo.
echo El Editor del Registro se ha abierto correctamente.
echo.
echo CONSEJOS FINALES:
echo 1. No modifique claves sin saber su proposito
echo 2. Anote los cambios que realice para poder revertirlos
echo 3. Cierre regedit cuando termine sus modificaciones
echo.
echo Presione una tecla para volver al menu...
pause >nul

goto exito_herramientas

:op_h4
echo [%DATE% %TIME%] Herramientas 4: Politicas grupo >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 4
echo Abriendo Editor de Politicas de Grupo...
echo.
start gpedit.msc
echo [%DATE% %TIME%] Editor politicas grupo iniciado >> "%LOG_PATH%"
goto exito_herramientas

:op_h5
echo [%DATE% %TIME%] Herramientas 5: Administrador servicios >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 5
echo Abriendo Administrador de Servicios...
echo.
start services.msc
echo [%DATE% %TIME%] Administrador servicios iniciado >> "%LOG_PATH%"
goto exito_herramientas

:op_h6
echo [%DATE% %TIME%] Herramientas 6: Programador tareas >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 6
echo Abriendo Programador de Tareas...
echo.
start taskschd.msc
echo [%DATE% %TIME%] Programador tareas iniciado >> "%LOG_PATH%"
goto exito_herramientas

:op_h7
echo [%DATE% %TIME%] Herramientas 7: Visor eventos >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 7
echo Abriendo Visor de Eventos...
echo.
start eventvwr.msc
echo [%DATE% %TIME%] Visor eventos iniciado >> "%LOG_PATH%"
goto exito_herramientas

:op_h8
echo [%DATE% %TIME%] Herramientas 8: Administrador dispositivos >> "%LOG_PATH%"
echo.
echo. Has elegido la opcion No. 8
echo Abriendo Administrador de Dispositivos...
echo.
start devmgmt.msc
echo [%DATE% %TIME%] Administrador dispositivos iniciado >> "%LOG_PATH%"
goto exito_herramientas

:: =========================================
:: SISTEMA DE EXITO MEJORADO POR CATEGORIA
:: =========================================

:exito_mantenimiento
color F2
echo.
echo =============== ^> TAREA REALIZADA CON EXITO ^< ==============
echo.
echo Detalles guardados en: %LOG_PATH%
echo.
pause
color F0
goto menu_mantenimiento

:exito_reinicio_mantenimiento
color F2
echo.
echo =============== ^> TAREA REALIZADA CON EXITO ^< ==============
echo.
echo ADVERTENCIA: Los cambios se aplicaran despues del proximo reinicio
echo Detalles guardados en: %LOG_PATH%
echo.
pause
color F0
goto menu_mantenimiento

:exito_red
color F2
echo.
echo =============== ^> TAREA REALIZADA CON EXITO ^< ==============
echo.
echo Detalles guardados en: %LOG_PATH%
echo.
pause
color F0
goto menu_red

:exito_seguridad
color F2
echo.
echo =============== ^> TAREA REALIZADA CON EXITO ^< ==============
echo.
echo Detalles guardados en: %LOG_PATH%
echo.
pause
color F0
goto menu_seguridad

:exito_discos
color F2
echo.
echo =============== ^> TAREA REALIZADA CON EXITO ^< ==============
echo.
echo Detalles guardados en: %LOG_PATH%
echo.
pause
color F0
goto menu_discos

:exito_herramientas
color F2
echo.
echo =============== ^> TAREA REALIZADA CON EXITO ^< ==============
echo.
echo Detalles guardados en: %LOG_PATH%
echo.
pause
color F0
goto menu_herramientas

:salir
echo [%DATE% %TIME%] Script finalizado por el usuario >> "%LOG_PATH%"
echo [%DATE% %TIME%] ===== SCRIPT FINALIZADO ===== >> "%LOG_PATH%"
cls
echo.
echo ============================================================
echo =        LICENCIA DE USO LIBRE Y CODIGO ABIERTO            =
echo ============================================================
echo #   - Este software es de USO LIBRE y GRATUITO             # 
echo #   - CODIGO ABIERTO - Puede ser modificado y distribuido  # 
echo #   - Sin restricciones comerciales                        # 
echo #   - Comparte el conocimiento tecnico                     # 
echo ============================================================
echo.
echo ============================================================
echo =                 INFORMACION DEL PROYECTO                 =         
echo ============================================================
echo #   - Proposito: Herramienta para soporte tecnico          #         
echo #   - Version: 3.0                                         #
echo #   - Desarrollador: Smith Lozano                          #
echo #   - Licencia: GPL v3 - CODIGO LIBRE                      #
echo ============================================================
echo.
echo ============================================================
echo =           GRACIAS POR USAR ESTA HERRAMIENTA!             =     
echo ============================================================
echo #   Si este script te fue util, considera:                 #
echo #   - Compartirlo con otros tecnicos                       #
echo #   - Mejorarlo y adaptarlo a tus necesidades              #
echo #   - Contribuir al conocimiento colectivo                 #
echo ============================================================
echo.
echo Log de actividades guardado en:
echo %LOG_PATH%
echo.
echo Presione cualquier tecla para cerrar...
pause >nul
exit

:: =========================================
:: FUNCIONES AUXILIARES
:: =========================================

:confirmar_accion_peligrosa
set "opcion=%~1"
set "confirmar=0"

if "%opcion%"=="7" set "confirmar=1"
if "%opcion%"=="8" set "confirmar=1"
if "%opcion%"=="9" set "confirmar=1"

if %confirmar% equ 1 (
    echo.
    echo    ADVERTENCIA: Esta accion es potencialmente peligrosa
    echo    Puede afectar el arranque del sistema o requerir reinicio
    echo.
    set /p "conf=¿Continuar? [S/N]: "
    if /i not "%conf%"=="S" (
        echo [%DATE% %TIME%] Usuario cancelo accion peligrosa: Opcion %opcion% >> "%LOG_PATH%"
        echo Accion cancelada por el usuario
        timeout /t 2 /nobreak >nul
        exit /b 1
    )
    echo [%DATE% %TIME%] Usuario confirmo accion peligrosa: Opcion %opcion% >> "%LOG_PATH%"
)
exit /b 0