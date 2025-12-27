// models/product_model.dart

class Product {
  final int id;
  final String name;
  final String description;
  final List<SubProduct> subProducts;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.subProducts,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var subList = json['sub_products'] as List? ?? [];
    List<SubProduct> subs = subList.map((i) => SubProduct.fromJson(i)).toList();

    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      subProducts: subs,
    );
  }
}

class SubProduct {
  final int id;
  final String name;
  final double rate;
  final double otherRate;
  final String unit;

  SubProduct({
    required this.id,
    required this.name,
    required this.rate,
    required this.otherRate,
    required this.unit,
  });

  factory SubProduct.fromJson(Map<String, dynamic> json) {
    return SubProduct(
      id: json['id'],
      name: json['name'],
      rate: double.tryParse(json['rate'].toString()) ?? 0.0,
      otherRate: double.tryParse(json['other_rate'].toString()) ?? 0.0,
      unit: json['unit'] ?? 'kg',
    );
  }
}

// Request to send to API
class CalculationRequest {
  final int subProductId;
  final String subProductName;
  final double estimatedWeight;

  CalculationRequest({
    required this.subProductId,
    required this.subProductName,
    required this.estimatedWeight,
  });

  Map<String, dynamic> toJson() {
    return {
      'sub_product_id': subProductId,
      'sub_product_name': subProductName,
      'estimated_weight': estimatedWeight,
    };
  }

  // If you have fromJson method, update it too
  factory CalculationRequest.fromJson(Map<String, dynamic> json) {
    return CalculationRequest(
      subProductId: json['sub_product_id'],
      subProductName: json['sub_product_name'],
      estimatedWeight: json['estimated_weight'].toDouble(),
    );
  }}

// Response from API
class CalculationResponse {
  final List<CalculationResultItem> items;
  final GrandTotals grandTotals;
  final String status;
  final String message;

  CalculationResponse({
    required this.items,
    required this.grandTotals,
    required this.status,
    required this.message,
  });

  factory CalculationResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List;

    // Extract items (all elements except the last one which contains totals)
    List<CalculationResultItem> items = [];
    for (int i = 0; i < dataList.length - 1; i++) {
      final item = dataList[i];
      if (item is Map<String, dynamic>) {
        items.add(CalculationResultItem.fromJson(item));
      }
    }

    // Extract grand totals from the last element in data array
    final lastElement = dataList.isNotEmpty ? dataList.last : {};
    final grandTotalsData = lastElement['grand_totals'] ?? {};

    return CalculationResponse(
      items: items,
      grandTotals: GrandTotals.fromJson(grandTotalsData),
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class CalculationResultItem {
  final int subProductId;
  final String subProductName;
  final String unit;
  final String estimatedQuantity;
  final double myRate;
  final double otherRate;
  final double myPrice;
  final double otherPrice;
  final double extraMoney;

  CalculationResultItem({
    required this.subProductId,
    required this.subProductName,
    required this.unit,
    required this.estimatedQuantity,
    required this.myRate,
    required this.otherRate,
    required this.myPrice,
    required this.otherPrice,
    required this.extraMoney,
  });

  factory CalculationResultItem.fromJson(Map<String, dynamic> json) {
    return CalculationResultItem(
      subProductId: json['sub_product_id'] ?? 0,
      subProductName: json['sub_product_name'] ?? 'Unknown',
      unit: json['unit'] ?? 'kg',
      estimatedQuantity: json['estimated_quantity'] ?? '',
      myRate: double.tryParse(json['my_rate'].toString()) ?? 0.0,
      otherRate: double.tryParse(json['other_rate'].toString()) ?? 0.0,
      myPrice: double.tryParse(json['my_price'].toString()) ?? 0.0,
      otherPrice: double.tryParse(json['other_price'].toString()) ?? 0.0,
      extraMoney: double.tryParse(json['extra_money'].toString()) ?? 0.0,
    );
  }

  // Helper getter to extract numeric weight from estimatedQuantity string
  double get estimatedWeight {
    try {
      final parts = estimatedQuantity.split(' ');
      return double.tryParse(parts[0]) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

class GrandTotals {
  final double totalMyPrice;
  final double totalOtherPrice;
  final double totalExtraMoney;

  GrandTotals({
    required this.totalMyPrice,
    required this.totalOtherPrice,
    required this.totalExtraMoney,
  });

  factory GrandTotals.fromJson(Map<String, dynamic> json) {
    return GrandTotals(
      totalMyPrice: double.tryParse(json['total_my_application_price']?.toString() ?? '0') ?? 0.0,
      totalOtherPrice: double.tryParse(json['total_other_price']?.toString() ?? '0') ?? 0.0,
      totalExtraMoney: double.tryParse(json['total_extra_money']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class OrderData {
  final CalculationResponse calculationResponse;
  final String productName;
  final List<CalculationRequest> calculationRequests;
  final String selectedLocation;
  final double? latitude;
  final double? longitude;
  final DateTime selectedDate;

  OrderData({
    required this.calculationResponse,
    required this.productName,
    required this.calculationRequests,
    required this.selectedLocation,
    this.latitude,
    this.longitude,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'calculation_response': calculationResponse.toString(),
      'product_name': productName,
      'calculation_requests': calculationRequests.map((r) => r.toJson()).toList(),
      'selected_location': selectedLocation,
      'latitude': latitude,
      'longitude': longitude,
      'selected_date': selectedDate.toIso8601String(),
    };
  }
}

