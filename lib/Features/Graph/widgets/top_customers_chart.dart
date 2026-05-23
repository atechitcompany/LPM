import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TopCustomersChart extends StatelessWidget {

  final Map<String, int> customerData;

  const TopCustomersChart({
    super.key,
    required this.customerData,
  });

  @override
  Widget build(BuildContext context) {

    if (customerData.isEmpty) {
      return const Center(
        child: Text(
          "No customer analytics found",
        ),
      );
    }

    /// SORT DESCENDING
    final customers =
    customerData.entries.toList()
      ..sort(
            (a, b) =>
            b.value.compareTo(a.value),
      );

    /// TAKE TOP 10
    final topCustomers =
    customers.take(10).toList();

    double maxX = 0;

    for (final e in topCustomers) {
      if (e.value > maxX) {
        maxX = e.value.toDouble();
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const Text(
            "Top Customers",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 420,

            child: BarChart(

              BarChartData(

                alignment:
                BarChartAlignment.spaceAround,

                maxY: maxX + 10,

                gridData: FlGridData(
                  show: true,
                ),

                borderData: FlBorderData(
                  show: false,
                ),

                barTouchData:
                BarTouchData(enabled: true),

                titlesData: FlTitlesData(

                  topTitles: AxisTitles(
                    sideTitles:
                    SideTitles(showTitles: false),
                  ),

                  rightTitles: AxisTitles(
                    sideTitles:
                    SideTitles(showTitles: false),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(

                      showTitles: true,
                      reservedSize: 60,

                      getTitlesWidget:
                          (value, meta) {

                        final index =
                        value.toInt();

                        if (index >= topCustomers.length) {
                          return const SizedBox();
                        }

                        final customer =
                            topCustomers[index].key;

                        String shortName = customer;

                        if (customer.length > 12) {
                          shortName =
                          "${customer.substring(0, 12)}...";
                        }

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            top: 8,
                          ),

                          child: RotatedBox(
                            quarterTurns: 1,

                            child: Text(
                              shortName,

                              style:
                              const TextStyle(
                                fontSize: 10,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                barGroups:
                topCustomers.asMap().entries.map((e) {

                  final index = e.key;

                  final customer = e.value;

                  return BarChartGroupData(

                    x: index,

                    barRods: [

                      BarChartRodData(

                        toY:
                        customer.value.toDouble(),

                        width: 26,

                        borderRadius:
                        BorderRadius.circular(6),

                        gradient:
                        const LinearGradient(
                          colors: [
                            Colors.green,
                            Colors.lightGreen,
                          ],
                          begin:
                          Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

              swapAnimationDuration:
              const Duration(milliseconds: 700),

              swapAnimationCurve:
              Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}