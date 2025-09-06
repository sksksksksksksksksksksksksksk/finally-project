import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'services/role_service.dart';
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
  runApp(MyApp());
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final RoleService _roleService = RoleService();

  late final GoRouter _router = GoRouter(
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/farmer_home',
        builder: (context, state) => const FarmerHomeScreen(),
      ),
      GoRoute(
        path: '/distributor_home',
        builder: (context, state) => const DistributorHomeScreen(),
      ),
      GoRoute(
        path: '/retailer_home',
        builder: (context, state) => const RetailerHomeScreen(),
      ),
      GoRoute(
        path: '/consumer_home',
        builder: (context, state) => const ConsumerHomeScreen(),
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
      final user = FirebaseAuth.instance.currentUser;
      final bool loggedIn = user != null;
      final String location = state.matchedLocation;

      final isAuthPage = location == '/welcome' || location == '/login' || location == '/register';
      final isRoot = location == '/';

      if (!loggedIn) {
        return isAuthPage ? null : '/welcome';
      }

      if (loggedIn && (isAuthPage || isRoot)) {
        final role = _roleService.getRoleForEmail(user.email!);
        switch (role) {
          case AppRole.farmer:
            return '/farmer_home';
          case AppRole.distributor:
            return '/distributor_home';
          case AppRole.retailer:
            return '/retailer_home';
          case AppRole.consumer:
            return '/consumer_home';
        }
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
