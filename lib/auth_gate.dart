import 'dart:async';

import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracks/ui/pages/home_page.dart';
import 'package:tracks/ui/pages/login_with_email_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> _syncExercises(BuildContext context) async {
    try {
      final exerciseRepo = context.read<ExerciseRepository>();
      exerciseRepo.performInitialSync();
      print('Running sync');
    } catch (e) {
      //
    }
  }

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
          unawaited(_syncExercises(context));
          return const HomePage();
        }
      },
    );
  }
}
