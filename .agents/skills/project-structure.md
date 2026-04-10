---
name: project-structure
description: Enforce the Clean Architecture folder structure, naming conventions, and code patterns when writing code in this Flutter project
---

# Project Structure Convention

When writing or creating code in this Flutter project, **always** follow this folder structure and coding patterns:

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

---

# File Naming Conventions

## Snake Case Required

All file names must use **snake_case**:

| Correct | Incorrect |
|---------|-----------|
| `user_model.dart` | `UserModel.dart` or `userModel.dart` |
| `auth_repository_impl.dart` | `AuthRepositoryImpl.dart` |
| `lesson_card.dart` | `LessonCard.dart` |
| `get_profile_usecase.dart` | `GetProfileUsecase.dart` |

## Suffix Patterns

| File Type | Suffix | Example |
|-----------|--------|---------|
| Models | `_model.dart` | `user_model.dart` |
| Repository implementations | `_repository_impl.dart` | `auth_repository_impl.dart` |
| Repository interfaces | *no suffix* (just name) | `auth_repository.dart` |
| Entities | `_entity.dart` | `user_entity.dart` |
| Use cases | `_usecase.dart` | `login_usecase.dart` |
| BLoC files | `_bloc.dart`, `_event.dart`, `_state.dart` | `auth_bloc.dart` |
| Pages | `_page.dart` | `home_page.dart` |
| Widgets | *descriptive name* | `lesson_card.dart`, `streak_badge.dart` |
| Data sources | `_{local/remote}_data_source.dart` | `auth_remote_data_source.dart` |

---

# Code Style Patterns

## Import Order

Always order imports in this sequence:

```dart
// 1. Dart core
import 'dart:async';
import 'dart:io';

// 2. Flutter packages
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 3. Third-party packages
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';

// 4. Project imports - absolute (relative imports discouraged)
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
```

**Blank line between each section.**

## Class Structure

### Pages (StatefulWidget)

```dart
class HomePage extends StatefulWidget {
  // const constructor with super.key
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Member variables
  
  // @override methods (initState, dispose, etc.)
  
  // Build method
  @override
  Widget build(BuildContext context) {
    // ...
  }
  
  // Helper methods (private with _)
  Widget _buildSection() { ... }
  
  // Computed properties
  double get _progress => ...;
}
```

### Widgets - Prefer Stateless

```dart
class LessonCard extends StatelessWidget {
  final String title;
  final int xp;
  final Color accentColor;

  const LessonCard({
    super.key,
    required this.title,
    required this.xp,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

### BLoC Pattern (Cubit-style)

**Event file** (`auth_event.dart`):
```dart
sealed class AuthEvent {}

final class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  LoginRequested({required this.email, required this.password});
}
```

**State file** (`auth_state.dart`):
```dart
sealed class AuthState {}

final class AuthInitial extends AuthState {}
final class AuthLoading extends AuthState {}
final class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);
}
final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

**Bloc file** (`auth_bloc.dart`):
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _loginUsecase;
  
  AuthBloc(this._loginUsecase) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // ...
  }
}
```

## Widget Organization in Build Methods

Use the **region comment** pattern for large build methods:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        _buildHeader(),
        _buildContent(),
        _buildFooter(),
      ],
    ),
  );
}

// ── Section header comments with dashes ───────────────────────────────────────

Widget _buildHeader() {
  return Container(
    // ...
  );
}

// ── Another section ───────────────────────────────────────────────────────────

void _showDialog() {
  // ...
}
```

## Comment Style

- Use `// ── Section title ───────────────────────────────────────────────────────` for major sections
- Use `//` for inline comments
- Use `///` for API documentation

---

# Model vs Entity Distinction

## Models (Data Layer)

- Located in `data/models/`
- Handle JSON serialization (with `json_serializable`)
- May contain conversion logic
- File suffix: `_model.dart`

```dart
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  
  UserModel({required this.id, required this.email});
  
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  UserEntity toEntity() => UserEntity(id: id, email: email);
}
```

## Entities (Domain Layer)

- Located in `domain/entities/`
- Pure Dart classes - no framework dependencies
- Business logic only
- File suffix: `_entity.dart`

```dart
class UserEntity {
  final String id;
  final String email;
  
  UserEntity({required this.id, required this.email});
}
```

---

# Examples

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
    ├── bloc/
    │   ├── profile_bloc.dart
    │   ├── profile_event.dart
    │   └── profile_state.dart
    ├── pages/profile_page.dart
    └── widgets/profile_avatar.dart
```

**Adding a utility?** Put it in `core/utils/`:
```dart
// lib/core/utils/date_formatter.dart
```

**Adding a shared widget?** Put it in `core/widgets/`:
```dart
// lib/core/widgets/custom_button.dart
```

**Adding a constant?** Put it in `core/constants/`:
```dart
// lib/core/constants/api_constants.dart
```

**NEVER** create files directly under `lib/features/{feature}/` or in random locations. Always place them in the correct subfolder based on their responsibility.

**NEVER** use PascalCase for file names. Always use snake_case.
