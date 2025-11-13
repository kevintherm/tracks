import 'dart:async';
import 'dart:developer';

import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/repositories/muscle_repository.dart';
import 'package:tracks/ui/pages/fragments/home_fragment.dart';
import 'package:tracks/ui/pages/fragments/profile_fragment.dart';
import 'package:tracks/ui/pages/fragments/schedule_fragment.dart';
import 'package:tracks/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracks/ui/pages/fragments/workout_fragment.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NavigationProvider navigationProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(() async {
        log('[Sync] Starting muscle sync..');
        await context.read<MuscleRepository>().performInitialSync();

        log('[Sync] Starting exercise sync..');
        await context.read<ExerciseRepository>().performInitialSync();

        log('[Sync] Sync complete..');
      }());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigationProvider = Provider.of<NavigationProvider>(context);
  }

  int get _selectedIndex => navigationProvider.selectedIndex;

  final List<Widget> pages = [
    HomeFragment(),
    ScheduleFragment(),
    WorkoutFragment(),
    ProfileFragment(),
  ];
  final _navigationItems = [
    NavigationDestination(
      label: 'Home',
      icon: const Icon(Iconsax.home_2_outline),
      selectedIcon: const Icon(Iconsax.home_2_bold),
    ),
    NavigationDestination(
      label: "Schedule",
      icon: const Icon(Iconsax.calendar_2_outline),
      selectedIcon: const Icon(Iconsax.calendar_2_bold),
    ),
    NavigationDestination(
      label: "Workouts",
      icon: const Icon(Iconsax.weight_1_outline),
      selectedIcon: const Icon(Iconsax.weight_1_bold),
    ),
    NavigationDestination(
      label: 'Profile',
      icon: const Icon(Iconsax.user_outline),
      selectedIcon: const Icon(Iconsax.user_bold),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            navigationProvider.setSelectedIndex(value);
          });
        },
        destinations: _navigationItems,
      ),
    );
  }
}
