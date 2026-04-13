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
├── service/              # Feature-scoped services (API wrappers, external SDKs)
├── utils/                # Feature-scoped utility functions (e.g. formatters)
└── presentation/
    ├── bloc/             # BLoC state management (bloc, events, states)
    ├── pages/            # Page/screen widgets — slim shells only (see Widget Decomposition)
    └── widgets/          # All UI components broken into dedicated single-responsibility files
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
| Feature widgets | `presentation/widgets/` | `explore_header.dart`, `topic_card.dart` |
| Feature-scoped services | `service/` | `open_alex_service.dart` |
| Feature-scoped utilities | `utils/` | `explore_utils.dart` |
| Shared services/helpers | `core/utils/` or `core/network/` | `logger.dart`, `api_client.dart` |

---

# Widget Decomposition Rules

**This is the most important structural rule.** Pages and large widgets must be broken into small, focused, single-responsibility files inside `presentation/widgets/`. Do not leave private classes inline inside a page file if they can be reused or named as independent concepts.

## Pages Are Slim Shells

A `_page.dart` file should only:
- Own the page-level state (scroll controllers, text controllers, timers)
- Compose BLoC providers
- Wire callbacks between child widgets
- Build the top-level `Scaffold` / `CustomScrollView`

It must **not** define inline private widget classes like `_Header`, `_Card`, `_StatsRow`, etc. Extract those into their own files in `presentation/widgets/`.

**Example — correct:**

```
lib/features/explore/presentation/
├── pages/
│   └── explore_page.dart              # ~130 lines: StatefulWidget shell + _ExploreBody
└── widgets/
    ├── explore_header.dart            # ExploreHeader
    ├── explore_search_panel.dart      # ExploreSearchPanel
    ├── explore_spotlight_card.dart    # ExploreSpotlightCard, SpotlightCover, _EmojiCover
    ├── explore_metrics_row.dart       # ExploreMetricsRow, ExploreMetricCard
    ├── explore_states.dart            # ExploreLoadingContent, ExploreErrorState, ExploreEmptyState
    ├── learning_subjects_section.dart # LearningSubjectsCategoryFilter, LearningSubjectsGrid
    ├── learning_subject_card.dart     # LearningSubjectCard (animated grid card)
    ├── library_subject_sheet.dart     # LibrarySubjectSheet, WorkCard, WorkDetailPill
    ├── difficulty_badge.dart          # DifficultyBadge, LevelPill
    ├── subject_detail_hero.dart       # SubjectDetailHero, _HeroBackground, _BackButton
    ├── subject_stats_row.dart         # SubjectStatsRow, SubjectStatCard
    ├── subject_description_card.dart  # SubjectDescriptionCard
    └── topic_card.dart                # TopicCard (animated), _TopicIcon, _TopicText, _TopicMeta
```

## Widget File Grouping

A single widget file may contain **one public widget + its tightly-coupled private sub-widgets**. Do not dump unrelated widgets into one file.

**Good:** `topic_card.dart` exports `TopicCard` with private helpers `_TopicIcon`, `_TopicText`, `_TopicMeta`.

**Bad:** `explore_widgets.dart` dumping all explore widgets together.

## Naming Widget Files

- Name the file after the **primary public widget** it exports: `topic_card.dart` → `TopicCard`.
- For groups of related small widgets (loading/error/empty states), a shared file is acceptable: `explore_states.dart`.
- Prefix widget files with the feature name when they belong to a page subsection: `explore_header.dart`, `explore_metrics_row.dart`.
- For detail-page widgets, prefix with the entity name: `subject_detail_hero.dart`, `subject_stats_row.dart`.

## When to Extract

Extract a widget into its own file when **any** of the following apply:
- It has its own state (`StatefulWidget`) — always extract.
- It has a distinct visual responsibility (header, card, badge, stats row, sheet).
- It is more than ~40 lines.
- It would be named as a concept (e.g. `DifficultyBadge`, `SpotlightCard`, `MetricsRow`).

Keep it inline only for truly throwaway structural helpers (e.g. a one-line `_SectionLabel` that is not used elsewhere).

---

# Key Principles

1. **Data goes in `data/`** — All data layer code (models, API calls, local storage, repository implementations)
2. **Pages are slim shells** — Extract every named widget concept into its own file in `presentation/widgets/`
3. **One concept per widget file** — Each file exports one primary public widget; private helpers may live in the same file
4. **Repositories go in `repo/`** — Repository interfaces in `domain/repositories/`, implementations in `data/repositories/`
5. **Services go in `service/` or `core/`** — Feature-scoped services in `feature/service/`, shared services in `core/`
6. **BLoC stays in `presentation/bloc/`** — All state management logic

---

# File Naming Conventions

## Snake Case Required

All file names must use **snake_case**:

| Correct | Incorrect |
|---------|-----------|
| `user_model.dart` | `UserModel.dart` or `userModel.dart` |
| `auth_repository_impl.dart` | `AuthRepositoryImpl.dart` |
| `topic_card.dart` | `TopicCard.dart` |
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
| Widgets | *descriptive name of primary widget* | `topic_card.dart`, `difficulty_badge.dart` |
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

// 4. Project imports — always absolute (no relative imports)
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/topic_card.dart';
```

**Blank line between each section.**

## Class Structure

### Pages (StatefulWidget) — slim shell pattern

```dart
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // Controllers / timers / services
  final _scrollCtrl = ScrollController();

  @override
  void initState() { super.initState(); /* setup */ }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // Compose BLoC providers + hand off to a stateless body widget
    return BlocProvider(
      create: (_) => getIt<MyBloc>()..add(const LoadEvent()),
      child: _MyBody(/* pass controllers and callbacks */),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
// Stateless — receives everything via constructor, delegates rendering to widgets/

class _MyBody extends StatelessWidget {
  const _MyBody({required this.scrollCtrl, /* ... */});
  // ...
}
```

### Widgets — prefer Stateless, extract StatefulWidget always

```dart
class TopicCard extends StatefulWidget {
  const TopicCard({super.key, required this.topic, required this.accent});

  final LearningTopic topic;
  final Color accent;

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  // ...
}
```

Private sub-widgets in the same file use `_` prefix and no `key`:

```dart
class _TopicIcon extends StatelessWidget {
  const _TopicIcon({required this.emoji, required this.accent});
  // ...
}
```

### BLoC Pattern

**Event file** (`_event.dart`):
```dart
sealed class AuthEvent {}

final class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});
}
```

**State file** (`_state.dart`):
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

**Bloc file** (`_bloc.dart`):
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

## Section Comments

Use the dash-rule pattern for major sections inside a file:

```dart
// ── Hero ─────────────────────────────────────────────────────────────────────

class SubjectDetailHero extends StatelessWidget { ... }

// ── Stats row ─────────────────────────────────────────────────────────────────

class SubjectStatsRow extends StatelessWidget { ... }
```

---

# Model vs Entity Distinction

## Models (Data Layer)

- Located in `data/models/`
- Handle JSON serialization (with `json_serializable`) or extend entities for static datasources
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
- Pure Dart classes — no framework dependencies
- File suffix: `_entity.dart`

```dart
class UserEntity {
  final String id;
  final String email;

  UserEntity({required this.id, required this.email});
}
```

---

# Full Feature Example

**Creating a new feature?** Follow this exact layout:

```
lib/features/explore/
├── data/
│   ├── datasources/learning_subject_local_datasource.dart
│   ├── models/learning_subject_model.dart
│   └── repositories/learning_subject_repository_impl.dart
├── domain/
│   ├── entities/learning_subject.dart
│   ├── repositories/learning_subject_repository.dart
│   └── usecases/
│       ├── get_all_learning_subjects.dart
│       ├── get_subjects_by_category.dart
│       └── search_learning_subjects.dart
├── service/
│   └── open_alex_service.dart
├── utils/
│   └── explore_utils.dart
└── presentation/
    ├── bloc/
    │   ├── learning_subjects_bloc.dart
    │   ├── learning_subjects_event.dart
    │   └── learning_subjects_state.dart
    ├── pages/
    │   ├── explore_page.dart                  # slim shell
    │   └── learning_subject_detail_page.dart  # slim shell
    └── widgets/
        ├── explore_header.dart
        ├── explore_search_panel.dart
        ├── explore_spotlight_card.dart
        ├── explore_metrics_row.dart
        ├── explore_states.dart
        ├── learning_subjects_section.dart
        ├── learning_subject_card.dart
        ├── library_subject_sheet.dart
        ├── difficulty_badge.dart
        ├── subject_detail_hero.dart
        ├── subject_stats_row.dart
        ├── subject_description_card.dart
        └── topic_card.dart
```

**Adding a utility?** Put it in `core/utils/` (shared) or `feature/utils/` (feature-scoped):
```dart
// lib/features/explore/utils/explore_utils.dart
String formatCount(int count) { ... }
```

**Adding a shared widget?** Put it in `core/widgets/`:
```dart
// lib/core/widgets/custom_button.dart
```

**Adding a constant?** Put it in `core/constants/`:
```dart
// lib/core/constants/api_constants.dart
```

---

# Hard Rules

- **NEVER** define named widget concepts as private classes inside a `_page.dart` file. Extract them to `presentation/widgets/`.
- **NEVER** create files directly under `lib/features/{feature}/` without a subfolder.
- **NEVER** use PascalCase for file names. Always snake_case.
- **NEVER** dump multiple unrelated widgets into one widget file.
- **ALWAYS** keep pages as slim shells: state management, provider setup, callback wiring only.
