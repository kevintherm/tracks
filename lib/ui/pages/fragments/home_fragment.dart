import 'package:provider/provider.dart';
import 'package:tracks/providers/navigation_provider.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/ui/components/app_container.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/exercises_page.dart';
import 'package:tracks/ui/pages/fragments/workout_fragment.dart';
import 'package:tracks/ui/pages/manage_schedule_page.dart';
import 'package:tracks/ui/pages/muscles_page.dart';
import 'package:tracks/ui/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/ui/pages/start_session_page.dart';
import 'package:tracks/utils/app_colors.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  final quickAccess = [
    {
      'icon': Iconsax.thorchain_rune_outline,
      'subtitle': 'Start a new',
      'title': 'Session',
      'action': (context) async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StartSessionPage()),
        );
      },
    },
    {
      'icon': Iconsax.search_favorite_outline,
      'subtitle': 'See other splits!',
      'title': 'Explore',
      'action': (BuildContext context) async {
        context.read<NavigationProvider>().setSelectedIndex(2);
      },
    },
  ];

  final quickChips = [
    {
      'icon': Iconsax.scan_outline,
      'title': 'Scan Calories',
      'action': (context) async {},
    },
    {
      'icon': Iconsax.weight_1_outline,
      'title': 'Manage Workouts',
      'action': (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkoutFragment()),
        );
      },
    },
    {
      'icon': Iconsax.weight_1_outline,
      'title': 'Manage Exercises',
      'action': (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ExercisesPage()),
        );
      },
    },
    {
      'icon': MingCute.fitness_line,
      'title': 'Manage Muscles',
      'action': (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MusclesPage()),
        );
      },
    },
    {
      'icon': Iconsax.calendar_1_outline,
      'title': 'Manage Schedule',
      'action': (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageSchedulePage()),
        );
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return SingleChildScrollView(
      child: Column(
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

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${auth.user?.name ?? 'Human'}!',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
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

                const SizedBox(height: 16),

                // Search bar
                Pressable(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Iconsax.search_normal_1_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Search",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Access
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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
                          borderRadius: BorderRadius.circular(24),
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

                const SizedBox(height: 12),

                // Quick Access 2
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    itemCount: quickChips.length,
                    itemBuilder: (context, index) {
                      final item = quickChips[index];

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Pressable(
                          onTap: () => item['action'] != null
                              ? (item['action'] as Function)(context)
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).cardColor,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item['icon'] as IconData, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  item['title'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
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

                const SizedBox(height: 24),

                // Today Split
                Text(
                  'Today Split',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                Pressable(
                  onTap: () {},
                  child: Column(
                    children: [
                      AppContainer(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      'assets/drawings/pushup.jpg',
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Push Up",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "Average of 8 sets per week",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SliderTheme(
                                          data: SliderThemeData(
                                            padding: EdgeInsets.only(top: 8),
                                            trackHeight: 14,
                                            disabledActiveTrackColor:
                                                AppColors.accent,
                                            thumbShape:
                                                SliderComponentShape.noThumb,
                                          ),
                                          child: Slider(
                                            value: 10,
                                            min: 0,
                                            max: 100,
                                            onChanged: null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Positioned(
                              right: 32 + 10,
                              top: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 12,
                                ),
                                child: Text(
                                  "Mediocre",
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // News
                Text(
                  'Science Based News',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                Pressable(
                  onTap: () {},
                  child: Column(
                    children: [
                      AppContainer(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      'assets/drawings/pushup.jpg',
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Push Up",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "Average of 8 sets per week",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SliderTheme(
                                          data: SliderThemeData(
                                            padding: EdgeInsets.only(top: 8),
                                            trackHeight: 14,
                                            disabledActiveTrackColor:
                                                AppColors.accent,
                                            thumbShape:
                                                SliderComponentShape.noThumb,
                                          ),
                                          child: Slider(
                                            value: 10,
                                            min: 0,
                                            max: 100,
                                            onChanged: null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Positioned(
                              right: 32 + 10,
                              top: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 12,
                                ),
                                child: Text(
                                  "Mediocre",
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
