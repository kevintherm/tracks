import 'package:tracks/ui/pages/edit_password_page.dart';
import 'package:tracks/ui/pages/edit_profile_page.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:tracks/utils/toast.dart';

class ProfileFragment extends StatefulWidget {
  const ProfileFragment({super.key});

  @override
  State<ProfileFragment> createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  final Map<String, dynamic> accountSection = {
    'title': 'Account',
    'items': [
      {
        'icon': Icons.person,
        'label': 'Edit Profile',
        'action': (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfilePage()),
          );
        },
      },
      {
        'icon': Icons.key,
        'label': 'Change Password',
        'action': (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditPasswordPage()),
          );
        },
      },
    ],
  };

  final Map<String, dynamic> preferencesSection = {
    'title': 'General',
    'items': [
      {
        'icon': Icons.dark_mode,
        'label': 'Dark Mode',
        'action': (context) {
          // Navigator.push(context, )
        }
      }
    ]
  };

  Future<void> signOut(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      await authService.signOut();
    } on Exception catch (e) {
      if (!context.mounted) return;
      Toast(context).error(content: Text(e.toString()));
    }
  }

  ImageProvider _getUserAvatarProvider(Map<String, dynamic>? user) {
    if (user == null) return NetworkImage(defaultAvatar);
    
    final userAvatar = user['avatar'] as String?;
    if (userAvatar != null && userAvatar.isNotEmpty) {
      // If it's a URL, use NetworkImage
      if (userAvatar.startsWith('http')) {
        return NetworkImage(userAvatar);
      }
      // If it's a PocketBase file reference, construct the URL
      else {
        final userId = user['id'] as String? ?? '';
        final pbUrl = PocketBaseService.getPocketBaseUrl(); // Your PocketBase URL
        return NetworkImage('$pbUrl/api/files/users/$userId/$userAvatar');
      }
    }
    
    // Fall back to default avatar
    return NetworkImage(defaultAvatar);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;

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
                CircleAvatar(
                  backgroundImage: _getUserAvatarProvider(user),
                  backgroundColor: Colors.grey[300], 
                  radius: 56.0
                ),
                SizedBox(height: 8.0),
                Text(
                  user?['name'] ?? 'User',
                  style: GoogleFonts.inter(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                Text(
                  'Joined on ${DateFormat.yMMMd().format(DateTime.tryParse(user?["created"] as String? ?? "") ?? DateTime.now())}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
    
          Container(
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
                    accountSection['title'],
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                            leading: Icon(
                              item['icon'],
                              color: Colors.grey[700],
                            ),
                            title: Text(
                              item['label'],
                              style: GoogleFonts.inter(fontSize: 16.0),
                            ),
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
    
          const SizedBox(height: 16),
    
          Container(
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
                    preferencesSection['title'],
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ListView.builder(
                    itemCount: preferencesSection['items'].length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = preferencesSection['items'][index];
    
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Material(
                          color: Theme.of(context).cardColor,
                          child: ListTile(
                            leading: Icon(
                              item['icon'],
                              color: Colors.grey[700],
                            ),
                            title: Text(
                              item['label'],
                              style: GoogleFonts.inter(fontSize: 16.0),
                            ),
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
    
          const SizedBox(height: 16),
    
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
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
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
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 16.0),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
              child: Text('Sign Out'),
            ),
          ),
    
          Spacer(),
    
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('About', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
