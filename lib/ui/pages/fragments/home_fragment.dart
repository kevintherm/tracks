import 'dart:developer';

import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tracks/models/post.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/repositories/post_repository.dart';
import 'package:tracks/repositories/schedule_repository.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/ui/components/app_container.dart';
import 'package:tracks/ui/pages/view_post_page.dart';
import 'package:intl/intl.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/exercises_page.dart';
import 'package:tracks/ui/pages/explore_page.dart';
import 'package:tracks/ui/pages/view_workout_page.dart';
import 'package:tracks/ui/pages/workouts_page.dart';
import 'package:tracks/ui/pages/manage_schedule_page.dart';
import 'package:tracks/ui/pages/muscles_page.dart';
import 'package:tracks/ui/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/ui/pages/start_session_page.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';

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
        // context.read<NavigationProvider>().setSelectedIndex(2);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ExplorePage()),
        );
      },
    },
  ];

  final quickChips = [
    // {
    //   'icon': Iconsax.scan_outline,
    //   'title': 'Scan Calories',
    //   'action': (context) async {},
    // },
    {
      'icon': Iconsax.weight_1_outline,
      'title': 'Manage Workouts',
      'action': (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkoutsPage()),
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
            // child: Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Pressable(
            //       onTap: () {},
            //       child: Icon(Iconsax.notification_1_outline, size: 32),
            //     ),
            //   ],
            // ),
            child: SizedBox.shrink(),
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),

                Text(
                  'Never too early to start your workout eh?',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Theme.of(context).colorScheme.onSurface,
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
                      color: Theme.of(context).cardColor,
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
                                  ? Theme.of(context).cardColor
                                  : Theme.of(context).cardColor,
                            ],
                            stops: [0, 0.3],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
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
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(height: 32),
                              Text(
                                item['subtitle'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: index == 0
                                      ? Colors.grey[600]
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                                BoxShadow(
                                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
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
                StreamBuilder<List<Schedule>>(
                  stream: context
                      .read<ScheduleRepository>()
                      .watchSchedulesForDate(DateTime.now()),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final schedule = snapshot.data!.first;
                      final workout = schedule.workout.value;

                      if (workout == null) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today Split',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildWorkoutCard(context, workout, "Today"),
                        ],
                      );
                    } else {
                      // Check for upcoming
                      return FutureBuilder<Map<String, dynamic>?>(
                        future: context
                            .read<ScheduleRepository>()
                            .getNextSchedule(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final schedule =
                                snapshot.data!['schedule'] as Schedule;
                            final date = snapshot.data!['date'] as DateTime;
                            final workout = schedule.workout.value;

                            if (workout == null) return const SizedBox.shrink();

                            final dateFormat = DateFormat('EEEE, MMM d');
                            final dateString = dateFormat.format(date);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upcoming Split',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildWorkoutCard(context, workout, dateString),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today Split',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppContainer(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      "No workouts scheduled.",
                                      style: GoogleFonts.inter(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),

                // News
                Text(
                  'Posts',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                FutureBuilder<List<Post>>(
                  future: context.read<PostRepository>().getPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Shimmer.fromColors(
                        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        highlightColor: Theme.of(context).colorScheme.surfaceContainer,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 14,
                                    color: Theme.of(context).cardColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 60,
                                    height: 12,
                                    color: Theme.of(context).cardColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 12,
                                        color: Theme.of(context).cardColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 40,
                                        height: 12,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      log('Failed to load posts: ${snapshot.error}');
                      return AppContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              "Cannot load posts.",
                              style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                      );
                    }
                    final posts = snapshot.data ?? [];
                    if (posts.isEmpty) {
                      return AppContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              "No posts available.",
                              style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Pressable(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewPostPage(post: post),
                              ),
                            );
                          },
                          child: AppContainer(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        post.userName ?? 'Unknown',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        post.created.toString().split(' ')[0],
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(
    BuildContext context,
    Workout workout,
    String badgeText,
  ) {
    return Pressable(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewWorkoutPage(workout: workout),
          ),
        );
      },
      child: AppContainer(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildWorkoutImage(context, workout),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (workout.description != null &&
                            workout.description!.isNotEmpty)
                          Text(
                            workout.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
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
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                child: Text(
                  badgeText,
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
    );
  }

  Widget _buildWorkoutImage(BuildContext context, Workout workout) {
    return getSafeImage(
      workout.pendingThumbnailPath ?? workout.thumbnail ?? '',
    );
  }
}
