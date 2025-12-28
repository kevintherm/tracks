import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/user.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/view_remote_exercise_page.dart';
import 'package:tracks/ui/pages/view_remote_schedule_page.dart';
import 'package:tracks/ui/pages/view_remote_workout_page.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

class ExploreProfilePage extends StatefulWidget {
  const ExploreProfilePage({super.key, this.userId});

  final String? userId;

  @override
  State<ExploreProfilePage> createState() => _ExploreProfilePageState();
}

class _ExploreProfilePageState extends State<ExploreProfilePage> {
  final pb = PocketBaseService.instance.client;

  int _selectedTab = 0; // 0: Workouts, 1: Exercises, 2: Schedule
  late PageController _pageController;
  late Future<User?> _userFuture;
  final List<Future<List>> futures = [
    Future.value([]),
    Future.value([]),
    Future.value([]),
  ];

  User? _user;
  int _workoutCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTab);
    _userFuture = _fetchUser();
    futures[0] = _fetchWorkouts().then((value) {
      if (mounted) {
        setState(() {
          _workoutCount = value.length;
        });
      }
      return value;
    });
    futures[1] = _fetchExercises();
    futures[2] = _fetchSchedules();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<User?> _fetchUser() async {
    await Future.delayed(Duration(milliseconds: 150));
    return await User.fetchUserById(widget.userId);
  }

  Future<List<Workout>> _fetchWorkouts() async {
    if (widget.userId == null) return [];
    final results = await pb
        .collection(PBCollections.workouts.value)
        .getList(filter: 'user = "${widget.userId}"');
    return results.items.map((e) => Workout.fromRecord(e)).toList();
  }

  Future<List<Exercise>> _fetchExercises() async {
    if (widget.userId == null) return [];
    final results = await pb
        .collection(PBCollections.exercises.value)
        .getList(filter: 'user = "${widget.userId}"');
    return results.items.map((e) => Exercise.fromRecord(e)).toList();
  }

  Future<List<Schedule>> _fetchSchedules() async {
    if (widget.userId == null) return [];
    final results = await pb
        .collection(PBCollections.schedules.value)
        .getList(
          filter: 'workout.user = "${widget.userId}"',
          expand: 'workout',
        );
    return results.items.map((e) => Schedule.fromRecord(e)).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _userFuture = _fetchUser();
      futures[0] = _fetchWorkouts().then((value) {
        if (mounted) {
          setState(() {
            _workoutCount = value.length;
          });
        }
        return value;
      });
      futures[1] = _fetchExercises();
      futures[2] = _fetchSchedules();
    });

    await _userFuture;
    await futures[0];
    await futures[1];
    await futures[2];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FutureBuilder<User?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              _user = snapshot.data;
            }

            if (_user == null &&
                snapshot.connectionState != ConnectionState.done) {
              return _buildShimmer();
            }

            if (_user == null) {
              if (snapshot.hasError) return _buildError(snapshot);
              return _buildNotFound(context);
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: NestedScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    // Sticky Header requires SliverAppBar
                    SliverAppBar(
                      backgroundColor: Colors.grey[50],
                      surfaceTintColor: Colors.grey[50],
                      elevation: 0,
                      leading: Pressable(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Iconsax.arrow_left_2_outline,
                          color: Colors.black,
                        ),
                      ),
                      title: Text(
                        _user!.username,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      actions: [
                        Pressable(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              Iconsax.more_circle_outline,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                      pinned: true,
                    ),

                    // Profile Content (Scrolls away)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildAvatar(_user),
                            const SizedBox(height: 16),
                            Text(
                              _user!.name,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "@${_user!.username}",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _user!.bio,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem(
                                    "Workouts", _workoutCount.toCompact()),
                                _buildStatItem(
                                    "Followers", _user!.followers.toCompact()),
                                _buildStatItem("Following",
                                    _user!.followings.toCompact()),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Pressable(
                                    onTap: () {},
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Follow",
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Pressable(
                                  onTap: () => Toast(context).neutral(
                                      content: Text("Coming soon...")),
                                  child: Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border:
                                          Border.all(color: Colors.grey[200]!),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Iconsax.message_outline,
                                        size: 24),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),

                    // Tabs (Sticks)
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        minHeight: 60,
                        maxHeight: 60,
                        child: Container(
                          color: Colors.grey[50],
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              _buildTabButton(0, "Workouts"),
                              const SizedBox(width: 24),
                              _buildTabButton(1, "Exercises"),
                              const SizedBox(width: 24),
                              _buildTabButton(2, "Schedule"),
                              const Spacer(),
                              Icon(Iconsax.filter_outline,
                                  size: 20, color: Colors.grey[600]),
                            ],
                          ),
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: PageView(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _selectedTab = index),
                  children: [_buildTab(0), _buildTab(1), _buildTab(2)],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    return FutureBuilder<List<dynamic>>(
      future: futures[index],
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: _buildError(snapshot));
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: _buildContentCardShimmer(),
          );
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return Center(
            child: Text(
              "No items found",
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          );
        }

        return _buildTabContent(index, data);
      },
    );
  }

  Widget _buildTabContent(int tabIndex, List<dynamic> items) {
    // Replaced CustomScrollView/Slivers with standard ListView.builder
    return ListView.separated(
      key: PageStorageKey<String>('tab_$tabIndex'),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildContentCard(tabIndex, index, items);
      },
    );
  }

  Center _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.user_remove_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'User not found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This user may have been deleted or does not exist',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Pressable(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.arrow_left_2_outline,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Go Back',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: [
        // App Bar Shimmer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _shimmerBox(width: 40, height: 40, radius: 12),
              const Spacer(),
              _shimmerBox(width: 40, height: 40, radius: 12),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar Shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Text Lines Shimmer
                _shimmerBox(width: 150, height: 24, radius: 8),
                const SizedBox(height: 8),
                _shimmerBox(width: 100, height: 16, radius: 8),
                const SizedBox(height: 16),
                _shimmerBox(width: double.infinity, height: 14, radius: 8),
                const SizedBox(height: 8),
                _shimmerBox(width: double.infinity, height: 14, radius: 8),
                const SizedBox(height: 24),

                // Stats Shimmer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) {
                    return Column(
                      children: [
                        _shimmerBox(width: 40, height: 20, radius: 8),
                        const SizedBox(height: 8),
                        _shimmerBox(width: 60, height: 14, radius: 8),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Action Buttons Shimmer
                Row(
                  children: [
                    Expanded(
                        child: _shimmerBox(height: 48, width: 0, radius: 16)),
                    const SizedBox(width: 12),
                    _shimmerBox(height: 48, width: 48, radius: 16),
                  ],
                ),
                const SizedBox(height: 32),

                // Tab Bar Shimmer
                Row(
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: _shimmerBox(width: 80, height: 40, radius: 8),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Content Cards Shimmer
                ..._buildContentCardShimmer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox(
      {double width = 0, double height = 0, double radius = 0}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width == 0 ? null : width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  List<Widget> _buildContentCardShimmer({int count = 3}) {
    return List.generate(count, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTabButton(int index, String text) {
    final isSelected = _selectedTab == index;
    return Pressable(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.black87 : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            width: isSelected ? 20 : 0,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(int tabIndex, int itemIndex, List<dynamic> items) {
    switch (tabIndex) {
      case 0:
        final wo = items[itemIndex] as Workout;
        return _buildWorkoutCard(wo);
      case 1:
        final ex = items[itemIndex] as Exercise;
        return _buildExerciseCard(ex);
      case 2:
        final schedule = items[itemIndex] as Schedule;
        return _buildScheduleCard(schedule);
      default:
        return const SizedBox();
    }
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Pressable(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ViewRemoteExercisePage(exerciseId: exercise.pocketbaseId!),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: exercise.thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: exercise.thumbnail!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Iconsax.diagram_outline,
                            size: 28,
                            color: Colors.grey[400],
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Iconsax.diagram_outline,
                          size: 28,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${exercise.caloriesBurned} cal",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    final workout = schedule.workout.value;
    return Pressable(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ViewRemoteSchedulePage(scheduleId: schedule.pocketbaseId!),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    schedule.recurrenceType.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  "${schedule.plannedDuration} min",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              workout?.name ?? "Unknown Workout",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (workout?.description != null)
              Text(
                workout!.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return Pressable(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ViewRemoteWorkoutPage(workoutId: workout.pocketbaseId!),
        ),
      ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // Background image
                  if (workout.thumbnail != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: workout.thumbnail!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Iconsax.weight_1_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (workout.thumbnail == null)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Iconsax.weight_1_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconsax.clock_outline,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "15min",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTag("Strength"),
                      const SizedBox(width: 8),
                      _buildTag("Intermediate"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Iconsax.heart_outline,
                        size: 18,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "324",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Iconsax.play_circle_outline,
                        size: 18,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "1.2k plays",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
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

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildError(snapshot) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.danger_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              snapshot.error.toString(),
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Pressable(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Go Back',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User? user) {
    final hasAvatar = user?.avatar?.isNotEmpty == true;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: hasAvatar
            ? CachedNetworkImage(imageUrl: user!.avatar!, fit: BoxFit.cover)
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey, Colors.grey.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    (user?.name.isNotEmpty == true ? user!.name[0] : '?')
                        .toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}