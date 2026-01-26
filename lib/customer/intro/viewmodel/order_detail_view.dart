import 'package:flutter/material.dart';
import '../models/order_status.dart';
import '../widgets/client_header_card.dart';
import '../widgets/order_status_card.dart';
import '../widgets/rating_card.dart';
import '../widgets/delivery_details_card.dart';
import '../widgets/price_details_card.dart';

class OrderDetailScreen extends StatelessWidget {
  OrderDetailScreen({super.key});

  final OrderStatus currentStatus = OrderStatus.autoBending;
  final Map<OrderStatus, bool> stepStatus = {
    OrderStatus.designing: true,
    OrderStatus.laserCutting: true,
    OrderStatus.autoBending: true, // 👈 CURRENT
    OrderStatus.manualBending: false,
    OrderStatus.delivered: false,
  };




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Client Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 1024;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 900 : double.infinity, // 👈 web width only
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24 : 20, // 👈 web spacing only
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    ClientHeaderCard(),
                    const SizedBox(height: 16),

                    OrderStatusCard(
                      stepStatus: stepStatus,
                    ),


                    const SizedBox(height: 16),

                    const RatingCard(),
                    const SizedBox(height: 16),


          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 900 : double.infinity, // 👈 web width only
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24 : 20, // 👈 web spacing only
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    ClientHeaderCard(),
                    const SizedBox(height: 16),

                    OrderStatusCard(currentStatus: currentStatus),
                    const SizedBox(height: 16),

                    const RatingCard(),
                    const SizedBox(height: 16),

                    const DeliveryDetailsCard(),
                    const SizedBox(height: 20),

                    const PriceDetailsCard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),

    );

  }
}
