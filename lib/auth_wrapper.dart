import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'services/role_service.dart';

class AuthWrapper extends StatelessWidget {
  final RoleService _roleService = RoleService();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          final role = _roleService.getRoleForEmail(snapshot.data!.email!);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            switch (role) {
              case AppRole.farmer:
                context.go('/farmer_home');
                break;
              case AppRole.distributor:
                context.go('/distributor_home');
                break;
              case AppRole.retailer:
                context.go('/retailer_home');
                break;
              case AppRole.consumer:
                context.go('/consumer_home');
                break;
            }
          });
        } else {
          // If user is logged out, show the welcome screen
          // The router will handle showing the welcome screen at '/'
        }

        // While the navigation is happening, show a loading indicator
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
