import 'dart:developer';

import 'package:factual/services/auth_service.dart';
import 'package:factual/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class RegisterWithEmailPage extends StatefulWidget {
  const RegisterWithEmailPage({super.key});

  @override
  State<RegisterWithEmailPage> createState() => _RegisterWithEmailPageState();
}

class _RegisterWithEmailPageState extends State<RegisterWithEmailPage> {
  bool _isLoading = false;

  bool _hidePassword = true;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Map<String, String?> _errors = {};

  Future<void> handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final AuthService authService = Provider.of<AuthService>(
        context,
        listen: false,
      );

      await authService.signUpWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration success, please login with your new credentials.'),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          duration: snackBarShort,
        ),
      );
    } on ClientException catch (e) {

      final errors = e.response['data'] ?? {};
      errors.forEach((key, value) {
        setState(() {
          _errors[key] = value['message'];
        });
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage(e)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          duration: snackBarShort,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hidePassword = true;
        });
      }
    }
  }

  void handleRedirectLogin(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Add bottom padding so keyboard doesn't cause overflow
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/solar_icons/login-3.svg',
                                width: 64,
                                height: 64,
                              ),
                              Text(
                                'Register',
                                style: GoogleFonts.inter(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: GoogleFonts.inter(),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => handleRedirectLogin(context),
                                    child: Text(
                                      'Login',
                                      style: GoogleFonts.inter(
                                        color: Colors.teal,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              TextFormField(
                                enabled: !_isLoading,
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(99.0),
                                  ),
                                ),
                                  onChanged: (value) {
                                    if (_errors['name'] != null) {
                                      setState(() {
                                        _errors['name'] = null;
                                      });
                                    }
                                  },
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Please enter your name'
                                    : _errors['name'],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                enabled: !_isLoading,
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(99.0),
                                  ),
                                ),
                                  onChanged: (value) {
                                    if (_errors['email'] != null) {
                                      setState(() {
                                        _errors['email'] = null;
                                      });
                                    }
                                  },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Email is invalid';
                                  }
                                  return _errors['email'];
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                onFieldSubmitted: (value) =>
                                    handleSubmit(context),
                                enabled: !_isLoading,
                                controller: _passwordController,
                                obscureText: _hidePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(99.0),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      !_hidePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _hidePassword = !_hidePassword;
                                      });
                                    },
                                  ),
                                ),
                                  onChanged: (value) {
                                    if (_errors['password'] != null) {
                                      setState(() {
                                        _errors['password'] = null;
                                      });
                                    }
                                  },
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Please enter your password'
                                    : _errors['password'],
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => handleSubmit(context),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Register'),
                                    const SizedBox(width: 8),
                                    _isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.arrow_forward),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
