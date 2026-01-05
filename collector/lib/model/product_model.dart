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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      subProducts: subs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sub_products': subProducts.map((sub) => sub.toJson()).toList(),
    };
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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      rate: (json['rate'] is num) ? (json['rate'] as num).toDouble() :
      double.tryParse(json['rate'].toString()) ?? 0.0,
      otherRate: (json['other_rate'] is num) ? (json['other_rate'] as num).toDouble() :
      double.tryParse(json['other_rate'].toString()) ?? 0.0,
      unit: json['unit']?.toString() ?? 'kg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rate': rate,
      'other_rate': otherRate,
      'unit': unit,
    };
  }
}

// Request to send to API
class CalculationRequest {
  final int subProductId;
  final String subProductName;
  final double estimatedWeight;
  final double? productRate;
  final double? otherRate;

  CalculationRequest({
    required this.subProductId,
    required this.subProductName,
    required this.estimatedWeight,
    this.productRate,
    this.otherRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'sub_product_id': subProductId,
      'sub_product_name': subProductName,
      'estimated_weight': estimatedWeight,
      'product_rate': productRate,
      'other_rate': otherRate,
    };
  }

  factory CalculationRequest.fromJson(Map<String, dynamic> json) {
    return CalculationRequest(
      subProductId: json['sub_product_id'] is int ? json['sub_product_id'] :
      int.tryParse(json['sub_product_id'].toString()) ?? 0,
      subProductName: json['sub_product_name']?.toString() ?? '',
      estimatedWeight: (json['estimated_weight'] is num) ?
      (json['estimated_weight'] as num).toDouble() :
      double.tryParse(json['estimated_weight'].toString()) ?? 0.0,
      productRate: json['product_rate'] != null ?
      ((json['product_rate'] is num) ?
      (json['product_rate'] as num).toDouble() :
      double.tryParse(json['product_rate'].toString()) ?? 0.0) : null,
      otherRate: json['other_rate'] != null ?
      ((json['other_rate'] is num) ?
      (json['other_rate'] as num).toDouble() :
      double.tryParse(json['other_rate'].toString()) ?? 0.0) : null,
    );
  }
}

// API Response Item
class CalculationItem {
  final int subProductId;
  final String subProductName;
  final double myRate;
  final double otherRate;
  final double estimatedWeight;
  final double extraMoney;

  CalculationItem({
    required this.subProductId,
    required this.subProductName,
    required this.myRate,
    required this.otherRate,
    required this.estimatedWeight,
    required this.extraMoney,
  });

  factory CalculationItem.fromJson(Map<String, dynamic> json) {
    return CalculationItem(
      subProductId: json['sub_product_id'] is int ? json['sub_product_id'] :
      int.tryParse(json['sub_product_id'].toString()) ?? 0,
      subProductName: json['sub_product_name']?.toString() ?? '',
      myRate: (json['my_rate'] is num) ? (json['my_rate'] as num).toDouble() :
      double.tryParse(json['my_rate'].toString()) ?? 0.0,
      otherRate: (json['other_rate'] is num) ? (json['other_rate'] as num).toDouble() :
      double.tryParse(json['other_rate'].toString()) ?? 0.0,
      estimatedWeight: (json['estimated_weight'] is num) ?
      (json['estimated_weight'] as num).toDouble() :
      double.tryParse(json['estimated_weight'].toString()) ?? 0.0,
      extraMoney: (json['extra_money'] is num) ? (json['extra_money'] as num).toDouble() :
      double.tryParse(json['extra_money'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub_product_id': subProductId,
      'sub_product_name': subProductName,
      'my_rate': myRate,
      'other_rate': otherRate,
      'estimated_weight': estimatedWeight,
      'extra_money': extraMoney,
    };
  }
}

// Response Grand Totals
class GrandTotals {
  final double? totalMyPrice;
  final double? totalOtherPrice;
  final double? totalExtraMoney;

  GrandTotals({
    this.totalMyPrice,
    this.totalOtherPrice,
    this.totalExtraMoney,
  });

  factory GrandTotals.fromJson(Map<String, dynamic> json) {
    return GrandTotals(
      totalMyPrice: json['total_my_price'] != null
          ? double.tryParse(json['total_my_price'].toString())
          : json['totalMyPrice'] != null
          ? double.tryParse(json['totalMyPrice'].toString())
          : 0,
      totalOtherPrice: json['total_other_price'] != null
          ? double.tryParse(json['total_other_price'].toString())
          : json['totalOtherPrice'] != null
          ? double.tryParse(json['totalOtherPrice'].toString())
          : 0,
      totalExtraMoney: json['total_extra_money'] != null
          ? double.tryParse(json['total_extra_money'].toString())
          : json['totalExtraMoney'] != null
          ? double.tryParse(json['totalExtraMoney'].toString())
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_my_price': totalMyPrice,
      'total_other_price': totalOtherPrice,
      'total_extra_money': totalExtraMoney,
    };
  }


  // For backward compatibility
  double get totalAmount => totalMyPrice!;
  double get ourTotal => totalMyPrice!;
  double get otherTotal => totalOtherPrice!;
}

// Response from API
class CalculationResponse {
  final List<dynamic>? items;  // Can be CalculationItem or Map
  final GrandTotals? grandTotals;
  final String status;
  final String message;

  CalculationResponse({
    this.items,
    this.grandTotals,
    required this.status,
    required this.message,
  });

  factory CalculationResponse.fromJson(Map<String, dynamic> json) {
    // Parse items array
    final itemsJson = json['items'] as List? ?? [];
    final List<CalculationItem> items = itemsJson.map((item) {
      if (item is Map<String, dynamic>) {
        return CalculationItem.fromJson(item);
      }
      return CalculationItem.fromJson({});
    }).toList();

    // Parse grand totals
    final grandTotals = json['grand_totals'] != null
        ? GrandTotals.fromJson(json['grand_totals'])
        : null;

    return CalculationResponse(
      items: items,
      grandTotals: grandTotals,
      status: json['status']?.toString() ?? 'error',
      message: json['message']?.toString() ?? '',
    );
  }

  // Alternative factory for different API response format
  factory CalculationResponse.fromAlternativeJson(Map<String, dynamic> json) {
    // Parse sub_products array (if API uses different key)
    final itemsJson = json['sub_products'] as List? ?? [];
    final List<CalculationItem> items = itemsJson.map((item) {
      if (item is Map<String, dynamic>) {
        return CalculationItem.fromJson(item);
      }
      return CalculationItem.fromJson({});
    }).toList();

    // Parse grand totals
    final grandTotals = json['grand_totals'] != null
        ? GrandTotals.fromJson(json['grand_totals'])
        : GrandTotals.fromJson({
      'total_my_price': json['total_my_price'] ?? 0,
      'total_other_price': json['total_other_price'] ?? 0,
      'total_extra_money': json['total_extra_money'] ?? 0,
    });

    return CalculationResponse(
      items: items,
      grandTotals: grandTotals,
      status: json['status']?.toString() ?? 'success',
      message: json['message']?.toString() ?? 'Calculation completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items?.map((item) {
        if (item is CalculationItem) {
          return item.toJson();
        }
        return item;
      }).toList(),
      'grand_totals': grandTotals?.toJson(),
      'status': status,
      'message': message,
    };
  }

  // For backward compatibility
  List<SubProductCalculation> get subProducts {
    return items?.map((item) {
      if (item is CalculationItem) {
        return SubProductCalculation(
          subProductId: item.subProductId,
          subProductName: item.subProductName,
          rate: item.myRate,
          otherRate: item.otherRate,
          estimatedWeight: item.estimatedWeight,
          actualWeight: item.estimatedWeight, // Use estimated as actual if not provided
          ourPrice: item.estimatedWeight * item.myRate,
          otherPrice: item.estimatedWeight * item.otherRate,
          extraMoney: item.extraMoney,
        );
      }
      return SubProductCalculation(
        subProductId: 0,
        subProductName: '',
        rate: 0,
        otherRate: 0,
        estimatedWeight: 0,
        actualWeight: 0,
        ourPrice: 0,
        otherPrice: 0,
        extraMoney: 0,
      );
    }).toList() ?? [];
  }
}

// For backward compatibility with old code
class SubProductCalculation {
  final int subProductId;
  final String subProductName;
  final double rate;
  final double otherRate;
  final double estimatedWeight;
  final double actualWeight;
  final double ourPrice;
  final double otherPrice;
  final double extraMoney;

  SubProductCalculation({
    required this.subProductId,
    required this.subProductName,
    required this.rate,
    required this.otherRate,
    required this.estimatedWeight,
    required this.actualWeight,
    required this.ourPrice,
    required this.otherPrice,
    required this.extraMoney,
  });

  factory SubProductCalculation.fromJson(Map<String, dynamic> json) {
    return SubProductCalculation(
      subProductId: json['sub_product_id'] is int ? json['sub_product_id'] :
      int.tryParse(json['sub_product_id'].toString()) ?? 0,
      subProductName: json['sub_product_name']?.toString() ?? '',
      rate: (json['rate'] is num) ? (json['rate'] as num).toDouble() :
      double.tryParse(json['rate'].toString()) ?? 0.0,
      otherRate: (json['other_rate'] is num) ? (json['other_rate'] as num).toDouble() :
      double.tryParse(json['other_rate'].toString()) ?? 0.0,
      estimatedWeight: (json['estimated_weight'] is num) ?
      (json['estimated_weight'] as num).toDouble() :
      double.tryParse(json['estimated_weight'].toString()) ?? 0.0,
      actualWeight: (json['actual_weight'] is num) ?
      (json['actual_weight'] as num).toDouble() :
      double.tryParse(json['actual_weight'].toString()) ?? 0.0,
      ourPrice: (json['our_price'] is num) ? (json['our_price'] as num).toDouble() :
      double.tryParse(json['our_price'].toString()) ?? 0.0,
      otherPrice: (json['other_price'] is num) ? (json['other_price'] as num).toDouble() :
      double.tryParse(json['other_price'].toString()) ?? 0.0,
      extraMoney: (json['extra_money'] is num) ? (json['extra_money'] as num).toDouble() :
      double.tryParse(json['extra_money'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub_product_id': subProductId,
      'sub_product_name': subProductName,
      'rate': rate,
      'other_rate': otherRate,
      'estimated_weight': estimatedWeight,
      'actual_weight': actualWeight,
      'our_price': ourPrice,
      'other_price': otherPrice,
      'extra_money': extraMoney,
    };
  }
}

// Order Data Model (for SharedPreferences)
class OrderData {
  final CalculationResponse? calculationResponse;
  final String productName;
  final List<CalculationRequest> calculationRequests;
  final String selectedLocation;
  final double? latitude;
  final double? longitude;
  final DateTime selectedDate;

  OrderData({
    this.calculationResponse,
    required this.productName,
    required this.calculationRequests,
    required this.selectedLocation,
    this.latitude,
    this.longitude,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'calculation_response': calculationResponse?.toJson(),
      'product_name': productName,
      'calculation_requests': calculationRequests.map((r) => r.toJson()).toList(),
      'selected_location': selectedLocation,
      'latitude': latitude,
      'longitude': longitude,
      'selected_date': selectedDate.toIso8601String(),
    };
  }

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      calculationResponse: json['calculation_response'] != null
          ? CalculationResponse.fromJson(json['calculation_response'])
          : null,
      productName: json['product_name']?.toString() ?? '',
      calculationRequests: (json['calculation_requests'] as List?)
          ?.map((item) => CalculationRequest.fromJson(item))
          .toList() ??
          [],
      selectedLocation: json['selected_location']?.toString() ?? '',
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() :
      json['latitude']?.toDouble(),
      longitude: (json['longitude'] is num) ? (json['longitude'] as num).toDouble() :
      json['longitude']?.toDouble(),
      selectedDate: DateTime.tryParse(json['selected_date']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

// API Service Helper Class
class ApiCalculationRequest {
  final List<Map<String, dynamic>> items;

  ApiCalculationRequest({
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items,
    };
  }

  factory ApiCalculationRequest.fromCalculationRequests(List<CalculationRequest> requests) {
    return ApiCalculationRequest(
      items: requests.map((req) => req.toJson()).toList(),
    );
  }
}