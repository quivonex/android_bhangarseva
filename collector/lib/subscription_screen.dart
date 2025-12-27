import 'package:collector/razorpay/PaymentScreen.dart';
import 'package:collector/razorpay/RazorpayPayment.dart';
import 'package:collector/razorpay/razorpay_service.dart';
import 'package:collector/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key, required userId, required username});

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final RazorpayService _razorpayService = RazorpayService();

  // Dummy subscription plans with realistic prices
  final List<Map<String, dynamic>> _dummyPlans = [
    {
      "id": "plan_basic",
      "title": "Basic Plan",
      "description": "Perfect for getting started",
      "price": 299, // ₹299
      "duration_days": 30,
      "features": [
        "Access to basic content",
        "Standard support",
        "Monthly updates"
      ]
    },
    {
      "id": "plan_pro",
      "title": "Pro Plan",
      "description": "Most popular choice",
      "price": 999, // ₹999
      "duration_days": 90,
      "features": [
        "Access to all content",
        "Priority support",
        "Weekly updates",
        "Advanced analytics"
      ]
    },
    {
      "id": "plan_premium",
      "title": "Premium Plan",
      "description": "Best value for professionals",
      "price": 2499.0, // ₹2,499
      "duration_days": 365,
      "features": [
        "Unlimited access",
        "24/7 VIP support",
        "Daily updates",
        "Custom analytics",
        "API access"
      ]
    },
    {
      "id": "plan_enterprise",
      "title": "Enterprise Plan",
      "description": "For large organizations",
      "price": 9999.0, // ₹9,999
      "duration_days": 365,
      "features": [
        "Everything in Premium",
        "Custom integrations",
        "Dedicated account manager",
        "SLA guarantee",
        "White labeling"
      ]
    }
  ];

  List<dynamic> _plans = [];
  bool _isLoading = false;
  String _userEmail = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _razorpayService.initialize();
    _loadUserData();
    _loadPlans();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('username') ?? 'test@example.com';
      _userName = prefs.getString('username') ?? 'Test User';
    });
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to fetch plans from API
      final apiPlans = await ApiService.getSubscriptionPlans();
      setState(() {
        _plans = apiPlans.isNotEmpty ? apiPlans : _dummyPlans;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading plans from API: $e');
      // Fallback to dummy plans
      setState(() {
        _plans = _dummyPlans;
        _isLoading = false;
      });
      print('Using dummy plans');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handlePlanSelection(Map<String, dynamic> plan) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Creating order...'),
            ],
          ),
        ),
      );

      // Create order on backend
      final orderData = await ApiService.createOrder(
        plan['price'],
        plan['title'],
      );

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to payment page
      Navigator.push(
        context,
        MaterialPageRoute(
          /*builder: (context) => PaymentPage(
            orderId: orderData['order_id'],
            amount: orderData['amount'],
            keyId: orderData['key_id'],
            planName: plan['title'],
            userName: _userName,
            userEmail: _userEmail,
          )*/
        builder: (context) => RazorpayPayment(
        orderId: orderData['order_id'],
        amount: orderData['amount']
         )
        ),
      ).then((result) {
        // Handle payment result when returning from payment page
        if (result != null && result['status'] == 'success') {
          _showSuccessSnackbar('Payment completed successfully!');
        }
      });

    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);

      print('Error creating order: $e');

      // Show detailed error message
      String errorMessage = 'Failed to create order';
      if (e.toString().contains('Connection refused')) {
        errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Session expired. Please login again.';
      }

      _showErrorSnackbar(errorMessage);

      // For testing/demo: Create mock order data
      await _handleMockOrder(plan);
    }
  }

  Future<void> _handleMockOrder(Map<String, dynamic> plan) async {
    // Mock order data for testing/demo
    final mockOrderData = {
      'order_id': 'order_mock_${DateTime.now().millisecondsSinceEpoch}',
      'amount': (plan['price'] * 100).toString(), // Convert to paise
      'key_id': 'rzp_test_tfn9mZnMHpB4Tj', // Mock key ID
    };

    // Show demo mode notice
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('Demo Mode'),
          ],
        ),
        content: const Text(
          'Using demo payment mode. This will simulate a payment without actual money transfer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToMockPayment(plan, mockOrderData);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _navigateToMockPayment(Map<String, dynamic> plan, Map<String, dynamic> orderData) {
    // Navigate to payment page with mock data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RazorpayPayment(
          orderId: orderData['order_id'],
          amount: double.parse(orderData['amount']), // Convert to double
        ),
      ),
    ).then((result) {
      if (result != null && result['status'] == 'success') {
        _showSuccessSnackbar('Mock payment completed!');
      }
    });
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    bool isPopular = plan['title'] == "Pro Plan";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: isPopular
            ? Border.all(color: Colors.blue, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              Text(
                plan['title'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isPopular ? Colors.blue : Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                plan['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 16),

              // Price section
              Row(
                children: [
                  Text(
                    '₹${plan['price']}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/ ${plan['duration_days']} days',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              // Price per day calculation
              if (plan['duration_days'] > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '₹${(plan['price'] / plan['duration_days']).toStringAsFixed(2)}/day',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Features list
              if (plan['features'] != null && (plan['features'] as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(plan['features'] as List).map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature.toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    const SizedBox(height: 20),
                  ],
                ),

              // Subscribe button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handlePlanSelection(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular ? Colors.blue : Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    isPopular ? 'Get Started' : 'Subscribe Now',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Subscription Plan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlans,
            tooltip: 'Refresh plans',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading subscription plans...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : _plans.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'No subscription plans available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadPlans,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          return _buildPlanCard(_plans[index]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            final hasSubscription = await ApiService.hasActiveSubscription();
            if (hasSubscription) {
              _showSuccessSnackbar('You have an active subscription! 🎉');
            } else {
              _showErrorSnackbar('No active subscription found');
            }
          } catch (e) {
            _showErrorSnackbar('Unable to check subscription status');
          }
        },
        icon: const Icon(Icons.subscriptions),
        label: const Text('Check Status'),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 16, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Secure payments powered by Razorpay',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}