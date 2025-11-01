import 'dart:async';
import 'dart:developer';

import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracks/ui/pages/home_page.dart';
import 'package:tracks/ui/pages/login_with_email_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: Provider.of<AuthService>(context).authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong!')),
          );
        }

        final user = snapshot.data;

        // return const HomePage();

        if (user == null) {
          return const LoginWithEmail();
        } else {
          
          // RUN sync after login
          unawaited(() async {
            log('[Sync] Starting exercise sync..');
            await context.read<ExerciseRepository>().performInitialSync();
            log('[Sync] Exercise synchronized..');
          }());

          return const HomePage();
        }
      },
    );
  }
}
