import 'package:collector/model/product_model.dart';
import 'package:flutter/material.dart';

const primaryGold = Color(0xFFb59d31);
const darkBrown = Color(0xFF4a3b1a);
const lightGold = Color(0xFFF6F0D3);
const lightGrey = Color(0xFFF8F9FA);
const mediumGrey = Color(0xFFE9ECEF);
const successGreen = Color(0xFF10B981);

class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final Map<String, dynamic> calculationData;

  const OrderConfirmationScreen({
    Key? key,
    required this.orderData,
    required this.calculationData, required CalculationResponse calculationResponse, required String productName, required List<CalculationRequest> calculationRequests,
  }) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _isConfirming = false;
  bool _isConfirmed = false;
  bool _isSignatureComplete = false;
  bool _isProcessingPayment = false;
  bool _isPaymentComplete = false;
  List<SignaturePoint> _signaturePoints = [];
  String _selectedPaymentMethod = 'cash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: Text(
          _isConfirmed ? 'Order Confirmed' : 'Confirm Order',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: darkBrown,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _isConfirmed
          ? _buildSuccessScreen()
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              _buildOrderSummaryCard(),
              const SizedBox(height: 20),

              // Customer Details Card
              _buildCustomerCard(),
              const SizedBox(height: 20),

              // Items Summary Card
              _buildItemsSummaryCard(),
              const SizedBox(height: 20),

              // Payment Summary Card
              _buildPaymentSummaryCard(),
              const SizedBox(height: 20),

              // Payment Method Selection
              _buildPaymentMethodSection(),
              const SizedBox(height: 20),

              // Signature Section
              _buildSignatureSection(),
              const SizedBox(height: 30),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2,
                color: primaryGold,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'ORDER SUMMARY',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${widget.orderData['id'] ?? 'ORD001'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryGold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: mediumGrey,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Pickup Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.orderData['date'] ?? 'Today',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: darkBrown,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: mediumGrey,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: primaryGold.withOpacity(0.3)),
                    ),
                    child: Text(
                      'TO CONFIRM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryGold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: primaryGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'CUSTOMER DETAILS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(widget.orderData['customerName'] ?? 'Customer'),
                    style: TextStyle(
                      color: primaryGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.orderData['customerName'] ?? 'Customer Name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: primaryGold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.orderData['phone'] ?? '+91 9876543210',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.orderData['address'] ?? 'No address provided',
                        style: TextStyle(
                          fontSize: 13,
                          color: darkBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSummaryCard() {
    final items = widget.calculationData['items'] ?? [
      {'name': 'Plastic', 'weight': '5.2 kg', 'price': '₹ 156'},
      {'name': 'Paper', 'weight': '3.8 kg', 'price': '₹ 76'},
      {'name': 'Glass', 'weight': '2.5 kg', 'price': '₹ 125'},
    ];

    final totalWeight = widget.calculationData['totalWeight'] ?? '11.5 kg';
    final totalItems = widget.calculationData['totalItems'] ?? '3 items';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag,
                color: primaryGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'ITEMS COLLECTED',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...items.map<Widget>((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: mediumGrey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['weight'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: mediumGrey,
                  ),
                  SizedBox(
                    width: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          item['price'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryGold.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryGold.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.scale,
                      size: 18,
                      color: primaryGold,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Weight',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          totalWeight,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: primaryGold.withOpacity(0.3),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Items Count',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      totalItems,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkBrown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    final totalAmount = widget.calculationData['totalAmount'] ?? '₹ 357.00';
    final ourPrice = widget.calculationData['ourPrice'] ?? '₹ 500.00';
    final otherPrice = widget.calculationData['otherPrice'] ?? '₹ 143.00';
    final earnings = widget.calculationData['earnings'] ?? '₹ 357.00';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payments,
                color: primaryGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'PAYMENT SUMMARY',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildPaymentRow('Our Price', ourPrice, Colors.grey[600]!),
          const SizedBox(height: 8),
          _buildPaymentRow('Other Price', otherPrice, Colors.red),
          const SizedBox(height: 8),
          _buildPaymentRow('Customer Earnings', earnings, successGreen),
          const SizedBox(height: 15),
          Divider(color: mediumGrey, height: 1),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryGold.withOpacity(0.1), primaryGold.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryGold.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'To be paid to customer',
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  totalAmount,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment,
                color: primaryGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'PAYMENT METHOD',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Select payment method to pay the customer',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildPaymentMethodCard(
                  icon: Icons.money,
                  title: 'Cash',
                  isSelected: _selectedPaymentMethod == 'cash',
                  onTap: () => setState(() => _selectedPaymentMethod = 'cash'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentMethodCard(
                  icon: Icons.account_balance_wallet,
                  title: 'UPI',
                  isSelected: _selectedPaymentMethod == 'upi',
                  onTap: () => setState(() => _selectedPaymentMethod = 'upi'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentMethodCard(
                  icon: Icons.credit_card,
                  title: 'Card',
                  isSelected: _selectedPaymentMethod == 'card',
                  onTap: () => setState(() => _selectedPaymentMethod = 'card'),
                ),
              ),
            ],
          ),
          if (_selectedPaymentMethod == 'upi')
            Container(
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UPI Details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter UPI ID (e.g., 9876543210@upi)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.payment, color: primaryGold),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? primaryGold.withOpacity(0.1) : lightGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryGold : mediumGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryGold : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? primaryGold : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.draw,
                color: primaryGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'CUSTOMER SIGNATURE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Ask the customer to sign below to confirm the pickup',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isSignatureComplete ? successGreen : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.localPosition);
                  _signaturePoints.add(SignaturePoint(
                    offset: localPosition,
                    timestamp: DateTime.now(),
                  ));
                  if (_signaturePoints.length > 10) {
                    _isSignatureComplete = true;
                  }
                });
              },
              onPanStart: (details) {
                setState(() {
                  final renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.localPosition);
                  _signaturePoints.add(SignaturePoint(
                    offset: localPosition,
                    timestamp: DateTime.now(),
                  ));
                });
              },
              onPanEnd: (details) {
                if (_signaturePoints.isNotEmpty) {
                  _isSignatureComplete = true;
                }
              },
              child: CustomPaint(
                painter: SignaturePainter(points: _signaturePoints),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _signaturePoints.clear();
                    _isSignatureComplete = false;
                  });
                },
                icon: Icon(Icons.refresh, size: 18),
                label: Text(
                  'Clear Signature',
                  style: TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
              ),
              if (_isSignatureComplete)
                Row(
                  children: [
                    Icon(Icons.check_circle, color: successGreen, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Signature Complete',
                      style: TextStyle(
                        color: successGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    // Extract numeric amount from string like "₹ 357.00"
    final amountString = widget.calculationData['totalAmount'] ?? '₹ 0.00';
    final amount = double.tryParse(amountString.replaceAll('₹', '').trim()) ?? 0.0;

    return Column(
      children: [
        // Pay Now Button (only shows when signature is complete)
        if (_isSignatureComplete && !_isPaymentComplete)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessingPayment ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  shadowColor: successGreen.withOpacity(0.3),
                ),
                child: _isProcessingPayment
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payments, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'PAY NOW ₹${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Confirm Order Button (only shows after payment)
        if (_isPaymentComplete && !_isConfirming)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isConfirming ? null : _confirmOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                shadowColor: primaryGold.withOpacity(0.3),
              ),
              child: _isConfirming
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'CONFIRM ORDER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Or text between buttons
        if (_isSignatureComplete && !_isPaymentComplete)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: mediumGrey),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(color: mediumGrey),
                ),
              ],
            ),
          ),

        // Skip Payment Button
        if (_isSignatureComplete && !_isPaymentComplete)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _isPaymentComplete = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment skipped. Will pay later.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              child: const Text(
                'SKIP PAYMENT FOR NOW',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessingPayment = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessingPayment = false;
      _isPaymentComplete = true;
    });

    // Extract numeric amount from string
    final amountString = widget.calculationData['totalAmount'] ?? '₹ 0.00';
    final amount = amountString.replaceAll('₹', '').trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment of ₹$amount completed via ${_selectedPaymentMethod.toUpperCase()}'),
        backgroundColor: successGreen,
      ),
    );
  }

  Future<void> _confirmOrder() async {
    setState(() => _isConfirming = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isConfirming = false;
      _isConfirmed = true;
    });
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: successGreen,
                size: 60,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Order Confirmed Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkBrown,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'Order #${widget.orderData['id'] ?? 'ORD001'} has been confirmed and marked as completed.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount Paid',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.calculationData['totalAmount'] ?? '₹ 0.00',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: mediumGrey, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _selectedPaymentMethod.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Customer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.orderData['customerName'] ?? 'Customer Name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        TimeOfDay.now().format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate back to orders screen
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('BACK TO ORDERS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: _shareReceipt,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share, color: primaryGold),
                  const SizedBox(width: 8),
                  Text(
                    'SHARE RECEIPT',
                    style: TextStyle(color: primaryGold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareReceipt() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt shared successfully'),
        backgroundColor: successGreen,
      ),
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'C';
  }
}

// Signature classes
class SignaturePoint {
  final Offset offset;
  final DateTime timestamp;

  SignaturePoint({required this.offset, required this.timestamp});
}

class SignaturePainter extends CustomPainter {
  final List<SignaturePoint> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      canvas.drawLine(p1.offset, p2.offset, paint);
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}