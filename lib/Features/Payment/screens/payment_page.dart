import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/payment_viewmodel.dart';
import '../widgets/record_payment_button.dart';
import 'record_payment_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  final PaymentViewModel _viewModel =
  PaymentViewModel();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: const Center(
        child: Text(
          'Payment Page',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButton: RecordPaymentButton(

        onTap: () {
          context.push('/record-payment');
        },
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
    );
  }
}