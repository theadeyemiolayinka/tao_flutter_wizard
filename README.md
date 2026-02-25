# tao_flutter_wizard

> **Enterprise-grade Mason-powered Flutter Clean Architecture scaffolding framework.**

A structured collection of Mason bricks that enforce feature-first Clean Architecture across Flutter projects.

Author: [TheAdeyemiOlayinka](https://theadeyemiolayinka.com)

---

## Architecture Philosophy

This framework enforces a strict **Feature-First Clean Architecture** pattern:

```
lib/features/{feature}/
  domain/
    entities/          ← Pure Dart, no framework deps. Freezed immutable domain types.
    repositories/      ← Interfaces only. I{Entity}Repository. Never "Impl".
    usecases/          ← Single-responsibility. TaskEither<Failure, T>.
  data/
    models/            ← Freezed + JSON. toEntity() / fromEntity().
    datasources/       ← Dio HTTP (remote) / storage (local). Never leaks to domain.
    repositories/      ← Implements domain interface. Maps model → entity.
  presentation/
    bloc/              ← Freezed events & states. bloc_concurrency transformer.
    pages/             ← StatelessWidget + BlocBuilder/Listener. No logic here.
    widgets/           ← Composable, feature-scoped UI.
  injection.dart       ← GetIt registrations. Auto-patched via mason:* anchors.
  routes.dart          ← GoRouter RouteBase list. Auto-patched via mason:routes.
  l10n/                ← ARB files per locale.
```

### Core Design Decisions

| Decision | Rationale |
|---|---|
| **`I{Name}Repository`** naming | No "Impl" suffix - the implementation *is* the repository. |
| **`fpdart` `Either` / `TaskEither`**| Typed error handling, no unchecked exceptions in domain. |
| **`get_it` manual registration** | No codegen magic. Explicit, readable, debuggable DI. |
| **`Freezed`** everywhere | Immutable entities, models, events, states. copyWith for free. |
| **`bloc_concurrency`** | `sequential()` by default. Prevents race conditions in event handlers. |
| **`HydratedBloc`** opt-in | State persistence is an explicit decision, not an afterthought. |
| **Anchor-comment auto-patching** | `// mason:repositories` etc. ensures DI and routing stay cohesive without manual edits. |

---

## Prerequisites

```bash
dart pub global activate mason_cli
```

---

## Setup

```bash
# From the root of THIS repo (or your project if using it as a submodule):
mason get
```

---

## Bricks

### 1. `feature` - Full Feature Skeleton

Generates the entire folder structure with anchor-ready `injection.dart` and `routes.dart`.

```bash
mason make feature --feature_name user_profile
```

**Generated output:**
```
lib/features/user_profile/
  injection.dart          ← // mason:datasources, // mason:repositories, // mason:blocs
  routes.dart             ← // mason:routes
  l10n/user_profile_en.arb
  presentation/pages/user_profile_page.dart
  user_profile.dart       ← barrel file
```

**Hook output (post-generation):**
```
 Feature "user_profile" scaffold generated!
  Next steps:
  1. In your app DI: register_user_profile_dependencies(getIt);
  2. In your router: ...userProfileRoutes,
  3. Add l10n arb file to l10n.yaml
  4. dart run build_runner build --delete-conflicting-outputs
```

---

### 2. `entity` - Freezed Entity + Model

Generates a domain entity and its data model with full JSON support and `toEntity`/`fromEntity` conversion.

```bash
mason make entity \
  --feature_name user_profile \
  --entity_name UserProfile \
  --fields '[{"name":"id","type":"String","isnullable":false},{"name":"displayName","type":"String","isnullable":false},{"name":"bio","type":"String","isnullable":true},{"name":"createdAt","type":"DateTime","isnullable":false}]'
```

**Generated:**
- `domain/entities/user_profile.dart` - Freezed entity
- `data/models/user_profile_model.dart` - Freezed model + `fromJson` / `toJson` / `toEntity()` / `fromEntity()`

**Template preview - entity:**
```dart
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String displayName,
    String? bio,
    required DateTime createdAt,
  }) = _UserProfile;
}
```

**Template preview - model:**
```dart
@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'displayName') required String displayName,
    @JsonKey(name: 'bio') String? bio,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  const UserProfileModel._();

  factory UserProfileModel.fromEntity(UserProfile entity) => UserProfileModel(
        id: entity.id,
        displayName: entity.displayName,
        bio: entity.bio,
        createdAt: entity.createdAt,
      );

  UserProfile toEntity() => UserProfile(
        id: id!,
        displayName: displayName!,
        bio: bio,
        createdAt: createdAt!,
      );
}
```

---

### 3. `repository` - Interface + Implementation + DataSource Stub

Generates the repository interface, implementation, and remote datasource. **Automatically patches `injection.dart`** via the post-gen hook.

```bash
mason make repository \
  --feature_name user_profile \
  --entity_name UserProfile \
  --methods '[{"signature":"getUserProfile(String id)","returnType":"UserProfile","methodName":"getUserProfile"},{"signature":"updateUserProfile(UserProfile profile)","returnType":"Unit","methodName":"updateUserProfile"}]'
```

**Generated:**
- `domain/repositories/i_user_profile_repository.dart`
- `data/repositories/user_profile_repository.dart`
- `data/datasources/user_profile_remote_datasource.dart`

**Auto-patched `injection.dart`:**
```dart
void registerUserProfileDependencies(GetIt getIt) {
  // Auto-inserted by hook ↓
  getIt.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSourceImpl(dio: getIt()),
  );
  // mason:datasources

  // Auto-inserted by hook ↓
  getIt.registerLazySingleton<IUserProfileRepository>(
    () => UserProfileRepository(remoteDataSource: getIt()),
  );
  // mason:repositories

  // mason:blocs
}
```

**Template preview - interface:**
```dart
abstract interface class IUserProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String id);
  Future<Either<Failure, Unit>> updateUserProfile(UserProfile profile);
}
```

---

### 4. `usecase` - TaskEither UseCase

```bash
mason make usecase \
  --feature_name user_profile \
  --usecase_name GetUserProfile \
  --entity_name UserProfile \
  --params "final String id;"
```

**Generated:** `domain/usecases/get_user_profile_usecase.dart`

```dart
class GetUserProfileParams {
  const GetUserProfileParams({required this.id});
  final String id;
}

class GetUserProfileUseCase
    implements UseCase<UserProfile, GetUserProfileParams> {
  GetUserProfileUseCase({required IUserProfileRepository repository})
      : _repository = repository;

  final IUserProfileRepository _repository;

  @override
  TaskEither<Failure, UserProfile> call(GetUserProfileParams params) =>
      TaskEither.tryCatch(
        () => _repository
            .getUserProfile(params.id)
            .then((e) => e.fold((f) => throw Exception(f.message), id)),
        (e, _) => ServerFailure(message: e.toString()),
      );
}
```

---

### 5. `bloc` - Freezed Bloc with Concurrency

```bash
mason make bloc \
  --feature_name user_profile \
  --bloc_name UserProfile \
  --events '["Load","Update","Clear"]' \
  --states '["Initial","Loading","Loaded","Error"]' \
  --hydrated false
```

**Generated:**
- `presentation/bloc/user_profile_bloc.dart`
- `presentation/bloc/user_profile_event.dart`
- `presentation/bloc/user_profile_state.dart`

```dart
// user_profile_event.dart
@freezed
sealed class UserProfileEvent with _$UserProfileEvent {
  const factory UserProfileEvent.load() = UserProfileLoadEvent;
  const factory UserProfileEvent.update() = UserProfileUpdateEvent;
  const factory UserProfileEvent.clear() = UserProfileClearEvent;
}

// user_profile_state.dart
@freezed
sealed class UserProfileState with _$UserProfileState {
  const factory UserProfileState.initial() = UserProfileInitialState;
  const factory UserProfileState.loading() = UserProfileLoadingState;
  const factory UserProfileState.loaded() = UserProfileLoadedState;
  const factory UserProfileState.error() = UserProfileErrorState;
}

// user_profile_bloc.dart
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc() : super(const UserProfileState.initial()) {
    on<UserProfileLoadEvent>(_onLoad, transformer: sequential());
    on<UserProfileUpdateEvent>(_onUpdate, transformer: sequential());
    on<UserProfileClearEvent>(_onClear, transformer: sequential());
  }
  // ...handler stubs
}
```

**With `--hydrated true`**, extends `HydratedBloc` and includes `fromJson`/`toJson` overrides:

```dart
class UserProfileBloc extends HydratedBloc<UserProfileEvent, UserProfileState> {
  // ...
  @override
  UserProfileState? fromJson(Map<String, dynamic> json) {
    try { return UserProfileState.fromJson(json); } catch (_) { return null; }
  }

  @override
  Map<String, dynamic>? toJson(UserProfileState state) {
    try { return state.toJson(); } catch (_) { return null; }
  }
}
```

---

### 6. `datasource` - Dio Remote DataSource

```bash
mason make datasource \
  --feature_name user_profile \
  --entity_name UserProfile \
  --include_local false
```

Generates a full `UserProfileRemoteDataSourceImpl` with `get`, `getAll`, `create`, `update`, `delete` - all typed against `UserProfileModel`.

---

### 7. `route` - GoRouter Route Entry

```bash
mason make route \
  --feature_name user_profile \
  --page_name UserProfileDetail \
  --route_path "/user/:id" \
  --route_params 'final id = state.pathParameters["id"]!;'
```

**Generated:**
- `routes/user_profile_detail_route.dart`
- `presentation/pages/user_profile_detail_page.dart`

**Auto-patches `routes.dart`:**
```dart
final List<RouteBase> userProfileRoutes = [
  // Auto-inserted by hook ↓
  userProfileDetailRoute,
  // mason:routes
];
```

---

### 8. `test` - Test Templates (mocktail)

```bash
# Bloc test
mason make test \
  --feature_name user_profile \
  --subject_name UserProfile \
  --test_type bloc

# Repository test
mason make test \
  --feature_name user_profile \
  --subject_name UserProfile \
  --test_type repository

# UseCase test
mason make test \
  --feature_name user_profile \
  --subject_name UserProfile \
  --test_type usecase
```

---

## Auto-Patching System

### Anchor Comments

Every `injection.dart` generated by the `feature` brick contains these anchors:

```dart
void registerUserProfileDependencies(GetIt getIt) {
  // mason:datasources
  // mason:repositories
  // mason:blocs
}
```

Every `routes.dart` contains:

```dart
final List<RouteBase> userProfileRoutes = [
  // mason:routes
];
```

### Hook Strategy

1. **`hook.dart`** - Dart script run by Mason post-generation.
2. **`anchor_patcher.dart`** - Shared utility with idempotency checks.
3. **Strategy:**
   - Read target file into string.
   - Check if file exists → fail gracefully with warning if missing.
   - Check if anchor exists → fail gracefully if missing.
   - Check if insertion already present → skip silently (idempotent).
   - `replaceFirst(anchor, '$insertion\n  $anchor')` - inserts above anchor.
   - Write back atomically.
4. **Import patching** - Adds missing `import` lines after the `get_it` import line.

---

## Required `pubspec.yaml` Dependencies

Add these to your Flutter project:

```yaml
dependencies:
  # State management
  bloc: ^8.1.4
  flutter_bloc: ^8.1.6
  hydrated_bloc: ^9.1.5
  bloc_concurrency: ^0.2.5

  # Functional programming
  fpdart: ^1.1.0

  # DI
  get_it: ^7.7.0

  # Networking
  dio: ^5.4.3+1

  # Routing
  go_router: ^14.2.7

  # Serialization
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

dev_dependencies:
  # Code generation
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0

  # Testing
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
```

---

## Full Workflow Example

```bash
# 1. Scaffold the feature
mason make feature --feature_name user_profile

# 2. Generate the entity
mason make entity \
  --feature_name user_profile \
  --entity_name UserProfile \
  --fields '[{"name":"id","type":"String","isnullable":false},{"name":"name","type":"String","isnullable":false}]'

# 3. Generate the repository (auto-patches injection.dart)
mason make repository \
  --feature_name user_profile \
  --entity_name UserProfile \
  --methods '[{"signature":"getUserProfile(String id)","returnType":"UserProfile","methodName":"getUserProfile"}]'

# 4. Generate a usecase
mason make usecase \
  --feature_name user_profile \
  --usecase_name GetUserProfile \
  --entity_name UserProfile \
  --params "final String id;"

# 5. Generate the bloc
mason make bloc \
  --feature_name user_profile \
  --bloc_name UserProfile \
  --events '["Load","Update"]' \
  --states '["Initial","Loading","Loaded","Error"]' \
  --hydrated false

# 6. Add a route (auto-patches routes.dart)
mason make route \
  --feature_name user_profile \
  --page_name UserProfile \
  --route_path "/user-profile"

# 7. Generate tests
mason make test --feature_name user_profile --subject_name UserProfile --test_type bloc
mason make test --feature_name user_profile --subject_name UserProfile --test_type repository
mason make test --feature_name user_profile --subject_name UserProfile --test_type usecase

# 8. Run code generation
dart run build_runner build --delete-conflicting-outputs
```

---

## Naming Conventions

| Concept | Pattern | Example |
|---|---|---|
| Feature dir | `snake_case` | `user_profile` |
| Entity | `PascalCase` | `UserProfile` |
| Repository interface | `I{Entity}Repository` | `IUserProfileRepository` |
| Repository implementation | `{Entity}Repository` | `UserProfileRepository` |
| Remote datasource | `{Entity}RemoteDataSource` | `UserProfileRemoteDataSource` |
| Bloc | `{Name}Bloc` | `UserProfileBloc` |
| UseCase | `{Action}{Entity}UseCase` | `GetUserProfileUseCase` |
| Route file | `{name}_route.dart` | `user_profile_route.dart` |

> Never use the `Impl` suffix. The concrete class *is* the implementation.

---

## License

MIT
