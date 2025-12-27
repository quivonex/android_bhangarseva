// models/request_model.dart
class Request {
  final String id;
  final String customerName;
  final String address;
  final String items;
  final String scheduledDate;
  final String status;
  final String amount;

  Request({
    required this.id,
    required this.customerName,
    required this.address,
    required this.items,
    required this.scheduledDate,
    required this.status,
    required this.amount,
  });
}