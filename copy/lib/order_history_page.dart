import 'package:flutter/material.dart';
import 'package:copy/services/api_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  // UPDATED COLOR THEME
  final Color primaryGreen = const Color(0xFF6FAE3E);
  final Color darkGreen = const Color(0xFF3E6B2C);
  final Color primaryBlue = const Color(0xFF1F4E79);
  final Color lightBackground = const Color(0xFFF4F7F3);
  final Color accentGold = const Color(0xFFC48A3A);
  final Color textDark = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.fetchOrders(await ApiService.getUserID());

      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(result['data']);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to fetch orders')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch orders: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: primaryBlue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : _orders.isEmpty
          ? Center(child: Text("No orders found.", style: TextStyle(color: textDark)))
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final photos = List<Map<String, dynamic>>.from(order['photos'] ?? []);
          final subProducts = List<Map<String, dynamic>>.from(order['sub_product_details'] ?? []);

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID and Date
                  Text(
                    order['order_id'] ?? "",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Date: ${order['date'] ?? '-'} | Time: ${order['time_slot'] ?? '-'}",
                    style: TextStyle(color: textDark),
                  ),
                  const SizedBox(height: 8),

                  // Address
                  Text(
                    "Address: ${order['address'] ?? '-'}",
                    style: TextStyle(fontSize: 14, color: textDark),
                  ),
                  const SizedBox(height: 4),

                  // Contact Info
                  Text(
                    "Contact: ${order['contact'] ?? '-'} | Alt: ${order['alt_contact'] ?? '-'}",
                    style: TextStyle(fontSize: 14, color: textDark),
                  ),
                  const SizedBox(height: 4),

                  // Available person
                  Text(
                    "Available Person: ${order['available_person_name'] ?? '-'}",
                    style: TextStyle(fontSize: 14, color: textDark),
                  ),
                  const SizedBox(height: 8),

                  // Sub Products
                  Text(
                    "Sub Products:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen),
                  ),
                  ...subProducts.map((sub) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Text(
                      "${sub['sub_product_name']} - ${sub['weight']} kg",
                      style: TextStyle(color: textDark),
                    ),
                  )),

                  const SizedBox(height: 8),

                  // Photos
                  if (photos.isNotEmpty) ...[
                    Text(
                      "Photos:",
                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        itemBuilder: (context, pIndex) {
                          final photo = photos[pIndex];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                photo['photo'] ?? '',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.broken_image, size: 80, color: accentGold),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
