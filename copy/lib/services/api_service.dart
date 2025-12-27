
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';

  class ApiService {
  static const String baseUrl = "https://api.bhangarseva.com";

  // Send OTP to email
  static Future<Map<String, dynamic>> sendOtp(String email) async {
  try {
  final url = Uri.parse("$baseUrl/user_prof/send_otp/");

  final response = await http.post(
  url,
  body: {"email": email},
  );
  print("response=="+response.toString());

  if (response.statusCode == 200) {

    final responseData = jsonDecode(response.body);

  // Save email to shared preferences for verification
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('email_for_verification', email);

  return {
  'success': true,
  'data': responseData,
  };
  } else {
  return {
  'success': false,
  'error': 'Failed to send OTP',
  };
  }
  } catch (e) {
  return {
  'success': false,
  'error': 'Network error: $e',
  };
  }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String otp, String email) async {
  try {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email_for_verification');

  if (email == null) {
  return {
  'success': false,
  'error': 'Email not found. Please restart the process.',
  };
  }

  final url = Uri.parse("$baseUrl/user_prof/verify_otp/");

  final response = await http.post(
  url,
  body: {
  "email": email,
  "otp": otp,
  },
  );

  if (response.statusCode == 200) {
  final responseData = jsonDecode(response.body);

  if (responseData['status'] == 'success') {
  // Save login data to shared preferences
  await _saveLoginData(responseData);

  return {
  'success': true,
  'data': responseData,
  };
  } else {
  return {
  'success': false,
  'error': responseData['message'] ?? 'OTP verification failed',
  };
  }
  } else {
  return {
  'success': false,
  'error': 'OTP verification failed',
  };
  }
  } catch (e) {
  return {
  'success': false,
  'error': 'Network error: $e',
  };
  }
  }

  static Future<Map<String, dynamic>> fetchOrders(String? userId) async {
    try {
      final url = Uri.parse("$baseUrl/selling_details/order_retrive/");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded', // FORM DATA
        },
        body: {
          'user_id': userId,  // 👉 send as simple Map (form-data)
        },
      );

      print("fetchOrders response: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return {
            'success': true,
            'data': List<Map<String, dynamic>>.from(responseData['data']),
          };
        } else {
          return {
            'success': false,
            'error': responseData['message'] ?? 'Failed to fetch orders',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch orders: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("Error fetching orders: $e");
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }



  static Future<Map<String, dynamic>> createSellingDetail({
    String? userId,
    required String date,
    required String timeSlotId,
    required double latitude,
    required double longitude,
    required String address,
    required String contact,
    required String altContact,
    required String personName,
    required List<int> subProducts,
    required List<Map<String, dynamic>> productDetails,
    required List<File> photos,
    String? instructions,
    String? landmark,
    required String userUpiId,
  }) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/selling_details/sell_create/"),
      );

      request.fields['user_id'] = userId.toString();
      request.fields['date'] = date;
      request.fields['time_slot'] = timeSlotId.toString();   // <-- CHANGE HERE
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['address'] = address;
      request.fields['contact'] = contact;
      request.fields['user_upi_id'] = userUpiId.toString();
      request.fields['alt_contact'] = altContact;
      request.fields['available_person_name'] = personName;
      request.fields['assigned_bhangarwala'] = '';

      request.fields['sub_products'] = jsonEncode(subProducts);
      request.fields['productDetails'] = jsonEncode(productDetails);

      if (instructions != null && instructions.isNotEmpty) {
        request.fields['special_instructions'] = instructions;
      }

      if (landmark != null && landmark.isNotEmpty) {
        request.fields['landmark'] = landmark;
      }

      for (var image in photos) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photos',
            image.path,
            filename:
            "scrap_${DateTime.now().millisecondsSinceEpoch}_${photos.indexOf(image)}.jpg",
          ),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      return jsonDecode(responseData);
    } catch (e) {
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }



  static Future<List<Map<String, dynamic>>> fetchTimeSlotsPost() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/selling_details/retrive_timeslots/"),
        headers: {
          "Content-Type": "application/json",
          // "Authorization": "Bearer <token>", // uncomment if auth is required
        },
        body: jsonEncode({}), // send empty body if API does not require params
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData["status"] == "success" && jsonData["data"] != null) {
          final List<dynamic> data = jsonData["data"];
          // Convert List<dynamic> to List<Map<String, dynamic>>
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception(jsonData["message"] ?? "Failed to load time slots");
        }
      } else {
        throw Exception(
            "Failed to load time slots, status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching time slots: $e");
      throw Exception("Error fetching time slots: $e");
    }
  }



  // Save login data to shared preferences
  static Future<void> _saveLoginData(Map<String, dynamic> responseData) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('user_email', responseData['data']['email']);
  await prefs.setString('user_id', responseData['data']['user_id'].toString());
  await prefs.setString('login_method', 'email_otp');
  await prefs.setString('login_time', DateTime.now().toIso8601String());

  // Clear the temporary email
  await prefs.remove('email_for_verification');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> saveLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language_code', code);
  }

  static Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_language_code');
  }

  static Future<void> saveLanguageFlag(String flag) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language_flag', flag);
  }

  static Future<String?> getLanguageFlag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_language_flag');
  }
  // Get user email
  static Future<String?> getUserEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_email');
  }

  static Future<String?> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId=prefs.getString('user_id');
    return userId;
  }


  // Logout
  static Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  }

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
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
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

  Future<CalculationResponse> calculatePrice(List<CalculationRequest> requests) async {
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

  static Future<Map<String, dynamic>> createShareContent({
    String title = "Download our Recycling App",
    String message = "Join us in making the environment better.",
    String link = "https://play.google.com/store/",
  }) async {
    final url = Uri.parse("${baseUrl}share_us/share_us_create/");

    final body = jsonEncode({
      "title": title,
      "message": message,
      "link": link,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Failed: Status ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Something went wrong: $e",
      };
    }
  }
// Add to ApiService class in api_service.dart

  }


