import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false));
}

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> scheduleCards = [
    {
      'date': '2nd June, 10:00 am',
      'type': 'Plastic and Paper Waste',
      'note': 'Make sure it\'s clean and dry',
      'color': Colors.lightBlue.shade100,
      'icon': Icons.recycling,
    },
    {
      'date': '5th June, 12:00 pm',
      'type': 'Bulk Item Pickups',
      'note': 'Normal waste with furniture and electronics',
      'color': Colors.grey.shade300,
      'icon': Icons.chair,
    },
    {
      'date': 'Tomorrow, 8:00 am',
      'type': 'Organic Waste',
      'note': 'Place Outside Before 7:30',
      'color': Colors.green.shade200,
      'icon': Icons.eco,
    },
  ];

  final List<Map<String, dynamic>> actionButtons = [
    {'label': 'Request Collection', 'icon': Icons.add_box_outlined},
    {'label': 'Pickup History', 'icon': Icons.history},
    {'label': 'Help & Support', 'icon': Icons.help_outline},
    {'label': 'Nearby Bins', 'icon': Icons.map},
    {'label': 'Schedule Collection', 'icon': Icons.schedule},
    {'label': 'Report Waste', 'icon': Icons.report_problem_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Homepage'),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'फोहर मलाइ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person),
                  ),
                ],
              ),
              SizedBox(height: 10),
              CarouselSlider(
                options: CarouselOptions(
                  height: 140,
                  enlargeCenterPage: true,
                  autoPlay: true,
                ),
                items: scheduleCards.map((card) {
                  return Builder(
                    builder: (context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: card['color'],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['date'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(card['icon'], size: 18),
                                SizedBox(width: 6),
                                Text(
                                  card['type'],
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              card['note'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Map Placeholder",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: actionButtons.map((btn) {
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey.shade200,
                          child: Icon(btn['icon'], color: Colors.green[800]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          btn['label'],
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
