# Wallet Mobile

A Flutter wallet application built with Cupertino widgets and Riverpod. This app works with the companion Spring Boot backend in `wallet_system` to handle registration, login, wallet creation, funding, transfers, transaction history, and profile updates.

## Full-Stack Context

This repository is the mobile client for the wallet platform. The backend lives in the companion repository:

[wallet_system](https://github.com/TechifyDev1/wallet_system)

Together, both projects provide:

- Mobile onboarding and authenticated wallet flows in Flutter
- REST APIs in Spring Boot
- JWT-based authentication with refresh-token support for app clients
- Wallet creation, funding, transfers, and transaction history
- Profile retrieval and account update flows
- Shared security responsibilities between the client and server

## What The Mobile App Does

- Register a new user account
- Sign in with email and password
- Create a 6-digit transaction PIN after first-time onboarding
- Reset a forgotten password with email, secret key, and new password
- Load the authenticated user profile and wallet summary
- Fund the wallet
- Search users and send money to a recipient
- Show recent contacts during transfer flow
- Display recent transactions on the home screen
- Browse paginated transaction history
- Update email and phone number from settings
- Change password while signed in
- Toggle light and dark theme
- Sign out and clear stored session data

## How Responsibilities Are Split

### Frontend Responsibilities In This Repo

The mobile app is responsible for user experience, local session handling, and sending the right data to the backend.

- `Secure local storage`
  Stores the access token, refresh token, first-time onboarding state, and theme preference on-device through `flutter_secure_storage`.
- `Automatic auth header handling`
  A shared HTTP client adds the bearer token to protected requests.
- `Refresh-token retry flow`
  If a protected request returns `401` or `403`, the app attempts token refresh before treating the session as expired.
- `Forced logout fallback`
  If refresh fails, the app clears local credentials and returns to an unauthenticated state.
- `Background session timeout`
  The app logs the user out if it resumes after more than 5 minutes in the background.
- `First-time PIN setup routing`
  New users are routed into PIN creation before using transfer-related actions.
- `Feature-based architecture`
  Repositories handle API access, while Riverpod providers manage async state and UI refreshes.

### Backend Responsibilities That Power The App

These are implemented in `wallet_system` and are important because the mobile app depends on them for money movement and account protection.

- `Protected API routes with Spring Security and JWT`
- `Refresh-token issuance for app clients`
- `Password hashing through PasswordEncoder`
- `Transaction PIN verification before transfers`
- `Transactional funding and transfer services`
- `Pessimistic wallet locking during balance updates`
- `Idempotency-key checks for funding and transfers`
- `Ledger entries for debit and credit records`
- `Password re-verification before sensitive profile updates`

## Feature Highlights

### Session And Account Safety

- Tokens are persisted through secure device storage instead of regular app preferences.
- Authenticated requests share one HTTP client so token injection and refresh handling stay consistent.
- If a session cannot be recovered, the app removes stored credentials and returns to the auth flow.
- The app adds a basic mobile session-safety rule by logging the user out after extended background time.

### Wallet And Transaction Experience

- Funding and transfer actions are connected to backend flows that enforce transaction rules.
- The app refreshes profile and activity data after balance-changing actions.
- Recent contacts and recent transactions are surfaced to make repeat activity quicker.
- Transfer flow uses a first-time PIN setup gate to support backend PIN enforcement.

### Settings And Profile Management

- Users can review their profile and wallet summary from the authenticated area.
- Email and phone updates are available from settings.
- Password reset is supported in two forms:
  signed-in password change and forgot-password recovery.

## Important Files

- `lib/main.dart`
  App bootstrap, splash preservation, auth-state gating, and background timeout handling.
- `lib/src/core/network/http_client.dart`
  Shared HTTP client for headers, bearer token injection, refresh handling, and unauthorized fallback.
- `lib/src/core/utils/storage.dart`
  Secure local persistence wrapper.
- `lib/src/core/network/api_endpoints.dart`
  Mobile-to-backend route mapping.
- `lib/src/features/auth/repository/auth_repository.dart`
  Login, registration, PIN setup, logout, forgot-password, and reset-password requests.
- `lib/src/features/fund_wallet/repository/fund_wallet_repo.dart`
  Wallet funding request handling.
- `lib/src/features/send_money/repository/send_money_repository.dart`
  User search, recent contacts, and transfer requests.

## Tech Stack

- Flutter
- Dart
- `flutter_riverpod`
- `http`
- `flutter_secure_storage`
- `intl`
- `decimal`
- `uuid`
- Cupertino-based widgets

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
- Dart SDK compatible with your Flutter version
- Android Studio, VS Code, or another Flutter-capable IDE
- A running `wallet_system` backend reachable from your device or emulator

### Install Dependencies

```bash
flutter pub get
```

### Run The App

```bash
flutter run
```

## Backend Connection

The API base URL is currently defined in `lib/src/core/network/api_endpoints.dart`:

```dart
static const String baseUrl = 'http://192.168.0.164:8080/api';
```

Update that value to match the machine hosting your backend before running the app.

- On a physical device, use your computer's LAN IP address.
- On an emulator or simulator, use the host address that matches your setup.
- This mobile app is designed to work with the Spring Boot backend in `wallet_system`.

## App Flow

1. The app starts and resolves the authenticated user state.
2. If the session is valid, the user enters the main tab shell.
3. If there is no valid session, the app shows the registration/login entry flow.
4. After login, first-time users are directed to create a transaction PIN.
5. Authenticated users continue into the main wallet experience.

## Security And Reliability Notes

- The client protects session continuity, but money movement guarantees are primarily enforced by the backend.
- Funding and transfer safety depend on backend transactions, idempotency protection, locking, and ledger recording.
- The current mobile timeout is based on background duration, not a full foreground inactivity timer.
- The app’s role is to store session state securely, send the required auth data, and react correctly to backend authorization outcomes.

## Useful Commands

```bash
flutter analyze
flutter test
flutter run
```

## Contributor Notes

- Keep API calls inside repositories instead of calling HTTP directly from widgets.
- Reuse the shared `HttpClient` so auth behavior stays consistent.
- Follow the feature-first folder structure when adding new screens or state.
