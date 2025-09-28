import 'package:factual/components/safe_keyboard.dart';
import 'package:factual/services/auth_service.dart';
import 'package:factual/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditPasswordPage extends StatefulWidget {
  const EditPasswordPage({super.key});

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  late AuthService authService;

  bool isLoading = false;

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void handleChangePassword(BuildContext context) {
    FocusScope.of(context).unfocus();

    String currentPassword = currentPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All fields are required'),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
          ),
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New password and confirm password do not match'),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    authService
        .updatePassword(currentPassword: currentPassword, newPassword: newPassword)
        .then((_) {
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();

          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: snackBarShort,
              content: Text('Password updated successfully'),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
              ),
            ),
          );
        })
        .catchError((error) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            SnackBar(
              duration: snackBarLong,
              content: Text(error.toString()),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
            ),
          );
        })
        .whenComplete(() {
          setState(() {
            isLoading = false;
          });
        });
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BackButton(
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Change Password',
                      style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w600, letterSpacing: 0.2),
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
                        Text('Current Password', style: GoogleFonts.inter(fontSize: 14.0)),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          enabled: !isLoading,
                          controller: currentPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(99.0)),
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        Text('New Password', style: GoogleFonts.inter(fontSize: 14.0)),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          enabled: !isLoading,
                          controller: newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(99.0)),
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        Text('Confirm Password', style: GoogleFonts.inter(fontSize: 14.0)),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          enabled: !isLoading,
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(99.0)),
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isLoading ? null : () => handleChangePassword(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Change Password'),
                                const SizedBox(width: 8),
                                if (isLoading)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
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
    );
  }
}
