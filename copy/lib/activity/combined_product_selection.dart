import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'calculation_screen.dart';
import 'package:copy/l10n/app_localizations.dart';

class CombinedProductSelectionScreen extends StatefulWidget {
  const CombinedProductSelectionScreen({Key? key}) : super(key: key);

  @override
  State<CombinedProductSelectionScreen> createState() =>
      _CombinedProductSelectionScreenState();
}

class _CombinedProductSelectionScreenState
    extends State<CombinedProductSelectionScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  Map<int, Map<int, TextEditingController>> _productControllers = {};
  Map<int, Map<int, bool>> _productSelections = {};
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';

  bool _isCalculating = false;
  double _totalEstimatedAmount = 0;
  CalculationResponse? _calculationResponse;

  /// 🎨 UPDATED COLOR THEME (ONLY CHANGE)
  final Color primaryBlue = const Color(0xFF1F4E79);
  final Color primaryGreen = const Color(0xFF6FAE3E);
  final Color accentGold = const Color(0xFFC48A3A);
  final Color whiteColor = const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        for (var product in products) {
          _productControllers[product.id] = {};
          _productSelections[product.id] = {};
          for (var subProduct in product.subProducts) {
            _productControllers[product.id]![subProduct.id] =
                TextEditingController();
            _productSelections[product.id]![subProduct.id] = false;
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<CalculationRequest> _getAllSelectedItems() {
    List<CalculationRequest> allItems = [];

    for (var product in _products) {
      final productItems = product.subProducts
          .where((sp) => _productSelections[product.id]![sp.id] == true)
          .where((sp) {
        final qty =
            double.tryParse(_productControllers[product.id]![sp.id]!.text) ?? 0;
        return qty > 0;
      })
          .map((sp) {
        final qty =
            double.tryParse(_productControllers[product.id]![sp.id]!.text) ?? 0;
        return CalculationRequest(
            subProductId: sp.id,
            subProductName: sp.name,
            estimatedWeight: qty);
      }).toList();

      allItems.addAll(productItems);
    }
    return allItems;
  }

  double _getTotalEstimatedEarnings() {
    double total = 0;
    for (var product in _products) {
      for (var sp in product.subProducts) {
        if (_productSelections[product.id]![sp.id] == true) {
          final qty =
              double.tryParse(_productControllers[product.id]![sp.id]!.text) ?? 0;
          total += qty * (sp.rate - sp.otherRate);
        }
      }
    }
    return total;
  }

  double _getTotalWeight() {
    double totalWeight = 0;
    for (var product in _products) {
      for (var sp in product.subProducts) {
        if (_productSelections[product.id]![sp.id] == true) {
          final qty =
              double.tryParse(_productControllers[product.id]![sp.id]!.text) ?? 0;
          totalWeight += qty;
        }
      }
    }
    return totalWeight;
  }

  double _getTotalOurPrice() {
    double total = 0;
    for (var product in _products) {
      for (var sp in product.subProducts) {
        if (_productSelections[product.id]![sp.id] == true) {
          final qty =
              double.tryParse(_productControllers[product.id]![sp.id]!.text) ?? 0;
          total += qty * sp.rate;
        }
      }
    }
    return total;
  }

  double _getTotalOtherPrice() {
    double total = 0;
    for (var product in _products) {
      for (var sp in product.subProducts) {
        if (_productSelections[product.id]![sp.id] == true) {
          final qty =
              double.tryParse(_productControllers[product.id]![sp.id]!.text) ?? 0;
          total += qty * sp.otherRate;
        }
      }
    }
    return total;
  }

  int _getTotalSelectedCount() => _getAllSelectedItems().length;

  Future<void> _calculateTotalAmount() async {
    final t = AppLocalizations.of(context)!;
    final selectedItems = _getAllSelectedItems();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.selectAtLeastOneItem), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
      _totalEstimatedAmount = 0;
    });

    try {
      final response = await _apiService.calculatePrice(selectedItems);
      setState(() {
        _calculationResponse = response;
        _totalEstimatedAmount = response.grandTotals.totalExtraMoney;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() => _isCalculating = false);
    }
  }

  void _proceedToCalculationScreen() {
    if (_calculationResponse != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CalculationScreen(
            calculationRequests: _getAllSelectedItems(),
            productName: "Multiple Products",
          ),
        ),
      );
    }
  }

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      setState(() => _filteredProducts = _products);
    } else {
      setState(() {
        _filteredProducts = _products.where((product) {
          return product.name.toLowerCase().contains(_searchQuery) ||
              product.description.toLowerCase().contains(_searchQuery) ||
              product.subProducts
                  .any((sp) => sp.name.toLowerCase().contains(_searchQuery));
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (!_isLoading && _error.isEmpty) _filterProducts();

    final totalSelectedCount = _getTotalSelectedCount();
    final totalEstimatedEarnings = _getTotalEstimatedEarnings();
    final totalWeight = _getTotalWeight();
    final totalOurPrice = _getTotalOurPrice();
    final totalOtherPrice = _getTotalOtherPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.selectProducts),
        backgroundColor: primaryBlue,
        foregroundColor: whiteColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: t.searchProducts,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          /// 🔝 SUMMARY BAR
          if (totalSelectedCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryGreen),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$totalSelectedCount ${t.itemsSelected}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryBlue)),
                        Text("${totalWeight.toStringAsFixed(1)} kg",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${t.ourPrice}: ₹${totalOurPrice.toStringAsFixed(2)}",
                            style: TextStyle(color: primaryGreen)),
                        Text(
                            "${t.otherPrice}: ₹${totalOtherPrice.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.redAccent)),
                        Text(
                            "${t.youEarn}: ₹${totalEstimatedEarnings.toStringAsFixed(2)}",
                            style: TextStyle(
                                color: accentGold,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryBlue,
                          child: Text(product.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(product.description),
                      ),
                      ...product.subProducts.map((subProduct) {
                        final selected =
                        _productSelections[product.id]![subProduct.id]!;
                        return Column(
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selected,
                                    activeColor: primaryGreen,
                                    onChanged: (v) => setState(() {
                                      _productSelections[product.id]![subProduct.id] =
                                          v ?? false;
                                      _calculationResponse = null;
                                    }),
                                  ),
                                  Expanded(child: Text(subProduct.name)),
                                  Chip(
                                    label: Text("₹${subProduct.rate}"),
                                    backgroundColor:
                                    accentGold.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 12, bottom: 8),
                                child: TextField(
                                  controller:
                                  _productControllers[product.id]![subProduct.id],
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                                  decoration: InputDecoration(
                                    labelText:
                                    "${t.enterWeightIn} ${subProduct.unit}",
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              )
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: totalSelectedCount > 0
          ? FloatingActionButton.extended(
        onPressed: _isCalculating ? null : _calculateTotalAmount,
        backgroundColor:
        _calculationResponse != null ? accentGold : primaryBlue,
        icon: const Icon(Icons.calculate),
        label: Text(_calculationResponse != null
            ? t.recalculate
            : t.calculateActual),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _calculationResponse != null
          ? Container(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: _proceedToCalculationScreen,
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.all(14)),
          child: Text(t.viewDetailedCalculation),
        ),
      )
          : null,
    );
  }
}
