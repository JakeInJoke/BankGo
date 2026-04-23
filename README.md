# BankGo 🏦

Aplicación base de banca móvil desarrollada con **Flutter** siguiendo los principios de **Clean Architecture**, patrones de diseño modernos y buenas prácticas de desarrollo de software.

## 🏗️ Arquitectura

El proyecto implementa **Clean Architecture** con separación por capas y organización **Feature-First**:

```
lib/
├── core/                          # Núcleo compartido de la app
│   ├── constants/                 # Colores, strings, dimensiones
│   ├── errors/                    # Failures y Exceptions
│   ├── network/                   # NetworkInfo, DioInterceptor
│   ├── routes/                    # AppRouter (navegación centralizada)
│   ├── theme/                     # AppTheme (light/dark)
│   └── utils/                     # Validators, CurrencyFormatter, DateFormatter
│
├── features/                      # Módulos funcionales
│   ├── auth/                      # Autenticación
│   │   ├── data/
│   │   │   ├── datasources/       # AuthRemoteDataSource, AuthLocalDataSource
│   │   │   ├── models/            # UserModel
│   │   │   └── repositories/      # AuthRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/          # User
│   │   │   ├── repositories/      # AuthRepository (contrato)
│   │   │   └── usecases/          # LoginUseCase, LogoutUseCase, GetCachedUserUseCase
│   │   └── presentation/
│   │       ├── bloc/              # AuthBloc, AuthEvent, AuthState
│   │       ├── pages/             # SplashPage, LoginPage
│   │       └── widgets/           # LoginForm, CustomTextField
│   │
│   ├── dashboard/                 # Panel principal
│   │   ├── data/                  # DashboardRemoteDataSource, modelos, repositorio
│   │   ├── domain/                # AccountSummary, RecentTransaction, usecases
│   │   └── presentation/          # DashboardBloc, DashboardPage, widgets
│   │
│   ├── accounts/                  # Cuentas bancarias
│   │   ├── data/                  # AccountModel
│   │   ├── domain/                # Account entity
│   │   └── presentation/          # AccountsPage
│   │
│   ├── transactions/              # Historial de transacciones
│   │   ├── data/                  # TransactionModel, datasources, repositorio
│   │   ├── domain/                # Transaction entity, usecases
│   │   └── presentation/          # TransactionsBloc, TransactionsPage
│   │
│   └── profile/                   # Perfil de usuario
│       └── presentation/          # ProfilePage
│
├── injection_container.dart       # Inyección de dependencias (GetIt)
└── main.dart                      # Punto de entrada
```

## 🛠️ Stack Tecnológico

| Categoría | Paquete | Versión |
|-----------|---------|---------|
| **State Management** | `flutter_bloc` | ^8.1.3 |
| **Inyección de dependencias** | `get_it` | ^7.6.4 |
| **Networking** | `dio` | ^5.3.2 |
| **Almacenamiento local** | `shared_preferences`, `flutter_secure_storage` | ^2.2.2 / ^9.0.0 |
| **Programación funcional** | `dartz` | ^0.10.1 |
| **UI / Fonts** | `google_fonts`, `shimmer`, `cached_network_image` | - |
| **Utilidades** | `intl`, `equatable`, `logger` | - |
| **Testing** | `bloc_test`, `mockito`, `flutter_test` | - |

## 📐 Principios de diseño

- **Clean Architecture**: Separación en capas Data / Domain / Presentation
- **SOLID**: Responsabilidad única, open/closed, Liskov, interfaces, inversión de dependencias
- **BLoC Pattern**: Gestión de estado predecible y testeable
- **Repository Pattern**: Abstracción de fuentes de datos
- **Dependency Injection**: Con GetIt para bajo acoplamiento
- **Feature-First**: Organización modular por característica

## 🚀 Cómo ejecutar

### Prerrequisitos
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code con plugins de Flutter

### Instalación

```bash
# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

### Ejecutar pruebas

```bash
flutter test
```

## ✨ Características implementadas

- [x] **Pantalla de splash** con animaciones
- [x] **Login** con validación de formularios
- [x] **Dashboard** con tarjeta de cuenta, saldo total, acciones rápidas y transacciones recientes
- [x] **Cuentas** – listado de cuentas con diseño diferenciado por tipo
- [x] **Transacciones** – historial con filtros por tipo (ingreso/egreso/transferencia)
- [x] **Perfil** – información del usuario con opciones de seguridad
- [x] **Tema claro/oscuro** automático según el sistema
- [x] **Skeleton loading** con shimmer en el dashboard
- [x] **Navegación** con transiciones personalizadas
- [x] **Manejo de errores** centralizado con Failures/Exceptions
