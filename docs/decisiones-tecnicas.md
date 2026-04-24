# Decisiones Técnicas Tomadas

Este documento resume las principales decisiones técnicas adoptadas en BankGo y el motivo de cada una.

## Matriz De Decisiones

| ID | Decisión | Descripción | Motivo técnico |
| --- | --- | --- | --- |
| DT-01 | Backend simulado oficial | La aplicación opera actualmente con MockBankApi como backend local de demo. | Permite avanzar en flujos funcionales y pruebas sin depender de un backend real todavía no disponible. |
| DT-02 | Arquitectura feature-first por capas | El proyecto se organiza por features y separa presentation, domain y data. | Reduce acoplamiento, mejora mantenibilidad y facilita refactors graduales. |
| DT-03 | Gestión de estado con BLoC | Los flujos principales de auth, dashboard, tarjetas y transacciones se apoyan en blocs. | Centraliza lógica de estado y hace más testeables los cambios de comportamiento. |
| DT-04 | Inyección de dependencias con GetIt | La resolución de servicios, repositorios y blocs se hace desde injection_container.dart. | Simplifica el wiring y permite reemplazar implementaciones por mocks o abstracciones. |
| DT-05 | Capa de repositorio sobre el mock | Varias pantallas y pruebas ya consumen repositorios en lugar de pegarse directamente al mock. | Protege a la UI de cambios en la fuente de datos y prepara la migración futura a backend real. |
| DT-06 | Cliente HTTP con Dio e interceptores | La app mantiene un cliente Dio con MockInterceptor y soporte para un backend futuro. | Permite conservar una estructura cercana a producción aunque hoy se use backend local. |
| DT-07 | Persistencia local separada por sensibilidad | Se usa Flutter Secure Storage para datos sensibles y SharedPreferences para datos no sensibles como PIN y preferencias. | Alinea nivel de seguridad con el tipo de dato persistido. |
| DT-08 | Autenticación demo con DNI, contraseña y PIN | El acceso inicial usa credenciales demo y luego puede apoyarse en PIN local. | Simula un flujo bancario más realista y permite reingreso rápido tras la sesión inicial. |
| DT-09 | Protección de datos sensibles por token temporal | La visualización de datos de tarjeta, transferencias y congelado de tarjeta exigen token o control temporal. | Refuerza seguridad funcional en operaciones sensibles. |
| DT-10 | Validaciones y formateo cubiertos por pruebas | Reglas de validación y formateo monetario tienen una batería amplia de tests. | Disminuye regresiones en formularios y en la presentación de importes. |
| DT-11 | Release Android endurecido | El build de release usa R8, ofuscación y split debug info. | Mejora tamaño, ofuscación y trazabilidad en entornos reales de distribución. |
| DT-12 | CI/CD con GitHub Actions y SonarCloud | El pipeline corre análisis, tests, build y publicación de artefactos. | Asegura control de calidad continuo y repetibilidad del proceso de entrega. |
| DT-13 | Compatibilidad desde Android 10 | Se decidió establecer compatibilidad mínima desde Android 10 mediante minSdkVersion 29. | Reduce fragmentación de comportamiento, simplifica compatibilidad de APIs modernas y alinea el soporte con las necesidades actuales del proyecto. |
| DT-14 | Reingreso por PIN tras inactividad | Se decidió aplicar un timeout de inactividad de 3 minutos para forzar el ingreso nuevamente por PIN. | Refuerza la seguridad de sesión en un contexto bancario sin exigir reautenticación completa en cada interacción. |
| DT-15 | Pago de servicios como flujo adicional de validación | Se decidió añadir y mantener el proceso de pago de servicios como operación adicional para validar reglas compartidas de negocio. | Permite comprobar que la lógica de tarjeta apagada, saldo insuficiente y comportamiento transaccional también se cumpla fuera del flujo de transferencias. |

## Evidencias En Código

| Decisión | Evidencia principal |
| --- | --- |
| Compatibilidad desde Android 10 | android/app/build.gradle con minSdkVersion 29 |
| Reingreso por PIN tras inactividad | lib/main.dart con Timer de 3 minutos que redirige a /pin-login |
| Pago de servicios para validar lógica de tarjeta apagada | lib/core/mocks/mock_bank_api.dart en processServicePayment, donde se bloquea la operación si la tarjeta está apagada |