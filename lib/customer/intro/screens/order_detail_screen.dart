import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/order_detail_viewmodel.dart';
import '../widgets/order_status_stepper.dart';
import '../widgets/rating_widget.dart';
import '../widgets/delivery_details_card.dart';
import '../widgets/price_details_card.dart';
import '../widgets/client_header_card.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderDetailViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Client Details")),
        body: Consumer<OrderDetailViewModel>(
          builder: (_, vm, __) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClientHeaderCard(
                    clientName: 'Client Name',
                    description: 'Desc 1',

                  ),
                  Text("Order ID: ${vm.order.orderId}"),
                  const SizedBox(height: 12),


                  OrderStatusTimeline(currentStep: 4),


                  ProductRatingWidget(
                    rating: vm.rating,
                    onRated: vm.setRating,
                  ),
                  const SizedBox(height: 12),
                  const Text("Delivery Details"),
                  const DeliveryDetailsCard(),

                  const SizedBox(height: 12),
                  const Text("Price Details"),
                  PriceDetailsCard(),

                  const SizedBox(height: 12),

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
