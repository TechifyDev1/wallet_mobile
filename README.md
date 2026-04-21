# Wallet Mobile

A Flutter wallet application built with Cupertino widgets and Riverpod. This mobile client connects to the companion `wallet_system` backend, which I also built, to handle authentication, wallet creation, funding, transfers, transaction history, and profile-related account operations.

## Overview

This project is organized around feature-first folders, repository-based data access, and Riverpod providers for state management. Authentication tokens and theme preference are stored securely on-device, while API calls are routed through a shared HTTP client that attaches auth headers, refreshes expired tokens, and logs the user out when a session can no longer be recovered.

## Full-Stack Context

This repository is the mobile client for the wallet platform. The backend lives in the companion repository:

[wallet_system](https://github.com/TechifyDev1/wallet_system)

Together, the two projects cover:

- Mobile onboarding and authenticated wallet experience in Flutter
- REST API development in Spring Boot
- Token-based authentication with refresh-token support for app clients
- Wallet creation, funding, transfers, and transaction history persistence
- User profile and account security flows across client and server

## What The App Does

- Register a new account
- Sign in with email and password
- Reset a forgotten password with email, secret key, and new password
- Create a 6-digit transaction PIN after first-time onboarding
- Load the authenticated user profile and wallet summary
- Fund the wallet with an idempotency key
- Search users and send money to a selected recipient
- Show recent contacts during transfer flow
- Display recent transactions on the home screen
- Browse paginated transaction history in the activity tab
- View and update account details such as email and phone number
- Change password from profile settings
- Toggle light and dark mode
- Sign out and clear stored session data

## Tech Stack

- Flutter
- Dart
- `flutter_riverpod` for app state
- `http` for API communication
- `flutter_secure_storage` for tokens and persisted theme
- `intl`, `decimal`, and `uuid` for formatting and transaction helpers
- Cupertino-based UI components

## Project Structure

```text
lib/
  main.dart
  src/
    common_widgets/
    core/
      constants/
      network/
      theme/
      user/
      utils/
    features/
      activity/
      auth/
      fund_wallet/
      home/
      main/
      send_money/
      settings/
```

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK compatible with the Flutter version in use
- Android Studio, VS Code, or another Flutter-capable IDE
- A running backend API reachable from your emulator or device

### Install Dependencies

```bash
flutter pub get
```

### Run The App

```bash
flutter run
```

## Backend Configuration

The API base URL is currently hardcoded in `lib/src/core/network/api_endpoints.dart`:

```dart
static const String baseUrl = 'http://192.168.0.164:8080/api';
```

Before running the app, update that value to match the machine hosting your backend.

- For a physical device, use your computer's LAN IP and make sure both devices are on the same network.
- For an emulator or simulator, use the host address that matches your local setup.
- The expected backend for this app is the Spring Boot service in `wallet_system`.
- Backend repository: [wallet_system](https://github.com/TechifyDev1/wallet_system)

## App Flow

1. On launch, the app checks the authenticated user state.
2. If the session is valid, it opens the main tab shell.
3. If not, it shows the registration entry screen.
4. After login, first-time users are routed to transaction PIN setup.
5. Authenticated users land in a three-tab experience: `Home`, `Activities`, and `Settings`.

## Architecture Notes

- `lib/main.dart` boots Riverpod, preserves the native splash screen until auth state resolves, and wires global unauthorized handling.
- `lib/src/core/network/http_client.dart` centralizes headers, bearer token injection, token refresh, and forced logout behavior.
- `lib/src/core/network/api_endpoints.dart` maps the mobile client to the backend routes exposed by `wallet_system`.
- Repositories in each feature handle API requests and response parsing.
- Providers coordinate async state, refreshes, and UI updates across screens.
- Secure storage is used for `token`, `refreshToken`, `isFirstTime`, and persisted theme preference.

## Useful Commands

```bash
flutter analyze
flutter test
flutter run
```

## Notes For Contributors

- Keep new API integrations inside the relevant feature repository rather than calling HTTP directly from UI code.
- Reuse the shared `HttpClient` so auth headers and refresh behavior remain consistent.
- Follow the existing feature-first folder structure when adding screens or state.
