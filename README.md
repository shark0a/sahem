# 🍳 Sahem — Context-Aware Recipe Discovery App

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![BLoC](https://img.shields.io/badge/State-BLoC%2FCubit-61DAFB)
![License](https://img.shields.io/badge/License-MIT-green)

Sahem is a **production-grade Flutter application** that intelligently suggests recipes based on your **time of day**, **geographic location**, and **local cuisine preferences** — powered by [TheMealDB API](https://www.themealdb.com/).

---

## ✨ Features

| Feature | Details |
|---|---|
| 🌅 Context Engine | Detects breakfast / lunch / dinner time automatically |
| 📍 Location Awareness | Reverse-geocodes your position to suggest regional cuisine |
| 🔍 Debounced Search | 400ms RxDart debounce, distinct filter, live results |
| ❤️ Favorites | Hive-persisted favorites with swipe-to-delete |
| 📶 Offline Support | Falls back to Hive cache when no internet |
| 🔔 Meal Notifications | WorkManager schedules daily 08:00 / 14:00 / 19:00 reminders |
| 💫 Animations | flutter_animate + shimmer loading skeletons |
| 🌙 Dark Mode | Full Material 3 light & dark theme support |

---

## 🏗️ Architecture

```
Clean Architecture + BLoC (Cubit) + Repository Pattern
┌─────────────────────────────────────────────────────┐
│  Presentation  │  Cubits (HomeCubit, SearchCubit,   │
│                │  FavoritesCubit) + Screens + Widgets│
├─────────────────────────────────────────────────────┤
│  Domain        │  Entities + Repositories (abstract) │
│                │  + UseCases                         │
├─────────────────────────────────────────────────────┤
│  Data          │  Models + RemoteDatasource (Dio)    │
│                │  + LocalDatasource (Hive)           │
│                │  + RepositoryImpl                   │
└─────────────────────────────────────────────────────┘
```

### Dependency Injection

| Scope | Annotation | Classes |
|---|---|---|
| Forever singleton | `@singleton` | LocationService, NotificationService, DioClient, AppRouter |
| Lazy singleton | `@LazySingleton` | RecipeRepositoryImpl |
| New per request | `@injectable` | UseCases, Cubits, ContextHelper |
| Async pre-resolved | `@preResolve` | HiveInterface |

---

## 🛠️ Tech Stack

```yaml
flutter_bloc: ^8.1.3        # State management (Cubit pattern)
get_it + injectable: latest  # Dependency injection
hive_flutter: ^1.1.0        # Local DB (favorites + cache)
dio + dio_cache_interceptor  # HTTP + caching
geolocator + geocoding       # Location services
flutter_local_notifications  # Push notifications
workmanager: ^0.5.2          # Background task scheduling
cached_network_image         # Image caching
flutter_animate: ^4.3.0     # Animations
shimmer: ^3.0.0              # Loading skeletons
connectivity_plus            # Network state
dartz: ^0.10.1               # Either / Failure pattern
go_router: ^12.1.1           # Declarative routing
rxdart: ^0.27.7              # Debounce / Streams
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.x (`flutter --version`)
- Dart 3.x
- Android SDK / Xcode (for iOS)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/your-org/sahem.git
cd sahem

# 2. Install dependencies
flutter pub get

# 3. Generate DI + Hive adapters (REQUIRED after adding @injectable classes)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

### Permissions Required

**Android** (`AndroidManifest.xml`):
- `INTERNET`, `ACCESS_NETWORK_STATE`
- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- `POST_NOTIFICATIONS` (Android 13+)
- `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`

**iOS** (`Info.plist`):
- `NSLocationWhenInUseUsageDescription`
- Background modes: `fetch`, `processing`

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage (requires lcov)
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

### Test Coverage

| Module | Tests |
|---|---|
| `ContextHelper` | Meal type detection, cuisine mapping, flags |
| `RecipeRepository` | Online/offline fetch, caching, favorites toggle |
| `SearchCubit` | Debounce, empty state, error state, distinct |
| `HomeCubit` | Location integration, offline fallback, refresh |
| `FavoritesCubit` | Load, remove, error states |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/     # AppColors, AppStrings, ApiEndpoints, AppTheme
│   ├── di/            # injection.dart, injection.config.dart (generated),
│   │                  # hive_module.dart, network_module.dart
│   ├── errors/        # Failures, Exceptions
│   ├── network/       # DioClient, CacheInterceptor
│   ├── services/      # LocationService, NotificationService, NetworkInfo
│   └── utils/         # ContextHelper (meal type + cuisine detection)
├── data/
│   ├── datasources/   # RecipeRemoteDatasource, RecipeLocalDatasource
│   ├── models/        # RecipeModel (@HiveType), generated adapter
│   └── repositories/  # RecipeRepositoryImpl
├── domain/
│   ├── entities/      # Recipe (pure Dart, Equatable)
│   ├── repositories/  # RecipeRepository (abstract)
│   └── usecases/      # GetSuggestedRecipes, SearchRecipes, 
│                      # ToggleFavorite, GetFavorites
├── presentation/
│   ├── cubits/        # HomeCubit, SearchCubit, FavoritesCubit + States
│   ├── router/        # AppRouter (GoRouter, @singleton)
│   ├── screens/       # Home, Search, Detail, Favorites, Splash
│   └── widgets/       # RecipeCard, ShimmerCard, AnimatedHeartButton,
│                      # OfflineBanner, EmptyStateWidget, BottomNavBar
└── main.dart          # DI init → Notifications → runApp
```

---

## 🔄 CI/CD

GitHub Actions pipeline (`.github/workflows/main.yml`):

```
push to main
    │
    ├── quality    → flutter analyze + dart format
    │
    ├── test       → flutter test --coverage + Codecov upload
    │
    ├── build-android  → flutter build apk --split-per-abi
    │                    → GitHub Release + APK upload
    │
    └── build-ios  → flutter build ios --no-codesign (macOS runner)
```

---

## 🎨 Design System

| Token | Value |
|---|---|
| Primary | `#F4A226` (warm amber) |
| Background | `#FAFAF8` (off-white) |
| Surface | `#FFFFFF` |
| Card shadow | `rgba(0,0,0,0.08)` |
| Border radius | `20px` (cards), `16px` (inputs), `12px` (list items) |
| Heading font | **Nunito** (700/800) |
| Body font | **Inter** (400/500) |

---

## 📜 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 🙏 Attributions

- Recipe data: [TheMealDB](https://www.themealdb.com/) (free tier)
- Design reference: Custom Figma → React design system
- Icons: [Material Symbols](https://fonts.google.com/icons)
