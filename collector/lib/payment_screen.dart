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
const SUCCESS = Color(0xFF28A745);
const INFO = Color(0xFF17A2B8);

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
  bool _manualPaymentMode = false;
  bool _showQrCode = false;
  String _error = '';
  String _paymentStatus = 'pending'; // pending, processing, completed, failed
  String _paymentMessage = '';
  String? _transactionId;
  String? _paymentId;
  DateTime? _paymentTime;
  String _selectedPaymentMethod = 'upi';
  String _selectedUpiApp = 'PhonePe';
  String _selectedUpiId = '9226859922@ybl';

  List<String> _availableUpiIds = [
    '9226859922@ybl',
    '9226859922@okicici',
    '9226859922@upi',
    '9226859922@axl',
  ];

  // Form controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();

  // Get selling detail ID from order data
  int get _sellingDetailId {
    return widget.orderData['id'] is int
        ? widget.orderData['id'] as int
        : int.tryParse(widget.orderData['id']?.toString() ?? '') ??
        widget.orderId;
  }

  // Get customer contact details
  String get _customerContact {
    return widget.customerPhone.isNotEmpty
        ? widget.customerPhone
        : widget.orderData['contact']?.toString() ??
        widget.apiResponseData?['data']?['contact']?.toString() ??
        '';
  }

  // Get customer name
  String get _customerName {
    return widget.customerName.isNotEmpty
        ? widget.customerName
        : widget.orderData['available_person_name']?.toString() ??
        widget.apiResponseData?['data']?['available_person_name']?.toString() ??
        'Customer';
  }

  // Get order reference
  String get _orderReference {
    return widget.orderData['order_id']?.toString() ??
        widget.apiResponseData?['data']?['order_id']?.toString() ??
        'ORD-${widget.orderId}';
  }

  double get _totalAmount {
    return widget.amount;
  }

  @override
  void initState() {
    super.initState();

    print('🔧 DEBUG: PaymentScreen initialized');
    print('🔧 Order Reference: $_orderReference');
    print('🔧 Selling Detail ID: $_sellingDetailId');
    print('🔧 Calculation Response Totals: ${widget.calculationResponse.grandTotals?.toJson()}');
    print('🔧 Sub Product Details: ${widget.subProductDetails.length} items');

    // Log each sub product detail
    for (var item in widget.subProductDetails) {
      print('🔧 Item: ${item['sub_product_name']} - Weight: ${item['weight']} - Rate: ${item['my_rate']}');
    }

    // Initialize controllers with proper values
    _amountController.text = _totalAmount.toStringAsFixed(2);
    _noteController.text = 'PaymentOrder$_orderReference';
    _upiIdController.text = _selectedUpiId;
    _paymentMethodController.text = 'UPI';

    // Debug: Print calculated amount
    print('🔧 Calculated Total Amount: $_totalAmount');
    print('🔧 Amount in controller: ${_amountController.text}');

    // Initialize payment status
    _loadPaymentStatus();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _paymentMethodController.dispose();
    _referenceController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  /// Load existing payment status if any
  Future<void> _loadPaymentStatus() async {
    try {
      setState(() {
        _paymentStatus = 'pending';
      });
    } catch (e) {
      print('🔧 DEBUG: Error loading payment status: $e');
    }
  }

  /// Generate PhonePe specific URL
  String _generatePhonePeUrl() {
    final upiId = _upiIdController.text.trim();
    final amount = _amountController.text.trim();
    final note = Uri.encodeComponent('paymentfrombhangarwalaagent');
    final customerName = Uri.encodeComponent(_customerName);
    final orderRef = Uri.encodeComponent(_orderReference);

    // PhonePe specific format
    return 'phonepe://pay?pa=$upiId&pn=$customerName&am=$amount&tn=$note&cu=INR&tr=$orderRef';
  }

  /// Generate Google Pay URL
  String _generateGooglePayUrl() {
    final upiId = _upiIdController.text.trim();
    final amount = _amountController.text.trim();
    final note = Uri.encodeComponent('paymentfrombhangarwalaagent');
    final customerName = Uri.encodeComponent(_customerName);

    return 'tez://upi/pay?pa=$upiId&pn=$customerName&am=$amount&tn=$note&cu=INR';
  }

  /// Generate Paytm URL
  String _generatePaytmUrl() {
    final upiId = _upiIdController.text.trim();
    final amount = _amountController.text.trim();
    final note = Uri.encodeComponent('paymentfrombhangarwalaagent');
    final customerName = Uri.encodeComponent(_customerName);

    return 'paytmmp://pay?pa=$upiId&pn=$customerName&am=$amount&tn=$note&cu=INR';
  }

  /// Generate generic UPI payment URL
  String _generateGenericUpiUrl() {
    final upiId = _upiIdController.text.trim();
    final amount = _amountController.text.trim();
    final note = Uri.encodeComponent('paymentfrombhangarwalaagent');
    final customerName = Uri.encodeComponent(_customerName);
    final orderRef = Uri.encodeComponent(_orderReference);

    // Standard UPI URL format
    String upiUrl = 'upi://pay?pa=$upiId';

    // Add parameters
    upiUrl += '&pn=$customerName';
    upiUrl += '&am=$amount';
    upiUrl += '&tn=$note';
    upiUrl += '&cu=INR';
    upiUrl += '&mc=0000'; // Merchant code
    upiUrl += '&tr=$orderRef'; // Transaction reference

    print('🔧 DEBUG: Generated UPI URL: $upiUrl');
    return upiUrl;
  }

  /// Get appropriate UPI URL based on selected app
  String _getUpiUrl() {
    switch (_selectedUpiApp.toLowerCase()) {
      case 'phonepe':
        return _generatePhonePeUrl();
      case 'google pay':
        return _generateGooglePayUrl();
      case 'paytm':
        return _generatePaytmUrl();
      default:
        return _generateGenericUpiUrl();
    }
  }

  /// Launch UPI payment
  Future<void> _launchUpiPayment() async {
    if (_upiIdController.text.isEmpty || !_upiIdController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid UPI ID'),
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
      final upiUrl = _getUpiUrl();

      print('🔧 DEBUG: Launching UPI URL: $upiUrl');
      print('🔧 Selected UPI App: $_selectedUpiApp');
      print('🔧 Using UPI ID: ${_upiIdController.text}');

      // Check if we can launch the URL
      bool canLaunch = await canLaunchUrl(Uri.parse(upiUrl));

      if (!canLaunch) {
        // Try alternative approach
        await _launchUpiAppDirectly();
      } else {
        await launchUrl(
          Uri.parse(upiUrl),
          mode: LaunchMode.externalApplication,
        );

        // Show verification dialog after a short delay
        await Future.delayed(const Duration(seconds: 1));
        _showUpiPaymentVerificationDialog();
      }

    } catch (e) {
      print('🔧 DEBUG: Error launching UPI payment: $e');
      setState(() {
        _error = 'Payment initiation failed: ${e.toString()}';
        _paymentInProgress = false;
      });

      _showPaymentFallbackOptions();
    }
  }

  /// Launch UPI app directly with package name
  Future<void> _launchUpiAppDirectly() async {
    try {
      String? packageName;
      String? marketUrl;

      // Set package name and market URL based on selected app
      switch (_selectedUpiApp.toLowerCase()) {
        case 'phonepe':
          packageName = 'com.phonepe.app';
          marketUrl = 'market://details?id=$packageName';
          break;
        case 'google pay':
          packageName = 'com.google.android.apps.nbu.paisa.user';
          marketUrl = 'market://details?id=$packageName';
          break;
        case 'paytm':
          packageName = 'net.one97.paytm';
          marketUrl = 'market://details?id=$packageName';
          break;
        case 'bhim':
          packageName = 'in.org.npci.upiapp';
          marketUrl = 'market://details?id=$packageName';
          break;
      }

      if (packageName != null && marketUrl != null) {
        bool canLaunch = await canLaunchUrl(Uri.parse(marketUrl));
        if (canLaunch) {
          await launchUrl(Uri.parse(marketUrl));
        } else {
          throw Exception('$_selectedUpiApp app not found. Please install from Play Store.');
        }
      } else {
        throw Exception('No UPI app found. Please install a UPI app.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Show UPI payment verification dialog
  void _showUpiPaymentVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UPI app launched: $_selectedUpiApp'),
            const SizedBox(height: 16),
            const Text(
              'Please complete the payment in the UPI app, then:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInstructionItem('1. Complete payment in $_selectedUpiApp'),
            _buildInstructionItem('2. Return to this app'),
            _buildInstructionItem('3. Click appropriate button below'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'After payment completion:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _paymentInProgress = false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markPaymentAsSuccessful();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SUCCESS,
            ),
            child: const Text('Payment Successful'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _markPaymentAsFailed();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ERROR),
            ),
            child: const Text('Payment Failed', style: TextStyle(color: ERROR)),
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

  /// Show fallback payment options when UPI fails
  void _showPaymentFallbackOptions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Payment Options'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'UPI payment failed. Please try one of these options:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Option 1: QR Code
            ListTile(
              leading: const Icon(Icons.qr_code, color: PRIMARY),
              title: const Text('Scan QR Code'),
              subtitle: const Text('Use any UPI app to scan'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _showQrCode = true;
                });
              },
            ),

            // Option 2: Change UPI ID
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: INFO),
              title: const Text('Change UPI ID'),
              subtitle: const Text('Try different UPI ID format'),
              onTap: () {
                Navigator.pop(context);
                _showUpiIdSelectionDialog();
              },
            ),

            // Option 3: Manual Entry
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.purple),
              title: const Text('Manual Payment Entry'),
              subtitle: const Text('Record cash or other payment'),
              onTap: () {
                Navigator.pop(context);
                _showManualPaymentDialog();
              },
            ),

            // Option 4: Share via WhatsApp
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
              title: const Text('Share via WhatsApp'),
              subtitle: const Text('Send payment request to customer'),
              onTap: () {
                Navigator.pop(context);
                _shareUpiDetailsViaWhatsApp();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show UPI ID selection dialog
  void _showUpiIdSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select UPI ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableUpiIds.map((upiId) {
            return RadioListTile<String>(
              title: Text(upiId),
              value: upiId,
              groupValue: _selectedUpiId,
              onChanged: (value) {
                setState(() {
                  _selectedUpiId = value!;
                  _upiIdController.text = value;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('UPI ID changed to $value'),
                    backgroundColor: INFO,
                  ),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Mark payment as successful and call API
  Future<void> _markPaymentAsSuccessful() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Generate unique transaction IDs
      _transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      _paymentId = 'PAY${DateTime.now().millisecondsSinceEpoch}';

      print('🔧 DEBUG: Marking payment as successful');
      print('🔧 Amount: ${_amountController.text}');
      print('🔧 Selling Detail ID: $_sellingDetailId');
      print('🔧 Payment ID: $_paymentId');
      print('🔧 Transaction ID: $_transactionId');
      print('🔧 Payment Method: $_selectedUpiApp');

      // Call verify payment API
      final verificationResponse = await _apiService.verifyPaymentApi(
        _amountController.text,
        _sellingDetailId,
        _paymentId!,
        _transactionId!,
        _selectedUpiApp,
      );

      print('🔧 DEBUG: API Response: $verificationResponse');

      if (verificationResponse['status'] == 'success') {
        setState(() {
          _paymentStatus = 'completed';
          _paymentMessage = verificationResponse['message'] ?? 'Payment completed successfully';
          _paymentTime = DateTime.now();
          _paymentInProgress = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_paymentMessage),
            backgroundColor: SUCCESS,
            duration: const Duration(seconds: 3),
          ),
        );

        _showPaymentSuccessDialog();

      } else {
        setState(() {
          _paymentStatus = 'failed';
          _paymentMessage = verificationResponse['message'] ?? 'Payment verification failed';
          _paymentInProgress = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_paymentMessage),
            backgroundColor: ERROR,
          ),
        );
      }
    } catch (e) {
      print('🔧 DEBUG: Error in markPaymentAsSuccessful: $e');
      setState(() {
        _error = 'Payment verification failed: ${e.toString()}';
        _paymentStatus = 'failed';
        _paymentInProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: ERROR,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Mark payment as failed
  void _markPaymentAsFailed() {
    setState(() {
      _paymentStatus = 'failed';
      _paymentMessage = 'Payment failed or was cancelled by user';
      _paymentInProgress = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment marked as failed'),
        backgroundColor: ERROR,
      ),
    );
  }

  /// Show QR Code dialog
  void _showQrCodeDialog() {
    final upiString = 'upi://pay?pa=${_upiIdController.text}&pn=${Uri.encodeComponent(_customerName)}'
        '&am=${_amountController.text}&tn=${Uri.encodeComponent(_noteController.text)}&cu=INR';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR Code Placeholder - In production, use qr_flutter package
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: PRIMARY, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code, size: 80, color: PRIMARY),
                    const SizedBox(height: 8),
                    Text(
                      _upiIdController.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: PRIMARY_DARK,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Scan to Pay',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PRIMARY_LIGHT,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Amount: ₹${_amountController.text}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UPI ID: ${_upiIdController.text}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Open any UPI app and scan this code',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: upiString));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('UPI payment string copied to clipboard'),
                  backgroundColor: SUCCESS,
                ),
              );
            },
            child: const Text('Copy UPI String'),
          ),
        ],
      ),
    );
  }

  /// Show manual payment entry dialog
  void _showManualPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Manual Payment Entry'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter payment details collected by agent:'),
                  const SizedBox(height: 16),

                  // Payment Method
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'upi', child: Text('UPI')),
                      DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                      DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value ?? 'cash';
                        _paymentMethodController.text = _selectedPaymentMethod;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Amount (read-only, display only)
                  TextFormField(
                    controller: _amountController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Reference Number
                  TextFormField(
                    controller: _referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Reference Number',
                      hintText: 'e.g., UPI Reference, Cash Receipt No.',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Additional Notes
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Note: This will mark the order as completed and record the payment.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_referenceController.text.isEmpty && _selectedPaymentMethod != 'cash') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a reference number'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  _processManualPayment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY,
                ),
                child: const Text('Mark as Paid'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Process manual payment entry
  Future<void> _processManualPayment() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Generate transaction IDs
      _transactionId = _referenceController.text.isNotEmpty
          ? _referenceController.text
          : 'CASH${DateTime.now().millisecondsSinceEpoch}';
      _paymentId = 'MAN${DateTime.now().millisecondsSinceEpoch}';

      print('🔧 DEBUG: Processing manual payment');
      print('🔧 Payment Method: $_selectedPaymentMethod');
      print('🔧 Reference: $_transactionId');

      // Call verify payment API with manual payment method
      final verificationResponse = await _apiService.verifyPaymentApi(
        _amountController.text,
        _sellingDetailId,
        _paymentId!,
        _transactionId!,
        _selectedPaymentMethod == 'cash' ? 'Cash' : _selectedPaymentMethod,
      );

      print('🔧 DEBUG: Manual Payment API Response: $verificationResponse');

      if (verificationResponse['status'] == 'success') {
        setState(() {
          _paymentStatus = 'completed';
          _paymentMessage = 'Payment recorded manually by agent';
          _paymentTime = DateTime.now();
          _manualPaymentMode = true;
          _paymentInProgress = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment recorded successfully'),
            backgroundColor: SUCCESS,
            duration: Duration(seconds: 3),
          ),
        );

        _showPaymentSuccessDialog();

      } else {
        setState(() {
          _paymentStatus = 'failed';
          _paymentMessage = verificationResponse['message'] ?? 'Failed to record payment';
          _paymentInProgress = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_paymentMessage),
            backgroundColor: ERROR,
          ),
        );
      }
    } catch (e) {
      print('🔧 DEBUG: Error in processManualPayment: $e');
      setState(() {
        _error = 'Failed to record payment: ${e.toString()}';
        _paymentStatus = 'failed';
        _paymentInProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment recording failed: ${e.toString()}'),
          backgroundColor: ERROR,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Share UPI details via WhatsApp
  Future<void> _shareUpiDetailsViaWhatsApp() async {
    final message = '''
*Payment Request* 📱

*Order:* $_orderReference
*Customer:* $_customerName
*Amount:* ₹${_amountController.text}

*UPI Payment Details:*
UPI ID: ${_upiIdController.text}
Amount: ₹${_amountController.text}
Note: ${_noteController.text}

Please make the payment using any UPI app.

Thank you! 🙏
''';

    final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(message)}';

    try {
      bool canLaunch = await canLaunchUrl(Uri.parse(whatsappUrl));
      if (canLaunch) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        // Copy to clipboard if WhatsApp not available
        Clipboard.setData(ClipboardData(text: message));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment details copied to clipboard. Share via any app.'),
            backgroundColor: SUCCESS,
          ),
        );
      }
    } catch (e) {
      print('🔧 DEBUG: WhatsApp sharing failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to open WhatsApp'),
          backgroundColor: ERROR,
        ),
      );
    }
  }

  /// Show payment success dialog
  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: SUCCESS),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order: $_orderReference'),
              Text('Amount: ₹${_amountController.text}'),
              if (_transactionId != null) Text('Reference: $_transactionId'),
              if (_manualPaymentMode) Text('Payment Method: ${_paymentMethodController.text}'),
              if (_paymentTime != null) Text('Time: ${_paymentTime!.toLocal().toString().substring(0, 16)}'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SUCCESS.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✅ Order marked as completed\n✅ Payment recorded successfully',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to orders screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  /// Copy UPI ID to clipboard
  void _copyUpiIdToClipboard() {
    Clipboard.setData(ClipboardData(text: _upiIdController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('UPI ID copied to clipboard'),
        backgroundColor: SUCCESS,
      ),
    );
  }

  /// Share payment details with customer
  void _sharePaymentDetails() {
    final message = '''
Payment Request for Order $_orderReference

Amount: ₹${_amountController.text}
UPI ID: ${_upiIdController.text}
Note: ${_noteController.text}

Please make the payment using any UPI app.
''';

    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment details copied to clipboard. Share with customer.'),
        backgroundColor: SUCCESS,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Collection'),
        backgroundColor: PRIMARY,
        centerTitle: true,
        actions: [
          if (_paymentStatus == 'pending')
            IconButton(
              onPressed: _sharePaymentDetails,
              icon: const Icon(Icons.share),
              tooltip: 'Share Payment Details',
            ),
          if (_paymentStatus == 'pending')
            IconButton(
              onPressed: () {
                setState(() {
                  _showQrCode = !_showQrCode;
                });
              },
              icon: Icon(_showQrCode ? Icons.payment : Icons.qr_code),
              tooltip: _showQrCode ? 'Show Payment Options' : 'Show QR Code',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PRIMARY))
          : _showQrCode
          ? _buildQrCodeView()
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
          const SizedBox(height: 16),

          // Calculation Summary Card
          _buildCalculationSummaryCard(),
          const SizedBox(height: 16),

          // Payment Status Banner
          if (_paymentStatus != 'pending') _buildPaymentStatusBanner(),
          if (_paymentStatus != 'pending') const SizedBox(height: 16),

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

  Widget _buildQrCodeView() {
    final upiString = 'upi://pay?pa=${_upiIdController.text}&pn=${Uri.encodeComponent(_customerName)}'
        '&am=${_amountController.text}&tn=${Uri.encodeComponent(_noteController.text)}&cu=INR';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan QR Code to Pay',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: PRIMARY_DARK,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Open any UPI app and scan this QR code',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // QR Code Container
            Container(
              width: 250,
              height: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: PRIMARY, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code, size: 120, color: PRIMARY),
                  const SizedBox(height: 16),
                  Text(
                    _upiIdController.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: PRIMARY_DARK,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'QUIVONEX SOLUTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Amount Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Amount to Pay',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${_amountController.text}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // UPI ID Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PRIMARY_LIGHT,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: PRIMARY),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UPI ID',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _upiIdController.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: PRIMARY_DARK,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _copyUpiIdToClipboard,
                    icon: const Icon(Icons.content_copy, color: PRIMARY),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: upiString));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('UPI payment string copied to clipboard'),
                      backgroundColor: SUCCESS,
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy UPI Payment String'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: INFO,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showQrCode = false;
                  });
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Payment Options'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: PRIMARY),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
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
            _buildSummaryRow('Customer', _customerName),
            if (_customerContact.isNotEmpty)
              _buildSummaryRow('Contact', _customerContact),
            if (widget.orderData['address'] != null)
              _buildSummaryRow('Address', widget.orderData['address'].toString()),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Products (${widget.subProductDetails.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.subProductDetails.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final item = entry.value;
              final weight = double.tryParse(item['weight'].toString()) ?? 0;
              final rate = double.tryParse(item['my_rate'].toString()) ?? 0;
              final value = weight * rate;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: PRIMARY.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: TextStyle(
                            color: PRIMARY,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['sub_product_name']?.toString() ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Rate: ₹$rate per kg',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${weight.toStringAsFixed(2)} kg',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₹${value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationSummaryCard() {
    final totals = widget.calculationResponse.grandTotals;

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
              'Amount Calculation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PRIMARY_DARK,
              ),
            ),
            const SizedBox(height: 12),
            if (totals != null) ...[
              _buildCalculationRow(
                'Our Rate Total',
                '₹${totals.totalMyPrice?.toStringAsFixed(2) ?? '0.00'}',
                Colors.green,
              ),
              _buildCalculationRow(
                'Other Rate Total',
                '₹${totals.totalOtherPrice?.toStringAsFixed(2) ?? '0.00'}',
                Colors.grey,
              ),
              const Divider(height: 16),
              _buildCalculationRow(
                'Total Earnings',
                '₹${totals.totalExtraMoney?.toStringAsFixed(2) ?? '0.00'}',
                Colors.orange,
                isMain: true,
              ),
            ],
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount Due:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PRIMARY_DARK,
                  ),
                ),
                Text(
                  '₹${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, Color color, {bool isMain = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: isMain ? 15 : 14,
              fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isMain ? 16 : 14,
              fontWeight: isMain ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBanner() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_paymentStatus) {
      case 'completed':
        statusColor = SUCCESS;
        statusIcon = Icons.check_circle;
        statusText = 'Payment Completed';
        break;
      case 'processing':
        statusColor = INFO;
        statusIcon = Icons.pending;
        statusText = 'Payment Processing';
        break;
      case 'failed':
        statusColor = ERROR;
        statusIcon = Icons.error;
        statusText = 'Payment Failed';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
        statusText = 'Payment Pending';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
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
                      'Reference: $_transactionId',
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
              'UPI ID for Payment:',
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
                      _upiIdController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: PRIMARY_DARK,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _copyUpiIdToClipboard,
                    icon: const Icon(Icons.content_copy, size: 20, color: PRIMARY),
                  ),
                ],
              ),
            ),

            // Change UPI ID button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _showUpiIdSelectionDialog,
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text('Change UPI ID'),
                style: TextButton.styleFrom(
                  foregroundColor: INFO,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Amount Display
            const Text(
              'Amount to Collect:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  '₹${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // UPI App Selection
            if (_paymentStatus == 'pending')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select UPI App:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedUpiApp,
                    items: const [
                      DropdownMenuItem(value: 'PhonePe', child: Text('PhonePe')),
                      DropdownMenuItem(value: 'Google Pay', child: Text('Google Pay')),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ],
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
        if (_paymentStatus == 'pending')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _paymentInProgress ? null : _launchUpiPayment,
              icon: const Icon(Icons.payment, size: 24),
              label: Text(
                'Pay via $_selectedUpiApp',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),

        if (_paymentStatus == 'pending')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showQrCode = true;
                });
              },
              icon: const Icon(Icons.qr_code, size: 24),
              label: const Text(
                'Show QR Code',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ACCENT,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),

        if (_paymentStatus == 'pending')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showManualPaymentDialog,
              icon: const Icon(Icons.edit_note, size: 24),
              label: const Text(
                'Manual Payment Entry',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: INFO,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareUpiDetailsViaWhatsApp,
            icon: const Icon(Icons.chat, size: 24, color: Colors.white),
            label: const Text(
              'Share via WhatsApp',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp green
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}