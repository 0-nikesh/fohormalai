import 'package:flutter/material.dart';
import 'package:fohormalai/features/home/calendar.dart';
import 'package:fohormalai/features/home/homepage.dart';
import 'package:fohormalai/features/home/marketplace.dart';
import 'package:fohormalai/features/home/settings.dart';
import 'package:fohormalai/features/home/map.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Homepage(),
    Marketplace(),
    Map(),
    Calendar(),
    Settings(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.shopping_bag, 1),
          _buildNavItem(Icons.map, 2),
          _buildNavItem(Icons.calendar_today, 3),
          _buildNavItem(Icons.settings, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Icon(
        icon,
        size: 28,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
      ),
    );
  }
}
