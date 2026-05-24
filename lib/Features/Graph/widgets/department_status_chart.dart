import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DepartmentStatusChart extends StatelessWidget {

  final Map<String, int> departmentData;

  const DepartmentStatusChart({
    super.key,
    required this.departmentData,
  });

  @override
  Widget build(BuildContext context) {

    if (departmentData.isEmpty) {

      return Container(
        height: 220,
        alignment: Alignment.center,

        child: const Text(
          "No department analytics found",
        ),
      );
    }

    final departments =
    departmentData.entries.toList();

    double maxY = 0;

    for (final e in departments) {

      if (e.value > maxY) {
        maxY = e.value.toDouble();
      }
    }

    final colors = [

      Colors.orange,

      Colors.blue,

      Colors.green,

      Colors.purple,

      Colors.red,
    ];

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

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
            "Department Workflow",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 320,

            child: BarChart(

              BarChartData(

                alignment:
                BarChartAlignment.spaceAround,

                maxY: maxY + 10,

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

                      reservedSize: 50,

                      getTitlesWidget:
                          (value, meta) {

                        final index =
                        value.toInt();

                        if (index >= departments.length) {
                          return const SizedBox();
                        }

                        final department =
                            departments[index].key;

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            top: 8,
                          ),

                          child: Text(
                            department,

                            textAlign:
                            TextAlign.center,

                            style:
                            const TextStyle(
                              fontSize: 10,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                barGroups:
                departments.asMap().entries.map((e) {

                  final index = e.key;

                  final department = e.value;

                  return BarChartGroupData(

                    x: index,

                    barRods: [

                      BarChartRodData(

                        toY:
                        department.value.toDouble(),

                        width: 28,

                        borderRadius:
                        BorderRadius.circular(8),

                        gradient:
                        LinearGradient(

                          colors: [

                            colors[index %
                                colors.length],

                            colors[index %
                                colors.length]
                                .withOpacity(0.5),
                          ],

                          begin:
                          Alignment.bottomCenter,

                          end:
                          Alignment.topCenter,
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

          const SizedBox(height: 18),

          Wrap(
            spacing: 14,
            runSpacing: 12,

            children:
            departments.asMap().entries.map((e) {

              final index = e.key;

              final department = e.value;

              return Row(
                mainAxisSize: MainAxisSize.min,

                children: [

                  Container(
                    width: 14,
                    height: 14,

                    decoration: BoxDecoration(
                      color:
                      colors[index %
                          colors.length],

                      borderRadius:
                      BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(width: 6),

                  Text(
                    "${department.key} (${department.value})",

                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}