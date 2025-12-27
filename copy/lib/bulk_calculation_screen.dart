import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'bulk_map_selection_screen.dart';


// 🌱 COLOR THEME
const PRIMARY_GREEN = Color(0xFF6FAE3E);
const DARK_GREEN = Color(0xFF3E6B2C);
const PRIMARY_BLUE = Color(0xFF1F4E79);
const LIGHT_BG = Color(0xFFF4F7F3);
const ACCENT_GOLD = Color(0xFFC48A3A);
const TEXT_DARK = Color(0xFF1E1E1E);
const ERROR = Color(0xFFB93D3D);

class BulkCalculationScreen extends StatefulWidget {
  final List<CalculationRequest> calculationRequests;
  final String productName;

  const BulkCalculationScreen({
    Key? key,
    required this.calculationRequests,
    required this.productName,
  }) : super(key: key);

  @override
  State<BulkCalculationScreen> createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<BulkCalculationScreen> {
  final ApiService _apiService = ApiService();
  CalculationResponse? _response;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _calculatePrice();
  }

  Future<void> _calculatePrice() async {
    try {
      final response =
      await _apiService.calculatePrice(widget.calculationRequests);
      setState(() {
        _response = response;
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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: LIGHT_BG,
      appBar: AppBar(
        title: Text(t.priceCalculation),
        backgroundColor: PRIMARY_BLUE,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: PRIMARY_GREEN))
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _buildResult(t),
    );
  }

  Widget _buildResult(AppLocalizations t) {
    final items = _response!.items;
    final totals = _response!.grandTotals;

    return Column(
      children: [

        /// 🔝 HEADER
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [PRIMARY_GREEN, ACCENT_GOLD],
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.calculate, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.productName,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PRIMARY_BLUE,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text("${items.length} Items",
                    style: const TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),

        /// 📦 ITEM LIST
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// NAME + UNIT
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 5,
                            decoration: BoxDecoration(
                              color: PRIMARY_GREEN,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.subProductName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: TEXT_DARK,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: PRIMARY_BLUE.withOpacity(.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.unit,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: PRIMARY_BLUE,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 1),

                      /// QTY + RATES
                      Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: LIGHT_BG,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            _itemInfo(
                              icon: Icons.scale,
                              label: "Qty",
                              value: "${item.estimatedWeight}",
                            ),
                            _divider(),
                            _itemInfo(
                              icon: Icons.trending_up,
                              label: "Our Rate",
                              value: "₹${item.myRate}",
                              valueColor: PRIMARY_GREEN,
                            ),
                            _divider(),
                            _itemInfo(
                              icon: Icons.trending_down,
                              label: "Other Rate",
                              value: "₹${item.otherRate}",
                              valueColor: ERROR,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// YOU EARN
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.savings,
                                  size: 16,
                                  color: PRIMARY_GREEN),
                              SizedBox(width: 6),
                              Text(
                                "You Earn",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  PRIMARY_GREEN,
                                  ACCENT_GOLD
                                ],
                              ),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              "₹${item.extraMoney.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        /// 💰 TOTAL SUMMARY
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PRIMARY_BLUE,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _totalRow("Our Total",
                  "₹${totals.totalMyPrice.toStringAsFixed(2)}"),
              _totalRow("Other Total",
                  "₹${totals.totalOtherPrice.toStringAsFixed(2)}"),
              const Divider(color: Colors.white),
              _totalRow("Net Earnings",
                  "₹${totals.totalExtraMoney.toStringAsFixed(2)}",
                  big: true),
            ],
          ),
        ),

        /// 🚚 BUTTON
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>  BulkMapSelectionScreen(
                    calculationResponse: _response!,
                    productName: widget.productName,
                    calculationRequests:
                    widget.calculationRequests,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.location_on),
            label: const Text("Proceed to Pickup"),
            style: ElevatedButton.styleFrom(
              backgroundColor: DARK_GREEN,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }

  /// 🔹 SMALL INFO ITEM
  Widget _itemInfo({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = TEXT_DARK,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: PRIMARY_BLUE),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 36,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _totalRow(String label, String value,
      {bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: big ? 14 : 12)),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: big ? 16 : 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
