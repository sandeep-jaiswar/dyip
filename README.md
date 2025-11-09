# dyip

[![PR Checks](https://github.com/sandeep-jaiswar/dyip/actions/workflows/pr-checks.yml/badge.svg)](https://github.com/sandeep-jaiswar/dyip/actions/workflows/pr-checks.yml)
[![Release Build](https://github.com/sandeep-jaiswar/dyip/actions/workflows/release.yml/badge.svg)](https://github.com/sandeep-jaiswar/dyip/actions/workflows/release.yml)
[![codecov](https://codecov.io/gh/sandeep-jaiswar/dyip/branch/production/graph/badge.svg)](https://codecov.io/gh/sandeep-jaiswar/dyip)
[![Coverage Status](https://coveralls.io/repos/github/sandeep-jaiswar/dyip/badge.svg?branch=production)](https://coveralls.io/github/sandeep-jaiswar/dyip?branch=production)

A new Flutter project with production-grade CI/CD pipeline.

## Features

- 🎯 Automated testing and code quality checks
- 📦 Continuous integration with GitHub Actions
- 🚀 Automated release builds and deployment
- 📊 Code coverage tracking with Codecov and Coveralls
- 🔄 Automated dependency updates with Dependabot
- 🔐 Phone number authentication with Firebase (OTP-based)
- 🏛️ Clean Architecture with BLoC pattern
- ✅ Comprehensive unit and widget tests

## CI/CD Pipeline

This project uses GitHub Actions for continuous integration and deployment:

### PR Checks Workflow
- **Triggers**: Push to `production`/`development` branches, Pull requests
- **Jobs**:
  - Code quality checks (static analysis, formatting)
  - Automated testing with coverage reporting
  - Matrix testing on Flutter stable and beta channels
  - Android APK builds (debug and release)
  - Artifact uploads for review

### Release Workflow
- **Triggers**: Git tags (`v*.*.*`), Manual workflow dispatch
- **Jobs**:
  - Automated changelog generation
  - Release creation with GitHub Releases
  - Production Android builds (APK and AAB)
  - Build artifacts with versioned naming

### Performance Optimizations
- ⚡ Aggressive caching for Flutter SDK, pub dependencies, and Gradle
- 🔄 Parallel matrix builds for multiple Flutter channels
- ⏱️ Optimized to complete PR checks in <5 minutes
- 📦 Smart artifact management with appropriate retention periods

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK (included with Flutter)
- Android Studio / VS Code with Flutter extensions
- Firebase project (for authentication)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/sandeep-jaiswar/dyip.git
cd dyip
```

2. Get dependencies:
```bash
flutter pub get
```

3. **Configure Firebase** (Required for phone authentication):

   a. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Enable Phone Authentication:
      - Go to Firebase Console → Authentication → Sign-in method
      - Enable "Phone" provider
      - Add your test phone numbers if needed for development
   
   c. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
   
   d. Configure Firebase for your Flutter project:
   ```bash
   flutterfire configure
   ```
   This will:
   - Create a Firebase project or select existing one
   - Register your Flutter apps (iOS/Android)
   - Generate `lib/firebase_options.dart` with your configuration
   
   e. For Android, download `google-services.json`:
      - Go to Firebase Console → Project Settings → Your Android App
      - Download `google-services.json`
      - Place it in `android/app/` directory
   
   f. For iOS, download `GoogleService-Info.plist`:
      - Go to Firebase Console → Project Settings → Your iOS App
      - Download `GoogleService-Info.plist`
      - Place it in `ios/Runner/` directory using Xcode

4. Run the app:
```bash
flutter run
```

### Firebase Setup Notes

- **Phone Authentication Requirements:**
  - For production, you need to add SHA-1 and SHA-256 fingerprints to Firebase Console
  - Generate them with: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
  - Add fingerprints in Firebase Console → Project Settings → Your Android App

- **Testing:**
  - Use Firebase Console to add test phone numbers for development
  - Format: +[country code][number], e.g., +1234567890

- **iOS Additional Setup:**
  - Enable Push Notifications capability in Xcode
  - Add your APNs key in Firebase Console for production

### Development

#### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

#### Code Quality
```bash
# Static analysis
flutter analyze

# Format code
flutter format lib test

# Check formatting
flutter format --set-exit-if-changed lib test
```

#### Building

```bash
# Build Android APK (debug)
flutter build apk --debug

# Build Android APK (release)
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release
```

## Project Structure

```
dyip/
├── .github/
│   ├── workflows/         # GitHub Actions workflows
│   │   ├── pr-checks.yml  # PR validation and testing
│   │   └── release.yml    # Release builds and deployment
│   └── dependabot.yml     # Automated dependency updates
├── android/               # Android-specific code
├── ios/                   # iOS-specific code
├── lib/
│   ├── core/              # Core utilities and base classes
│   │   ├── error/         # Error handling (failures, exceptions)
│   │   └── usecases/      # Base use case classes
│   ├── features/
│   │   └── authentication/    # Phone authentication feature
│   │       ├── domain/        # Business logic layer
│   │       │   ├── entities/  # Domain entities (User)
│   │       │   ├── repositories/  # Repository interfaces
│   │       │   └── usecases/  # Use cases (SendOtp, VerifyOtp, etc.)
│   │       ├── data/          # Data layer
│   │       │   ├── datasources/   # Remote data sources (Firebase)
│   │       │   ├── models/        # Data models
│   │       │   └── repositories/  # Repository implementations
│   │       └── presentation/  # Presentation layer
│   │           ├── bloc/      # BLoC (events, states, bloc)
│   │           ├── pages/     # UI screens
│   │           └── widgets/   # Reusable widgets
│   ├── injection.dart     # Dependency injection setup
│   ├── firebase_options.dart  # Firebase configuration
│   └── main.dart          # App entry point
├── test/                  # Test files
├── pubspec.yaml          # Project dependencies
└── README.md             # This file
```

## Architecture

This project follows **Clean Architecture** principles with **BLoC** (Business Logic Component) pattern for state management.

### Layers

1. **Domain Layer** (innermost layer)
   - Contains business entities and business rules
   - Defines repository interfaces
   - Implements use cases
   - No dependencies on external frameworks

2. **Data Layer**
   - Implements repository interfaces defined in domain layer
   - Handles data from external sources (Firebase)
   - Maps data models to domain entities
   - Handles exceptions and converts them to failures

3. **Presentation Layer** (outermost layer)
   - Contains UI components (screens, widgets)
   - Uses BLoC for state management
   - Reacts to state changes and triggers events
   - Depends only on domain layer through BLoC

### Authentication Flow

1. User enters phone number → `SendOtpEvent`
2. BLoC calls `SendOtp` use case
3. Repository calls Firebase to send OTP
4. On success, BLoC emits `OtpSent` state
5. User enters OTP → `VerifyOtpEvent`
6. BLoC calls `VerifyOtp` use case
7. Repository verifies OTP with Firebase
8. On success, BLoC emits `Authenticated` state
9. User navigates to home screen
10. User can logout → `LogoutEvent` → `Unauthenticated` state

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

All PRs must pass the automated CI checks before merging.

## Branch Protection

The `production` and `development` branches are protected and require:
- ✅ All CI checks to pass
- ✅ Code review approval
- ✅ Up-to-date with base branch

## Release Process

To create a new release:

1. **Automated** (Recommended):
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
   The release workflow will automatically build and publish the release.

2. **Manual**:
   - Go to Actions → Release Build
   - Click "Run workflow"
   - Enter the version number
   - The workflow will create the release

## Resources

A few resources to get you started with Flutter development:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/) - Tutorials, samples, and API reference

## License

This project is licensed under the MIT License - see the LICENSE file for details.
