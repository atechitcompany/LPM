class PaymentMaterialModel {

  final int srNo;

  final String material;

  final String materialName;

  final double rate;

  final String quantityOrSize;

  final double amount;

  PaymentMaterialModel({

    required this.srNo,

    required this.material,

    required this.materialName,

    required this.rate,

    required this.quantityOrSize,

    required this.amount,
  });
}