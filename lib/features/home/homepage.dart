import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            const SizedBox(height: 16),
            _buildGarbageInfoCard(),
            _buildMapPreview(),
            const SizedBox(height: 16),
            _buildShortcutGrid(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            'फोहोर मलाई',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const CircleAvatar(backgroundImage: AssetImage('assets/avatar.png')),
        ],
      ),
    );
  }

  Widget _buildGarbageInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xffE0F7FA), Color(0xffB2EBF2)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "2nd June, 10:00 am",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text("Plastic and Paper Waste", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              "\u2139\uFE0F Make sure it's clean and dry",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/map_preview.png',
          fit: BoxFit.cover,
          height: 180,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildShortcutGrid() {
    final items = [
      {'icon': Icons.local_shipping, 'label': 'Request\nCollection'},
      {'icon': Icons.history, 'label': 'Pickup\nHistory'},
      {'icon': Icons.help_outline, 'label': 'Help &\nSupport'},
      {'icon': Icons.delete_outline, 'label': 'Nearby\nBins'},
      {'icon': Icons.calendar_today, 'label': 'Schedule\nCollection'},
      {'icon': Icons.warning_amber, 'label': 'Report\nWaste'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) => _buildShortcutItem(
          items[index]['icon'] as IconData,
          items[index]['label'] as String,
        ),
      ),
    );
  }

  Widget _buildShortcutItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[100],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.grey[800]),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home, color: Colors.green, size: 28),
          Icon(Icons.shopping_bag_outlined, color: Colors.grey[600], size: 28),
          Icon(Icons.map, color: Colors.grey[600], size: 28),
          Icon(Icons.calendar_month, color: Colors.grey[600], size: 28),
          Icon(Icons.settings, color: Colors.grey[600], size: 28),
        ],
      ),
    );
  }
}
