import 'package:factual/components/safe_keyboard.dart';
import 'package:factual/models/app_user.dart';
import 'package:factual/providers/navigation_provider.dart';
import 'package:factual/services/auth_service.dart';
import 'package:factual/utils/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late AuthService authService;

  bool get isEmailVerified => authService.currentUser != null && authService.currentUser!.emailVerified;

  AppUser user = AppUser.empty();

  bool isLoading = false;
  bool hasUnsavedChanges = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void handleSaveChange(BuildContext context) {
    FocusScope.of(context).unfocus();

    String name = nameController.text.trim();
    String email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text('Name and Email cannot be empty'),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
        ),
      );
      return;
    }

    if (email != user.email) {
      showDialog(
        context: context,
        builder: (context) {
          TextEditingController passwordController = TextEditingController();
          return AlertDialog(
            title: Text('Reauthenticate'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Editing sensitive information, please enter your password to continue.'),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    isLoading = true;
                  });

                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    if (passwordController.text.trim().isEmpty) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Password cannot be empty'),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                            ),
                          ),
                        ),
                      );
                      return;
                    }

                    await authService.updateEmail(email: email, password: passwordController.text);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Email updated successfully'), backgroundColor: Colors.green),
                    );

                    if (name != user.name) {
                      await authService.updateProfile(name: name);
                      messenger.showSnackBar(
                        SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text(e.message ?? fatalError), backgroundColor: Colors.red));
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: Text('Confirm'),
              ),
            ],
          );
        },
      );
    } else if (name != user.name) {
      setState(() {
        isLoading = true;
      });

      authService.updateProfile(name: name).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
        );
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  void handleUnsavedChanges() {
    setState(() {
      hasUnsavedChanges = nameController.text.trim() != user.name || emailController.text.trim() != user.email;
    });
  }

  Future<bool> confirmUnsavedChanges(BuildContext context) async {
    if (!hasUnsavedChanges) return true;

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes'),
        content: Text('You have unsaved changes. Are you sure you want to leave without saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Leave'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void initState() {
    super.initState();
    nameController.addListener(handleUnsavedChanges);
    emailController.addListener(handleUnsavedChanges);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authService = Provider.of<AuthService>(context, listen: false);
      setState(() {
        isLoading = true;
      });

      try {
        authService.fetchUserData().then((value) {
          setState(() {
            if (value == null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(fatalError), backgroundColor: Colors.red));
              Navigator.pop(context);
              isLoading = false;
              return;
            }

            user = value;
            nameController.text = user.name;
            emailController.text = user.email;
            isLoading = false;
          });
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.removeListener(handleUnsavedChanges);
    emailController.removeListener(handleUnsavedChanges);
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => confirmUnsavedChanges(context),
      child: Scaffold(
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
                        onPressed: () async {
                          if (await confirmUnsavedChanges(context)) {
                            Provider.of<NavigationProvider>(context, listen: false).setSelectedIndex(1);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  GestureDetector(
                    onTap: () {
                      print('fuck you');
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(backgroundColor: Colors.red[300], radius: 48.0),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(99.0), color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.edit, size: 16.0, color: Colors.teal),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                          Text('Name', style: GoogleFonts.inter(fontSize: 14.0)),
                          const SizedBox(height: 6.0),
                          TextFormField(
                            enabled: !isLoading,
                            controller: nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(99.0)),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Name cannot be empty' : null,
                          ),

                          const SizedBox(height: 16.0),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Email', style: GoogleFonts.inter(fontSize: 14.0)),
                              const SizedBox(width: 8.0),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: isEmailVerified ? Colors.blue[50] : Colors.amber[50],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isEmailVerified ? Icons.check : Icons.clear,
                                        size: 16.0,
                                        color: isEmailVerified ? Colors.blue : Colors.amber,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        isEmailVerified ? 'VERIFIED' : 'UNVERIFIED',
                                        style: TextStyle(
                                          color: isEmailVerified ? Colors.blue[700] : Colors.amber[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6.0),
                          TextFormField(
                            enabled: !isLoading,
                            controller: emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(99.0)),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Name cannot be empty' : null,
                          ),

                          const SizedBox(height: 16.0),

                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: isLoading ? null : () => handleSaveChange(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Save Changes'),
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
