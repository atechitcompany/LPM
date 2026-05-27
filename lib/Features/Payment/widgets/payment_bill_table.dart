import 'package:flutter/material.dart';

import '../models/payment_material_model.dart';

class PaymentBillTable extends StatelessWidget {

  final List<PaymentMaterialModel>
  materials;

  const PaymentBillTable({
    super.key,
    required this.materials,
  });

  @override
  Widget build(BuildContext context) {

    if (materials.isEmpty) {

      return Container(
        padding: const EdgeInsets.all(20),

        alignment: Alignment.center,

        child: const Text(
          "No bill materials found",
        ),
      );
    }

    double totalAmount = 0;

    for (final item in materials) {
      totalAmount += item.amount;
    }

    return Container(

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),

      child: Column(
        children: [

          /// =========================
          /// TABLE
          /// =========================

          SingleChildScrollView(

            scrollDirection: Axis.horizontal,

            child: DataTable(

              headingRowColor:
              MaterialStateProperty.all(
                Colors.grey.shade200,
              ),

              columnSpacing: 24,

              columns: const [

                DataColumn(
                  label: Text(
                    "Sr. No.",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                DataColumn(
                  label: Text(
                    "Material",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                DataColumn(
                  label: Text(
                    "Material Name",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                DataColumn(
                  label: Text(
                    "Rate",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                DataColumn(
                  label: Text(
                    "Qty / Size",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                DataColumn(
                  label: Text(
                    "Amount",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ],

              rows:
              materials.map((item) {

                return DataRow(

                  cells: [

                    DataCell(
                      Text(
                        item.srNo.toString(),
                      ),
                    ),

                    DataCell(
                      Text(
                        item.material,
                      ),
                    ),

                    DataCell(
                      SizedBox(
                        width: 220,

                        child: Text(
                          item.materialName,
                        ),
                      ),
                    ),

                    DataCell(
                      Text(
                        "₹ ${item.rate.toStringAsFixed(2)}",
                      ),
                    ),

                    DataCell(
                      Text(
                        item.quantityOrSize,
                      ),
                    ),

                    DataCell(
                      Text(
                        "₹ ${item.amount.toStringAsFixed(2)}",
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          /// =========================
          /// TOTAL SECTION
          /// =========================

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.grey.shade100,

              borderRadius:
              const BorderRadius.only(

                bottomLeft:
                Radius.circular(18),

                bottomRight:
                Radius.circular(18),
              ),
            ),

            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.end,

              children: [

                const Text(
                  "Grand Total : ",

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                Text(
                  "₹ ${totalAmount.toStringAsFixed(2)}",

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,

                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}