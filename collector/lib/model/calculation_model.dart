// models/calculation_models.dart
class CalculationRequest {
  final int subProductId;
  final String subProductName;
  final double? estimatedWeight;

  CalculationRequest({
    required this.subProductId,
    required this.subProductName,
    this.estimatedWeight,
  });

  Map<String, dynamic> toJson() => {
    'sub_product_id': subProductId,
    'sub_product_name': subProductName,
    'estimated_weight': estimatedWeight ?? 0,
  };
}

class CalculationResponse {
  final String status;
  final String? message;
  final List<dynamic> data;
  final List<Map<String, dynamic>>? items;
  final Map<String, dynamic>? weightBasedTotals;
  final Map<String, dynamic>? pieceBasedTotals;
  final Map<String, dynamic>? grandTotals;

  CalculationResponse({
    required this.status,
    this.message,
    required this.data,
    this.items,
    this.weightBasedTotals,
    this.pieceBasedTotals,
    this.grandTotals,
  });

  factory CalculationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>;
    final List<Map<String, dynamic>> items = [];
    Map<String, dynamic>? weightBasedTotals;
    Map<String, dynamic>? pieceBasedTotals;
    Map<String, dynamic>? grandTotals;

    for (var item in data) {
      if (item is Map<String, dynamic>) {
        if (item.containsKey('sub_product_id')) {
          items.add(item);
        } else if (item.containsKey('total_weight_based')) {
          weightBasedTotals = item['total_weight_based'] as Map<String, dynamic>?;
          pieceBasedTotals = item['total_piece_based'] as Map<String, dynamic>?;
          grandTotals = item['grand_totals'] as Map<String, dynamic>?;
        }
      }
    }

    return CalculationResponse(
      status: json['status'] ?? 'error',
      message: json['message'],
      data: data,
      items: items,
      weightBasedTotals: weightBasedTotals,
      pieceBasedTotals: pieceBasedTotals,
      grandTotals: grandTotals,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data,
    'items': items,
    'weightBasedTotals': weightBasedTotals,
    'pieceBasedTotals': pieceBasedTotals,
    'grandTotals': grandTotals,
  };
}

class GrandTotals {
  final double totalMyApplicationPrice;
  final double totalOtherPrice;
  final double totalExtraMoney;
  final double? totalWeight;
  final double? totalPiece;

  GrandTotals({
    required this.totalMyApplicationPrice,
    required this.totalOtherPrice,
    required this.totalExtraMoney,
    this.totalWeight,
    this.totalPiece,
  });

  factory GrandTotals.fromJson(Map<String, dynamic> json) {
    return GrandTotals(
      totalMyApplicationPrice: (json['total_my_application_price'] as num?)?.toDouble() ?? 0.0,
      totalOtherPrice: (json['total_other_price'] as num?)?.toDouble() ?? 0.0,
      totalExtraMoney: (json['total_extra_money'] as num?)?.toDouble() ?? 0.0,
      totalWeight: (json['total_weight'] as num?)?.toDouble(),
      totalPiece: (json['total_piece'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_my_application_price': totalMyApplicationPrice,
    'total_other_price': totalOtherPrice,
    'total_extra_money': totalExtraMoney,
    'total_weight': totalWeight,
    'total_piece': totalPiece,
  };
}

class StructuredCalculationResponse {
  final String status;
  final String? message;
  final List<CalculatedItem> items;
  final GrandTotals grandTotals;
  final Map<String, dynamic>? weightBasedTotals;
  final Map<String, dynamic>? pieceBasedTotals;
  final Map<String, dynamic> rawResponse;

  StructuredCalculationResponse({
    required this.status,
    this.message,
    required this.items,
    required this.grandTotals,
    this.weightBasedTotals,
    this.pieceBasedTotals,
    required this.rawResponse,
  });

  factory StructuredCalculationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>;
    final List<CalculatedItem> items = [];
    GrandTotals grandTotals = GrandTotals(
      totalMyApplicationPrice: 0,
      totalOtherPrice: 0,
      totalExtraMoney: 0,
    );
    Map<String, dynamic>? weightBasedTotals;
    Map<String, dynamic>? pieceBasedTotals;

    for (var item in data) {
      if (item is Map<String, dynamic>) {
        if (item.containsKey('sub_product_id')) {
          items.add(CalculatedItem.fromJson(item));
        } else if (item.containsKey('total_weight_based')) {
          weightBasedTotals = item['total_weight_based'] as Map<String, dynamic>?;
          pieceBasedTotals = item['total_piece_based'] as Map<String, dynamic>?;

          final gt = item['grand_totals'] as Map<String, dynamic>?;
          if (gt != null) {
            grandTotals = GrandTotals.fromJson(gt);
          }
        }
      }
    }

    return StructuredCalculationResponse(
      status: json['status'] ?? 'error',
      message: json['message'],
      items: items,
      grandTotals: grandTotals,
      weightBasedTotals: weightBasedTotals,
      pieceBasedTotals: pieceBasedTotals,
      rawResponse: json,
    );
  }
}

class CalculatedItem {
  final int subProductId;
  final String subProductName;
  final String unit;
  final double estimatedWeight;
  final double myRate;
  final double otherRate;
  final double myPrice;
  final double otherPrice;
  final double extraMoney;

  CalculatedItem({
    required this.subProductId,
    required this.subProductName,
    required this.unit,
    required this.estimatedWeight,
    required this.myRate,
    required this.otherRate,
    required this.myPrice,
    required this.otherPrice,
    required this.extraMoney,
  });

  factory CalculatedItem.fromJson(Map<String, dynamic> json) {
    return CalculatedItem(
      subProductId: (json['sub_product_id'] as num).toInt(),
      subProductName: json['sub_product_name'] ?? '',
      unit: json['unit'] ?? 'kg',
      estimatedWeight: (json['estimated_weight'] as num?)?.toDouble() ?? 0.0,
      myRate: (json['my_rate'] as num?)?.toDouble() ?? 0.0,
      otherRate: (json['other_rate'] as num?)?.toDouble() ?? 0.0,
      myPrice: (json['my_price'] as num?)?.toDouble() ?? 0.0,
      otherPrice: (json['other_price'] as num?)?.toDouble() ?? 0.0,
      extraMoney: (json['extra_money'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'sub_product_id': subProductId,
    'sub_product_name': subProductName,
    'unit': unit,
    'estimated_weight': estimatedWeight,
    'my_rate': myRate,
    'other_rate': otherRate,
    'my_price': myPrice,
    'other_price': otherPrice,
    'extra_money': extraMoney,
  };
}