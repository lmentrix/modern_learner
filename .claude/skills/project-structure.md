---
name: project-structure
description: Enforce the Clean Architecture folder structure when writing code in this Flutter project
---

# Project Structure Convention

When writing or creating code in this Flutter project, **always** follow this folder structure:

## Feature-Level Organization

Each feature lives under `lib/features/{feature_name}/` with Clean Architecture layers:

```
lib/features/{feature}/
├── data/
│   ├── datasources/      # API calls, local storage (remote & local data sources)
│   ├── models/           # Data models (DTOs, JSON serialization)
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Business entities (pure Dart classes)
│   ├── repositories/     # Repository abstractions (interfaces)
│   └── usecases/         # Business logic use cases
└── presentation/
    ├── bloc/             # BLoC state management (bloc, events, states)
    ├── pages/            # Page/screen widgets
    └── widgets/          # Reusable widgets specific to this feature
```

## Core-Level Organization

Shared/core functionality lives under `lib/core/`:

```
lib/core/
├── constants/            # App-wide constants (API endpoints, app config)
├── di/                   # Dependency injection setup
├── errors/               # Exception and failure classes
├── network/              # Network layer (API client, interceptors)
├── theme/                # App theme (colors, text styles, theme data)
├── utils/                # Utility functions and helpers
└── widgets/              # Reusable widgets across the app
```

## File Placement Rules

| File Type | Location | Example |
|-----------|----------|---------|
| Data models | `data/models/` | `user_model.dart` |
| API/Local data sources | `data/datasources/` | `auth_remote_data_source.dart` |
| Repository implementations | `data/repositories/` | `auth_repository_impl.dart` |
| Entities | `domain/entities/` | `user_entity.dart` |
| Repository interfaces | `domain/repositories/` | `auth_repository.dart` |
| Use cases | `domain/usecases/` | `login_usecase.dart` |
| BLoC files | `presentation/bloc/` | `auth_bloc.dart`, `auth_event.dart`, `auth_state.dart` |
| Page screens | `presentation/pages/` | `home_page.dart` |
| Feature widgets | `presentation/widgets/` | `lesson_card.dart`, `streak_badge.dart` |
| Services/helpers | `core/utils/` or `core/network/` | `logger.dart`, `api_client.dart` |

## Key Principles

1. **Data goes in `data/`** - All data layer code (models, API calls, local storage, repository implementations)
2. **Widgets go in `widgets/`** - All UI components that aren't full pages
3. **Repositories go in `repo/`** - Repository interfaces in `domain/repositories/`, implementations in `data/repositories/`
4. **Services go in `core/`** - Shared services, utilities, and network code
5. **BLoC stays in `presentation/bloc/`** - All state management logic

## Examples

**Creating a new feature?** Follow the pattern:
```
lib/features/profile/
├── data/
│   ├── datasources/profile_local_data_source.dart
│   ├── datasources/profile_remote_data_source.dart
│   ├── models/profile_model.dart
│   └── repositories/profile_repository_impl.dart
├── domain/
│   ├── entities/profile_entity.dart
│   ├── repositories/profile_repository.dart
│   └── usecases/get_profile_usecase.dart
└── presentation/
    ├── bloc/profile_bloc.dart
    ├── pages/profile_page.dart
    └── widgets/profile_avatar.dart
```

**Adding a utility?** Put it in `core/utils/`:
```dart
lib/core/utils/date_formatter.dart
```

**Adding a shared widget?** Put it in `core/widgets/`:
```dart
lib/core/widgets/custom_button.dart
```

**NEVER** create files directly under `lib/features/{feature}/` or in random locations. Always place them in the correct subfolder based on their responsibility.
