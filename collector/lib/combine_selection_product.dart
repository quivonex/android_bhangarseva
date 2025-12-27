// screens/combined_product_selection_screen.dart
import 'package:collector/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calculation_screen.dart';
import 'model/product_model.dart';

class CombinedProductSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const CombinedProductSelectionScreen({
    Key? key,
    required this.orderData,
  }) : super(key: key);

  @override
  State<CombinedProductSelectionScreen> createState() =>
      _CombinedProductSelectionScreenState();
}

class _CombinedProductSelectionScreenState
    extends State<CombinedProductSelectionScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  final Map<int, Map<int, TextEditingController>> _productControllers = {};
  final Map<int, Map<int, bool>> _productSelections = {};

  bool _isLoading = true;
  bool _isCalculating = false;
  String _error = '';
  String _searchQuery = '';

  CalculationResponse? _calculationResponse;

  late final Map<String, dynamic> _orderData;
  bool _isEditMode = false;

  final Map<int, double> _alreadySelectedProducts = {};

  final Color brownPrimary = const Color(0xFF5A3E1A);
  final Color mustardYellow = const Color(0xFFC2A21B);
  final Color whiteColor = Colors.white;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isPanelVisible = false;

  // SharedPreferences instance
  late SharedPreferences _prefs;
  final String _selectionKey = 'selected_products_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _orderData = widget.orderData;
    _initSharedPreferences();
    _parseOrderData();
    _loadProducts();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    // Dispose all text controllers
    for (var productMap in _productControllers.values) {
      for (var controller in productMap.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  /// Initialize SharedPreferences
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save selected products to SharedPreferences
  Future<void> _saveSelectedProducts() async {
    final List<Map<String, dynamic>> selectedProducts = [];

    for (var product in _products) {
      for (var subProduct in product.subProducts) {
        final isSelected = _productSelections[product.id]?[subProduct.id] ?? false;
        if (isSelected) {
          final weight = double.tryParse(
              _productControllers[product.id]?[subProduct.id]?.text ?? '0') ??
              0;

          selectedProducts.add({
            'product_id': product.id,
            'product_name': product.name,
            'sub_product_id': subProduct.id,
            'sub_product_name': subProduct.name,
            'weight': weight,
            'my_rate': subProduct.rate,
            'other_rate': subProduct.otherRate,
            'unit': subProduct.unit,
          });
        }
      }
    }

    // Save to SharedPreferences
    final productJsonList = selectedProducts.map((p) {
      return {
        ...p,
        'weight': p['weight'].toString(),
        'my_rate': p['my_rate'].toString(),
        'other_rate': p['other_rate'].toString(),
      };
    }).toList();

    await _prefs.setString(_selectionKey, productJsonList.toString());
    print('Saved ${selectedProducts.length} products to SharedPreferences');
  }

  /// Load selected products from SharedPreferences
  Future<void> _loadSavedSelections() async {
    final savedData = _prefs.getString(_selectionKey);
    if (savedData != null && savedData.isNotEmpty) {
      try {
        // Parse the saved data
        final List<dynamic> productList = savedData as List<dynamic>;

        for (var productData in productList) {
          final productId = productData['product_id'] as int;
          final subProductId = productData['sub_product_id'] as int;
          final weight = double.tryParse(productData['weight'].toString()) ?? 0;

          // Restore selection and weight
          if (_productControllers.containsKey(productId) &&
              _productControllers[productId]!.containsKey(subProductId)) {
            setState(() {
              _productSelections[productId]![subProductId] = true;
              _productControllers[productId]![subProductId]!.text = weight.toString();
            });
          }
        }
      } catch (e) {
        print('Error loading saved selections: $e');
      }
    }
  }

  // 🔁 Invalidate API calculation when user edits anything
  void _invalidateCalculation() {
    if (_calculationResponse != null) {
      setState(() => _calculationResponse = null);
    }
    // Save changes to SharedPreferences
    _saveSelectedProducts();
  }

  void _parseOrderData() {
    _isEditMode = _orderData.containsKey('id');

    if (_orderData['sub_product_details'] != null) {
      for (var d in _orderData['sub_product_details']) {
        _alreadySelectedProducts[d['sub_product_id']] =
            (d['weight'] ?? 0).toDouble();
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _apiService.getProducts();

      for (var p in products) {
        _productControllers[p.id] = {};
        _productSelections[p.id] = {};

        for (var sp in p.subProducts) {
          final controller = TextEditingController();

          if (_alreadySelectedProducts.containsKey(sp.id)) {
            controller.text = _alreadySelectedProducts[sp.id].toString();
            _productSelections[p.id]![sp.id] = true;
          } else {
            _productSelections[p.id]![sp.id] = false;
          }

          _productControllers[p.id]![sp.id] = controller;
        }
      }

      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });

      // Load saved selections after products are loaded
      await _loadSavedSelections();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ---------------- CALCULATIONS ----------------

  List<CalculationRequest> _getItemsWithWeight() {
    final List<CalculationRequest> items = [];

    for (var p in _products) {
      for (var sp in p.subProducts) {
        final selected = _productSelections[p.id]?[sp.id] ?? false;
        if (!selected) continue;

        final qty = double.tryParse(
          _productControllers[p.id]?[sp.id]?.text ?? '',
        ) ??
            0;

        if (qty > 0) {
          items.add(
            CalculationRequest(
              subProductId: sp.id,
              subProductName: sp.name,
              estimatedWeight: qty,
              productRate: sp.rate, // Save rate for display
              otherRate: sp.otherRate, // Save other rate for display
            ),
          );
        }
      }
    }

    return items;
  }

  double _getTotalWeight() {
    double total = 0;

    for (var p in _products) {
      for (var sp in p.subProducts) {
        final selected = _productSelections[p.id]?[sp.id] ?? false;
        if (!selected) continue;

        final qty = double.tryParse(
          _productControllers[p.id]?[sp.id]?.text ?? '',
        ) ??
            0;

        if (qty > 0) {
          total += qty;
        }
      }
    }

    return total;
  }

  double _getEstimatedEarnings() {
    double total = 0;

    for (var p in _products) {
      for (var sp in p.subProducts) {
        final selected = _productSelections[p.id]?[sp.id] ?? false;
        if (!selected) continue;

        final qty = double.tryParse(
          _productControllers[p.id]?[sp.id]?.text ?? '',
        ) ??
            0;

        if (qty <= 0) continue;

        final diff = sp.rate - sp.otherRate;
        if (diff > 0) {
          total += qty * diff;
        }
      }
    }

    return total;
  }

  int _getSelectedCount() {
    int count = 0;

    for (var p in _products) {
      for (var sp in p.subProducts) {
        final selected = _productSelections[p.id]?[sp.id] ?? false;
        if (!selected) continue;

        final qty = double.tryParse(
          _productControllers[p.id]?[sp.id]?.text ?? '',
        ) ??
            0;

        if (qty > 0) {
          count++;
        }
      }
    }

    return count;
  }

  // ---------------- API CALCULATION ----------------

  Future<void> _calculateTotalAmount() async {
    final items = _getItemsWithWeight();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter weight for at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCalculating = true);

    try {
      final res = await _apiService.calculatePrice(items);

      // Save calculation data to SharedPreferences
      await _saveCalculationData(res, items);

      setState(() {
        _calculationResponse = res;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() => _isCalculating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calculation failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Save calculation data to SharedPreferences
  Future<void> _saveCalculationData(CalculationResponse response, List<CalculationRequest> items) async {
    final calculationData = {
      'response': {
        'items': response.items,
        'grandTotals': response.grandTotals?.toJson(),
      },
      'requests': items.map((item) => item.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _prefs.setString('calculation_data', calculationData.toString());
    print('Calculation data saved to SharedPreferences');
  }

  // ---------------- UI ----------------

  Widget _buildProductItem(Product p, SubProduct sp) {
    final selected = _productSelections[p.id]![sp.id]!;
    final controller = _productControllers[p.id]![sp.id]!;

    final qty = double.tryParse(controller.text) ?? 0;
    final diff = sp.rate - sp.otherRate;
    final earning = (qty > 0 && diff > 0) ? qty * diff : 0;

    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (v) {
                setState(() {
                  _productSelections[p.id]![sp.id] = v ?? false;
                  if (!(v ?? false)) controller.clear();
                  _invalidateCalculation();
                });
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sp.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Rate: ₹${sp.rate.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Other: ₹${sp.otherRate.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (selected && earning > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "₹${earning.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        if (selected)
          Padding(
            padding: const EdgeInsets.only(left: 48, right: 12, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _invalidateCalculation(),
                  decoration: InputDecoration(
                    labelText: "Weight (${sp.unit})",
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (qty > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Value at my rate: ₹${(qty * sp.rate).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Text(
                        'Value at other rate: ₹${(qty * sp.otherRate).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Order Products' : 'Select Products'),
        backgroundColor: brownPrimary,
        foregroundColor: whiteColor,
        actions: [
          // Clear all button
          IconButton(
            onPressed: () {
              setState(() {
                for (var productMap in _productSelections.values) {
                  for (var key in productMap.keys) {
                    productMap[key] = false;
                  }
                }
                for (var productMap in _productControllers.values) {
                  for (var controller in productMap.values) {
                    controller.clear();
                  }
                }
                _calculationResponse = null;
              });
              _prefs.remove(_selectionKey);
              _prefs.remove('calculation_data');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All selections cleared'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),

      // 🔘 BUTTON KEPT
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCalculating ? null : _calculateTotalAmount,
        icon: _isCalculating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.calculate),
        label: Text(
          _isCalculating ? 'Calculating...' : 'Calculate Actual',
        ),
        backgroundColor: brownPrimary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // 🔘 VIEW DETAILS BUTTON KEPT
      bottomNavigationBar: _calculationResponse != null
          ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalculationScreen(
                    calculationRequests: _getItemsWithWeight(),
                    productName: "Multiple Products",
                    orderData: _orderData,
                    calculationResponse: _calculationResponse,
                    isEditMode: _isEditMode,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: brownPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'View Detailed Calculation',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      )
          : null,

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.only(bottom: 140),
        children: [
          // Summary Card
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: brownPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: brownPrimary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected Items",
                      style: TextStyle(
                        color: brownPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${_getSelectedCount()} items",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Total Weight",
                      style: TextStyle(
                        color: brownPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${_getTotalWeight().toStringAsFixed(2)} kg",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Earnings Summary
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Estimated Earnings:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "₹${_getEstimatedEarnings().toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Products List
          ..._products.map(
                (p) => Card(
              margin: const EdgeInsets.all(8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: brownPrimary.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.category, color: Color(0xFF5A3E1A)),
                        const SizedBox(width: 8),
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...p.subProducts
                      .map((sp) => _buildProductItem(p, sp))
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}