// screens/price_card.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class PriceCard extends StatefulWidget {
  const PriceCard({Key? key}) : super(key: key);

  @override
  State<PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<PriceCard> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = true;
  String _error = '';

  // UPDATED COLOR THEME
  final Color primaryGreen = const Color(0xFF6FAE3E);
  final Color darkGreen = const Color(0xFF3E6B2C);
  final PRIMARY_BLUE = const Color(0xFF1F4E79);
  final Color lightBackground = const Color(0xFFF4F7F3);
  final Color accentGold = const Color(0xFFC48A3A);
  final Color textDark = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: const Text('Price Card'),
        backgroundColor:  PRIMARY_BLUE ,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : _error.isNotEmpty
          ? Center(child: Text(_error, style: TextStyle(color: textDark)))
          : _products.isEmpty
          ? Center(child: Text('No products available', style: TextStyle(color: textDark)))
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.all(8),
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 14, color: textDark),
                  ),
                  const SizedBox(height: 8),
                  ...product.subProducts.map((subProduct) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(subProduct.name,
                            style: TextStyle(fontSize: 14, color: textDark)),
                        Text("₹${subProduct.rate}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: accentGold)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
