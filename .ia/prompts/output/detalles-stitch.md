 Nuevas Pantallas (Screens)


  │ Pantalla                   │ Ubicación                 │ Descripción Funcional                                                                                                                    │
  ├────────────────────────────┼───────────────────────────┼────────────────────────────────────────────────────────────────────
  │ Configuración de PIN       │ pin_setup_page.dart       │ Flujo de creación y confirmación de PIN de 6 dígitos tras el login inicial.                                                              │
  │ Login por PIN              │ pin_login_page.dart       │ Acceso rápido mediante teclado numérico seguro y aleatorizado.                                                                           │
  │ Asistente de Transferencia │ transfer_wizard_page.dart │ Flujo en 3 pasos: 1. Validación de cuenta (16 dígitos), 2. Selección de monto/origen con validación de saldo, 3. Verificación por Token. │
  │ Detalles de Tarjeta        │ card_details_page.dart    │ Visualización de tarjeta física/digital, CVV dinámico con temporizador de 3 min y switch de encendido/apagado protegido por Token.       │
  │ Pago de Servicios          │ service_payment_page.dart │ Formulario para pagar servicios (Luz, Agua, etc.) con validación de estado de tarjeta en tiempo real.                                    │
  ───────────────────────────┴───────────────────────────┴────────────────────────────────────────────────────────────────────────

  🏗️ Componentes y Widgets Reutilizables

   * AuthHeader: Widget unificado para el branding en pantallas de autenticación (Logo + Título + Subtítulo).
   * PinIndicator: Visualizador animado de los 6 dígitos del PIN para feedback inmediato al usuario.
   * EmailPasswordLoginForm: Formulario estándar de inicio de sesión con validaciones de formato y seguridad.
   * QuickActionsWidget: Actualizado con accesos directos funcionales a "Transferir" y "Servicios".
   * SecureNumericKeypad: Teclado con disposición aleatoria para prevenir patrones de rastreo de dedos.

  🔐 Reglas de Visualización y Privacidad (Mocks de Datos)

   * Enmascarado Selectivo:
       * Cuenta Principal: Muestra saldo y número de cuenta/tarjeta enmascarado (**** 1234).
       * Otras Cuentas: Todo el contenido sensible (saldo y números) se visualiza como **** para privacidad total.
   * Tarjeta de Crédito: Implementación visual de la línea de crédito con una barra de progreso que diferencia el consumo actual del cupo disponible.

  ⚡ Dinámicas de la Interfaz (Lógica de UI)

   1. Bloqueo por Inactividad: Listener global que redirige a PinLoginPage si no hay interacción en 3 minutos.
   2. Temporizador de CVV: Contador regresivo de 180 segundos en la vista de tarjeta; al expirar, oculta la información y requiere nueva validación.
   3. Alertas In-App (Simulación):
       * Compras Fallidas: Notificación tipo SnackBar flotante cada vez que el simulador de fondo intenta una compra mientras la tarjeta está "Apagada".
       * Estado de Red: Detección proactiva de falta de conexión a internet con alerta inmediata al usuario.
   4. Limpieza de UI: Se eliminó el botón de "Agregar Cuenta" (+) en la pantalla de gestión de cuentas para simplificar la navegación según requerimiento.

  Este consolidado permite validar que cada mock visual tiene ahora una contraparte funcional implementada en el código, respetando los estados de carga, error y éxito definidos. ¿Deseas que genere algún
  diagrama de navegación o reporte técnico adicional?