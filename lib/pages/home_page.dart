import 'package:factual/pages/fragments/home_fragment.dart';
import 'package:factual/pages/fragments/profile_fragment.dart';
import 'package:factual/providers/navigation_provider.dart';
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

  final List<Widget> pages = [const HomeFragment(), ProfileFragment()];
  final _navigationItems = [
    NavigationDestination(label: 'Home', icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home)),
    NavigationDestination(
      label: 'Profile',
      icon: const Icon(Icons.person_outline),
      selectedIcon: const Icon(Icons.person),
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
