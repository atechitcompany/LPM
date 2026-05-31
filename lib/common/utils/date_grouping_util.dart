import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateGroupingUtil {
  /// Takes a list of Firebase documents and groups them by their creation/modification date.
  static Map<String, List<QueryDocumentSnapshot>> groupDataByDate(
      List<QueryDocumentSnapshot> docs) {
    Map<String, List<QueryDocumentSnapshot>> groupedData = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Attempt to extract the date field gracefully
      Timestamp? timestamp;

      // 1. Check for updatedAt or createdAt at the root
      if (data.containsKey('updatedAt') && data['updatedAt'] is Timestamp) {
        timestamp = data['updatedAt'] as Timestamp;
      } else if (data.containsKey('createdAt') &&
          data['createdAt'] is Timestamp) {
        timestamp = data['createdAt'] as Timestamp;
      }
      // 2. Check if there's a designer map containing submittedAt (for Jobs)
      else if (data['designer'] is Map &&
          data['designer']['submittedAt'] is Timestamp) {
        timestamp = data['designer']['submittedAt'] as Timestamp;
      }

      String dateKey;
      if (timestamp != null) {
        dateKey = DateFormat('dd MMM yyyy').format(timestamp.toDate());
      } else {
        dateKey = 'Unknown Date';
      }

      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = [];
      }
      groupedData[dateKey]!.add(doc);
    }

    return groupedData;
  }
}
