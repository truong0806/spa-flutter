import 'dart:convert';

import 'package:booking_system_flutter/services/vnpay/src/web_view_page.dart';
import 'package:nb_utils/nb_utils.dart';
import './vnpay/vnpay_flutter.dart';
import '../../main.dart';
import '../model/payment_gateway_response.dart';
import 'package:flutter/material.dart';

class VnpayServiceNew {
  late PaymentSetting paymentSetting;
  double totalAmount = 0;
  num bookingId = 0;
  num discount = 0;
  String type = "";
  late Function(Map<String, dynamic>) onComplete;

  VnpayServiceNew({
    required PaymentSetting paymentSetting,
    required double totalAmount,
    num discount  = 0,
    type = "",
    required bookingId,
    required Function(Map<String, dynamic>) onComplete,
  }) {
    this.paymentSetting = paymentSetting;
    this.totalAmount = totalAmount;
    this.discount = discount;
    this.type = type;
    this.bookingId = bookingId;
    this.onComplete = onComplete;
  }

  Future<void> vnpayPay(BuildContext context) async {
  String vnpayPaymentKey = '';
  String vnpayURL = '';
  String vnpayPaymentPublishKey = '';
  String vnp_OrderInfo = '';
  
  if (paymentSetting.isTest == 1) {
    vnpayPaymentKey = paymentSetting.testValue!.vnpayKey.validate();
    vnpayURL = paymentSetting.testValue!.vnpayUrl.validate();
    vnpayPaymentPublishKey = paymentSetting.testValue!.vnpayPublickey.validate();
  } else {
    vnpayPaymentKey = paymentSetting.liveValue!.vnpayKey!;
    vnpayURL = paymentSetting.liveValue!.vnpayUrl!;
    vnpayPaymentPublishKey = paymentSetting.liveValue!.vnpayPublickey!;
  }
  
  if (vnpayPaymentKey.isEmpty || vnpayURL.isEmpty || vnpayPaymentPublishKey.isEmpty) {
    throw Exception('Payment configuration is incomplete. Contact your admin.');
  }
  
  vnp_OrderInfo = 'Thanh toan don hang ${bookingId} ${appStore.userFullName} ${totalAmount} ${discount} ${type}';
  
  num customerId = appStore.userId;
  
  try {
    final paymentUrl = await VNPAYFlutter.instance.generatePaymentUrl(
      bookingId: bookingId,
      customerId: customerId,
      discount: discount,
      txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: totalAmount,
    );

    log('Payment URL: $paymentUrl');

    if (paymentUrl.isNotEmpty) {
      final result = await  Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(url: paymentUrl),
        ),
      );
      print("result::: $result");
      if (result is Map<String, String>) {
      final transactionStatus = result['transactionStatus'] ?? 'unknown';
      final transactionId = result['transactionId'] ?? 'unknown';

      onComplete.call({
        'transaction_status': transactionStatus,
        'transaction_id': transactionId,
      });
      } else {
        // Handle unexpected result type
        onComplete.call({
          'transaction_status': 'unknown',
          'transaction_status_text': 'unknown',
          'transaction_id': 'unknown',
        });
      }
    } else {
      throw Exception('Failed to generate a valid payment URL.');
    }
  } catch (e) {
    log('Error generating payment URL: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to generate payment URL. Please try again.')),
    );
  }
}

  
}
