import 'package:factual/pages/edit_password_page.dart';
import 'package:factual/pages/edit_profile_page.dart';
import 'package:factual/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileFragment extends StatelessWidget {
  ProfileFragment({super.key});

  final Map<String, dynamic> accountSection = {
    'title': 'General',
    'items': [
      {
        'icon': Icons.person,
        'label': 'Edit Profile',
        'action': (BuildContext context) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
        },
      },
      {
        'icon': Icons.key,
        'label': 'Change Password',
        'action': (BuildContext context) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditPasswordPage()));
        },
      },
    ],
  };

  Future<void> signOut(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      await authService.signOut();
    } on Exception catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 250.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(backgroundColor: Colors.red[300], radius: 56.0),
                SizedBox(height: 8.0),
                Text(
                  'John Doe',
                  style: GoogleFonts.inter(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  'Joined on Jan 25, 2024',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.white
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(accountSection['title'], style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.0),
                  ListView.builder(
                    itemCount: accountSection['items'].length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = accountSection['items'][index];

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Material(
                          color: Theme.of(context).cardColor,
                          child: ListTile(
                            leading: Icon(item['icon'], color: Colors.grey[700]),
                            title: Text(item['label'], style: GoogleFonts.inter(fontSize: 16.0)),
                            onTap: () => item['action'](context),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Spacer(),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Sign Out'),
                    content: Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          signOut(context);
                        },
                        child: Text('Sign Out'),
                      ),
                    ],
                  ),
                );
              },
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 16.0)),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
              ),
              child: Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}
