import 'package:factual/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:factual/pages/home_page.dart';
import 'package:factual/pages/login_with_email_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
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
        print('AuthGate: User state changed - ${user != null ? 'Logged in' : 'Logged out'}');

        if (user == null) {
          return const LoginWithEmail();
        } else {
          return const HomePage();
        }
      },
    );
  }
}
