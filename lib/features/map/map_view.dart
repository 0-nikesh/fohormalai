import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fohormalai/app/services/pickup_schedule_service.dart';
import 'package:fohormalai/app/models/pickup_schedule.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  List<PickupSchedule> _activePickups = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActivePickups();
  }

  Future<void> _loadActivePickups() async {
    try {
      setState(() => _isLoading = true);
      final pickups = await PickupScheduleService.getActivePickups();
      setState(() {
        _activePickups = pickups;
        _isLoading = false;
        _error = null; // Clear any previous errors
      });
    } catch (e) {
      debugPrint('Error loading pickups: $e');
      setState(() {
        _error = 'Failed to load pickup locations';
        _isLoading = false;
        _activePickups = []; // Clear any stale data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // ? Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Text(_error!),
          //         ElevatedButton(
          //           onPressed: _loadActivePickups,
          //           child: const Text('Retry'),
          //         ),
          //       ],
          //     ),
          //   )
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(27.7172, 85.3240), // Kathmandu center
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.fohormalai.app',
              ),
              MarkerLayer(
                markers: _activePickups
                    .map(
                      (pickup) => Marker(
                        point: LatLng(pickup.latitude, pickup.longitude),
                        child: IconButton(
                          iconSize: 40,
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.location_on,
                            color: _getColorForWasteType(pickup.garbageType),
                          ),
                          onPressed: () {
                            _showPickupDetails(context, pickup);
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
    );
  }

  Color _getColorForWasteType(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'organic':
        return Colors.green;
      case 'plastic':
        return Colors.blue;
      case 'metal':
        return Colors.brown;
      default:
        return Colors.red;
    }
  }

  void _showPickupDetails(BuildContext context, PickupSchedule pickup) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: _getColorForWasteType(pickup.garbageType),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pickup Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.location_on, pickup.location),
            _detailRow(Icons.delete_outline, '${pickup.garbageType} Waste'),
            _detailRow(Icons.access_time, pickup.dateTime.toString()),
            if (pickup.coverageRadiusKm != null)
              _detailRow(
                Icons.radio_button_checked,
                'Coverage: ${pickup.coverageRadiusKm}km radius',
              ),
            if (pickup.usersNotified != null)
              _detailRow(
                Icons.people_outline,
                '${pickup.usersNotified} users notified',
              ),
            if (pickup.distanceKm != null)
              _detailRow(
                Icons.straighten,
                'Distance: ${pickup.distanceKm}km from you',
              ),
            _detailRow(Icons.person, 'Admin: ${pickup.adminName}'),
            if (pickup.notes.isNotEmpty) _detailRow(Icons.note, pickup.notes),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
