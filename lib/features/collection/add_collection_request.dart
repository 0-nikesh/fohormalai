import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../app/models/waste_type.dart';
import '../../app/services/location_service.dart';
import '../../app/services/collection_request_service.dart';

class AddCollectionRequest extends StatefulWidget {
  const AddCollectionRequest({super.key});

  @override
  State<AddCollectionRequest> createState() => _AddCollectionRequestState();
}

class _AddCollectionRequestState extends State<AddCollectionRequest> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  WasteType _selectedType = WasteType.compost;
  List<File> _selectedImages = [];
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _quantityController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4CAF50),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4CAF50),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _chooseFromMap() async {
    try {
      // Get current location as initial position
      final currentLatLng = await LocationService.getCurrentLatLng();
      LatLng initialPosition = const LatLng(
        27.7172,
        85.3240,
      ); // Default to Kathmandu

      if (currentLatLng != null) {
        initialPosition = currentLatLng;
      }

      // Show map picker dialog
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MapPickerScreen(initialPosition: initialPosition),
        ),
      );

      if (result != null) {
        setState(() {
          _latitude = result['latitude'];
          _longitude = result['longitude'];
          _addressController.text = result['address'] ?? 'Selected from map';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both date and time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final DateTime pickupDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      String? imagePath;
      if (_selectedImages.isNotEmpty) {
        imagePath = _selectedImages.first.path;
      }

      await CollectionRequestService.createCollectionRequest(
        wasteType: _selectedType.name,
        quantity: _quantityController.text.trim(),
        pickupDate: pickupDateTime,
        location: _addressController.text.trim(),
        latitude: _latitude ?? 0.0,
        longitude: _longitude ?? 0.0,
        specialNotes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        imagePath: imagePath,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Collection request created successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('Not authenticated')) {
        errorMessage = 'Please login to create a collection request';
      } else if (errorMessage.contains('Connection refused') ||
          errorMessage.contains('SocketException')) {
        errorMessage =
            'Unable to connect to server. Please check your internet connection.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: $errorMessage')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'RETRY',
            onPressed: () => _submitRequest(),
            textColor: Colors.white,
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImagePickerOption(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    subtitle: 'Pick from gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImagePickerOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    subtitle: 'Take a photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF4CAF50), size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Collection Request',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black54),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header Card
            // Container(
            //   padding: const EdgeInsets.all(20),
            //   decoration: BoxDecoration(
            //     gradient: const LinearGradient(
            //       colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //     ),
            //     borderRadius: BorderRadius.circular(16),
            //     boxShadow: [
            //       BoxShadow(
            //         color: const Color(0xFF4CAF50).withOpacity(0.3),
            //         blurRadius: 10,
            //         offset: const Offset(0, 4),
            //       ),
            //     ],
            //   ),
            //   child: const Row(
            //     children: [
            //       Icon(Icons.recycling, color: Colors.white, size: 32),
            //       SizedBox(width: 12),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               'Schedule Waste Collection',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 18,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             Text(
            //               'Help keep our environment clean',
            //               style: TextStyle(color: Colors.white70, fontSize: 14),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 24),

            // Waste Type Selection
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Waste Type', Icons.category),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<WasteType>(
                    value: _selectedType,
                    decoration: _buildInputDecoration('Select waste type'),
                    items: WasteType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            _getWasteTypeIcon(type),
                            const SizedBox(width: 8),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedType = value);
                    },
                  ),
                ],
              ),
            ),

            // Quantity Input
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Quantity', Icons.scale),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: _buildInputDecoration('Enter quantity'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            _buildQuantityButton(
                              icon: Icons.remove,
                              onPressed: () {
                                final current =
                                    int.tryParse(_quantityController.text) ?? 0;
                                if (current > 0) {
                                  _quantityController.text = (current - 1)
                                      .toString();
                                }
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: const Text(
                                'kg',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            _buildQuantityButton(
                              icon: Icons.add,
                              onPressed: () {
                                final current =
                                    int.tryParse(_quantityController.text) ?? 0;
                                _quantityController.text = (current + 1)
                                    .toString();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Date and Time Selection
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Pickup Schedule', Icons.schedule),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDate != null
                                      ? DateFormat(
                                          'MMM d, yyyy',
                                        ).format(_selectedDate!)
                                      : 'Select Date',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : 'Select Time',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Location Selection
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Pickup Location', Icons.location_on),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: _buildInputDecoration('Enter pickup address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pickup address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _chooseFromMap,
                      icon: const Icon(Icons.map, size: 20),
                      label: const Text('Choose from Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue[700],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.blue[200]!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image Upload Section
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Photo Evidence', Icons.camera_alt),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to upload photo',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Help us identify your waste better',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: FileImage(_selectedImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Special Notes
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Special Notes', Icons.note),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: _buildInputDecoration(
                      'Any special instructions for collection...',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Submit Request',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    String hint, {
    EdgeInsets? contentPadding,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      contentPadding: contentPadding ?? const EdgeInsets.all(16),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Icon _getWasteTypeIcon(WasteType type) {
    switch (type) {
      case WasteType.compost:
        return const Icon(Icons.eco, color: Color(0xFF4CAF50));
      case WasteType.plastic:
        return const Icon(Icons.recycling, color: Color(0xFF2196F3));
      case WasteType.paper:
        return const Icon(Icons.description, color: Color(0xFFFFC107));
      case WasteType.glass:
        return const Icon(Icons.wine_bar, color: Color(0xFF9C27B0));
      default:
        return const Icon(Icons.delete, color: Colors.grey);
    }
  }
}

// Map Picker Screen
class MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapPickerScreen({super.key, required this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _selectedPosition = const LatLng(27.7172, 85.3240);
  String _selectedAddress = '';
  bool _isLoading = false;
  bool _mapAvailable = true;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    _getAddressFromLatLng(_selectedPosition);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      setState(() => _isLoading = true);

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressParts = <String>[];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        setState(() {
          _selectedAddress = addressParts.join(', ');
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress =
            'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Location'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _mapAvailable
              ? FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPosition,
                    initialZoom: 15.0,
                    onTap: (_, point) {
                      setState(() => _selectedPosition = point);
                      _getAddressFromLatLng(point);
                    },
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.fohormalai',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedPosition,
                          width: 40,
                          height: 40,
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              // Get the current map center and move the marker relative to drag
                              final currentCenter = _mapController.center;
                              final offset = details.delta;
                              // Convert screen movement to geo coordinate movement
                              final scale =
                                  1.0 / _mapController.camera.zoom * 0.01;
                              final newLat =
                                  currentCenter.latitude - (offset.dy * scale);
                              final newLng =
                                  currentCenter.longitude + (offset.dx * scale);
                              final newPosition = LatLng(newLat, newLng);

                              setState(() {
                                _selectedPosition = newPosition;
                              });
                              _getAddressFromLatLng(newPosition);
                            },
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Could not load the map',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please check your internet connection',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _mapAvailable = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),

          // Address display card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selected Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Loading address...'),
                          ],
                        )
                      : Text(
                          _selectedAddress.isEmpty
                              ? 'Tap on map to select location'
                              : _selectedAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                ],
              ),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'latitude': _selectedPosition.latitude,
                  'longitude': _selectedPosition.longitude,
                  'address': _selectedAddress,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Confirm Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
