import 'package:flutter/material.dart';

class PaymentViewModel extends ChangeNotifier {

  void onRecordPaymentPressed(BuildContext context) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Record Payment Clicked',
        ),
      ),
    );
  }
}