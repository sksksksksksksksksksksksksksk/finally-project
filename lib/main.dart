import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'auth_wrapper.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/farmer_home_screen.dart';
import 'screens/create_batch_screen.dart';
import 'screens/qr_display_screen.dart';
import 'screens/transfer_batch_screen.dart';
import 'screens/consumer_home_screen.dart';
import 'screens/consumer_qr_scanner_screen.dart';
import 'screens/consumer_batch_history_screen.dart';
import 'screens/distributor_home_screen.dart';
import 'screens/retailer_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Router configuration
  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return AuthWrapper();
      },
    ),
    GoRoute(
      path: '/welcome',
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomeScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegistrationScreen();
      },
    ),
    GoRoute(
      path: '/farmer_home',
      builder: (BuildContext context, GoRouterState state) {
        return const FarmerHomeScreen();
      },
    ),
    GoRoute(
      path: '/distributor_home',
      builder: (BuildContext context, GoRouterState state) {
        return const DistributorHomeScreen();
      },
    ),
    GoRoute(
      path: '/retailer_home',
      builder: (BuildContext context, GoRouterState state) {
        return const RetailerHomeScreen();
      },
    ),
    GoRoute(
      path: '/consumer_home',
      builder: (BuildContext context, GoRouterState state) {
        return const ConsumerHomeScreen();
      },
    ),
    GoRoute(
      path: '/create_batch',
      builder: (BuildContext context, GoRouterState state) {
        return const CreateBatchScreen();
      },
    ),
    GoRoute(
      path: '/qr_display/:batchId',
      builder: (BuildContext context, GoRouterState state) {
        final String batchId = state.pathParameters['batchId']!;
        return QrDisplayScreen(batchId: batchId);
      },
    ),
    GoRoute(
      path: '/transfer_batch',
      builder: (BuildContext context, GoRouterState state) {
        return const TransferBatchScreen();
      },
    ),
    GoRoute(
      path: '/consumer_qr_scanner',
      builder: (BuildContext context, GoRouterState state) {
        return const ConsumerQrScannerScreen();
      },
    ),
    GoRoute(
      path: '/batch_history/:batchId',
      builder: (BuildContext context, GoRouterState state) {
        final String batchId = state.pathParameters['batchId']!;
        return ConsumerBatchHistoryScreen(batchId: batchId);
      },
    ),
  ],
   redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register' || state.matchedLocation == '/welcome';

    // If user is not logged in and not on a login/register page, redirect to welcome
    if (!loggedIn && !loggingIn) {
      return '/welcome';
    }

    // If user is logged in and tries to access login/register, redirect to home
    if (loggedIn && loggingIn) {
      return '/';
    }

    return null;
  },
);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'AgriChain',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
         scaffoldBackgroundColor: Colors.green[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ),
    );
  }
}
