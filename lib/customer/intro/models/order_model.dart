class OrderModel {
  final String clientName;
  final String description;
  final String orderId;
  final int currentStep;
  final double listingPrice;
  final double sellingPrice;
  final double discount;
  final double fees;

  OrderModel({
    required this.clientName,
    required this.description,
    required this.orderId,
    required this.currentStep,
    required this.listingPrice,
    required this.sellingPrice,
    required this.discount,
    required this.fees,
  });

  double get total =>
      sellingPrice - discount + fees;
}
