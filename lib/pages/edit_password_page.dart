import 'package:factual/components/safe_keyboard.dart';
import 'package:factual/services/auth_service.dart';
import 'package:factual/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class EditPasswordPage extends StatefulWidget {
  const EditPasswordPage({super.key});

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late AuthService authService;

  bool isLoading = false;

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final Map<String, String?> errors = {};

  void handleChangePassword(BuildContext context) async {
    FocusScope.of(context).unfocus();
  if (!_formKey.currentState!.validate()) return;
  final currentPassword = currentPasswordController.text.trim();
  final newPassword = newPasswordController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      await authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      // Success actions:
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: snackBarShort,
          content: const Text('Password updated successfully'),
          backgroundColor: Colors.green,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
        ),
      );
    } on ClientException catch (error) {
      
      final errs = error.response['data'] ?? {};
      errs.forEach((key, value) {
        setState(() {
          errors[key] = value['message'];
        });
      });

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          duration: snackBarLong,
          content: Text(errorMessage(error)),
          backgroundColor: Colors.red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
        ),
      );
    } catch (error) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          duration: snackBarLong,
          content: Text(fatalError),
          backgroundColor: Colors.red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize authService before using it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authService = Provider.of<AuthService>(context, listen: false);
    });
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SafeKeyboard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BackButton(onPressed: () => Navigator.pop(context)),
                      Text(
                        'Change Password',
                        style: GoogleFonts.inter(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12, width: 1),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Password',
                            style: GoogleFonts.inter(fontSize: 14.0),
                          ),
                          const SizedBox(height: 6.0),
                          TextFormField(
                            enabled: !isLoading,
                            controller: currentPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                            ),
                            onChanged: (value) {
                              if (errors['currentPassword'] != null) {
                                setState(() {
                                  errors['currentPassword'] = null;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Current password is required';
                              }
                              return errors['currentPassword'];
                            },
                          ),

                          const SizedBox(height: 16.0),

                          Text(
                            'New Password',
                            style: GoogleFonts.inter(fontSize: 14.0),
                          ),
                          const SizedBox(height: 6.0),
                          TextFormField(
                            enabled: !isLoading,
                            controller: newPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                            ),
                            onChanged: (value) {
                              if (errors['password'] != null) {
                                setState(() {
                                  errors['password'] = null;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'New password is required';
                              }
                              return errors['password'];
                            },
                          ),

                          const SizedBox(height: 16.0),

                          Text(
                            'Confirm Password',
                            style: GoogleFonts.inter(fontSize: 14.0),
                          ),
                          const SizedBox(height: 6.0),
                          TextFormField(
                            enabled: !isLoading,
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                            ),
                            onChanged: (value) {
                              if (errors['confirmPassword'] != null) {
                                setState(() {
                                  errors['confirmPassword'] = null;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm password is required';
                              }
                              if (newPasswordController.text != value) {
                                return 'Passwords do not match';
                              }
                              return errors['confirmPassword'];
                            },
                          ),

                          const SizedBox(height: 16.0),

                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: isLoading
                                  ? null
                                  : () => handleChangePassword(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Change Password'),
                                  const SizedBox(width: 8),
                                  if (isLoading)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
