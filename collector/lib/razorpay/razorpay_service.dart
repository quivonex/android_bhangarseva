import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/api_services.dart';

class RazorpayService {
  late Razorpay _razorpay;
  Function(Map<String, dynamic>)? onSuccess;
  Function(String)? onError;
  String? _currentOrderId;
  String? _currentPlanName;

  void initialize() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<void> openCheckout({
    required String orderId,
    required String keyId,
    required int amount,
    required String planName,
    required String userName,
    required String userEmail,
    required String userContact,
  }) async {
    _currentOrderId = orderId;
    _currentPlanName = planName;

    final options = {
      'key': keyId,
      'amount': amount,
      'name': 'Subscription App',
      'description': planName,
      'order_id': orderId,
      'prefill': {
        'contact': userContact,
        'email': userEmail,
        'name': userName,
      },
      'external': {
        'wallets': ['paytm', 'phonepe', 'gpay'],
      },
      'theme': {
        'color': '#FF6B6B',
        'hide_topbar': false,
      },
      'retry': {
        'enabled': true,
        'max_count': 1,
      },
      'timeout': 300, // 5 minutes
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Razorpay Error: $e');
      onError?.call('Failed to open payment gateway');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment Success: ${response.paymentId}');

    if (_currentOrderId != null && _currentPlanName != null) {
      try {
        // Verify payment with backend
        final result = await ApiService.verifyPaymentPlan(
          _currentOrderId!,
          response.paymentId!,
          response.signature!,
          _currentPlanName!,
        );

        if (onSuccess != null) {
          onSuccess!({
            'payment_id': response.paymentId,
            'order_id': response.orderId,
            'signature': response.signature,
            'verification_result': result,
          });
        }
      } catch (e) {
        print('Verification Error: $e');
        onError?.call('Payment successful but verification failed');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    onError?.call('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }
}