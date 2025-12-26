import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tracks/models/user.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/explore_profile_page.dart';
import 'package:tracks/ui/pages/search_page.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final pb = PocketBaseService.instance.client;

  late final Future<List<User>> _popularCreators = _fetchPopularCreators();
  late final Future<List<Workout>> _trendingWorkouts = _fetchTrendingWorkouts();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<User>> _fetchPopularCreators() async {
    try {
      final records = await pb
          .collection(PBCollections.users.value)
          .getFullList(
            batch: 10,
            filter: 'id != "$tracksAccountID"',
            sort: '-total_copies,-followers',
          );
      return records.map((e) => User.fromRecord(e)).toList();
    } catch (e) {
      log('[ERROR] $e');
      return [];
    }
  }

  Future<List<Workout>> _fetchTrendingWorkouts() async {
    try {
      final records = await pb
          .collection(PBCollections.workouts.value)
          .getList(
            page: 1,
            perPage: 10,
            sort: '-created',
            filter: 'is_public = true',
            expand: 'exercises',
          );
      return records.items.map((e) => Workout.fromRecord(e)).toList();
    } catch (e) {
      log('[ERROR] $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Explore",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Iconsax.search_favorite_1_outline),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Discover workouts from the community",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Pressable(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SearchPage(scope: SearchPageScope.explore),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
              ),
            ),

            // System Account - Featured Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Pressable(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ExploreProfilePage(userId: tracksAccountID);
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.lightPrimary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Iconsax.medal_star_bold,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Tracks Official",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Iconsax.verify_bold,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Get started with curated workouts",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Trending Workouts Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Trending Workouts",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Pressable(
                      onTap: () {},
                      child: Text(
                        "See all",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Trending Workouts List
            SliverToBoxAdapter(
              child: FutureBuilder<List<Workout>>(
                future: _trendingWorkouts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 3,
                        itemBuilder: (context, index) =>
                            const _TrendingWorkoutSkeleton(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 200,
                      child: Center(child: Text('Error loading workouts')),
                    );
                  }

                  final workouts = snapshot.data ?? [];
                  if (workouts.isEmpty) {
                    return SizedBox(
                      height: 200,
                      child: Center(child: Text('No trending workouts found')),
                    );
                  }

                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workout = workouts[index];
                        return _TrendingWorkoutCard(
                          title: workout.name,
                          author: "Tracks User", // Placeholder
                          exercises:
                              0, // Placeholder as we can't easily get count
                          duration: "N/A", // Placeholder
                          gradient: [
                            AppColors.secondary,
                            AppColors.darkSecondary,
                          ], // Placeholder
                          copies: 0, // Placeholder
                          imagePath: workout.thumbnail,
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Community Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular Creators",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Pressable(
                      onTap: () {},
                      child: Text(
                        "See all",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Popular Creators List
            FutureBuilder<List<User>>(
              future: _popularCreators,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const _CreatorSkeleton(),
                        childCount: 5,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: Text('Error loading creators')),
                    ),
                  );
                }

                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: Text('No creators found')),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final user = users[index];
                      return _CreatorCard(
                        name: user.name.isNotEmpty ? user.name : user.username,
                        username: "@${user.username}",
                        workouts: 0, // Placeholder
                        followers: user.followers.toCompact(),
                        avatarColor: AppColors.primary, // Placeholder
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ExploreProfilePage(userId: user.id),
                          ),
                        ),
                      );
                    }, childCount: users.length),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _TrendingWorkoutCard extends StatelessWidget {
  final String title;
  final String author;
  final int exercises;
  final String duration;
  final List<Color> gradient;
  final int copies;
  final String? imagePath;

  const _TrendingWorkoutCard({
    required this.title,
    required this.author,
    required this.exercises,
    required this.duration,
    required this.gradient,
    required this.copies,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {
        // TODO: Navigate to workout details
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background: Image or Gradient
              if (imagePath != null)
                Positioned.fill(
                  child: getImage(
                    imagePath,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              if (imagePath == null)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              // Gradient Overlay
              if (imagePath != null)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.copy_outline,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "$copies",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Iconsax.arrow_right_3_outline,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 18,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      author,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _WorkoutStat(
                          icon: Iconsax.weight_1_outline,
                          label: "$exercises",
                        ),
                        const SizedBox(width: 12),
                        _WorkoutStat(
                          icon: Iconsax.clock_outline,
                          label: duration,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WorkoutStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CreatorCard extends StatelessWidget {
  final String name;
  final String username;
  final int workouts;
  final String followers;
  final Color avatarColor;
  final void Function() onTap;

  const _CreatorCard({
    required this.name,
    required this.username,
    required this.workouts,
    required this.followers,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [avatarColor, avatarColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    username,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.weight_1_outline,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$workouts",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Iconsax.people_outline,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      followers,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}

class _TrendingWorkoutSkeleton extends StatelessWidget {
  const _TrendingWorkoutSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 14, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 60, height: 12, color: Colors.white),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(width: 40, height: 12, color: Colors.white),
                      const SizedBox(width: 12),
                      Container(width: 40, height: 12, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatorSkeleton extends StatelessWidget {
  const _CreatorSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 16, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 80, height: 12, color: Colors.white),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(width: 40, height: 12, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(width: 40, height: 12, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
