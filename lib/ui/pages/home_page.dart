import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/ui/pages/fragments/home_fragment.dart';
import 'package:tracks/ui/pages/fragments/news_fragment.dart';
import 'package:tracks/ui/pages/fragments/profile_fragment.dart';
import 'package:tracks/ui/pages/fragments/schedule_fragment.dart';
import 'package:tracks/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NavigationProvider navigationProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigationProvider = Provider.of<NavigationProvider>(context);
  }

  int get _selectedIndex => navigationProvider.selectedIndex;

  final List<Widget> pages = [
    HomeFragment(),
    ScheduleFragment(),
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
