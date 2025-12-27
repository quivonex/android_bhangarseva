import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/product_model.dart';

class ApiService {
  static const String baseUrl = "https://api.bhangarseva.com";

  // Login
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> loginWithUsernamePassword(String username,
      String password,) async {
    try {
      final url = Uri.parse('$baseUrl/Bhangarwala_user/bhangarwala_login/');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Map the response to match your expected format
        if (responseData['status'] == 'success') {
          // Extract user data from response
          final userData = responseData['data'] is List &&
              responseData['data'].isNotEmpty
              ? responseData['data'][0]
              : {};

          // Save user data locally
          await _saveLoginData(responseData, userData);

          return {
            'success': true,
            'message': responseData['message'] ?? 'Login successful',
            'data': userData,
            'user_id': userData['user_id']?.toString(),
            'username': userData['username']?.toString(),
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Login failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Login Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Save user info - Updated version
  static Future<void> _saveLoginData(Map<String, dynamic> responseData,
      Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Debug print to see what data we're getting
      print('Saving Login Data - ResponseData keys: ${responseData.keys}');
      print('Saving Login Data - UserData keys: ${userData.keys}');
      print('UserData content: $userData');

      // Clear any existing data first
      await prefs.clear();

      // Save basic login status
      await prefs.setString('isLoggedIn', "true");
      await prefs.setString('login_time', DateTime.now().toIso8601String());

      // Save user data from userData map
      if (userData.isNotEmpty) {
        // Save user_id - handle different possible formats
        final userId = userData['user_id'];
        if (userId != null) {
          try {
            await prefs.setString('user_id', userId.toString());
          } catch (e) {
            print('Error parsing user_id as int: $e');
          }
        }

        // Save username
        final username = userData['username'];
        if (username != null) {
          await prefs.setString('username', username.toString());
        }

        // Save email
        final email = userData['email'] ?? userData['username'];
        if (email != null) {
          await prefs.setString('user_email', email.toString());
        }

        // Save name if available
        final name = userData['name'] ?? userData['full_name'] ??
            userData['username'];
        if (name != null) {
          await prefs.setString('user_name', name.toString());
        }

        // Save phone if available
        final phone = userData['phone'] ?? userData['mobile'] ??
            userData['contact'];
        if (phone != null) {
          await prefs.setString('user_phone', phone.toString());
        }
      }

      // Save token from response data if available
      final token = responseData['token'] ?? userData['token'];
      if (token != null) {
        await prefs.setString('auth_token', token.toString());
      }

      // Verify saved data
      print('Saved data verification:');
      print('Saved data isLoggedIn: ${prefs.getString('isLoggedIn')}');
      print('Saved data user_id: ${prefs.getString('user_id')}');
      print('Saved data username: ${prefs.getString('username')}');
      print('Saved data user_email: ${prefs.getString('user_email')}');
      print('Saved data auth_token exists: ${prefs.getString('auth_token') !=
          null}');
    } catch (e) {
      print('Error saving login data: $e');
      rethrow;
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Get user ID as string
  static Future<String?> getUserIdString() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id_str');
  }

  // Check login
  static Future<String?> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('isLoggedIn');
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  // Get username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<List<dynamic>> getSubscriptionPlans() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/plans'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load plans');
    }
  }

  static Future<Map<String, dynamic>> createOrder(double amount,
      String planName) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/create-order'),
      headers: headers,
      body: jsonEncode({
        'amount': amount,
        'plan_name': planName,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create order');
    }
  }

  static Future<Map<String, dynamic>> verifyPaymentPlan(String orderId,
      String paymentId,
      String signature,
      String planName) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/verify-payment'),
      headers: headers,
      body: jsonEncode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
        'plan_name': planName,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Payment verification failed');
    }
  }

  static Future<List<dynamic>> getMySubscriptions() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/my-subscriptions'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load subscriptions');
    }
  }

  static Future<bool> hasActiveSubscription() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/check-subscription'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['has_active_subscription'] ?? false;
    }
    return false;
  }

  Future<Map<String, dynamic>> getPendingOrders({
    String? fromDate,
    String? toDate,
  }) async {
    final Map<String, dynamic> body = {
      'bhangarwala_id': await ApiService.getUserId(),
      'status': 'Pending',
    };

    if (fromDate != null && fromDate.isNotEmpty) {
      body['from_date'] = fromDate;
    }
    if (toDate != null && toDate.isNotEmpty) {
      body['to_date'] = toDate;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Bhangarwala_user/bhangarwala_order_status/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load orders. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<Map<String, dynamic>> acceptOrder({
    required int requestId,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Bhangarwala_user/bhangarwala_respond_order/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "request_id": requestId,
          "bhangarwala_id": await ApiService.getUserId(),
          "action": "Accepted",
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to accept order: $e');
    }
  }


  Future<Map<String, dynamic>> verifyPaymentApi(String text, int sellingDetailId, String? paymentId, String? transactionId, String selectedUpiApp) async {
    try {
      final bhangarwalaId = await ApiService.getUserId();
      final finalAmount = double.parse(text);

      final response = await http.post(
        Uri.parse('$baseUrl/selling_details/update-order-status/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "bhangarwala_id": bhangarwalaId,
          "selling_detail_id": sellingDetailId,
          "action": "Completed",
          "final_amount": finalAmount,
          "payment_id": paymentId ?? 'PAY${DateTime.now().millisecondsSinceEpoch}',
          "transaction_id": transactionId ?? 'TXN${DateTime.now().millisecondsSinceEpoch}',
          "payment_status": "completed",
          "payment_method": "upi",
          "upi_app": selectedUpiApp,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  Future<Map<String, dynamic>> rejectOrder({
    required int requestId,
    required String reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Bhangarwala_user/bhangarwala_respond_order/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "request_id": requestId,
          "bhangarwala_id": await ApiService.getUserId(),
          "action": "Rejected",
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to reject order: $e');
    }
  }

// Add this method to your ApiService class

  Future<Map<String, dynamic>> updateOrderProducts({
    required int orderId,
    required List<Map<String, dynamic>> subProductDetails,
    required double totalAmount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/your_update_endpoint_here/'),
        // Update with your actual endpoint
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': 'Bearer ${await getToken()}',
        },
        body: jsonEncode({
          "id": orderId,
          // Send order ID for update
          "bhangarwala_id": await getUserId(),
          "sub_product_details": subProductDetails,
          // Send in the required format
          "total_amount": totalAmount,
          "action": "Updated",
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to update order products: $e');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day
        .toString().padLeft(2, '0')}";
  }

  // Helper methods for data formatting
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString()
          .padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  static String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month
          .toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour
          .toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(
          2, '0')}";
    } catch (e) {
      return dateTimeString;
    }
  }

  static String formatSubProducts(List<dynamic> subProducts) {
    if (subProducts.isEmpty) return 'No items';

    return subProducts.map((product) {
      return product['sub_product_name']?.toString() ?? 'Unknown';
    }).join(', ');
  }

  static double calculateTotalWeight(List<dynamic> subProducts) {
    double totalWeight = 0;
    for (var product in subProducts) {
      totalWeight += (product['weight'] ?? 0).toDouble();
    }
    return totalWeight;
  }

  static String formatAddress(String address, double lat, double lng) {
    if (address.isNotEmpty && address != "null") return address;
    return "Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}";
  }

  // services/api_services.dart - Add this method to the ApiService class
  Future<Map<String, dynamic>> getBhangarwalaOrderStatus({
    required int bhangarwalaId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'bhangarwala_id': bhangarwalaId,
      };

      // Add date parameters if provided
      if (fromDate != null && fromDate.isNotEmpty) {
        body['from_date'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        body['to_date'] = toDate;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/Bhangarwala_user/bhangarwala_order_status/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load order status. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

// Add this method to your ApiService class in api_services.dart
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/product_details/retrive_sub_product/'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer <token>', // uncomment if you need auth
        },
        body: json.encode({}), // Add empty body or required parameters
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // The actual list is inside the "data" key
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => Product.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Unknown error');
        }
      } else {
        print("Status Code Error: ${response.statusCode}");
        print("Response Body: ${response.body}");
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print("Network Error: $e");
      throw Exception('Failed to load products: $e');
    }
  }


  Future<CalculationResponse> calculatePrice(
      List<CalculationRequest> requests) async {
    final response = await http.post(
      Uri.parse('$baseUrl/product_details/calculate_price/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "sub_product_data": requests.map((r) => r.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return CalculationResponse.fromJson(json);
    } else {
      throw Exception('Calculation failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getAcceptedRequests() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Bhangarwala_user/bhangarwala/requests/accepted/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "bhangarwala_id": await ApiService.getUserId(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'HTTP Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load accepted requests: $e');
    }
  }

// Add these methods to your ApiService class

  Future<Map<String, dynamic>> initiatePayment({
    required int orderId,
    required double amount,
    required String customerPhone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/initiate_payment/'),
        // Your payment initiation endpoint
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': 'Bearer ${await getToken()}',
        },
        body: jsonEncode({
          "order_id": orderId,
          "amount": amount,
          "customer_phone": customerPhone,
          "bhangarwala_id": await getUserId(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }


  Future<Map<String, dynamic>> completeOrder({
    required int orderId,
    required double finalAmount,
    required List<Map<String, dynamic>> subProductDetails,
    String? paymentId,
    String? transactionId,
    String paymentStatus = 'completed',
    String paymentMethod = 'upi',
    String? upiApp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Bhangarwala_user/bhangarwala_respond_order/'),
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': 'Bearer ${await getToken()}',
        },
        body: jsonEncode({
          "id": orderId,
          "bhangarwala_id": await getUserId(),
          "action": "Completed",
          "final_amount": finalAmount,
          "sub_product_details": subProductDetails,
          "payment_id": paymentId,
          "transaction_id": transactionId,
          "payment_status": paymentStatus,
          "payment_method": paymentMethod,
          "upi_app": upiApp,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to complete order: $e');
    }
  }
  Future<Map<String, dynamic>> updateOrderStatus(
      dynamic sellingDetailId) async {
    final url = Uri.parse('$baseUrl/selling_details/update-order-status/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'selling_detail_id': sellingDetailId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update order status');
    }
  }

  Future<Map<String, dynamic>> updateSellingDetail(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/selling_details/selling-detail/update/');

    print('DEBUG: Updating selling detail with data: $data');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Add your authorization headers if needed
        // 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update selling detail. Status code: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getAllHeavyOrders() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Bhangarwala_user/bhangarwala/heavy-orders/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "bhangarwala_id": 0, // Using 0 or any value to get all orders
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return {
          "message": "No orders found",
          "count": 0,
          "data": []
        };
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

}