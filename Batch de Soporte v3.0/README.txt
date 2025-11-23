DESCRIPCION GENERAL
Script batch integral para mantenimiento, diagnóstico y administración de sistemas Windows. 
Desarrollado específicamente para técnicos de soporte con funcionalidades avanzadas y modo seguro integrado.

DESARROLLADOR
Smith Lozano
Version: 3.0
Categoria: Herramientas de Soporte Técnico

CARACTERISTICAS PRINCIPALES

SISTEMA DE SEGURIDAD
- Autenticación con contraseña: Contraseña predeterminada: soporte
- Detección automática de Modo Seguro: Acceso directo sin autenticación
- Auto-elevación de privilegios: Solicita automáticamente permisos de administrador
- Logging completo: Registro detallado de todas las operaciones

ESTRUCTURA MODULAR
5 categorías principales organizadas en menús

MENU PRINCIPAL

1. MANTENIMIENTO DEL SISTEMA
[1]  Eliminar Archivos Temporales del Sistema Operativo
[2]  Eliminar Archivos Temporales del Perfil Local del Usuario
[3]  Eliminar Archivos Caches de Programas y Aplicaciones
[4]  Liberar Espacio en la Unidad de Almacenamiento [HDD]
[5]  Desfragmentar Sistema Operativo [Aplica Solo Para Discos Duros]
[6]  Diagnosticar Memoria RAM [Se Ejecuta desde el Arranque]
[7]  Comprobar Y Reparar Errores Logicos en la Unidad De Almacenamiento
[8]  Entrar en Modo Seguro Sin Funciones de Red [LAN-WiFi]
[9]  Entrar en Modo Seguro Con Funciones de Red [LAN]
[10] Salir de Modo Seguro [Inicia Windows Normalmente]
[11] Reparar archivos de sistema (SFC Scan)

2. RED Y CONECTIVIDAD
[1]  Eliminar Caches DNS [Registros del Dominio]
[2]  Liberar Dirección IP [DHCP]
[3]  Renovar Dirección IP [DHCP]
[4]  Dirección Física [Adaptadores de RED]
[5]  Información Detallada [Adaptadores de RED]
[6]  Diagnosticar conexión a Internet
[7]  Resetear configuración de red completa
[8]  Ver estadísticas de red
[9]  Probar conectividad a servidores DNS

3. SEGURIDAD Y AUDITORIA
[1]  Ver eventos de seguridad recientes
[2]  Listar procesos sospechosos
[3]  Ver usuarios conectados
[4]  Auditoría de servicios ejecutándose
[5]  Ver registros de firewall
[6]  Escanear puertos abiertos

4. DISCOS Y ALMACENAMIENTO
[1]  Administración de Discos Duros
[2]  Ver estado de discos (SMART)
[3]  Limpiar System Restore (solo puntos antiguos)
[4]  Ver información detallada de particiones y sistemas de archivos
[5]  Ver espacio detallado por carpeta
[6]  Analizar uso de espacio en disco

5. HERRAMIENTAS AVANZADAS
[1]  Información del Sistema
[2]  Acerca de Windows
[3]  Editor de registro rápido
[4]  Editor de políticas de grupo
[5]  Administrador de servicios
[6]  Programador de tareas
[7]  Visor de eventos
[8]  Administrador de dispositivos

FUNCIONALIDADES DESTACADAS

DIAGNOSTICO AVANZADO
- Internet completo: Pruebas de ping a múltiples servidores DNS
- DNS extendido: Análisis de resolución y conectividad
- Procesos sospechosos: Detección de malware y actividades inusuales
- Puertos abiertos: Escaneo completo de conexiones de red

MODO SEGURO INTEGRADO
- Detección automática: Reconoce cuando Windows está en modo seguro
- Acceso directo: Sin necesidad de autenticación en modo seguro
- Configuración boot: Opciones para entrar/salir del modo seguro

GESTION DE ARCHIVOS TEMPORALES
- Limpieza selectiva: Temporales del sistema, usuario y programas
- Conteo preciso: Muestra archivos eliminados y fallidos
- Manejo seguro: No elimina archivos críticos del sistema

HERRAMIENTAS DEL SISTEMA
- Acceso rápido: Todas las herramientas administrativas de Windows
- Interfaz unificada: Menú centralizado para técnicos
- Logging automático: Registro de todas las actividades

ESTRUCTURA DE ARCHIVOS

ARCHIVOS DE LOG GENERADOS
%temp%\Soporte_Tecnico_[usuario]_[fecha]_[hora].log  -> Log principal
%temp%\Diagnostico_Internet_[hora].txt              -> Diagnóstico red
%temp%\Pruebas_DNS_[hora].txt                       -> Pruebas DNS
%temp%\Eventos_Seguridad_[hora].txt                 -> Auditoría seguridad
%temp%\Analisis_Procesos_[hora].txt                 -> Procesos sospechosos
%temp%\Estado_Discos_[hora].txt                     -> Estado discos

CARACTERISTICAS DE SEGURIDAD

MEDIDAS IMPLEMENTADAS
- Validación de entrada: Prevención de inyección de comandos
- Confirmación para acciones peligrosas: Modo seguro, CHKDSK, etc.
- Logging completo: Auditoría de todas las operaciones
- Manejo de errores: Control de excepciones y fallos

ACCIONES QUE REQUIEREN CONFIRMACION
- Configuración de modo seguro
- Ejecución de CHKDSK con reinicio
- Reset completo de red
- Apertura del editor de registro

COMPATIBILIDAD

SISTEMAS OPERATIVOS
- Windows 10
- Windows 11
- Windows 8/8.1
- Windows 7 (con PowerShell)

REQUISITOS
- Permisos: Ejecución como Administrador
- PowerShell: Versión 2.0 o superior
- Espacio: Suficiente para archivos temporales

INSTRUCCIONES DE USO

EJECUCION NORMAL
1. Ejecutar como administrador
2. Ingresar contraseña: soporte
3. Navegar por los menús según necesidad

MODO SEGURO
1. Ejecutar en modo seguro de Windows
2. Acceso directo sin contraseña
3. Funcionalidades limitadas según disponibilidad

PERSONALIZACION
- Contraseña: Modificar variable PASSWORD_CORRECTA
- Logging: Rutas configurables en variables
- Opciones: Modificar menús según necesidades específicas

TECNOLOGIAS UTILIZADAS

LENGUAJES Y HERRAMIENTAS
- Batch Scripting: Lógica principal
- PowerShell: Funcionalidades avanzadas
- Comandos CMD: Herramientas del sistema
- Utilidades Windows: MSINFO32, DISKMGMT, etc.

CARACTERISTICAS TECNICAS
- Delayed Expansion: Manejo de variables dinámicas
- Error Handling: Control de códigos de error
- User Interface: Menús coloridos y organizados
- Modular Design: Código estructurado y mantenible

SOPORTE Y MANTENIMIENTO

REPORTE DE PROBLEMAS
- Revisar archivos de log en %temp%\
- Verificar permisos de administrador
- Confirmar ejecución en modo seguro si aplica

ACTUALIZACIONES
- Versión actual: 3.0
- Mejoras continuas basadas en feedback
- Compatibilidad con nuevas versiones de Windows

NOTA IMPORTANTE: Este script está diseñado para técnicos calificados. 
Algunas funciones pueden afectar el sistema si se usan incorrectamente. 
Siempre verifique las acciones antes de ejecutarlas.

© Smith Lozano - Código Abierto - Uso Libre :)