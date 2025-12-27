// screens/calculation_screen.dart
import 'package:collector/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collector/services/api_services.dart';
import 'package:collector/model/product_model.dart';

const PRIMARY = Color(0xFF9C8E18);
const PRIMARY_LIGHT = Color(0xFFF7EEA8);
const PRIMARY_DARK = Color(0xFF5E3B1F);
const ACCENT = Color(0xFFF4D03F);
const ERROR = Color(0xFFB93D3D);

class CalculationScreen extends StatefulWidget {
  final List<CalculationRequest> calculationRequests;
  final String productName;
  final Map<String, dynamic> orderData;
  final CalculationResponse? calculationResponse;
  final bool isEditMode;

  const CalculationScreen({
    Key? key,
    required this.calculationRequests,
    required this.productName,
    required this.orderData,
    this.calculationResponse,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  State<CalculationScreen> createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  final ApiService _apiService = ApiService();

  CalculationResponse? _response;
  bool _loading = true;
  bool _updatingOrder = false;
  String _error = '';

  final Map<int, TextEditingController> _actualWeightControllers = {};
  final Map<int, double> _estimatedWeights = {};

  // Add this for SharedPreferences
  late SharedPreferences _prefs;
  List<Map<String, dynamic>> _savedSelections = [];
  bool _hasSavedData = false;

  @override
  void initState() {
    super.initState();

    print('DEBUG: CalculationScreen initialized');
    print('DEBUG: Number of calculationRequests: ${widget.calculationRequests.length}');
    print('DEBUG: CalculationResponse provided: ${widget.calculationResponse != null}');

    // Initialize SharedPreferences
    _initSharedPreferences().then((_) {
      if (widget.calculationRequests.isEmpty) {
        print('DEBUG: WARNING - calculationRequests is empty!');
        _error = 'No items selected for calculation';
        _loading = false;
        return;
      }

      // Initialize controllers and estimated weights
      for (final req in widget.calculationRequests) {
        print('DEBUG: Initializing item: ${req.subProductName} (ID: ${req.subProductId}) - Weight: ${req.estimatedWeight}');
        _estimatedWeights[req.subProductId] = req.estimatedWeight ?? 0;
        _actualWeightControllers[req.subProductId] = TextEditingController(
          text: req.estimatedWeight?.toStringAsFixed(2) ?? '0.00',
        );
      }

      // Check for saved calculation data
      _loadSavedCalculationData();

      // If calculation response is provided, use it directly
      if (widget.calculationResponse != null) {
        print('DEBUG: Using provided calculationResponse');
        _response = widget.calculationResponse;
        _loading = false;
      } else {
        // Otherwise fetch calculation from API
        print('DEBUG: No calculationResponse provided, calling _calculate()');
        _calculate();
      }
    });
  }

  /// Initialize SharedPreferences
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Load saved calculation data from SharedPreferences
  Future<void> _loadSavedCalculationData() async {
    final savedData = _prefs.getString('calculation_data');

    if (savedData != null && savedData.isNotEmpty) {
      try {
        // Parse the saved data
        final Map<String, dynamic> data = savedData as Map<String, dynamic>;
        final List<dynamic> requests = data['requests'] as List<dynamic>;

        setState(() {
          _savedSelections = List<Map<String, dynamic>>.from(requests);
          _hasSavedData = _savedSelections.isNotEmpty;
        });

        print('DEBUG: Loaded ${_savedSelections.length} saved selections');
      } catch (e) {
        print('DEBUG: Error loading saved data: $e');
      }
    }
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (final c in _actualWeightControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _calculate() async {
    print('DEBUG: _calculate() called');
    if (widget.calculationRequests.isEmpty) {
      setState(() {
        _error = 'No items to calculate';
        _loading = false;
      });
      return;
    }

    try {
      setState(() => _loading = true);
      print('DEBUG: Calling API with ${widget.calculationRequests.length} items');
      final res = await _apiService.calculatePrice(widget.calculationRequests);

      // Save calculation data
      await _saveCalculationData(res);

      setState(() {
        _response = res;
        _loading = false;
      });
    } catch (e) {
      print('DEBUG: Error in calculation: $e');
      setState(() {
        _error = 'Calculation failed: ${e.toString()}';
        _loading = false;
      });
    }
  }

  /// Save calculation data to SharedPreferences
  Future<void> _saveCalculationData(CalculationResponse response) async {
    final calculationData = {
      'response': {
        'items': response.items,
        'grandTotals': response.grandTotals?.toJson(),
      },
      'requests': widget.calculationRequests.map((item) => item.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _prefs.setString('calculation_data', calculationData.toString());
    print('DEBUG: Calculation data saved to SharedPreferences');
  }

  Future<void> _updateCalculationWithActualWeights() async {
    try {
      setState(() => _loading = true);

      // Create new requests with actual weights
      final List<CalculationRequest> updatedRequests = [];

      for (final req in widget.calculationRequests) {
        final controller = _actualWeightControllers[req.subProductId];
        final actualWeight = double.tryParse(controller?.text ?? '0') ?? 0;

        updatedRequests.add(
          CalculationRequest(
            subProductId: req.subProductId,
            subProductName: req.subProductName,
            estimatedWeight: actualWeight,
            productRate: req.productRate,
            otherRate: req.otherRate,
          ),
        );
      }

      // Recalculate with actual weights
      final res = await _apiService.calculatePrice(updatedRequests);

      // Save updated calculation data
      await _saveCalculationData(res);

      setState(() {
        _response = res;
        _loading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calculation updated with actual weights'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // UPDATE ORDER STATUS API INTEGRATION
  Future<void> _updateOrderStatus() async {
    try {
      setState(() => _updatingOrder = true);

      // Get selling detail ID from order data
      final sellingDetailId = widget.orderData['id'];

      if (sellingDetailId == null) {
        throw Exception('Order ID not found');
      }

      print('DEBUG: Updating order status for selling_detail_id: $sellingDetailId');

      // Call API to update order status
      final response = await _apiService.updateOrderStatus(sellingDetailId);

      print('DEBUG: Order update response: $response');

      // Extract message from response
      final message = response['message'] ?? 'Order updated successfully';

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to PaymentScreen after successful update
      _navigateToPaymentScreen();

    } catch (e) {
      print('DEBUG: Error updating order status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _updatingOrder = false);
    }
  }

  void _navigateToPaymentScreen() {
    // Prepare sub product details for payment screen
    final subProductDetails = _prepareSubProductDetails();
    final totalAmount = _getTotalAmount();

    // Get order ID and customer phone
    final orderId = widget.orderData['id'] is int
        ? widget.orderData['id'] as int
        : int.tryParse(widget.orderData['id']?.toString() ?? '') ?? 0;

    final customerPhone = widget.orderData['customer_phone']?.toString() ??
        widget.orderData['phone']?.toString() ?? '';

    print('DEBUG: Navigating to PaymentScreen');
    print('DEBUG: orderId: $orderId');
    print('DEBUG: totalAmount: $totalAmount');
    print('DEBUG: customerPhone: $customerPhone');
    print('DEBUG: subProductDetails count: ${subProductDetails.length}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          orderId: orderId,
          amount: totalAmount,
          customerPhone: customerPhone,
          orderData: widget.orderData,
          calculationResponse: _response!,
          subProductDetails: subProductDetails,
        ),
      ),
    );
  }

  // Prepare sub product details for payment screen
  List<Map<String, dynamic>> _prepareSubProductDetails() {
    final List<Map<String, dynamic>> details = [];

    if (_response?.items != null) {
      for (final item in _response!.items!) {
        final subProductId = item['sub_product_id'] as int?;
        final controller = subProductId != null
            ? _actualWeightControllers[subProductId]
            : null;

        final actualWeight = double.tryParse(controller?.text ?? '0') ?? 0;

        details.add({
          'sub_product_id': subProductId,
          'sub_product_name': item['sub_product_name'],
          'weight': actualWeight,
          'estimated_weight': item['estimated_weight'],
          'my_rate': item['my_rate'],
          'other_rate': item['other_rate'],
          'extra_money': item['extra_money'],
        });
      }
    }

    return details;
  }

  // Calculate total amount
  double _getTotalAmount() {
    if (_response?.grandTotals == null) return 0;
    return _response!.grandTotals!.totalMyPrice ?? 0;
  }

  // Widget to show saved selections summary
  Widget _buildSavedSelectionsSummary() {
    if (!_hasSavedData || _savedSelections.isEmpty) {
      return const SizedBox();
    }

    double totalWeight = 0;
    double totalValue = 0;

    for (var selection in _savedSelections) {
      final weight = double.tryParse(selection['weight'].toString()) ?? 0;
      final myRate = double.tryParse(selection['my_rate'].toString()) ?? 0;
      totalWeight += weight;
      totalValue += weight * myRate;
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PRIMARY_LIGHT,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMARY.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: PRIMARY_DARK),
              const SizedBox(width: 8),
              const Text(
                'Saved Selection Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: PRIMARY_DARK,
                ),
              ),
              const Spacer(),
              Text(
                '${_savedSelections.length} items',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSavedStatItem('Total Weight', '${totalWeight.toStringAsFixed(2)} kg'),
              _buildSavedStatItem('Estimated Value', '₹${totalValue.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Show saved selections in a dialog
                _showSavedSelectionsDialog();
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Saved Items'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY.withOpacity(0.1),
                foregroundColor: PRIMARY_DARK,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: PRIMARY_DARK,
          ),
        ),
      ],
    );
  }

  void _showSavedSelectionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Product Selections'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _savedSelections.length,
            itemBuilder: (context, index) {
              final item = _savedSelections[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: PRIMARY.withOpacity(0.1),
                  child: Text('${index + 1}'),
                ),
                title: Text(item['sub_product_name']?.toString() ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight: ${item['weight']} ${item['unit']}'),
                    Text('Rate: ₹${item['my_rate']} (Other: ₹${item['other_rate']})'),
                  ],
                ),
                trailing: Text(
                  '₹${((double.tryParse(item['weight'].toString()) ?? 0) * (double.tryParse(item['my_rate'].toString()) ?? 0)).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Clear saved data
              _prefs.remove('calculation_data');
              setState(() {
                _hasSavedData = false;
                _savedSelections.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved data cleared'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear Saved'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY,
        title: Text(widget.isEditMode ? "Update Order" : "Calculation Details"),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: PRIMARY))
          : _error.isNotEmpty
          ? _errorView()
          : _response == null
          ? _noDataView()
          : _mainView(),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: ERROR),
          const SizedBox(height: 10),
          Text(
            _error,
            style: const TextStyle(color: ERROR),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculate,
            style: ElevatedButton.styleFrom(backgroundColor: PRIMARY),
            child: const Text("Retry Calculation"),
          ),
        ],
      ),
    );
  }

  Widget _noDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No calculation data available',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Items passed: ${widget.calculationRequests.length}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _calculate,
            style: ElevatedButton.styleFrom(backgroundColor: PRIMARY),
            child: const Text("Calculate Now"),
          ),
        ],
      ),
    );
  }

  Widget _mainView() {
    final items = _response?.items ?? [];
    final requestsCount = widget.calculationRequests.length;

    print('DEBUG: Building mainView');
    print('DEBUG: items.length = ${items.length}');
    print('DEBUG: calculationRequests.length = ${requestsCount}');

    return Column(
      children: [
        _orderHeader(),
        _buildSavedSelectionsSummary(), // Added saved selections summary
        _itemsHeader(items.length, requestsCount),
        Expanded(child: items.isEmpty ? _emptyItems() : _itemsList(items)),
        _summaryCard(),
        _actionButtons(),
      ],
    );
  }

  Widget _orderHeader() {
    final orderId = widget.orderData['order_id'] ?? widget.orderData['id'] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(12),
      color: PRIMARY_DARK,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ORDER #$orderId",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.orderData['address'] ?? 'N/A',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (widget.isEditMode) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit, size: 12, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Edit Mode - Order ID: ${widget.orderData['id']}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _itemsHeader(int itemsCount, int requestsCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [PRIMARY_LIGHT.withOpacity(0.9), ACCENT.withOpacity(0.8)],
        ),
        border: Border(bottom: BorderSide(color: PRIMARY.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 20, color: PRIMARY_DARK),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditMode ? "Update Actual Weights" : "Selected Products",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: PRIMARY_DARK,
                  ),
                ),
                if (requestsCount > 0 && itemsCount == 0)
                  Text(
                    'Calculating...',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: PRIMARY,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$requestsCount ${requestsCount == 1 ? 'item' : 'items'}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyItems() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber, size: 48, color: Colors.orange),
          const SizedBox(height: 12),
          const Text(
            "No items in calculation",
            style: TextStyle(
              color: Colors.orange,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Expected: ${widget.calculationRequests.length} items",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _calculate,
            style: ElevatedButton.styleFrom(backgroundColor: PRIMARY),
            child: const Text("Recalculate"),
          ),
        ],
      ),
    );
  }

  Widget _itemsList(List items) {
    print('DEBUG: Building itemsList with ${items.length} items');

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        final subProductId = item['sub_product_id'] as int?;
        final controller = subProductId != null
            ? _actualWeightControllers[subProductId]
            : null;

        // Find the corresponding request to get the rates
        CalculationRequest? request;
        for (var req in widget.calculationRequests) {
          if (req.subProductId == subProductId) {
            request = req;
            break;
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Row(
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
                          '${index + 1}',
                          style: TextStyle(
                            color: PRIMARY,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['sub_product_name']?.toString() ?? 'Unknown Product',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (request != null)
                            Row(
                              children: [
                                Text(
                                  'My Rate: ₹${request.productRate?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Other Rate: ₹${request.otherRate?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Weight Information
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoColumn(
                        "Est. Weight",
                        "${item['estimated_weight']?.toStringAsFixed(2) ?? '0.00'} kg",
                        Colors.blue,
                      ),
                      _infoColumn(
                        "My Rate",
                        "₹${item['my_rate']?.toStringAsFixed(2) ?? '0.00'}",
                        Colors.green,
                      ),
                      _infoColumn(
                        "Other Rate",
                        "₹${item['other_rate']?.toStringAsFixed(2) ?? '0.00'}",
                        Colors.grey,
                      ),
                      _infoColumn(
                        "Earnings",
                        "₹${item['extra_money']?.toStringAsFixed(2) ?? '0.00'}",
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Actual Weight Input
                const Divider(height: 1, color: Colors.grey),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.edit_note, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Actual Weight",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: controller,
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "0.00",
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            BorderSide(color: PRIMARY.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: PRIMARY, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "kg",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard() {
    final totals = _response?.grandTotals;
    if (totals == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [PRIMARY.withOpacity(0.9), PRIMARY_DARK],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Summary",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow("Our Total Price",
              "₹${(totals.totalMyPrice ?? 0).toStringAsFixed(2)}"),
          const SizedBox(height: 6),
          _summaryRow("Other Total Price",
              "₹${(totals.totalOtherPrice ?? 0).toStringAsFixed(2)}"),
          const SizedBox(height: 10),
          const Divider(color: Colors.white54, height: 1),
          const SizedBox(height: 12),
          _summaryRow(
            "Total Earnings",
            "₹${(totals.totalExtraMoney ?? 0).toStringAsFixed(2)}",
            isMain: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isMain = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isMain ? Colors.white : Colors.white70,
            fontSize: isMain ? 15 : 13,
            fontWeight: isMain ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isMain ? Colors.white : Colors.white,
            fontSize: isMain ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          // Recalculate Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ACCENT,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _updateCalculationWithActualWeights,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calculate, size: 20),
                SizedBox(width: 8),
                Text(
                  "Recalculate with Actual Weights",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Main Action Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isEditMode ? Colors.orange : PRIMARY,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _updatingOrder ? null : () {
              if (widget.isEditMode) {
                // Call API to update order status
                _updateOrderStatus();
              } else {
                // Navigate to PaymentScreen
                _navigateToPaymentScreen();
              }
            },
            child: _updatingOrder
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
                SizedBox(width: 8),
                Text(
                  "Updating Order...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            )
                : Text(
              widget.isEditMode
                  ? "Update Order & Proceed to Payment"
                  : "Proceed to Payment",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}