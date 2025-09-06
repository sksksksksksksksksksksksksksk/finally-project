# AgriChain Application Blueprint

## Overview

AgriChain is a Flutter-based mobile and web application designed to...

(Further details to be added as the application evolves)

## Features & History

*   **Initial Setup:** The project was initialized as a standard Flutter application.
*   **Authentication:** Firebase Authentication has been integrated to handle user sign-up, login, and session management.
*   **Navigation:** The `go_router` package has been implemented for declarative routing, managing navigation between the welcome/login screen and the main application content.
*   **Testing Framework Fix (Completed):** The widget testing setup was broken due to issues with mocking Firebase services. This has been resolved by:
    *   Adding `mockito` and `firebase_core_platform_interface` to the development dependencies.
    *   Creating mock implementations for `FirebasePlatform` and `FirebaseAppPlatform` using the `MockPlatformInterfaceMixin`.
    *   This allows widget tests to run in a pure Dart environment without requiring a native Firebase connection, ensuring that UI components can be tested reliably.

## Current Plan

The immediate task of fixing the broken test suite is complete. The `flutter test` command now executes successfully. The application is in a stable, testable state.
