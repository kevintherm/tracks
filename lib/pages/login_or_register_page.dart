import 'package:factual/pages/login_with_email_page.dart';
import 'package:factual/pages/register_with_email_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool _isRegister = true;

  void handleRedirectRegister(context) {
    setState(() {
      _isRegister = !_isRegister;
    });
  }

  void handleRegisterEmail() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            _isRegister ? RegisterWithEmailPage() : LoginWithEmail(),
      ),
    );
  }

  void handleRegisterGoogle(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                    'Factual',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isRegister
                            ? 'Already have an account?'
                            : 'Your first time here?',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => handleRedirectRegister(context),
                        child: Text(
                          _isRegister ? 'Login' : 'Register',
                          style: GoogleFonts.inter(
                            color: Colors.teal,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: InkWell(
                            onTap: () => handleRegisterEmail(),
                            borderRadius: BorderRadius.circular(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.email_outlined, size: 32),

                                  const SizedBox(height: 32),

                                  Text(
                                    '${_isRegister ? 'Register' : 'Login'} with',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.grey[600]
                                          : Colors.grey[300],
                                    ),
                                  ),
                                  Text(
                                    'Email',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8.0),
                            onTap: () => handleRegisterGoogle(context),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/google-color.svg',
                                    width: 32,
                                    height: 32,
                                  ),

                                  const SizedBox(height: 32),

                                  Text(
                                    '${_isRegister ? 'Register' : 'Login'} with',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.grey[600]
                                          : Colors.grey[300],
                                    ),
                                  ),
                                  Text(
                                    'Google',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
