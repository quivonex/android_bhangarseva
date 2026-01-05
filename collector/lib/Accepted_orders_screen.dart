import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_services.dart';
import 'combine_selection_product.dart';

const Color primaryGold = Color(0xFFb59d31);
const Color darkBrown = Color(0xFF4a3b1a);
const Color lightGrey = Color(0xFFF8F9FA);
const Color darkGrey = Color(0xFF6C757D);
const Color successGreen = Color(0xFF28A745);
const Color warningYellow = Color(0xFFFFC107);
const Color infoBlue = Color(0xFF17A2B8);

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final ApiService _apiService = ApiService();

  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAcceptedOrders();
  }

  // 🔄 Load accepted orders
  Future<void> _loadAcceptedOrders() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getAcceptedRequests();

      if (response['status'] == 'success') {
        setState(() {
          _orders = response['data'];
          _isLoading = false;
        });
      } else {
        throw Exception("API Error");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🗺 Open Map for Directions
  Future<void> _openMapForDirections(Map<String, dynamic> order) async {
    String address = order['address'] ?? '';

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Encode the address for URL
    String encodedAddress = Uri.encodeComponent(address);

    // Try Google Maps first
    String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$encodedAddress&travelmode=driving';

    // Alternative URLs
    String appleMapsUrl = 'https://maps.apple.com/?daddr=$encodedAddress';
    String wazeUrl = 'https://waze.com/ul?q=$encodedAddress&navigate=yes';

    try {
      // Try Google Maps
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        // Try Apple Maps
        await launchUrl(
          Uri.parse(appleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(Uri.parse(wazeUrl))) {
        // Try Waze
        await launchUrl(
          Uri.parse(wazeUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // If no map app is available, show options
        _showMapOptionsDialog(address);
      }
    } catch (e) {
      _showMapOptionsDialog(address);
    }
  }

  // Show map options dialog
  void _showMapOptionsDialog(String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Maps'),
        content: const Text('Choose a map application to open:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openInBrowser(address);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
            ),
            child: const Text('Open in Browser'),
          ),
        ],
      ),
    );
  }

  // Open address in browser as fallback
  Future<void> _openInBrowser(String address) async {
    String encodedAddress = Uri.encodeComponent(address);
    String mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    try {
      await launchUrl(
        Uri.parse(mapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ▶ Start Pickup
  void _startPickup(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CombinedProductSelectionScreen(
          orderData: order,
        ),
      ),
    );
  }

  // 👁 View Details
  void _showOrderDetails(Map<String, dynamic> order) {
    bool isPending = order['order_status']?.toLowerCase() == 'pending';
    bool isAccepted = order['order_status']?.toLowerCase() == 'accepted';
    bool isInProgress = order['order_status']?.toLowerCase() == 'in_progress';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.only(top: 50),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #${order['order_id']}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkBrown,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order['order_status']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order['order_status']?.toUpperCase() ?? 'UNKNOWN',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Customer Information Section
              const Text(
                "CUSTOMER INFORMATION",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkGrey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),

              // Customer Info Cards
              _buildInfoCard(
                icon: Icons.person,
                title: order['available_person_name'] ?? 'N/A',
                subtitle: "Customer Name",
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.phone,
                      title: order['contact'] ?? 'N/A',
                      subtitle: "Primary Contact",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.phone_android,
                      title: order['alt_contact'] ?? 'N/A',
                      subtitle: "Alternate Contact",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pickup Details Section
              const Text(
                "PICKUP DETAILS",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkGrey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),

              // Pickup Details Cards
              _buildInfoCard(
                icon: Icons.location_on,
                title: order['address'] ?? 'N/A',
                subtitle: "Pickup Address",
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.calendar_today,
                      title: _formatDate(order['date']),
                      subtitle: "Pickup Date",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.access_time,
                      title: order['time_slot'] ?? 'N/A',
                      subtitle: "Time Slot",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Action Buttons - UPDATED with Map button icon
              if (isPending || isAccepted || isInProgress)
                Column(
                  children: [
                    // Start Pickup Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _startPickup(order);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGold,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.directions_bike, size: 24),
                        label: const Text(
                          "START PICKUP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else if (isPending)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: darkGrey),
                    ),
                    icon: const Icon(Icons.info_outline, size: 24),
                    label: const Text(
                      "PENDING APPROVAL",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    // View Details Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkGrey,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle, size: 24),
                        label: const Text(
                          "VIEW DETAILS",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build info cards
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryGold, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: darkGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkBrown,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return successGreen;
      case 'pending':
        return warningYellow;
      case 'in_progress':
        return infoBlue;
      case 'completed':
        return successGreen;
      default:
        return darkGrey;
    }
  }

  // Helper method to format date
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  // Helper method to build order card
  Widget _buildOrderCard(Map<String, dynamic> order, int index) {
    bool isPending = order['order_status']?.toLowerCase() == 'pending';
    bool isAccepted = order['order_status']?.toLowerCase() == 'accepted';
    bool isInProgress = order['order_status']?.toLowerCase() == 'in_progress';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Order #${order['order_id']}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkBrown,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['order_status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order['order_status']?.toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order Details
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: darkGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order['available_person_name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      color: darkGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: darkGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order['address'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      color: darkGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.access_time_outlined,
                    size: 18, color: darkGrey),
                const SizedBox(width: 8),
                Text(
                  "${_formatDate(order['date'])} • ${order['time_slot']}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: darkGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons - UPDATED with Map icon button next to main button
            Row(
              children: [
                // Map Direction Icon Button
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => _openMapForDirections(order),
                    icon: const Icon(Icons.directions, size: 24, color: Colors.white),
                    tooltip: "Get Directions",
                  ),
                ),
                const SizedBox(width: 12),

                // Main Action Button (expands to fill remaining space)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showOrderDetails(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPending || isAccepted || isInProgress ? primaryGold : darkGrey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(0, 50),
                    ),
                    icon: Icon(
                      isPending || isAccepted || isInProgress
                          ? Icons.directions_bike
                          : Icons.arrow_forward,
                      size: 20,
                    ),
                    label: Text(
                      isPending || isAccepted || isInProgress
                          ? "START PICKUP"
                          : "VIEW DETAILS",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text(
          "Accepted Orders",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGold,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAcceptedOrders,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: primaryGold,
          strokeWidth: 3,
        ),
      )
          : _orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              "No Orders Found",
              style: TextStyle(
                fontSize: 18,
                color: darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Accepted orders will appear here",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAcceptedOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        color: primaryGold,
        onRefresh: _loadAcceptedOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _orders.length,
          itemBuilder: (_, index) =>
              _buildOrderCard(_orders[index], index),
        ),
      ),
    );
  }
}