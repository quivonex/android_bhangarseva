import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'combine_selection_product.dart';

const Color primaryGold = Color(0xFFb59d31);
const Color darkBrown = Color(0xFF4a3b1a);
const Color lightGrey = Color(0xFFF8F9FA);

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
        SnackBar(content: Text(e.toString())),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order ${order['order_id']}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
              const SizedBox(height: 15),
              _info("Name", order['available_person_name']),
              _info("Contact", order['contact']),
              _info("Alt Contact", order['alt_contact']),
              _info("Address", order['address']),
              _info("Date", order['date']),
              _info("Time Slot", order['time_slot']),
              _info("Status", order['order_status']),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startPickup(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "START PICKUP",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text("Accepted Orders"),
        backgroundColor: primaryGold,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAcceptedOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text("No Accepted Orders"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (_, index) {
          final order = _orders[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              title: Text(order['order_id']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['address'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(order['time_slot']),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _showOrderDetails(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                ),
                child: const Text("View"),
              ),
            ),
          );
        },
      ),
    );
  }
}
