# Security Design & Policy: BankGo Mobile App
**Versión:** 1.0  
**Rol:** Security Engineer  

---

## 1. Clasificación de Datos y Protección de PII
Para cumplir con el requisito de "No PII en logs", se define la siguiente estrategia:

### Definición de PII (Personally Identifiable Information) en BankGo:
* **Identificadores:** Nombres completos, números de documento (DNI/CE), correos electrónicos.
* **Financieros:** Números de tarjeta de crédito/débito, números de cuenta, saldos y montos de transferencias.
* **Credenciales:** Tokens de acceso, Refresh Tokens, secretos PKCE. 

### Estrategia de Prevención de Filtrado:
* **Sanitización de Logs:** Implementación de un `Timber.Tree` (Android) o un `Logger` centralizado que intercepte cualquier objeto de la capa de Data y aplique una máscara a campos sensibles antes de enviarlos a la consola.
* **Implementación del Logger Condicional**
Para evitar fugas de información en producción, utilizaremos una validación de entorno. Solo permitiremos logs de diagnóstico técnico, eliminando cualquier rastro de datos de negocio.

```dart
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class BankGoLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
    // En producción (release), solo registramos errores críticos y advertencias.
    level: kReleaseMode ? Level.error : Level.debug, 
  );

  static void info(String message) => _logger.i(message);
  static void error(String message, [dynamic error, StackTrace? stack]) => 
      _logger.e(message, error: error, stackTrace: stack);
}
```

## 2. Comunicaciones: Interceptor de Seguridad (OAuth2 + PKCE)
Para asegurar que todas las peticiones al backend mock sean autorizadas, se diseña un **AuthInterceptor** que inyecta el token de forma automática.

### Diseño del Interceptor:
Para inyectar el token OAuth2 simulado de manera limpia y centralizada, utilizaremos un **Interceptor** con el paquete `dio`.

### Interceptor de Seguridad (Flutter/Dio):
```dart
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final SecureTokenStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Recuperar token del almacenamiento seguro
    final token = await _storage.getAccessToken();
    
    // 2. Inyectar headers de seguridad
    options.headers['Authorization'] = 'Bearer $token';
    options.headers['X-Frame-Options'] = 'DENY'; // Protección básica OWASP 
    
    return handler.next(options);
  }
}
```