// screens/completed_requests_screen.dart
import 'package:flutter/material.dart';

const primaryGold = Color(0xFFb59d31);
const darkBrown = Color(0xFF4a3b1a);

class CompletedRequestsScreen extends StatefulWidget {
  const CompletedRequestsScreen({super.key});

  @override
  State<CompletedRequestsScreen> createState() => _CompletedRequestsScreenState();
}

class _CompletedRequestsScreenState extends State<CompletedRequestsScreen> {
  List<Map<String, dynamic>> _completedRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedRequests();
  }

  Future<void> _loadCompletedRequests() async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _completedRequests = [
        {
          'id': 'C001',
          'customerName': 'Rajesh Kumar',
          'address': '123 Main St, Mumbai',
          'items': 'Plastic, Paper',
          'completedDate': '2024-01-10',
          'amount': '₹150',
          'rating': 4,
        },
        {
          'id': 'C002',
          'customerName': 'Priya Singh',
          'address': '456 Oak Ave, Delhi',
          'items': 'Metal, Glass',
          'completedDate': '2024-01-09',
          'amount': '₹230',
          'rating': 5,
        },
        {
          'id': 'C003',
          'customerName': 'Amit Patel',
          'address': '789 Pine Rd, Bangalore',
          'items': 'E-waste, Plastic',
          'completedDate': '2024-01-08',
          'amount': '₹180',
          'rating': 4,
        },
      ];
      _isLoading = false;
    });
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Requests'),
        backgroundColor: primaryGold,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryGold),
        ),
      )
          : _completedRequests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Completed Requests',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _completedRequests.length,
        itemBuilder: (context, index) {
          final request = _completedRequests[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Request #${request['id']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customer: ${request['customerName']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Address: ${request['address']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Items: ${request['items']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Completed: ${request['completedDate']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount: ${request['amount']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      _buildRatingStars(request['rating']),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}