import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart';

// 1. THE FINAL, CORRECT MOCK PLATFORM INTERFACE
// This class mocks the FirebasePlatform interface. It correctly uses the
// `MockPlatformInterfaceMixin` and extends `Mock` from `mockito`.
class MockFirebasePlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {

  // Return a mock app instance.
  final FirebaseAppPlatform _mockApp = MockFirebaseApp();

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return _mockApp;
  }

  @override
  List<FirebaseAppPlatform> get apps => [_mockApp];

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _mockApp;
  }
}

// 2. THE FINAL, CORRECT MOCK FIREBASE APP PLATFORM
// This was the source of the final error. This class ALSO needs to use the
// `MockPlatformInterfaceMixin` because it is mocking a platform interface.
class MockFirebaseApp extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseAppPlatform {

  @override
  String get name => '[DEFAULT]';

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'mock-api-key',
        appId: 'mock-app-id',
        messagingSenderId: 'mock-sender-id',
        projectId: 'mock-project-id',
      );
}

// 3. SETUP FUNCTION
// This sets our mock as the live instance before any tests run.
void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = MockFirebasePlatform();
}

// 4. THE TEST
void main() {
  // Set up the mocks once for all tests.
  setupFirebaseMocks();

  testWidgets('Welcome Screen renders correctly when not logged in', (WidgetTester tester) async {
    // Use the mock auth provider to simulate a logged-out state.
    final auth = MockFirebaseAuth(signedIn: false);

    // Build the app.
    await tester.pumpWidget(MyApp());

    // Let the UI settle after any async operations.
    await tester.pumpAndSettle();

    // FINALLY, verify the correct widgets are on screen.
    expect(find.text('Welcome to AgriChain'), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
    expect(find.byKey(const Key('register_button')), findsOneWidget);
  });
}
