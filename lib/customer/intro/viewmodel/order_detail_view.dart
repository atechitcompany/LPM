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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF6F7F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClientHeaderCard(),
            const SizedBox(height: 16),

            OrderStatusCard(currentStatus: currentStatus),
            const SizedBox(height: 16),

            const RatingCard(),
            const SizedBox(height: 16),

            const DeliveryDetailsCard(),
            const SizedBox(height: 16),

            const PriceDetailsCard(),
          ],
        ),
      ),
    );
  }
}
