import 'package:collector/razorpay/razorpay_service.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final int amount;
  final String keyId;
  final String planName;
  final String userName;
  final String userEmail;

  const PaymentPage({
    super.key,
    required this.orderId,
    required this.amount,
    required this.keyId,
    required this.planName,
    required this.userName,
    required this.userEmail,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final RazorpayService _razorpayService = RazorpayService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpayService.initialize();
    _setupRazorpayCallbacks();
    _initiatePayment();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _setupRazorpayCallbacks() {
    _razorpayService.onSuccess = (Map<String, dynamic> result) {
      setState(() {
        _isProcessing = false;
      });

      _showSuccessDialog(result);
    };

    _razorpayService.onError = (String errorMessage) {
      setState(() {
        _isProcessing = false;
      });

      _showErrorDialog(errorMessage);
    };
  }

  void _initiatePayment() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate delay for demo
    Future.delayed(const Duration(seconds: 1), () {
      _razorpayService.openCheckout(
        orderId: widget.orderId,
        keyId: widget.keyId,
        amount: widget.amount,
        planName: widget.planName,
        userName: widget.userName,
        userEmail: widget.userEmail,
        userContact: '9999999999', // Get from user profile
      );
    });
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan: ${widget.planName}'),
            const SizedBox(height: 10),
            Text('Amount: ₹${widget.amount / 100}'),
            const SizedBox(height: 10),
            Text(
              'Payment ID: ${result['payment_id']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to subscription page
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Payment Failed'),
          ],
        ),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessing = false;
              });
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Gateway'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'Processing Payment...',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Opening Razorpay Gateway',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ] else ...[
              const Icon(
                Icons.payment,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment Gateway',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Plan: ${widget.planName}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                'Amount: ₹${widget.amount / 100}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _initiatePayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),
                child: const Text('Proceed to Payment'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}