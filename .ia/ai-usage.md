## Herramientas de IA utilizadas

### 1. Github Copilot
- **LLM Utilizados por tarea:**
    | Modelo | Uso principal |
    |---|---|
    | Gemini 2.5 Pro | Análisis de arquitectura, revisión de seguridad y razonamiento de largo contexto |
    | GPT 4.5 | Generación de código boilerplate, corrección de errores y refactors puntuales |
    | Claude Sonnet 4.6 | Iteración de código complejo, tests unitarios y resolución de fallos de CI/CD |

### 2. Gemini CLI + Stitch
- Se utilizó **Gemini CLI** con la extensión **Stitch** para generar el **esqueleto base del aplicativo**.
- Stitch permitió scaffoldear la estructura inicial de features y componentes Flutter desde descripciones en lenguaje natural.
- Artefactos generados en esta fase:
    - Estructura de carpetas por feature (`auth`, `accounts`, `dashboard`, `transactions`, `profile`).
    - Componentes base de UI: tarjetas de cuenta, lista de movimientos, formulario de login.
    - Punto de entrada `main.dart` y configuración inicial de rutas.

### 3. Gemini Web
- Consultas de análisis de requerimientos y validación de decisiones de diseño.

### 4. Jules
- Se intentó usar **Jules** para la generación de pantallas UI completas de forma autónoma.
- **Resultado:** Jules no funcionó correctamente para este caso; los componentes generados requerían correcciones extensas de layout, estilos y lógica de estado que hacían inviable el output directo.
- **Decisión:** Se abandonó el uso de Jules para UI y se pasó a **iteración manual asistida por Github Copilot**, donde el desarrollador controlaba cada cambio y la IA actuaba como asistente en línea.

---

## Aplicación de IA

### 1. Análisis de requerimientos
- **Herramienta:** Gemini Web
- Se analizaron los requerimientos del proyecto a partir de una visión específica del producto bancario.
- Se definió el alcance funcional: autenticación, dashboard, movimientos, transferencias y gestión de tarjeta.

![Visión de análisis](Vision%20de%20análisis.png)

### 2. Generación del esqueleto base
- **Herramienta:** Gemini CLI + Stitch
- Se generó la estructura inicial del proyecto: carpetas por feature, componentes base de UI y configuración de rutas.
- **Valor generado:** En minutos se obtuvo una base navegable que habría tomado horas construir manualmente desde cero.

### 3. Diseño de arquitectura
- **Herramienta:** Github Copilot (Gemini 2.5 Pro)
- Se validó y refinó la arquitectura **Clean Architecture** con separación `data / domain / presentation`.
- Se diseñó el esquema de inyección de dependencias con **GetIt** y el uso de **BLoC** como patrón de estado.
- **Valor generado:** La IA detectó inconsistencias entre capas antes de que llegaran a código ejecutable.

### 4. Generación y corrección de código
- **Herramienta:** Github Copilot (Claude Sonnet 4.6 / GPT 4.5)
- Datasources, repositorios, casos de uso y BLoCs por feature.
- Estandarización de imports al formato `package:`.
- División de páginas grandes en widgets dedicados (cuentas, dashboard, wizard de transferencias).
- Implementación del mock central (`MockBankApi`) para operar sin backend real.
- **Valor generado:** Reducción significativa del tiempo de escritura de capas repetitivas; el desarrollador se enfocó en lógica de negocio, no en boilerplate.

### 5. Seguridad
- **Herramienta:** Github Copilot (Gemini 2.5 Pro)
- Revisión del interceptor de red (`DioInterceptor`) para inyección de bearer token simulado.
- Definición de lineamientos OWASP Mobile: manejo de PII, tokens, caché y almacenamiento local.
- Clasificación del keystore como secreto crítico y configuración segura en CI.
- **Valor generado:** La IA identificó riesgos de fuga de PII en logs que no eran evidentes durante la escritura inicial del código.

### 6. Configuración Android y CI/CD
- **Herramienta:** Github Copilot (Claude Sonnet 4.6)
- Migración de Gradle al esquema moderno compatible con Flutter.
- Ajuste de `minSdkVersion` (29), `compileSdkVersion` y `targetSdkVersion` (36).
- Corrección de errores de recursos e íconos Android para build release.
- Configuración de firma release con keystore en GitHub Actions (secrets).
- **Valor generado:** Resolución de errores de Gradle que sin asistencia habrían requerido horas de depuración manual en documentación fragmentada.

### 7. Pruebas unitarias
- **Herramienta:** Github Copilot (Claude Sonnet 4.6)
- Tests del mock central (`MockBankApi`).
- Tests de BLoCs: `CardBloc`, `AccountsBloc`, `AuthBloc`, `DashboardBloc`, `TransactionsBloc`.
- Tests de repositorios, casos de uso y utilidades del core.
- 62 tests pasando con cobertura generada vía `flutter test --coverage`.
- **Valor generado:** Suite de tests completa generada en una fracción del tiempo que tomaría escribirla manualmente; el desarrollador solo revisó y ajustó casos borde.

### 8. Generación de documentación
- **Herramienta:** Github Copilot (Claude Sonnet 4.6)
- Se usó la IA para apoyarse en la redacción y estructuración de la documentación del proyecto.
- El propio archivo `ai-usage.md` fue elaborado con apoyo de IA: secciones, tabla de valor, validación y descripción de herramientas.
- Se documentaron decisiones de arquitectura, convenciones del proyecto y notas de CI/CD con asistencia del modelo.
- **Valor generado:** Documentación técnica detallada y estructurada en minutos, manteniendo consistencia de estilo y cobertura completa de los temas relevantes.

---

## Valor generado por IA

| Área | Sin IA (estimado) | Con IA (real) | Ahorro |
|---|---|---|---|
| Esqueleto base del proyecto | 1-2 días | ~30 min | ~90% |
| Capas de arquitectura por feature | 3-4 días | ~4 horas | ~85% |
| Suite de pruebas unitarias (62 tests) | 2-3 días | ~3 horas | ~85% |
| Diagnóstico de errores Gradle/CI | 4-6 horas | ~45 min | ~85% |
| Revisión de lineamientos de seguridad | 3-4 horas | ~1 hora | ~70% |

---

## Validación de información generada por IA

Cada output de la IA fue revisado manualmente antes de integrarse. Los mecanismos de validación utilizados fueron:

### 1. Revisión de diffs entre archivos
Antes de aceptar cualquier cambio generado, se revisó el diff completo del archivo para identificar modificaciones inesperadas, código sobrante, o cambios fuera del scope solicitado. No se aceptó ningún bloque de código sin leer su diff completo.

### 2. `flutter analyze` manual
La IA no ejecuta el análisis estático por su cuenta. Después de cada bloque de cambios significativo se ejecutó `flutter analyze --no-fatal-infos` manualmente para verificar que no se introdujeran nuevos warnings, imports no usados, o errores de tipo. Este paso evitó acumulación de deuda técnica silenciosa.

### 3. Validación de coherencia de tests
Los tests generados por la IA fueron revisados para verificar que:
- Prueban la lógica esperada, no solo que el código compila.
- Si se rompe la lógica de negocio (ej. cambiar una condición en el BLoC), el test falla. Se verificó esto modificando temporalmente la lógica y comprobando que los tests detectaban el error antes de revertir.

### 4. Revisión de logs y datos sensibles
Se revisó manualmente cada statement de log (`AppLogger`) generado o modificado por la IA para confirmar que no expone PII (correo, teléfono, DNI, tokens). Cualquier log que incluyera datos de usuario fue reescrito con `[redacted]` o eliminado.

### 5. Validación manual de la interfaz
La UI generada o modificada fue verificada ejecutando la app en el dispositivo personal del desarrollador:
- Concordancia visual con el diseño esperado.
- Flujo funcional completo (login → dashboard → movimientos → tarjeta).
- Se verificó adicionalmente que el **release build** se ejecuta correctamente en el celular personal, no solo en emulador.

---

## Tareas NO delegadas a la IA y por qué

### 1. Análisis de la necesidad del cliente
**Razón:** La IA no tiene acceso al contexto real del cliente, sus restricciones de negocio, sus prioridades ni su historial. Solo el desarrollador puede interpretar correctamente lo que el cliente necesita vs. lo que dice que necesita. La IA fue útil para estructurar el análisis de los requerimientos en base a mi visión, pero el análisis crítico del problema fue completamente humana.

### 2. Revisión objetiva de issues durante la codificación
**Razón:** La IA tiende a confirmar el enfoque que se le presenta ("sycophancy"). La identificación de problemas reales en el flujo de trabajo, inconsistencias arquitectónicas y decisiones técnicas que no eran del todo viables y requirió revisión humana independiente, para evitar el sesgo de confirmación. Se revisó manualmente el output de la IA antes de integrar cada cambio.

### 3. Definición y detalle de información sensible
**Razón:** Determinar qué datos son sensibles en el contexto específico de este producto bancario (qué es PII, qué debe cifrarse, qué no debe loguearse) requiere juicio sobre el dominio de negocio y el marco regulatorio aplicable. La IA proporcionó lineamientos generales OWASP, pero la clasificación concreta de campos y flujos fue decision propia.

### 4. QA y validación funcional
**Razón:** La verificación de que la app se comporta correctamente desde la perspectiva del usuario final: flujos completos, UX, casos no cubiertos por tests automatizados que requieren de ejecución manual y criterio humano. La IA no puede ejecutar la app ni percibir problemas de usabilidad o consistencia visual.

### 5. Generación de UI sin intervención humana
**Razón:** Se intentó con Jules y no funcionó. La generación autónoma de UI en Flutter requiere criterio estético, coherencia con el sistema de diseño y conocimiento del contexto del producto que la IA actual no puede garantizar sin supervisión. Cada componente de UI fue revisado o ajustado.

### 6. Remoción de deprecaciones
**Razón:** Aunque la IA puede sugerir el reemplazo de APIs deprecadas, la decisión de cuándo y cómo aplicar cada cambio requiere entender el impacto en el comportamiento de la app. Algunos reemplazos sugeridos por la IA introducían cambios de comportamiento sutiles.

