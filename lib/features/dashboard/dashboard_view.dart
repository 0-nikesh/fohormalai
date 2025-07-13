import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/providers/auth_provider.dart';
import '../../app/providers/notification_provider.dart';
import 'new_home_tab.dart'; // Using our new implementation
import 'marketplace_tab.dart';
import 'collection_requests_tab.dart';
import 'profile_tab.dart';
import '../map/map_view.dart';

class DashboardPage extends StatefulWidget {
  final int initialTabIndex;

  const DashboardPage({super.key, this.initialTabIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int _selectedIndex;

  final List<Widget> _tabs = const [
    HomeTab(),
    MapView(),
    MarketplaceTab(),
    CollectionRequestsTab(),
    ProfileTab(),
  ];

  // Public method to allow children to change tabs
  void onTabChange(int index) {
    if (index >= 0 && index < _tabs.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Icon(isSelected ? activeIcon : icon),
      label: label,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: null,
        centerTitle: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.green[700],
                ),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, _) {
                  final unreadCount = notificationProvider.unreadCount;
                  if (unreadCount == 0) return const SizedBox.shrink();

                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: authProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : _tabs[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.green[700],
            unselectedItemColor: Colors.grey[400],
            backgroundColor: Colors.white,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            onTap: _onItemTapped,
            items: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Map',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.store_outlined,
                activeIcon: Icons.store,
                label: 'Marketplace',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.recycling_outlined,
                activeIcon: Icons.recycling,
                label: 'Collections',
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
