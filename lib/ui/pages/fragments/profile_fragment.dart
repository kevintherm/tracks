import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/ui/components/section_card.dart';
import 'package:tracks/ui/pages/edit_password_page.dart';
import 'package:tracks/ui/pages/edit_profile_page.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/ui/pages/login_with_email_page.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:tracks/utils/toast.dart';

class _SectionItem {
  final String label;
  final Icon icon;
  final void Function(BuildContext context) action;

  const _SectionItem({
    required this.label,
    required this.icon,
    required this.action,
  });
}

class _Section {
  final String title;
  final List<_SectionItem> items;

  const _Section({required this.title, required this.items});
}

class ProfileFragment extends StatefulWidget {
  const ProfileFragment({super.key});

  @override
  State<ProfileFragment> createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  List<_Section> _buildSections() {
    final authService = context.read<AuthService>();

    return [
      _Section(
        title: 'Account',
        items: [
          _SectionItem(
            label: 'Edit Profile',
            icon: Icon(Iconsax.user_edit_outline),
            action: (context) {
              if (authService.currentUser == null) {
                Toast(
                  context,
                ).neutral(content: Text("Login to access this feature."));
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),
          _SectionItem(
            label: 'Change Password',
            icon: Icon(Iconsax.key_outline),
            action: (context) {
              if (authService.currentUser == null) {
                Toast(
                  context,
                ).neutral(content: Text("Login to access this feature."));
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditPasswordPage()),
              );
            },
          ),
        ],
      ),

      _Section(
        title: 'General',
        items: [
          _SectionItem(
            label: 'Dark Mode',
            icon: Icon(Iconsax.moon_outline),
            action: (context) {},
          ),
          _SectionItem(
            label: 'Sync to Cloud',
            icon: Icon(Iconsax.cloud_outline),
            action: (context) => _showSyncToggleSheet(context),
          ),
        ],
      ),
    ];
  }

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
    if (user == null) return AssetImage('assets/drawings/not-found.jpg');

    final userAvatar = user['avatar'] as String?;
    if (userAvatar != null && userAvatar.isNotEmpty) {
      final userId = user['id'] as String? ?? '';
      final pbUrl = PocketBaseService.getPocketBaseUrl();
      return NetworkImage('$pbUrl/api/files/users/$userId/$userAvatar');
    }

    return AssetImage('assets/drawings/not-found.jpg');
  }

  void _showSyncToggleSheet(BuildContext context) {
    final authService = context.read<AuthService>();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isSyncEnabled = authService.isSyncEnabled;

            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.cloud_outline,
                        size: 32,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cloud Sync',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enable cloud sync to backup your data and sync across devices. You must be signed in to use this feature.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (authService.currentUser == null) return;

                        setModalState(() {
                          authService.isSyncEnabled = !isSyncEnabled;
                        });
                        setState(() {}); // Update parent state
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isSyncEnabled
                                      ? Iconsax.cloud_change_bold
                                      : Iconsax.cloud_cross_outline,
                                  color: isSyncEnabled
                                      ? Colors.green[600]
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isSyncEnabled ? 'Enabled' : 'Disabled',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: isSyncEnabled,
                              onChanged: (value) =>
                                  authService.currentUser ??
                                  (value) {
                                    setModalState(() {
                                      authService.isSyncEnabled = value;
                                    });
                                    setState(() {}); // Update parent state
                                  },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isSyncEnabled)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.tick_circle_bold,
                            color: Colors.green[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your data will be synced to the cloud',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (authService.currentUser == null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.login_bold,
                            color: AppColors.darkAccent.withValues(alpha: 0.9),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Login to sync your data to the cloud',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.darkAccent.withValues(
                                  alpha: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final List<_Section> sections = _buildSections();

    return Column(
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
                radius: 56.0,
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

        Expanded(
          child: ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return SectionCard(
                title: section.title,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: section.items.length,
                  itemBuilder: (context, itemIndex) {
                    final item = section.items[itemIndex];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => item.action(context),
                        borderRadius: BorderRadius.circular(8),
                        child: ListTile(
                          leading: item.icon,
                          title: Text(
                            item.label,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(
                            Iconsax.arrow_right_3_outline,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                if (user == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginWithEmail(),
                    ),
                  );
                  return;
                }

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
              child: Text(user == null ? 'Login' : 'Sign Out'),
            ),
          ),
        ),
      ],
    );
  }
}
