# tao_flutter_wizard

> **Enterprise-grade Mason-powered Flutter Clean Architecture scaffolding framework.**

A structured collection of Mason bricks that enforce feature-first Clean Architecture across Flutter projects.

Author: [TheAdeyemiOlayinka](https://theadeyemiolayinka.com)

---

## Architecture Philosophy

This framework enforces a strict **Feature-First Clean Architecture** pattern:

```
lib/
  app/
    bloc/              ← AppBloc - global orchestration (theme, auth, connectivity...)
  core/
    dto/               ← CoreDto interface (data layer contract)
    error/             ← Failure, exceptions, error_mapper
    network/           ← DioClient, interceptors, ApiResponse
    platform/          ← ConnectivityService
    theme/             ← AppColors, AppTextStyles, AppSpacing, AppRadius, AppTheme
                          AppTextField, AppButton, AppCheckbox, AppToggle, AppRadio
    usecase/           ← UseCase<T, Params> + NoParams
    router/            ← AppRouter (GoRouter)
    observer/          ← AppBlocObserver
    config/            ← AppConfig + EnvConfig
    injection.dart     ← Core-level GetIt registrations

  features/{feature}/
    domain/
      entities/        ← Pure Dart, no framework deps. Freezed immutable domain types.
      repositories/    ← Interfaces only. I{Entity}Repository.
      usecases/        ← Single-responsibility. TaskEither<Failure, T>.
    data/
      dtos/            ← Freezed + JSON. Implements CoreDto. toEntity() / fromEntity().
      datasources/     ← Dio HTTP (remote) / storage (local). Never leaks to domain.
      repositories/    ← Implements domain interface. Maps DTO → entity.
    application/
      services/        ← Feature services: business logic that spans more than one usecase.
    presentation/
      bloc/            ← Freezed events & states. bloc_concurrency transformer.
      pages/           ← StatelessWidget + BlocBuilder/Listener. No logic here.
      widgets/         ← Composable, feature-scoped UI.
    injection.dart     ← GetIt registrations. Auto-patched via mason:: hook anchors.
    routes.dart        ← GoRouter RouteBase list. Auto-patched via mason:routes.
    l10n/              ← ARB files per locale.
```

### Core Design Decisions

| Decision | Rationale |
|---|---|
| **`I{Name}Repository`** naming | No "Impl" suffix - the implementation *is* the repository. |
| **`fpdart` `Either` / `TaskEither`**| Typed error handling, no unchecked exceptions in domain. |
| **`get_it` manual registration** | No codegen magic. Explicit, readable, debuggable DI. |
| **`Freezed`** everywhere | Immutable entities, DTOs, models, events, states. copyWith for free. |
| **`bloc_concurrency`** | `sequential()` by default. Prevents race conditions in event handlers. |
| **`HydratedBloc`** opt-in | State persistence is an explicit decision, not an afterthought. |
| **`AppBloc`** for orchestration | Single authoritative source for auth, theme, locale, connectivity. |
| **`CoreDto`** interface | All DTOs implement a common contract for type-safe serialisation. |
| **`mason::` hook markers** | Double-colon markers are patched by post_gen hooks for usecases & services. |
| **Idempotency interceptor** | UUID v4 `Idempotency-Key` header on all mutating requests. |
| **Retry interceptor** | Exponential back-off (3 retries) for transient network/5xx errors. |

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

### 1. `core` - Full Core Architecture Skeleton

Generates the boilerplate for the entire `core/` and `app/bloc/` folders:
error handling, advanced Dio network stack, config, theme + design-system, AppBloc, routing, and DI.

```bash
mason make core \
  --use_cases true \
  --network true \
  --base_url "https://api.example.com" \
  --idempotency true \
  --retry true \
  --connectivity true \
  --config true \
  --bloc_observer true \
  --app_router true \
  --theme true \
  --design_system true \
  --app_bloc true
```

**Generated network stack (`core/network/`):**

| File | Purpose |
|---|---|
| `dio_client.dart` | Pre-configured `Dio` instance with all interceptors |
| `api_response.dart` | Generic `ApiResponse<T>` envelope (success / paginated / failure) |
| `interceptors/token_interceptor.dart` | Bearer token attach + queued refresh lock on 401 |
| `interceptors/idempotency_interceptor.dart` | UUID v4 `Idempotency-Key` header for POST/PUT/PATCH/DELETE |
| `interceptors/retry_interceptor.dart` | Exponential back-off: 3 retries, 1s/2s/4s delays, skips 4xx |
| `interceptors/logging_interceptor.dart` | Debug-mode request/response logging |
| `interceptors/error_interceptor.dart` | Normalises `DioException` → typed `AppException` subclasses |

**Generated platform services (`core/platform/`):**

| File | Purpose |
|---|---|
| `connectivity_service.dart` | `ConnectivityService` wrapping `connectivity_plus` - stream + one-shot check |

**Generated design-system (`core/theme/`):**

| File | Purpose |
|---|---|
| `app_colors.dart` | Material 3 colour palette tokens |
| `app_text_styles.dart` | Inter-based `TextTheme` |
| `app_spacing.dart` | 4-based spacing scale (xxs → xxxl) |
| `app_radius.dart` | Corner radius tokens + pre-built `BorderRadius` shortcuts |
| `input_theme.dart` | `InputThemeHelper` - factory methods for all input decoration presets |
| `app_theme.dart` | Light + dark `ThemeData` using all above tokens |
| `app_text_field.dart` | `AppTextField` with modes: normal / password / email / phone / textarea |
| `app_button.dart` | `AppButton` with variants: filled / outlined / text / tonal / destructive / pill |
| `app_checkbox.dart` | `AppCheckbox` with label, subtitle, tristate |
| `app_toggle.dart` | `AppToggle` with label, subtitle, custom colours |
| `app_radio.dart` | `AppRadioGroup<T>` - typed, with labels and subtitles |

**Generated `app/bloc/`:**

See **[AppBloc](#appbloc---app-orchestration)** section below.

---

### 2. `feature` - Full Feature Skeleton

Generates the entire folder structure with anchor-ready `injection.dart` and `routes.dart`.

```bash
mason make feature --feature_name user_profile
```

**Generated output:**
```
lib/features/user_profile/
  injection.dart          ← // mason::datasources / ::repositories / ::services / ::usecases / ::blocs
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

### 3. `entity` - Freezed Entity + Model

Generates a domain entity and its data model with full JSON support and `toEntity`/`fromEntity` conversion.

```bash
mason make entity \
  --feature_name user_profile \
  --entity_name UserProfile \
  --fields 'id:String|displayName:String|bio:String?|createdAt:DateTime'
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

### 4. `repository` - Interface + Implementation + DataSource Stub

Generates the repository interface, implementation, and remote datasource. **Automatically patches `injection.dart`** via the post-gen hook.

```bash
mason make repository \
  --feature_name user_profile \
  --entity_name UserProfile \
  --methods 'getUserProfile(String id):UserProfile|updateUserProfile(UserProfile profile):Unit'
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

### 5. `usecase` - TaskEither UseCase

```bash
mason make usecase \
  --feature_name user_profile \
  --usecase_name GetUserProfile \
  --entity_name UserProfile \
  --params 'id:String'
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

> **Auto-injection:** the post_gen hook patches `features/user_profile/injection.dart`
> under the `// mason::usecases` marker automatically.

---

### 10. `dto` - Freezed Data Transfer Object

Generates a Freezed + `json_serializable` DTO in the feature's **data layer**,
implementing `CoreDto` (`core/dto/core_dto.dart`) and scaffolding `fromEntity`/`toEntity`.

```bash
mason make dto \
  --feature_name user_profile \
  --dto_name UserProfile \
  --entity_name UserProfile \
  --fields 'id:String|name:String|bio:String?'
```

**Generated:**
- `core/dto/core_dto.dart` - abstract interface (generated once by `core` brick or first dto run)
- `features/user_profile/data/dtos/user_profile_dto.dart`

```dart
@freezed
class UserProfileDto
    with _$UserProfileDto
    implements CoreDto<UserProfileDto> {
  const UserProfileDto._();
  const factory UserProfileDto({
    required String id,
    required String name,
    String? bio,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);

  factory UserProfileDto.fromEntity(UserProfile entity) =>
      UserProfileDto(id: entity.id, name: entity.name, bio: entity.bio);

  UserProfile toEntity() =>
      UserProfile(id: id, name: name, bio: bio);

  @override
  Map<String, dynamic> toJson() => _$UserProfileDtoToJson(this);
}
```

---

### 11. `service` - Feature Application Service

Generates a service interface + implementation in the **application layer**
(`features/{name}/application/services/`) and auto-registers it in `injection.dart`.

```bash
mason make service \
  --feature_name auth \
  --service_name AuthSession
```

**Generated:**
- `features/auth/application/services/auth_session_service.dart` - abstract interface
- `features/auth/application/services/auth_session_service_impl.dart` - concrete impl

**Auto-patched `features/auth/injection.dart`:**
```dart
void registerAuthDependencies(GetIt getIt) {
  // mason::services
  getIt.registerLazySingleton<AuthSessionService>(
    () => AuthSessionServiceImpl(),
  );
  ...
}
```

---

### AppBloc - App Orchestration

Generated by `mason make core --app_bloc true` into `lib/app/bloc/`.

`AppBloc` is a `HydratedBloc` that owns all cross-cutting app concerns:

| Field | Type | Persisted | Description |
|---|---|---|---|
| `themeMode` | `ThemeMode` | ✅ | Light / dark / system |
| `locale` | `Locale?` | ✅ | App locale (null = device default) |
| `isFirstLaunch` | `bool` | ✅ | Cleared after onboarding |
| `authStatus` | `AuthStatus` | ❌ | `unknown` / `authenticated` / `unauthenticated` |
| `connectivityStatus` | `ConnectivityStatus` | ❌ | `online` / `offline` |
| `forceUpdateRequired` | `bool` | ❌ | From remote config |

**Events:**
```dart
AppEvent.started()
AppEvent.themeModeChanged(ThemeMode.dark)
AppEvent.localeChanged(Locale('fr'))
AppEvent.authStatusChanged(AuthStatus.authenticated)
AppEvent.connectivityChanged(ConnectivityStatus.offline)
AppEvent.forceUpdateFlagReceived(required: true)
AppEvent.firstLaunchAcknowledged()
```

**Usage in `main.dart`:**
```dart
BlocProvider(
  create: (_) => getIt<AppBloc>()..add(const AppEvent.started()),
  child: BlocBuilder<AppBloc, AppState>(
    builder: (context, state) => MaterialApp.router(
      themeMode: state.themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: state.locale,
      routerConfig: appRouter,
    ),
  ),
)
```

---

### 6. `bloc` - Freezed Bloc with Concurrency

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

### 7. `datasource` - Dio Remote DataSource

```bash
mason make datasource \
  --feature_name user_profile \
  --entity_name UserProfile \
  --crud_datasource true \
  --methods '' \
  --include_local false
```

Generates a full `UserProfileRemoteDataSourceImpl` with `get`, `getAll`, `create`, `update`, `delete` - all typed against `UserProfileModel`.

---

### 8. `route` - GoRouter Route Entry

```bash
mason make route \
  --feature_name user_profile \
  --page_name UserProfileDetail___Id \
  --path_params 'final id = state.pathParameters["id"]!;'
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

### 9. `test` - Test Templates (mocktail)

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
  // mason::datasources     ← patched by: datasource brick
  // mason::repositories    ← patched by: repository brick
  // mason::services        ← patched by: service brick (post_gen hook)
  // mason::usecases        ← patched by: usecase brick (post_gen hook)
  // mason::blocs           ← patched by: bloc brick
}
```

> **Note:** `mason::` (double-colon) markers are used by post_gen hooks from
> the `usecase` and `service` bricks. Single-colon `mason:` markers are
> used by bricks that patch files directly during generation (datasource, repository).

Every `routes.dart` contains:

```dart
final List<RouteBase> userProfileRoutes = [
  // mason:routes
];
```

### Hook Strategy

1. **`pre_gen.dart`** - Reads `pubspec.yaml` for `package_name`, parses field/param lists.
2. **`post_gen.dart`** - Patches target files (injection.dart, routes.dart) via anchor replacement.
3. **Idempotency:**
   - Checks if file exists → graceful warning if missing.
   - Checks if anchor exists → graceful warning if missing.
   - Checks if insertion already present → silently skips.
   - Uses `replaceFirst(anchor, '$insertion\n  $anchor')` - inserts above anchor and preserves it.
4. **Import patching** - adds missing `import` statements at the top of the file.

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

  # Connectivity
  connectivity_plus: ^6.0.3

  # Idempotency key generation
  uuid: ^4.4.0

  # Routing
  go_router: ^14.2.7

  # Serialization
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Fonts
  google_fonts: ^6.2.1

dev_dependencies:
  # Code generation
  build_runner: ^2.4.13
  freezed: ^2.5.7
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
# 1. Scaffold the core architecture
mason make core \
  --use_cases true \
  --network true \
  --base_url "https://api.example.com" \
  --idempotency true \
  --retry true \
  --connectivity true \
  --config true \
  --bloc_observer true \
  --app_router true \
  --theme true \
  --design_system true \
  --app_bloc true

# 2. Scaffold a feature
mason make feature --feature_name user_profile

# 3. Generate the domain entity
mason make entity \
  --feature_name user_profile \
  --entity_name UserProfile \
  --fields 'id:String|name:String|bio:String?'

# 4. Generate a DTO (data layer, with fromEntity/toEntity stubs)
mason make dto \
  --feature_name user_profile \
  --dto_name UserProfile \
  --entity_name UserProfile \
  --fields 'id:String|name:String|bio:String?'

# 5. Generate the repository (auto-patches injection.dart)
mason make repository \
  --feature_name user_profile \
  --entity_name UserProfile \
  --methods 'getUserProfile(String id):UserProfile'

# 6. Generate a feature service (auto-patches injection.dart under ::services)
mason make service \
  --feature_name user_profile \
  --service_name UserProfileCache

# 7. Generate a usecase (auto-patches injection.dart under ::usecases)
mason make usecase \
  --feature_name user_profile \
  --usecase_name GetUserProfile \
  --entity_name UserProfile \
  --params 'id:String'

# 8. Generate the bloc
mason make bloc \
  --feature_name user_profile \
  --bloc_name UserProfile \
  --events 'Load,Update,Clear' \
  --states 'Initial,Loading,Loaded,Error' \
  --hydrated false

# 9. Add a route (auto-patches routes.dart)
mason make route \
  --feature_name user_profile \
  --page_name UserProfile \
  --path_params ''

# 10. Generate tests
mason make test --feature_name user_profile --subject_name UserProfile --test_type bloc
mason make test --feature_name user_profile --subject_name UserProfile --test_type usecase

# 11. Run code generation
dart run build_runner build --delete-conflicting-outputs
```

---

## Naming Conventions

| Concept | Pattern | Example |
|---|---|---|
| Feature dir | `snake_case` | `user_profile` |
| Entity | `PascalCase` | `UserProfile` |
| DTO | `{Name}Dto` | `UserProfileDto` |
| Repository interface | `I{Entity}Repository` | `IUserProfileRepository` |
| Repository implementation | `{Entity}Repository` | `UserProfileRepository` |
| Remote datasource | `{Entity}RemoteDataSource` | `UserProfileRemoteDataSource` |
| Bloc | `{Name}Bloc` | `UserProfileBloc` |
| UseCase | `{Action}{Entity}UseCase` | `GetUserProfileUseCase` |
| Feature service interface | `{Name}Service` | `UserProfileCacheService` |
| Feature service impl | `{Name}ServiceImpl` | `UserProfileCacheServiceImpl` |
| Route file | `{name}_route.dart` | `user_profile_route.dart` |

> Never use the `Impl` suffix except for service implementations - the concrete class *is* the repository.

---

## License

MIT
