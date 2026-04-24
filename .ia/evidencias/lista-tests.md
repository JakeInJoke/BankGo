# Listado Formal De Pruebas

Este documento resume las pruebas unitarias actuales del proyecto BankGo y explica el propósito de cada una.

## Resumen

- Suite actual: 62 pruebas
- Archivos de prueba documentados: 10
- Objetivo general: validar reglas de negocio, mapeo de datos, formateo, validaciones de entrada y flujos sensibles de seguridad.

## Core

### core/errors/exceptions_test.dart

- UnauthorizedException captura status code 401
	Por qué: valida que el error de autenticación conserve el código esperado para que la app pueda reaccionar correctamente ante sesiones inválidas.
- TimeoutException captura status code 408
	Por qué: asegura que los timeouts se representen con el código correcto y no se confundan con otros errores de red o servidor.
- ServerException conserva código de error personalizado
	Por qué: garantiza que los errores del backend o mock mantengan su código original, útil para diagnóstico y manejo diferenciado.

### core/utils/currency_formatter_test.dart

- formats positive amount with peso sign
	Por qué: verifica que el formateo monetario principal muestre símbolo y separadores correctos para importes positivos.
- formats zero correctly
	Por qué: asegura consistencia visual cuando el monto es cero, un caso común en saldos o movimientos iniciales.
- formats large amounts
	Por qué: protege el renderizado de montos altos, evitando errores de separador de miles.
- adds + prefix for positive amounts
	Por qué: confirma que los ingresos o abonos se distingan visualmente con el signo esperado.
- adds - prefix for negative amounts
	Por qué: confirma que cargos o egresos mantengan el signo negativo esperado.
- formats thousands with locale compact suffix
	Por qué: valida el formato compacto usado en ciertos contextos de UI para no saturar el espacio visual.

### core/utils/validators_test.dart

- returns null for valid emails
	Por qué: asegura que correos válidos no sean rechazados por error.
- returns error for empty email
	Por qué: protege formularios contra envíos vacíos.
- returns error for invalid email formats
	Por qué: evita aceptar correos mal estructurados.
- returns null for valid passwords (>= 8 chars)
	Por qué: confirma la regla mínima de longitud para contraseñas válidas.
- returns error for empty password
	Por qué: evita autenticaciones o formularios con contraseñas vacías.
- returns error for password < 8 characters
	Por qué: protege la restricción mínima de seguridad para contraseñas.
- returns null for non-empty string
	Por qué: valida el comportamiento base del campo requerido.
- returns error for empty string
	Por qué: evita aceptar entradas vacías o solo con espacios.
- includes field name in error message if provided
	Por qué: asegura mensajes de error más claros y útiles para el usuario.
- returns null for valid amounts
	Por qué: confirma que montos correctamente escritos sean aceptados.
- returns error for empty amount
	Por qué: evita operaciones sin importe definido.
- returns error for zero or negative amounts
	Por qué: protege reglas básicas de negocio en pagos y transferencias.
- returns error for non-numeric input
	Por qué: impide procesar texto no numérico como monto.
- returns null for valid phone numbers
	Por qué: acepta números con estructura válida.
- returns error for empty phone
	Por qué: evita registros o formularios incompletos.
- returns error for invalid phone formats
	Por qué: bloquea teléfonos demasiado cortos, largos o con caracteres inválidos.
- returns true for valid emails
	Por qué: valida el helper booleano usado en chequeos rápidos.
- returns false for invalid emails
	Por qué: asegura coherencia del helper para correos inválidos.
- returns true for passwords >= 8 chars
	Por qué: confirma el helper booleano para contraseñas válidas.
- returns false for passwords < 8 chars
	Por qué: confirma el helper booleano para contraseñas inválidas.

### core/mocks/mock_bank_api_test.dart

- retorna usuario demo con credenciales válidas
	Por qué: verifica que el backend mock permita autenticación con las credenciales demo oficiales.
- lanza UnauthorizedException con credenciales inválidas
	Por qué: asegura que el mock también respete el camino de error de autenticación.
- pagina transacciones y filtra por tipo
	Por qué: valida paginación y filtrado, fundamentales para movimientos e historial.
- procesa pago de servicio con tarjeta encendida
	Por qué: garantiza que el flujo permitido de pago genere la respuesta esperada.
- rechaza compra cuando la tarjeta está apagada
	Por qué: protege una regla crítica de seguridad funcional.
- procesa pago con saldo suficiente
	Por qué: comprueba que el mock simule correctamente una operación viable.
- rechaza compra con saldo insuficiente
	Por qué: asegura la regla de fondos suficientes antes de procesar pagos.
- permite transferencia desde cuenta verificada de ahorro
	Por qué: valida el caso exitoso de transferencia permitido por negocio.
- rechaza transferencia desde tarjeta de crédito
	Por qué: protege la restricción de no usar crédito como origen de transferencia.

## Auth

### features/auth/data/user_model_test.dart

- fromJson creates model with correct values
	Por qué: asegura que los datos de autenticación se lean correctamente desde la respuesta serializada.
- toJson serializes correctly
	Por qué: protege el proceso inverso, útil para persistencia o cache.
- fromEntity creates model from User entity
	Por qué: valida el puente entre dominio y data layer.
- is a subtype of User
	Por qué: garantiza compatibilidad entre modelo concreto y entidad esperada por el resto de la app.

### features/auth/domain/user_entity_test.dart

- copyWith returns updated instance
	Por qué: asegura mutaciones controladas sin perder valores previos.
- equality is based on props
	Por qué: protege la igualdad estructural usada por Equatable y por el manejo de estados.
- inequality when id differs
	Por qué: confirma que dos usuarios distintos no sean tratados como el mismo.

## Dashboard

### features/dashboard/data/recent_transaction_model_test.dart

- placeholders returns non-empty list
	Por qué: asegura que el dashboard tenga datos base o de demo para renderizar.
- placeholder items have non-zero amounts
	Por qué: evita placeholders irreales o inútiles para validación visual.
- income transactions have positive amounts
	Por qué: refuerza consistencia semántica entre tipo y monto.
- expense transactions have negative amounts
	Por qué: evita inconsistencias entre egreso y signo monetario.
- isIncome returns true for income type
	Por qué: valida helpers derivados usados por la UI o lógica de presentación.
- isExpense returns true for expense type
	Por qué: valida helpers derivados para clasificar movimientos correctamente.

## Accounts

### features/accounts/data/accounts_repository_impl_test.dart

- retorna cuentas cuando hay conexión
	Por qué: asegura el camino exitoso del repositorio de cuentas.
- retorna fallo de red si no hay conexión
	Por qué: protege el comportamiento esperado offline sin filtrar errores ambiguos.
- mapea movimientos desde el datasource
	Por qué: confirma que la capa repositorio entregue movimientos correctamente al dominio.
- mapea ServerException a ServerFailure
	Por qué: garantiza que los errores técnicos se traduzcan al contrato de fallos del dominio.

### features/accounts/presentation/bloc/card_bloc_test.dart

- permite ver información sensible con token válido
	Por qué: valida el acceso controlado a datos sensibles de tarjeta.
- rechaza intento de interceptar información con token inválido
	Por qué: protege contra exposición de información sensible sin autorización válida.
- la sesión sensible decrementa el contador y no se queda en espera
	Por qué: asegura que el temporizador de visibilidad funcione y expire correctamente.
- oculta información sensible al vencer la sesión
	Por qué: valida el cierre automático de sesión sensible por seguridad.

## Transactions

### features/transactions/data/transfer_repository_impl_test.dart

- valida cuenta destino con conexión activa
	Por qué: asegura que el repositorio acepte cuentas de destino correctamente verificadas.
- retorna fallo de red al solicitar token sin conexión
	Por qué: protege el flujo de seguridad cuando no hay conectividad.
- mapea errores del datasource al enviar transferencia
	Por qué: garantiza que fallos de envío lleguen al dominio como errores controlables y no como excepciones crudas.