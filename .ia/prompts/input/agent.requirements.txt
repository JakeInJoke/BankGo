# Documento de Requerimientos de Negocio: BankGo Mobile App

**Versión:** 1.0
**Estado:** Finalizado
**Rol:** Business Analyst Senior

---

## 1. Contexto y Objetivos
[cite_start]BankGo es una aplicación móvil de banca personal enfocada en clientes finales[cite: 4]. [cite_start]El objetivo principal es entregar una solución funcional demostrando el uso responsable y efectivo de herramientas de IA (GitHub Copilot, Claude, Gemini) para optimizar el ciclo de desarrollo (SDLC)[cite: 7, 9].

---

## 2. Requerimientos Funcionales (Alcance Mínimo)

| ID | Módulo | Requerimiento Detallado |
| :--- | :--- | :--- |
| **FR-01** | **Autenticación** | [cite_start]Implementación de OIDC/OAuth2 + PKCE de forma simulada para acceso seguro[cite: 14]. |
| **FR-02** | **Dashboard** | [cite_start]Pantalla principal con listado de cuentas y visualización de saldos[cite: 15]. |
| **FR-03** | **Movimientos** | [cite_start]Detalle de transacciones por cuenta incluyendo paginación simple[cite: 16]. |
| **FR-04** | **Transferencias** | [cite_start]Flujo a beneficiario mock con pantallas de revisión y confirmación[cite: 17]. |
| **FR-05** | **Gestión de Tarjeta** | [cite_start]Función para congelar/descongelar tarjetas con flujo de confirmación[cite: 18]. |
| **FR-06** | **Modo Offline** | [cite_start]Capacidad de lectura de datos no sensibles desde caché local sin conexión[cite: 5, 19]. |
| **FR-07** | **Notificaciones** | [cite_start]Alertas in-app tras la confirmación exitosa de una transferencia[cite: 20]. |

---

## 3. Requerimientos No Funcionales

### 🛡️ Seguridad y Buenas Prácticas
* [cite_start]**OWASP:** Cumplimiento de lineamientos de seguridad para aplicaciones móviles[cite: 46].
* [cite_start]**Privacidad de Datos:** Prohibición estricta de incluir Información de Identificación Personal (PII) en los logs[cite: 27].
* [cite_start]**Manejo de Tokens:** Uso de tokens simulados bajo principios de seguridad básica[cite: 27].

### ⚡ Rendimiento y UX
* [cite_start]**Estados de Interfaz:** Implementación obligatoria de estados de carga, error, lista vacía y reintento[cite: 21].
* [cite_start]**Paginación:** Requerida en el listado de movimientos para eficiencia de datos[cite: 16].

### ⚙️ Disponibilidad
* [cite_start]**Persistencia Local:** Almacenamiento local obligatorio para habilitar la lectura en modo offline[cite: 26].

---

## 4. Requerimientos Técnicos y de IA

### Ciclo de Vida y Herramientas (SDLC)
* [cite_start]**IA Explícita:** Uso obligatorio de herramientas como GitHub Copilot, Claude o Gemini en codificación, refactorización y documentación[cite: 33, 36, 37].
* [cite_start]**Validación:** El desarrollador debe validar manualmente el output de la IA y documentar qué tareas no delegó y por qué[cite: 40, 41].
* [cite_start]**CI/CD:** Pipeline básico que incluya Lint, Unit Tests y Build[cite: 30].

### Arquitectura y Documentación
* [cite_start]**Diagramas:** Entrega obligatoria de diagrama de arquitectura y wireframes del flujo principal[cite: 23, 32].
* [cite_start]**Backend:** Uso de API REST o GraphQL simulada (Mock)[cite: 24].
* [cite_start]**Testing:** Inclusión de 3 a 5 pruebas unitarias significativas[cite: 29].

---

## 5. Entregables Obligatorios
1. [cite_start]**Código Fuente:** Repositorio ejecutable[cite: 49].
2. [cite_start]**Documentación:** README, decisiones técnicas y documento de uso de IA (`ai-usage.md`)[cite: 31, 54].
3. [cite_start]**Evidencias:** Pruebas unitarias y pipeline CI/CD configurado[cite: 51, 52].
4. [cite_start]**Arquitectura:** Diagramas y wireframes[cite: 50, 53].