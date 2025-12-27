// screens/payment_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:collector/services/api_services.dart';
import 'package:collector/model/product_model.dart';

class PaymentScreen extends StatefulWidget {
  final int orderId;
  final double amount;
  final String customerPhone;
  final Map<String, dynamic> orderData;
  final CalculationResponse calculationResponse;
  final List<Map<String, dynamic>> subProductDetails;

  const PaymentScreen({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.customerPhone,
    required this.orderData,
    required this.calculationResponse,
    required this.subProductDetails,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _apiService = ApiService();
  String? _selectedUpiApp;
  bool _isProcessing = false;
  String _error = '';
  String _paymentStatus = '';
  bool _paymentSuccess = false;

  // List of popular UPI apps in India
  final List<Map<String, dynamic>> _upiApps = [
    {
      'id': 'gpay',
      'name': 'Google Pay',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF5F6368),
    },
    {
      'id': 'phonepe',
      'name': 'PhonePe',
      'icon': Icons.phone_android,
      'color': Color(0xFF5F259F),
    },
    {
      'id': 'paytm',
      'name': 'Paytm',
      'icon': Icons.account_balance,
      'color': Color(0xFF00BAF2),
    },
    {
      'id': 'bhim',
      'name': 'BHIM UPI',
      'icon': Icons.currency_rupee,
      'color': Color(0xFFFB6A02),
    },
    {
      'id': 'amazonpay',
      'name': 'Amazon Pay',
      'icon': Icons.shopping_cart,
      'color': Color(0xFF232F3E),
    },
    {
      'id': 'cash',
      'name': 'Cash Payment',
      'icon': Icons.money,
      'color': Color(0xFF4CAF50),
    },
  ];

  Future<void> _processPayment() async {
    if (_selectedUpiApp == null) {
      setState(() => _error = 'Please select a payment method');
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = '';
      _paymentStatus = 'Initiating payment...';
    });

    try {
      // Step 1: Initiate payment
      _paymentStatus = 'Initiating payment...';
      final paymentResponse = await _apiService.initiatePayment(
        orderId: widget.orderId,
        amount: widget.amount,
        customerPhone: widget.customerPhone,
      );

      // Check if payment was initiated successfully
      if (paymentResponse['success'] == true) {
        _paymentStatus = 'Payment initiated. Processing...';

        // Simulate payment processing with actual UPI intent
        if (_selectedUpiApp != 'cash') {
          // For UPI apps, simulate processing
          await Future.delayed(const Duration(seconds: 3));

          // Simulate successful UPI payment
          final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
          final paymentId = 'PAY${DateTime.now().millisecondsSinceEpoch}';

          // Step 2: Verify payment (simulated for demo)
          _paymentStatus = 'Verifying payment...';
          await Future.delayed(const Duration(seconds: 2));

          // Step 3: Complete the order
          _paymentStatus = 'Completing order...';
          final completeResponse = await _apiService.completeOrder(
            orderId: widget.orderId,
            finalAmount: widget.amount,
            subProductDetails: widget.subProductDetails,
            paymentId: paymentId,
            transactionId: transactionId,
            paymentStatus: 'completed',
            paymentMethod: 'upi',
            upiApp: _selectedUpiApp,
          );

          if (completeResponse['success'] == true) {
            setState(() {
              _paymentSuccess = true;
              _paymentStatus = 'Payment successful!';
            });

            // Show success message
            _showSuccessDialog();
          } else {
            throw Exception('Failed to complete order');
          }
        } else {
          // For cash payment
          _paymentStatus = 'Processing cash payment...';
          await Future.delayed(const Duration(seconds: 2));

          // Complete order for cash payment
          final completeResponse = await _apiService.completeOrder(
            orderId: widget.orderId,
            finalAmount: widget.amount,
            subProductDetails: widget.subProductDetails,
            paymentId: null,
            transactionId: null,
            paymentStatus: 'completed',
            paymentMethod: 'cash',
            upiApp: null,
          );

          if (completeResponse['success'] == true) {
            setState(() {
              _paymentSuccess = true;
              _paymentStatus = 'Cash payment recorded!';
            });

            // Show success message for cash
            _showSuccessDialog(isCash: true);
          } else {
            throw Exception('Failed to record cash payment');
          }
        }
      } else {
        throw Exception('Failed to initiate payment: ${paymentResponse['message']}');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _error = e.toString();
        _paymentStatus = 'Payment failed';
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showSuccessDialog({bool isCash = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCash
                  ? 'Cash payment of ₹${widget.amount.toStringAsFixed(2)} has been recorded successfully.'
                  : 'Payment of ₹${widget.amount.toStringAsFixed(2)} has been completed successfully.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order ID:', style: TextStyle(color: Colors.grey.shade600)),
                      Text('#${widget.orderData['order_id']}', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount:', style: TextStyle(color: Colors.grey.shade600)),
                      Text('₹${widget.amount.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment Method:', style: TextStyle(color: Colors.grey.shade600)),
                      Text(
                        _selectedUpiApp == 'cash' ? 'Cash' : 'UPI (${_getUpiAppName(_selectedUpiApp!)})',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, {
                'paymentSuccess': true,
                'orderCompleted': true,
                'paymentMethod': _selectedUpiApp == 'cash' ? 'cash' : 'upi',
                'upiApp': _selectedUpiApp,
                'amount': widget.amount,
              });
            },
            child: Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getUpiAppName(String appId) {
    final app = _upiApps.firstWhere((app) => app['id'] == appId, orElse: () => {});
    return app['name'] ?? appId.toUpperCase();
  }

  Widget _buildUpiAppCard(Map<String, dynamic> upiApp) {
    final isSelected = _selectedUpiApp == upiApp['id'];
    final isCash = upiApp['id'] == 'cash';

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? upiApp['color'].withOpacity(0.2) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? upiApp['color'] : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            upiApp['icon'],
            color: upiApp['color'],
            size: 28,
          ),
        ),
        title: Text(
          upiApp['name'],
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? upiApp['color'] : Colors.black87,
            fontSize: 16,
          ),
        ),
        subtitle: isCash
            ? Text(
          'Pay with cash on delivery',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        )
            : null,
        trailing: Radio<String>(
          value: upiApp['id'],
          groupValue: _selectedUpiApp,
          activeColor: upiApp['color'],
          onChanged: (value) {
            setState(() {
              _selectedUpiApp = value;
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedUpiApp = upiApp['id'];
          });
        },
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order ID and Customer
            _buildDetailRow('Order ID', '#${widget.orderData['order_id']}'),
            _buildDetailRow('Customer', widget.orderData['customer_name'] ?? 'Customer'),
            _buildDetailRow('Phone', widget.customerPhone),

            const Divider(height: 20),

            // Items summary
            Text(
              'Items:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.subProductDetails.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '• ${item['sub_product_name']}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item['weight']} kg',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),

            if (widget.subProductDetails.length > 3)
              Text(
                '...and ${widget.subProductDetails.length - 3} more items',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),

            const Divider(height: 20),

            // Total amount
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    '₹${widget.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            _paymentStatus,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Please wait...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
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
        title: const Text('Payment'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (!_isProcessing) Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  _buildOrderSummary(),

                  // Payment Method Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Choose how you want to pay',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // UPI Apps List
                  ..._upiApps.map((upiApp) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: _buildUpiAppCard(upiApp),
                  )).toList(),

                  // Processing indicator
                  if (_isProcessing)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildProcessingIndicator(),
                    ),

                  // Error message
                  if (_error.isNotEmpty && !_isProcessing)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _error,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Pay Now Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: _isProcessing
                ? SizedBox() // Hide button when processing
                : ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedUpiApp != null ? Colors.green : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 56),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Pay Now ₹${widget.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}