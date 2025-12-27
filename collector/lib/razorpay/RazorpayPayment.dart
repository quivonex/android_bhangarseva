import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPayment extends StatefulWidget {
  final double amount;
  final String orderId;

  RazorpayPayment({required this.amount, required this.orderId});

  @override
  _RazorpayPaymentState createState() => _RazorpayPaymentState();
}

class _RazorpayPaymentState extends State<RazorpayPayment> {
  late Razorpay _razorpay;

  // ⚠️ REMOVE THE APOSTROPHE FROM YOUR KEY!
  // Wrong: "rzp_test_tfn9mZnMHpB4Tj'"
  // Right: "rzp_test_tfn9mZnMHpB4Tj"
  final String _keyId = "rzp_test_tfn9mZnMHpB4Tj"; // Fixed key - no apostrophe!

  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    try {
      print('Initializing Razorpay with key: ${_keyId.substring(0, 10)}...');

      // Validate key format
      if (!_keyId.startsWith('rzp_')) {
        throw Exception('Invalid Razorpay key format');
      }

      if (_keyId.contains("'") || _keyId.contains('"')) {
        throw Exception('Key contains invalid characters');
      }

      _razorpay = Razorpay();
      _setupListeners();
      _initialized = true;

      print('✅ Razorpay initialized successfully');
    } catch (e) {
      print('❌ Razorpay initialization error: $e');
      _initialized = false;

      // Show error immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog('Payment initialization failed: ${e.toString()}');
      });
    }
  }

  void _setupListeners() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _initiatePayment() async {
    // Check if initialized
    if (!_initialized) {
      _showErrorDialog('Payment gateway not initialized. Please restart the app.');
      return;
    }

    // Validate key again
    if (_keyId.isEmpty || !_keyId.startsWith('rzp_')) {
      _showErrorDialog('Invalid Razorpay configuration. Please check your API key.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create payment options
      var options = {
        'key': _keyId.trim(), // Trim any whitespace
        'amount': (widget.amount / 100).toStringAsFixed(0), // Convert to paise
        'currency': 'INR',
        'name': 'Bhangar-Seva',
        'description': 'Payment for Order #${widget.orderId}',
        'prefill': {
          'contact': '+919876543210',
          'email': 'customer@email.com',
        },
        'theme': {
          'color': '#F37254',
          'backdrop_color': '#FFFFFF',
        },
        'timeout': 180, // 3 minutes
        'retry': {
          'enabled': true,
          'max_count': 1
        }
      };

      print('Opening payment with amount: ${widget.amount}');
      print('Using key: ${_keyId.substring(0, 15)}...');

      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');

      String errorMessage = 'Failed to open payment gateway';

      if (e.toString().contains('invalid') || e.toString().contains('auth')) {
        errorMessage = 'Invalid API key. Please check your Razorpay configuration.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('✅ Payment Success: ${response.paymentId}');

    // Close any open dialogs
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Payment Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thank you for your payment!'),
            SizedBox(height: 15),
            _buildDetailRow('Order ID:', widget.orderId),
            _buildDetailRow('Payment ID:', response.paymentId ?? 'N/A'),
            _buildDetailRow('Amount:', '₹${widget.amount.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, {
                'status': 'success',
                'payment_id': response.paymentId,
                'order_id': widget.orderId,
              }); // Return to previous screen with result
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('❌ Payment Error: ${response.code} - ${response.message}');

    String errorMessage = 'Payment failed. Please try again.';

    // Parse error codes
    if (response.code == 2) {
      errorMessage = 'Network error. Please check your internet connection.';
    } else if (response.code == 1) {
      errorMessage = 'Payment cancelled by user.';
    } else if (response.message?.toLowerCase().contains('invalid') == true ||
        response.message?.toLowerCase().contains('auth') == true) {
      errorMessage = 'Invalid payment configuration. Please contact support.';
    } else if (response.message != null) {
      errorMessage = response.message!;
    }

    _showErrorDialog(errorMessage);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('🔗 External Wallet: ${response.walletName}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${response.walletName}...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Payment Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _initiatePayment(); // Retry
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment'),
        centerTitle: true,
        backgroundColor: Color(0xFFF37254), // Match Razorpay color
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order Summary Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt, color: Color(0xFFF37254)),
                          SizedBox(width: 10),
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(),
                      SizedBox(height: 15),
                      _buildSummaryRow('Order ID', '#${widget.orderId}'),
                      SizedBox(height: 10),
                      _buildSummaryRow('Amount', '₹${widget.amount.toStringAsFixed(2)}'),
                      SizedBox(height: 10),
                      _buildSummaryRow('Currency', 'INR (₹)'),
                      SizedBox(height: 15),
                      Divider(),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Payable',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${widget.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Payment Button
              if (_isLoading)
                Column(
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFF37254),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Opening payment gateway...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _initialized ? _initiatePayment : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Color(0xFFF37254),
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Proceed to Secure Payment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 20),

              // Security Info
              Card(
                color: Colors.grey[50],
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security, color: Colors.green, size: 18),
                          SizedBox(width: 8),
                          Text(
                            '100% Secure Payment',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your payment is secured by Razorpay. We do not store your card details.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/razorpay_logo.png', // Add Razorpay logo to assets
                            height: 20,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Secured by Razorpay',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Payment Methods Info
              Text(
                'Accepted Payment Methods:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 15,
                runSpacing: 10,
                children: [
                  _buildPaymentMethod('Credit Card'),
                  _buildPaymentMethod('Debit Card'),
                  _buildPaymentMethod('UPI'),
                  _buildPaymentMethod('Net Banking'),
                  _buildPaymentMethod('Wallet'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(String method) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        method,
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
      ),
    );
  }

  @override
  void dispose() {
    if (_initialized) {
      _razorpay.clear();
    }
    super.dispose();
  }
}