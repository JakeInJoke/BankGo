# Arquitectura Técnica: BankGo Mobile App
**Documento de Diseño de Sistemas (SDD)**

---

## 1. Patrón Arquitectónico: Clean Architecture + MVVM

Para garantizar la testabilidad, escalabilidad y la independencia de frameworks, se ha definido una estructura de tres capas principales.

### Estructura de Capas
1. **Domain Layer (Capa Central):** Contiene las Entidades de Negocio, los Casos de Uso (Interactors) y las interfaces de los Repositorios. Es 100% independiente de bibliotecas externas.
2. **Data Layer:** Implementa las interfaces del dominio. Aquí reside el **Repository Pattern**, que orquestra la lógica entre el `RemoteDataSource` (Retrofit/Ktor para Mock API) y el `LocalDataSource` (Room/SQLite para Cache).
3. **Presentation Layer:** Sigue el patrón **MVVM**. Los ViewModels se encargan de la lógica de estado de la UI, comunicándose con la capa de Dominio mediante Inyección de Dependencias.

---

## 2. Estrategia de Datos: Repository Pattern & Offline First

La arquitectura implementa una política de **"Cache-Aside"** para cumplir con el requerimiento de modo offline.

- **Alternancia de Datos:** - Al realizar una consulta, el Repositorio intenta obtener datos del `RemoteDataSource`.
    - Tras una respuesta exitosa, actualiza el `LocalDataSource` (Cache).
    - Ante un fallo de red o estado offline, el Repositorio retorna automáticamente el flujo de datos desde la Cache Local.
- **Mocking:** La capa de red apunta a un servidor de mocks (ej. MockLab o un interceptor local) que simula latencia y códigos de error HTTP para validar los estados de carga y error en la UI.

---

## 3. Inyección de Dependencias (DI) y Testabilidad

Se configura un contenedor de dependencias (ej. Hilt, Koin o Swinject) para desacoplar las implementaciones y facilitar los **Unit Tests**.

### Configuración de Módulos:
- **NetworkModule:** Provee el cliente HTTP y los servicios API.
- **DatabaseModule:** Provee la instancia de la base de datos local y los DAOs.
- **RepositoryModule:** Vincula las interfaces del Dominio con las implementaciones de la capa de Data.
- **UseCaseModule:** Inyecta los casos de uso en los ViewModels.

**Impacto en Testing:** Esta configuración permite sustituir fácilmente los `DataSources` reales por `Mocks` o `Fakes` durante las pruebas unitarias, asegurando que la lógica de negocio se testee de forma aislada.

---

## 4. Pipeline CI/CD: Automatización del SDLC

Para mantener un flujo de entrega continua optimizado, se define el siguiente pipeline (ej. GitHub Actions):

1. **Etapa 1: Lint (Calidad de Código)**
   - Ejecución de analizadores estáticos (Ktlint, SwiftLint, Detekt).
   - Verificación de estilos y reglas de seguridad básicas.
2. **Etapa 2: Test (Validación)**
   - Ejecución automatizada de **Unit Tests** (JUnit, XCTest).
   - Generación de reportes de cobertura (mínimo esperado 70% en Domain Layer).
3. **Etapa 3: Build (Construcción)**
   - Generación del artefacto (.apk, .aab, .ipa) en entorno de staging/debug.
   - Firma del binario para distribución en herramientas de testing (Firebase App Distribution / TestFlight).

---

## 5. Diseño de Componentes (Diagrama Conceptual)



1. **UI (View):** Observa el estado del ViewModel.
2. **ViewModel:** Expone `StateFlow` o `LiveData`.
3. **Use Case:** Ejecuta la lógica de negocio (ej. `ExecuteTransferUseCase`).
4. **Repository:** Decide si los datos vienen de la Web o del almacenamiento local.
5. **Data Sources:** Implementaciones específicas de red y persistencia.

---

## 6. Consideraciones de IA en la Arquitectura
- **Generación de Boilerplate:** Se sugiere utilizar IA para generar las clases de datos (DTOs) y los mapeadores entre capas.
- **Unit Test Generation:** Delegar a la IA la creación de pruebas unitarias basadas en los contratos de los Repositorios definidos en este documento.