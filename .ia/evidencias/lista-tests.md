# Matriz Formal De Pruebas

Este documento consolida las pruebas unitarias actuales del proyecto BankGo en un formato tabular más formal. Las decisiones técnicas del proyecto se documentan por separado en el archivo decisiones-tecnicas.md dentro de esta misma carpeta.

## Resumen Ejecutivo

| Campo | Valor |
| --- | --- |
| Suite actual | 62 pruebas |
| Archivos documentados | 10 |
| Cobertura funcional principal | Core, Auth, Dashboard, Accounts, Transactions |
| Enfoque de validación | Reglas de negocio, mapeo de datos, validaciones, seguridad funcional y manejo de errores |

## Matriz De Pruebas

### core/errors/exceptions_test.dart

| ID | Prueba | Propósito |
| --- | --- | --- |
| EXC-01 | UnauthorizedException captura status code 401 | Valida que el error de autenticación conserve el código esperado para que la app pueda reaccionar correctamente ante sesiones inválidas. |
| EXC-02 | TimeoutException captura status code 408 | Asegura que los timeouts se representen con el código correcto y no se confundan con otros errores de red o servidor. |
| EXC-03 | ServerException conserva código de error personalizado | Garantiza que los errores del backend o mock mantengan su código original, útil para diagnóstico y manejo diferenciado. |

### core/utils/currency_formatter_test.dart

| ID | Prueba | Propósito |
| --- | --- | --- |
| CUR-01 | formats positive amount with peso sign | Verifica que el formateo monetario principal muestre símbolo y separadores correctos para importes positivos. |
| CUR-02 | formats zero correctly | Asegura consistencia visual cuando el monto es cero, un caso común en saldos o movimientos iniciales. |
| CUR-03 | formats large amounts | Protege el renderizado de montos altos, evitando errores de separador de miles. |
| CUR-04 | adds + prefix for positive amounts | Confirma que los ingresos o abonos se distingan visualmente con el signo esperado. |
| CUR-05 | adds - prefix for negative amounts | Confirma que cargos o egresos mantengan el signo negativo esperado. |
| CUR-06 | formats thousands with locale compact suffix | Valida el formato compacto usado en ciertos contextos de UI para no saturar el espacio visual. |

### core/utils/validators_test.dart

| ID | Prueba | Propósito |
| --- | --- | --- |
| VAL-01 | returns null for valid emails | Asegura que correos válidos no sean rechazados por error. |
| VAL-02 | returns error for empty email | Protege formularios contra envíos vacíos. |
| VAL-03 | returns error for invalid email formats | Evita aceptar correos mal estructurados. |
| VAL-04 | returns null for valid passwords (>= 8 chars) | Confirma la regla mínima de longitud para contraseñas válidas. |
| VAL-05 | returns error for empty password | Evita autenticaciones o formularios con contraseñas vacías. |
| VAL-06 | returns error for password < 8 characters | Protege la restricción mínima de seguridad para contraseñas. |
| VAL-07 | returns null for non-empty string | Valida el comportamiento base del campo requerido. |
| VAL-08 | returns error for empty string | Evita aceptar entradas vacías o solo con espacios. |
| VAL-09 | includes field name in error message if provided | Asegura mensajes de error más claros y útiles para el usuario. |
| VAL-10 | returns null for valid amounts | Confirma que montos correctamente escritos sean aceptados. |
| VAL-11 | returns error for empty amount | Evita operaciones sin importe definido. |
| VAL-12 | returns error for zero or negative amounts | Protege reglas básicas de negocio en pagos y transferencias. |
| VAL-13 | returns error for non-numeric input | Impide procesar texto no numérico como monto. |
| VAL-14 | returns null for valid phone numbers | Acepta números con estructura válida. |
| VAL-15 | returns error for empty phone | Evita registros o formularios incompletos. |
| VAL-16 | returns error for invalid phone formats | Bloquea teléfonos demasiado cortos, largos o con caracteres inválidos. |
| VAL-17 | returns true for valid emails | Valida el helper booleano usado en chequeos rápidos. |
| VAL-18 | returns false for invalid emails | Asegura coherencia del helper para correos inválidos. |
| VAL-19 | returns true for passwords >= 8 chars | Confirma el helper booleano para contraseñas válidas. |
| VAL-20 | returns false for passwords < 8 chars | Confirma el helper booleano para contraseñas inválidas. |

### core/mocks/mock_bank_api_test.dart

| ID | Prueba | Propósito |
| --- | --- | --- |
| MBA-01 | retorna usuario demo con credenciales válidas | Verifica que el backend mock permita autenticación con las credenciales demo oficiales. |
| MBA-02 | lanza UnauthorizedException con credenciales inválidas | Asegura que el mock también respete el camino de error de autenticación. |
| MBA-03 | pagina transacciones y filtra por tipo | Valida paginación y filtrado, fundamentales para movimientos e historial. |
| MBA-04 | procesa pago de servicio con tarjeta encendida | Garantiza que el flujo permitido de pago genere la respuesta esperada. |
| MBA-05 | rechaza compra cuando la tarjeta está apagada | Protege una regla crítica de seguridad funcional. |
| MBA-06 | procesa pago con saldo suficiente | Comprueba que el mock simule correctamente una operación viable. |
| MBA-07 | rechaza compra con saldo insuficiente | Asegura la regla de fondos suficientes antes de procesar pagos. |
| MBA-08 | permite transferencia desde cuenta verificada de ahorro | Valida el caso exitoso de transferencia permitido por negocio. |
| MBA-09 | rechaza transferencia desde tarjeta de crédito | Protege la restricción de no usar crédito como origen de transferencia. |

### features/auth/data/user_model_test.dart

| ID | Prueba | Propósito |
| --- | --- | --- |
| AUT-D-01 | fromJson creates model with correct values | Asegura que los datos de autenticación se lean correctamente desde la respuesta serializada. |
| AUT-D-02 | toJson serializes correctly | Protege el proceso inverso, útil para persistencia o cache. |
| AUT-D-03 | fromEntity creates model from User entity | Valida el puente entre dominio y data layer. |
| AUT-D-04 | is a subtype of User | Garantiza compatibilidad entre modelo concreto y entidad esperada por el resto de la app. |

### features/auth/domain/user_entity_test.dart

| ID | Prueba | Propósito |
| --- | --- | --- |
| AUT-E-01 | copyWith returns updated instance | Asegura mutaciones controladas sin perder valores previos. |
| AUT-E-02 | equality is based on props | Protege la igualdad estructural usada por Equatable y por el manejo de estados. |
| AUT-E-03 | inequality when id differs | Confirma que dos usuarios distintos no sean tratados como el mismo. |

### features/dashboard/data/recent_transaction_model_test.dart

| ID | Prueba | Propósito |
| --- | --- | --- |
| DSH-01 | placeholders returns non-empty list | Asegura que el dashboard tenga datos base o de demo para renderizar. |
| DSH-02 | placeholder items have non-zero amounts | Evita placeholders irreales o inútiles para validación visual. |
| DSH-03 | income transactions have positive amounts | Refuerza consistencia semántica entre tipo y monto. |
| DSH-04 | expense transactions have negative amounts | Evita inconsistencias entre egreso y signo monetario. |
| DSH-05 | isIncome returns true for income type | Valida helpers derivados usados por la UI o lógica de presentación. |
| DSH-06 | isExpense returns true for expense type | Valida helpers derivados para clasificar movimientos correctamente. |

### features/accounts/data/accounts_repository_impl_test.dart

| ID | Prueba | Propósito |
| --- | --- | --- |
| ACC-D-01 | retorna cuentas cuando hay conexión | Asegura el camino exitoso del repositorio de cuentas. |
| ACC-D-02 | retorna fallo de red si no hay conexión | Protege el comportamiento esperado offline sin filtrar errores ambiguos. |
| ACC-D-03 | mapea movimientos desde el datasource | Confirma que la capa repositorio entregue movimientos correctamente al dominio. |
| ACC-D-04 | mapea ServerException a ServerFailure | Garantiza que los errores técnicos se traduzcan al contrato de fallos del dominio. |

### features/accounts/presentation/bloc/card_bloc_test.dart

| ID | Prueba | Propósito |
| --- | --- | --- |
| ACC-B-01 | permite ver información sensible con token válido | Valida el acceso controlado a datos sensibles de tarjeta. |
| ACC-B-02 | rechaza intento de interceptar información con token inválido | Protege contra exposición de información sensible sin autorización válida. |
| ACC-B-03 | la sesión sensible decrementa el contador y no se queda en espera | Asegura que el temporizador de visibilidad funcione y expire correctamente. |
| ACC-B-04 | oculta información sensible al vencer la sesión | Valida el cierre automático de sesión sensible por seguridad. |

### features/transactions/data/transfer_repository_impl_test.dart

| ID | Prueba | Propósito |
| --- | --- | --- |
| TRF-01 | valida cuenta destino con conexión activa | Asegura que el repositorio acepte cuentas de destino correctamente verificadas. |
| TRF-02 | retorna fallo de red al solicitar token sin conexión | Protege el flujo de seguridad cuando no hay conectividad. |
| TRF-03 | mapea errores del datasource al enviar transferencia | Garantiza que fallos de envío lleguen al dominio como errores controlables y no como excepciones crudas. |

