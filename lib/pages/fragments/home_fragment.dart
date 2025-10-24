import 'package:tracks/components/buttons/pressable.dart';
// import 'package:tracks/components/safe_keyboard.dart';
import 'package:tracks/pages/session_page.dart';
import 'package:tracks/services/auth_service.dart';
// import 'package:tracks/services/pocketbase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:tracks/utils/app_colors.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  // final _pb = PocketBaseService.instance;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final firstName = user?['name'].toString().split(' ')[0] ?? '';

    final quickAccess = [
      {
        'icon': Iconsax.thorchain_rune_outline,
        'subtitle': 'Start a new',
        'title': 'Session',
        'action': (context) async {
          // Create session data

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SessionPage()),
          );
        },
      },
      {
        'icon': Iconsax.search_favorite_outline,
        'subtitle': 'See other people splits!',
        'title': 'Explore',
        'action': (context) async {},
      },
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Pressable(
                onTap: () {},
                child: Icon(Iconsax.notification_1_outline, size: 32),
              ),
            ],
          ),
        ),
    
        const SizedBox(height: 32),
    
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/icons/solar_icons/smile-circle.svg',
                width: 64,
                height: 64,
              ),
    
              const SizedBox(height: 8),
    
              Text(
                'Hello, $firstName!',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[700],
                ),
              ),
    
              Text(
                'Never too early to start your workout eh?',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
    
              const SizedBox(height: 32),
        
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: quickAccess.length,
                itemBuilder: (context, index) {
                  final item = quickAccess[index];
    
                  return Pressable(
                    onTap: () => item['action'] != null
                        ? (item['action'] as Function)(context)
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            index == 0
                                ? AppColors.lightPrimary
                                : Theme.of(context).cardColor,
                            index == 0
                                ? Colors.white
                                : Theme.of(context).cardColor,
                          ],
                          stops: [0, 0.5],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[300]!,
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.grey[200]!,
                            offset: const Offset(0, -2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              item['icon'] as IconData?,
                              size: 32,
                              color: index == 0
                                  ? Colors.white
                                  : Colors.grey[800],
                            ),
                            const SizedBox(height: 32),
                            Text(
                              item['subtitle'] as String,
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
                              item['title'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
