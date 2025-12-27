// screens/pending_requests_screen.dart
import 'package:flutter/material.dart';

import 'model/request_model.dart'; // You'll need to create this model

const primaryGold = Color(0xFFb59d31);
const darkBrown = Color(0xFF4a3b1a);
const lightGold = Color(0xFFF6F0D3);

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  List<Request> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _pendingRequests = [
        Request(
          id: '1',
          customerName: 'Rajesh Kumar',
          address: '123 Main St, Mumbai',
          items: 'Plastic, Paper',
          scheduledDate: '2024-01-15',
          status: 'pending',
          amount: '₹150',
        ),
        Request(
          id: '2',
          customerName: 'Priya Singh',
          address: '456 Oak Ave, Delhi',
          items: 'Metal, Glass',
          scheduledDate: '2024-01-16',
          status: 'pending',
          amount: '₹230',
        ),
        Request(
          id: '3',
          customerName: 'Amit Patel',
          address: '789 Pine Rd, Bangalore',
          items: 'E-waste, Plastic',
          scheduledDate: '2024-01-17',
          status: 'pending',
          amount: '₹180',
        ),
      ];
      _isLoading = false;
    });
  }

  void _acceptRequest(String requestId) {
    // TODO: Implement accept request API
    setState(() {
      _pendingRequests.removeWhere((request) => request.id == requestId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request $requestId accepted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectRequest(String requestId) {
    // TODO: Implement reject request API
    setState(() {
      _pendingRequests.removeWhere((request) => request.id == requestId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request $requestId rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Requests'),
        backgroundColor: primaryGold,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryGold),
        ),
      )
          : _pendingRequests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pending_actions,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Pending Requests',
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
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
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
                        'Request #${request.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Pending',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customer: ${request.customerName}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Address: ${request.address}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Items: ${request.items}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scheduled: ${request.scheduledDate}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Amount: ${request.amount}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _rejectRequest(request.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _acceptRequest(request.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGold,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
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