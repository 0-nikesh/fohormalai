import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../app/models/collection_request.dart';
import '../../app/services/collection_request_service.dart';

class CollectionRequestsTab extends StatefulWidget {
  const CollectionRequestsTab({super.key});

  @override
  State<CollectionRequestsTab> createState() => _CollectionRequestsTabState();
}

class _CollectionRequestsTabState extends State<CollectionRequestsTab>
    with TickerProviderStateMixin {
  List<CollectionRequest> _requests = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchRequests();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Future<void> _fetchRequests() async {
  //   if (kDebugMode) {
  //     print('🔄 CollectionRequestsTab: Fetching user-specific requests...');
  //   }

  //   setState(() {
  //     _isLoading = true;
  //     _error = null;
  //   });

  //   try {
  //     final requests =
  //         await CollectionRequestService.getUserCollectionRequests();

  //     if (kDebugMode) {
  //       print(
  //         '✅ CollectionRequestsTab: Received ${requests.length} user requests',
  //       );
  //       if (requests.isNotEmpty) {
  //         print(
  //           '📋 First request: ID=${requests[0].id}, Type=${requests[0].wasteType}',
  //         );
  //       }
  //     }

  //     setState(() {
  //       _requests = requests;
  //       _isLoading = false;
  //     });
  //     _animationController.forward();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('❌ CollectionRequestsTab: Error fetching user requests: $e');
  //     }

  //     setState(() {
  //       _error = 'Failed to load your requests: $e';
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _fetchRequests() async {
    if (kDebugMode) {
      print('🔄 CollectionRequestsTab: Fetching user-specific requests...');
    }

    if (!mounted) return; // <-- Add this line

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final requests =
          await CollectionRequestService.getUserCollectionRequests();

      if (kDebugMode) {
        print(
          '✅ CollectionRequestsTab: Received ${requests.length} user requests',
        );
        if (requests.isNotEmpty) {
          print(
            '📋 First request: ID=${requests[0].id}, Type=${requests[0].wasteType}',
          );
        }
      }

      if (!mounted) return; // <-- Add this line

      setState(() {
        _requests = requests;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      if (kDebugMode) {
        print('❌ CollectionRequestsTab: Error fetching user requests: $e');
      }

      if (!mounted) return; // <-- Add this line

      setState(() {
        _error = 'Failed to load your requests: $e';
        _isLoading = false;
      });
    }
  }

  List<CollectionRequest> get _filteredRequests {
    if (_selectedFilter == 'all') return _requests;
    return _requests
        .where((req) => req.status?.toLowerCase() == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBody: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Stats Cards Section
              _buildStatsSection(),

              const SizedBox(height: 20),

              // Filter Section
              _buildFilterSection(),

              const SizedBox(height: 20),

              // Requests List Section
              _buildRequestsSection(),

              const SizedBox(height: 100), // Extra padding for floating button
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24, right: 8),
        child: _buildModernFAB(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildModernFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF43A047), Color(0xFF10B981)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43A047).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _onNewRequestButton,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                height: 80,
                margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildModernStatCard(
                  'Total',
                  _requests.length.toString(),
                  Icons.description_rounded,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernStatCard(
                  'Pending',
                  _requests
                      .where((r) => r.status?.toLowerCase() == 'pending')
                      .length
                      .toString(),
                  Icons.schedule_rounded,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernStatCard(
                  'Completed',
                  _requests
                      .where((r) => r.status?.toLowerCase() == 'completed')
                      .length
                      .toString(),
                  Icons.check_circle_rounded,
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Requests',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildModernFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildModernFilterChip('Pending', 'pending'),
                const SizedBox(width: 8),
                _buildModernFilterChip('Confirmed', 'confirmed'),
                const SizedBox(width: 8),
                _buildModernFilterChip('Completed', 'completed'),
                const SizedBox(width: 8),
                _buildModernFilterChip('Cancelled', 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsSection() {
    if (_isLoading) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF4CAF50)),
              SizedBox(height: 16),
              Text('Loading your requests...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_filteredRequests.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Requests',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${_filteredRequests.length} found',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF4CAF50),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredRequests.length,
            itemBuilder: (context, index) =>
                _buildGlassmorphismRequestCard(_filteredRequests[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphismRequestCard(CollectionRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF81C784).withOpacity(0.05),
            Colors.white.withOpacity(0.9),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showRequestDetails(request),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getWasteTypeColor(
                                  request.wasteType,
                                ).withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              _getWasteTypeIcon(request.wasteType),
                              size: 20,
                              color: _getWasteTypeColor(request.wasteType),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _capitalizeWasteType(request.wasteType),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                                Text(
                                  'Request #${request.id.substring(0, 8)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildGlassmorphismStatusBadge(
                            request.status ?? 'pending',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              Icons.schedule_rounded,
                              'Pickup Date',
                              DateFormat(
                                'MMM d, yyyy',
                              ).format(request.pickupDate),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.location_on_rounded,
                              'Location',
                              request.location,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.scale_rounded,
                              'Quantity',
                              request.quantity,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphismStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Colors.green[100]!.withOpacity(0.3);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!.withOpacity(0.3);
        textColor = Colors.red[800]!;
        break;
      case 'confirmed':
        backgroundColor = Colors.blue[100]!.withOpacity(0.3);
        textColor = Colors.blue[800]!;
        break;
      default:
        backgroundColor = Colors.orange[100]!.withOpacity(0.3);
        textColor = Colors.orange[800]!;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textColor.withOpacity(0.3)),
          ),
          child: Text(
            _formatStatus(status),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: const Color(0xFF2E7D32)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 48),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchRequests,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF81C784).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.eco_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'No requests yet!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your eco-friendly journey by creating your first collection request',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Tap the + button below to get started',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(CollectionRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Details',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Full request details would go here...'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWasteTypeIcon(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'plastic':
        return Icons.local_drink_rounded;
      case 'paper':
        return Icons.description_rounded;
      case 'glass':
        return Icons.wine_bar_rounded;
      case 'metal':
        return Icons.build_rounded;
      case 'electronic':
        return Icons.computer_rounded;
      case 'organic':
        return Icons.eco_rounded;
      default:
        return Icons.recycling_rounded;
    }
  }

  Color _getWasteTypeColor(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'plastic':
        return const Color(0xFF2196F3);
      case 'paper':
        return const Color(0xFF795548);
      case 'glass':
        return const Color(0xFF00BCD4);
      case 'metal':
        return const Color(0xFF607D8B);
      case 'electronic':
        return const Color(0xFF9C27B0);
      case 'organic':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF009688);
    }
  }

  String _formatStatus(String status) {
    return status.isNotEmpty
        ? '${status[0].toUpperCase()}${status.substring(1)}'
        : 'Pending';
  }

  String _capitalizeWasteType(String wasteType) {
    if (wasteType.isEmpty) return 'Unknown Waste';
    final formattedType =
        '${wasteType[0].toUpperCase()}${wasteType.substring(1)}';
    return wasteType.toLowerCase().contains('waste')
        ? formattedType
        : '$formattedType Waste';
  }

  void _onNewRequestButton() {
    Navigator.pushNamed(context, '/add_collection_request').then((value) {
      if (value == true) {
        _fetchRequests();
      }
    });
  }
}
