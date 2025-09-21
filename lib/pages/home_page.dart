import 'package:factual/services/auth_service.dart';
import 'package:factual/utils/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text('Home Page'),
          FilledButton(
            onPressed: () async {
              try {
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );

                await authService.signOut();
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message ?? fatalError),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
