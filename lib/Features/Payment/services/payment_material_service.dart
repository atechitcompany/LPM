import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment_material_model.dart';

class PaymentMaterialService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// ============================
  /// FIELD → COLLECTION MAPPING
  /// ============================

  final Map<String, String> materialCollections = {

    "Blade": "Blades",

    "PlyType": "Plys",

    "RubberType": "Rubbers",

    "Perforation": "Perforations",

    "Creasing": "Creasings",

    "ZigZagBlade": "Zig Zags Blades",

    "HoleType": "Holes",

    "MaleEmbossType": "Males Embosse",

    "FemaleEmbossType": "Females Emobosse",
  };

  /// ============================
  /// FETCH MATERIALS FROM JOB
  /// ============================

  Future<List<PaymentMaterialModel>>
  fetchMaterialsForJob(
      String jobName,
      ) async {

    final List<PaymentMaterialModel>
    materials = [];

    /// FETCH JOB

    final jobSnapshot =
    await _firestore
        .collection("jobs")
        .where(
      "designer.data.particularJobName",
      isEqualTo: jobName,
    )
        .limit(1)
        .get();

    if (jobSnapshot.docs.isEmpty) {
      return [];
    }

    final jobData =
    jobSnapshot.docs.first.data();
    final designerData =
    Map<String, dynamic>.from(
      jobData["designer"]?["data"] ?? {},
    );

    int srNo = 1;

    /// LOOP THROUGH MATERIAL FIELDS

    for (final entry
    in materialCollections.entries) {

      final fieldName = entry.key;

      final collectionName =
          entry.value;

      print("=========== JOB DATA ===========");
      print(designerData);

      print("FIELD NAME => $fieldName");
      print("FIELD VALUE => ${designerData[fieldName]}");

      final materialValue =
      (designerData[fieldName] ?? "")
          .toString()
          .trim();

      /// SKIP EMPTY / NO

      if (materialValue.isEmpty ||
          materialValue == "No") {
        continue;
      }

      /// FETCH RATE

      double rate = 0;

      try {

        final materialSnapshot =
        await _firestore
            .collection(collectionName)
            .where(
          collectionName,
          isEqualTo: materialValue,
        )
            .limit(1)
            .get();

        if (materialSnapshot.docs.isNotEmpty) {

          final materialData =
          materialSnapshot
              .docs
              .first
              .data();

          rate =
              (materialData["rate"] ?? 0)
                  .toDouble();
        }

      } catch (e) {

        print(
            "❌ Error fetching rate: $e");
      }

      /// QUANTITY / SIZE FIELD

      String quantity = "";

      switch (fieldName) {

        case "Blade":
          quantity =
              (designerData["BladeSize"] ?? "")
                  .toString();
          break;

        case "PlyType":
          quantity =
          "${designerData["PlyLength"] ?? ""} x "
              "${designerData["PlyBreadth"] ?? ""}";
          break;

        case "RubberType":
          quantity =
              (designerData["RubberSize"] ?? "")
                  .toString();
          break;

        case "Perforation":
          quantity =
              (designerData["PerforationSize"] ?? "")
                  .toString();
          break;

        case "Creasing":
          quantity =
              (designerData["CreasingSize"] ?? "")
                  .toString();
          break;

        case "ZigZagBlade":
          quantity =
              (designerData["ZigZagBladeSize"] ?? "")
                  .toString();
          break;

        default:
          quantity = "-";
      }

      /// CALCULATE AMOUNT

      double qty = 1;

      try {

        qty = double.parse(
          quantity.isEmpty
              ? "1"
              : quantity,
        );

      } catch (_) {}

      final amount = qty * rate;

      /// ADD BILL ROW

      materials.add(

        PaymentMaterialModel(

          srNo: srNo,

          material: fieldName,

          materialName: materialValue,

          rate: rate,

          quantityOrSize: quantity,

          amount: amount,
        ),
      );

      srNo++;
    }

    print("TOTAL MATERIALS => ${materials.length}");

    return materials;
  }
}