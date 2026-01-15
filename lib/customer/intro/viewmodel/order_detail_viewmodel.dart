import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderDetailViewModel extends ChangeNotifier {
  final OrderModel order = OrderModel(
    clientName: "Client Name",
    description: "Desc 1",
    orderId: "12345675082651",
    currentStep: 4,
    listingPrice: 650,
    sellingPrice: 500,
    discount: 20,
    fees: 5,
  );

  int rating = 0;

  void setRating(int value) {
    rating = value;
    notifyListeners();
  }
}
