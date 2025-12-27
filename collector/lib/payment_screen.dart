// screens/payment_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collector/model/product_model.dart';
import 'package:collector/services/api_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const PRIMARY = Color(0xFF9C8E18);
const PRIMARY_LIGHT = Color(0xFFF7EEA8);
const PRIMARY_DARK = Color(0xFF5E3B1F);
const ACCENT = Color(0xFFF4D03F);
const ERROR = Color(0xFFB93D3D);

class PaymentScreen extends StatefulWidget {
  final int orderId;
  final double amount;
  final String customerPhone;
  final String customerName;
  final Map<String, dynamic> orderData;
  final CalculationResponse calculationResponse;
  final List<Map<String, dynamic>> subProductDetails;
  final Map<String, dynamic>? apiResponseData;

  const PaymentScreen({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.customerPhone,
    required this.customerName,
    required this.orderData,
    required this.calculationResponse,
    required this.subProductDetails,
    this.apiResponseData,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _paymentInProgress = false;
  String _error = '';
  String _paymentStatus = 'pending';
  String _paymentMessage = '';
  String? _transactionId;
  String? _paymentId;
  DateTime? _paymentTime;
  String _selectedUpiApp = 'PhonePe';

  // UPI Payment Details
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Get UPI ID from order data
  String get _upiId {
    return widget.orderData['user_upi_id']?.toString() ??
        widget.apiResponseData?['data']?['user_upi_id']?.toString() ??
        '';
  }

  // Get selling detail ID from order data
  int get _sellingDetailId {
    return widget.orderData['id'] is int
        ? widget.orderData['id'] as int
        : int.tryParse(widget.orderData['id']?.toString() ?? '') ??
        widget.orderId;
  }

  // Get customer contact details
  String get _customerContact {
    return widget.customerPhone.isNotEmpty ? widget.customerPhone :
    widget.orderData['contact']?.toString() ??
        widget.apiResponseData?['data']?['contact']?.toString() ??
        '';
  }

  // Get customer name
  String get _customerName {
    return widget.customerName.isNotEmpty ? widget.customerName :
    widget.orderData['available_person_name']?.toString() ??
        widget.apiResponseData?['data']?['available_person_name']?.toString() ??
        'Customer';
  }

  // Get order reference
  String get _orderReference {
    return widget.orderData['order_id']?.toString() ??
        widget.apiResponseData?['data']?['order_id']?.toString() ??
        'ORD-${widget.orderId}';
  }



  @override
  void initState() {
    super.initState();

    print('DEBUG: PaymentScreen initialized');
    print('DEBUG: Order ID: ${widget.orderId}');
    print('DEBUG: Selling Detail ID: $_sellingDetailId');
    print('DEBUG: Amount: ${widget.amount}');
    print('DEBUG: Customer Phone: ${widget.customerPhone}');
    print('DEBUG: Customer Name: ${widget.customerName}');
    print('DEBUG: UPI ID: $_upiId');
    print('DEBUG: Order Data: ${widget.orderData}');
    print('DEBUG: API Response Data: ${widget.apiResponseData}');

    // Set initial amount
    _amountController.text = widget.amount.toStringAsFixed(2);
    _noteController.text = 'Payment for Order $_orderReference';

    // Initialize payment status
    //_loadPaymentStatus();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /*Future<void> _loadPaymentStatus() async {
    try {
      setState(() => _isLoading = true);

      // Check if payment already exists for this order
      final paymentStatus = await _apiService.getPaymentStatus(widget.orderId);

      if (paymentStatus != null && paymentStatus['status'] == 'success') {
        setState(() {
          _paymentStatus = 'completed';
          _paymentMessage = paymentStatus['message'] ?? 'Payment already completed';
          _transactionId = paymentStatus['transaction_id'];
          _paymentTime = DateTime.tryParse(paymentStatus['payment_time'] ?? '');
        });
      }
    } catch (e) {
      print('DEBUG: Error loading payment status: $e');
      // Ignore error - assume no payment exists
    } finally {
      setState(() => _isLoading = false);
    }
  }*/

  // Generate UPI payment URL
  String _generateUpiUrl() {
    final upiId = _upiId;
    final amount = _amountController.text;
    final note = Uri.encodeComponent(_noteController.text);
    final customerName = Uri.encodeComponent(_customerName);
    final customerPhone = _customerContact;
    final orderRef = Uri.encodeComponent(_orderReference);

    // Standard UPI URL format
    String upiUrl = 'upi://pay?pa=$upiId';

    // Add parameters
    upiUrl += '&pn=$customerName';
    upiUrl += '&am=$amount';
    upiUrl += '&tn=$note';
    upiUrl += '&cu=INR';

    // Add optional parameters
    if (customerPhone.isNotEmpty) {
      upiUrl += '&mc=0000'; // Merchant code
    }

    // Add order reference as transaction reference
    upiUrl += '&tr=$orderRef';

    print('DEBUG: Generated UPI URL: $upiUrl');
    return upiUrl;
  }

  // Initiate UPI Payment
  Future<void> _initiateUpiPayment() async {
    if (_upiId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('UPI ID not found for this order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _paymentInProgress = true;
      _error = '';
    });

    try {
      final upiUrl = _generateUpiUrl();

      if (await canLaunchUrl(Uri.parse(upiUrl))) {
        // Call accept order API first

        // Generate payment and transaction IDs
        _paymentId = 'PAY${DateTime.now().millisecondsSinceEpoch}';
        _transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';

        // Launch UPI app
        final result = await launchUrl(
          Uri.parse(upiUrl),
          mode: LaunchMode.externalApplication,
        );

        if (!result) {
          throw Exception('Failed to launch UPI app');
        }

        // Show instructions for user
        _showPaymentInstructions();

      } else {
        throw Exception('No UPI app found. Please install a UPI app like Google Pay, PhonePe, or Paytm.');
      }
    } catch (e) {
      print('DEBUG: Error initiating UPI payment: $e');
      setState(() {
        _error = 'Failed to initiate payment: ${e.toString()}';
        _paymentInProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  // Show payment instructions dialog
  void _showPaymentInstructions() {
    // Show UPI app selection dialog
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select UPI App'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select which UPI app you will use:'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedUpiApp,
                  items: const [
                    DropdownMenuItem(value: 'Google Pay', child: Text('Google Pay')),
                    DropdownMenuItem(value: 'PhonePe', child: Text('PhonePe')),
                    DropdownMenuItem(value: 'Paytm', child: Text('Paytm')),
                    DropdownMenuItem(value: 'BHIM', child: Text('BHIM')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUpiApp = value ?? 'PhonePe';
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'UPI App',
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Payment Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInstructionItem('1. Complete payment in $_selectedUpiApp'),
                _buildInstructionItem('2. Return to this app'),
                _buildInstructionItem('3. Click "Verify Payment" below'),
                const SizedBox(height: 8),
                const Text(
                  'Note: Do not close this app while payment is in progress.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showPaymentConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY,
                ),
                child: const Text('Continue'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Started'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment has been initiated in $_selectedUpiApp.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildInstructionItem('1. Complete payment in $_selectedUpiApp'),
            _buildInstructionItem('2. Return to this app'),
            _buildInstructionItem('3. Click "Verify Payment" below'),
            const SizedBox(height: 12),
            const Text(
              'Note: Do not close this app while payment is in progress.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _paymentInProgress = false;
              });
            },
            child: const Text('Cancel Payment'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY,
            ),
            child: const Text('Verify Payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, size: 16, color: PRIMARY),
          const SizedBox(width: 4),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // Verify payment with backend
  Future<void> _verifyPayment() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Call API to verify payment and mark order as completed
      final verificationResponse = await _apiService.verifyPaymentApi(_amountController.text,
          _sellingDetailId,
          _paymentId,
          _transactionId,
          _selectedUpiApp
      );


      if (verificationResponse['status'] == 'success') {
        // Payment successful
        setState(() {
          _paymentStatus = 'completed';
          _paymentMessage = verificationResponse['message'] ?? 'Payment completed successfully';
          _paymentTime = DateTime.now();
          _paymentInProgress = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_paymentMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back or to success screen
        _showPaymentSuccessDialog();

      } else {
        // Payment failed or pending
        setState(() {
          _paymentStatus = 'failed';
          _paymentMessage = verificationResponse['message'] ?? 'Payment verification failed';
          _paymentInProgress = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_paymentMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Error verifying payment: $e');
      setState(() {
        _error = 'Payment verification failed: ${e.toString()}';
        _paymentStatus = 'failed';
        _paymentInProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment verification failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  // Show payment success dialog
  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: $_orderReference'),
            Text('Amount: ₹${_amountController.text}'),
            if (_transactionId != null) Text('Transaction ID: $_transactionId'),
            if (_paymentId != null) Text('Payment ID: $_paymentId'),
            Text('UPI App: $_selectedUpiApp'),
            if (_paymentTime != null) Text('Time: ${_paymentTime!.toLocal()}'),
            const SizedBox(height: 16),
            const Text(
              'Order has been marked as completed.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY,
            ),
            child: const Text('View Order Details'),
          ),
        ],
      ),
    );
  }



  // Copy UPI ID to clipboard
  void _copyUpiIdToClipboard() {
    Clipboard.setData(ClipboardData(text: _upiId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('UPI ID copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Share payment details
  void _sharePaymentDetails() {
    final message = '''
Payment Request for Order $_orderReference

Amount: ₹${_amountController.text}
UPI ID: $_upiId
Note: ${_noteController.text}

Please make the payment using any UPI app.
''';

    // In a real app, you would use a share plugin here
    // For now, copy to clipboard
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment details copied to clipboard. Share with customer.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: PRIMARY,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PRIMARY))
          : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Card
          _buildOrderSummaryCard(),
          const SizedBox(height: 20),

          // Payment Status Card
          if (_paymentStatus != 'pending') _buildPaymentStatusCard(),
          if (_paymentStatus != 'pending') const SizedBox(height: 20),

          // Payment Details Card
          _buildPaymentDetailsCard(),
          const SizedBox(height: 20),

          // Error Message
          if (_error.isNotEmpty) _buildErrorMessage(),
          if (_error.isNotEmpty) const SizedBox(height: 20),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PRIMARY_DARK,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Order ID', _orderReference),
            _buildSummaryRow('Selling Detail ID', '$_sellingDetailId'),
            _buildSummaryRow('Customer', _customerName),
            if (_customerContact.isNotEmpty)
              _buildSummaryRow('Contact', _customerContact),
            _buildSummaryRow('Total Amount', '₹${widget.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Items (${widget.subProductDetails.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.subProductDetails.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '• ${item['sub_product_name']}',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item['weight']} kg',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_paymentStatus) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Payment Completed';
        break;
      case 'processing':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Payment Processing';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Payment Failed';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
        statusText = 'Payment Pending';
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  if (_paymentMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _paymentMessage,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  if (_transactionId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Txn ID: $_transactionId',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (_selectedUpiApp.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'UPI App: $_selectedUpiApp',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildPaymentDetailsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PRIMARY_DARK,
              ),
            ),
            const SizedBox(height: 16),

            // UPI ID Section
            const Text(
              'Pay To UPI ID:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PRIMARY_LIGHT,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: PRIMARY),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _upiId.isNotEmpty ? _upiId : 'UPI ID not available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _upiId.isNotEmpty ? PRIMARY_DARK : Colors.grey,
                      ),
                    ),
                  ),
                  if (_upiId.isNotEmpty)
                    IconButton(
                      onPressed: _copyUpiIdToClipboard,
                      icon: const Icon(Icons.content_copy, size: 20),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),

            // Note Input
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Payment Note',
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ERROR.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ERROR.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: ERROR),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error,
              style: const TextStyle(color: ERROR),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_paymentStatus != 'completed')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _paymentInProgress ? null : _initiateUpiPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _paymentInProgress
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Processing...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Start UPI Payment',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        if (_paymentStatus == 'processing')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Verifying...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Verify Payment',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _sharePaymentDetails,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: PRIMARY),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share, size: 24, color: PRIMARY),
                SizedBox(width: 12),
                Text(
                  'Share Payment Details',
                  style: TextStyle(fontSize: 16, color: PRIMARY),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


}