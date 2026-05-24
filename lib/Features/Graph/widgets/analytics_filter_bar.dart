import 'package:flutter/material.dart';

class AnalyticsFilterBar extends StatelessWidget {

  final String selectedGraph;

  final List<String> graphTypes;

  final ValueChanged<String?> onGraphChanged;

  const AnalyticsFilterBar({
    super.key,
    required this.selectedGraph,
    required this.graphTypes,
    required this.onGraphChanged,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

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
            "Analytics Filters",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(

            value: selectedGraph,

            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(14),

                borderSide: BorderSide.none,
              ),
            ),

            items: graphTypes.map((graph) {

              return DropdownMenuItem(
                value: graph,
                child: Text(graph),
              );
            }).toList(),

            onChanged: onGraphChanged,
          ),
        ],
      ),
    );
  }
}