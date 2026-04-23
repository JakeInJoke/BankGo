# Consolidado de Solicitudes y Pasos Seguidos - BankGo

## Objetivo del documento
Este documento consolida las solicitudes realizadas durante la evolución del proyecto BankGo y resume los pasos técnicos ejecutados para estabilizar la aplicación, habilitar su ejecución local/CI y dejarla operativa con datos mock conforme al alcance actual.

## Resumen ejecutivo
Durante el trabajo sobre BankGo se atendieron solicitudes en cinco frentes principales:

1. Corrección de errores de compilación y análisis.
2. Estandarización de imports y eliminación de deprecaciones.
3. Ajustes de Android/CI para generar builds release.
4. Seguridad y lineamientos de manejo de tokens, caché y PII.
5. Implementación de una capa mock general para operar sin backend real.

El proyecto quedó con análisis limpio y con capacidad de ejecutar autenticación, dashboard y movimientos usando datos mock centralizados.

## Consolidado de solicitudes atendidas

### 1. Corrección de errores del proyecto
Solicitudes atendidas:
- Solucionar errores de compilación.
- Resolver warnings y deprecaciones.
- Dejar el proyecto sin issues en análisis.

Acciones ejecutadas:
- Corrección de errores de sintaxis y referencias inválidas en la capa visual y de tema.
- Normalización de imports a formato `package:`.
- Reemplazo de usos de APIs deprecadas como `withOpacity()` por `withValues(alpha:)`.
- Limpieza de imports no usados.
- Ajuste de constructores con `const` cuando aplicaba.

Resultado:
- `flutter analyze --no-fatal-infos` quedó limpio.

### 2. Estandarización de arquitectura y base ejecutable
Solicitudes atendidas:
- Dejar una base ejecutable y mantenible.
- Mantener el proyecto alineado a Clean Architecture.

Acciones ejecutadas:
- Revisión de la organización por features.
- Conservación de inyección de dependencias con GetIt.
- Revisión de flujos de auth, dashboard y transactions para mantener consistencia en data/domain/presentation.

Resultado:
- La app mantiene separación por capas y una ruta clara para extender módulos faltantes.

### 3. Compatibilidad Android y build release
Solicitudes atendidas:
- Hacer la app compatible desde Android 10.
- Corregir errores de Gradle/Flutter plugin.
- Habilitar `flutter build appbundle --release`.
- Resolver problemas de firma en CI.

Acciones ejecutadas:
- Migración de configuración Gradle al esquema moderno con plugins declarativos.
- Actualización de Java/Kotlin target según requisitos del stack Android moderno.
- Ajuste de `minSdkVersion` a 29 para compatibilidad desde Android 10.
- Ajuste de `compileSdkVersion` y `targetSdkVersion` a 36 para compatibilidad con plugins Android actuales.
- Corrección de recursos Android faltantes para permitir empaquetado release.
- Corrección del manejo del keystore de release en GitHub Actions.
- Resolución robusta de `storeFile` en Gradle para soportar rutas relativas al módulo y al root Android.
- Validación de archivos de firma en workflow antes de ejecutar el build.

Resultado:
- El build `appbundle --release` quedó operativo.
- CI pudo quedar alineado con la firma release vía secrets.

### 4. Seguridad del aplicativo móvil
Solicitudes atendidas:
- Diseñar la capa de seguridad móvil.
- Definir PII y cómo evitar su fuga en logs.
- Definir interceptor para token OAuth2 simulado.
- Generar lineamientos OWASP Mobile sobre manejo de tokens y caché.
- Aclarar si el keystore es un dato sensible.

Acciones ejecutadas:
- Revisión de la capa de red existente (`DioInterceptor`).
- Revisión del almacenamiento local de usuario autenticado.
- Definición conceptual de PII: correo, teléfono, identificadores personales, tokens, referencias sensibles y cualquier dato que permita identificar o comprometer al usuario.
- Confirmación de que el keystore debe tratarse como secreto crítico.
- Establecimiento de lineamientos para no loguear PII ni tokens.
- Base del interceptor para inyectar bearer token simulado.
- Identificación de necesidad de proteger datos no sensibles en caché local y evitar persistencia insegura de secretos.

Resultado:
- Quedó definido el marco de seguridad para el uso responsable de logs, tokens, caché y artefactos de firma.

### 5. Credenciales de ingreso
Solicitudes atendidas:
- Identificar credenciales de ingreso.

Acciones ejecutadas:
- Revisión del flujo de login en UI, repositorio y datasource.
- Confirmación de que inicialmente no existían credenciales hardcodeadas en la app.
- Posteriormente, con la capa mock, se definieron credenciales demo controladas.

Resultado:
- Antes del mock, las credenciales dependían del backend.
- Después del mock, existen credenciales demo explícitas para pruebas locales.

### 6. Mock general según requerimientos
Solicitudes atendidas:
- Hacer un mock general para ejecutar consultas de acuerdo al documento de requerimientos.

Acciones ejecutadas:
- Se creó una capa mock central: `lib/core/mocks/mock_bank_api.dart`.
- Se conectó autenticación al mock general.
- Se conectó dashboard al mock general.
- Se conectó movimientos al mock general.
- Se registró el mock en el contenedor de dependencias.
- Se agregaron pruebas unitarias específicas del mock.

Resultado funcional del mock:
- Login simulado con credenciales demo.
- Resumen de cuenta.
- Transacciones recientes.
- Listado paginado/filtrado de movimientos.
- Métodos preparados para transferencia mock y congelar/descongelar tarjeta.

Credenciales demo del mock:
- Email: `demo@bankgo.com`
- Password: `BankGo123!`

## Pasos técnicos seguidos

### Fase 1. Diagnóstico
1. Se revisó la estructura del proyecto y la separación por features.
2. Se identificaron fallos de análisis, build, assets y configuración Android.
3. Se validaron datasources, repositorios, DI y rutas principales.

### Fase 2. Estabilización del código
1. Se corrigieron errores de sintaxis y referencias inválidas.
2. Se estandarizaron imports a `package:`.
3. Se eliminaron deprecaciones y lints relevantes.
4. Se validó el proyecto con análisis y pruebas.

### Fase 3. Estabilización de Android y CI
1. Se migró Gradle al esquema moderno compatible con Flutter actual.
2. Se alinearon Java, Kotlin, compileSdk y targetSdk.
3. Se corrigieron errores de recursos e íconos Android.
4. Se arregló la firma release para ejecución local y CI.
5. Se revisaron workflows de GitHub Actions.

### Fase 4. Seguridad
1. Se revisó interceptor de red.
2. Se revisó almacenamiento local del usuario.
3. Se definieron lineamientos para no exponer PII/tokens en logs.
4. Se clasificó el keystore como secreto sensible.

### Fase 5. Mock funcional
1. Se detectó que dashboard y transactions tenían placeholders aislados.
2. Se identificó que auth todavía dependía de API real.
3. Se creó una capa mock central para unificar comportamiento.
4. Se conectaron datasources al mock central.
5. Se añadieron pruebas unitarias nuevas.
6. Se ejecutó análisis final del proyecto.

## Archivos relevantes involucrados

### Mock y ejecución funcional sin backend
- `lib/core/mocks/mock_bank_api.dart`
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart`
- `lib/features/transactions/data/datasources/transactions_remote_datasource.dart`
- `lib/injection_container.dart`
- `test/core/mocks/mock_bank_api_test.dart`

### Android y CI/CD
- `android/app/build.gradle`
- `android/build.gradle`
- `android/settings.gradle`
- `android/gradle/wrapper/gradle-wrapper.properties`
- `.github/workflows/flutter-action.yml`
- `.github/workflows/flutter-build.yml`
- `android/app/src/main/AndroidManifest.xml`

### Seguridad
- `lib/core/network/dio_interceptor.dart`
- `lib/features/auth/data/datasources/auth_local_datasource.dart`

## Estado actual del proyecto

### Operativo hoy
- Autenticación mock.
- Dashboard con datos mock.
- Movimientos con datos mock.
- Build Android release funcional.
- Compatibilidad desde Android 10.
- Pipeline con lint/analyze/tests/build encaminado.

### Validaciones logradas
- Análisis estático limpio.
- Pruebas unitarias del mock pasando.
- Build release Android operativo.

## Limitaciones actuales
Aunque el mock general cubre gran parte del alcance operativo, todavía hay requerimientos del documento de negocio que están preparados conceptualmente pero no conectados a UI completa:

- Transferencias mock con pantallas de revisión y confirmación.
- Gestión de tarjeta para congelar/descongelar.
- Notificaciones in-app posteriores a transferencias.
- OIDC/OAuth2 + PKCE simulado más explícito a nivel de flujo visual.
- Documentación específica de uso de IA (`ai-usage.md`) si aún no se ha creado.
- Diagramas y wireframes obligatorios si aún no se han generado.

## Recomendaciones siguientes
1. Crear módulo de transferencias y usar `submitTransfer()` del mock general.
2. Crear módulo de tarjeta y conectar `toggleCardFreeze()`.
3. Mostrar credenciales demo en la pantalla de login para facilitar pruebas.
4. Añadir una bandera de entorno `mockMode` para alternar entre mock y API real.
5. Mover almacenamiento de token a `flutter_secure_storage` y dejar `shared_preferences` solo para datos no sensibles.
6. Generar `ai-usage.md`, diagrama de arquitectura y wireframes para completar entregables del requerimiento.

## Conclusión
Se consolidó una base funcional y ejecutable de BankGo con arquitectura limpia, build Android estable, CI utilizable, lineamientos de seguridad definidos y una capa mock general que permite avanzar el desarrollo sin depender de un backend real. El sistema ya soporta pruebas funcionales del flujo principal actualmente implementado y queda preparado para extender los módulos faltantes del alcance de negocio.
