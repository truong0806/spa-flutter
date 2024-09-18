import 'dart:convert';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class MOMOFlutter {
  static final MOMOFlutter _instance = MOMOFlutter();
  static MOMOFlutter get instance => _instance;
  Map<String, dynamic> _sortParams(Map<String, dynamic> params) {
    final sortedParams = <String, dynamic>{};
    final keys = params.keys.toList()..sort();
    for (String key in keys) {
      sortedParams[key] = params[key];
    }
    return sortedParams;
  }

  Future<String>  generatePaymentUrl({
    required num bookingId,
    required num customerId,
    required num discount,
    required String txnRef,
    required double amount,
  }) async  {
     var requestBody = {
      "payment_method": "momo",
      "booking_id": bookingId,
      "customer_id": customerId,
      "discount": discount,
      "payment_type": "momo",
      "total_amount": amount,
      "is_mobile": 1,
      "type": "advance_payment",
      "datetime": DateTime.now().toIso8601String(),
      "payment_status": "failed",
      "currency_code": "VND",
    };

     final response = await createMomoPayment(requestBody);

    if (response.isNotEmpty) {
      print("responseData::: $response");
      return response['url'] ?? 'Error: No payment URL returned';
    } else {
      return 'Error: Failed to get payment URL';
    }
  }

}

