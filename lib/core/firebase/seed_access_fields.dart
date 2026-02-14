import 'package:cloud_firestore/cloud_firestore.dart';

class AccessFieldSeeder {

  static Future<void> uploadDesignerFields() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    Map<String, dynamic> designerFields = {
      "PartyName": "edit",
      "DesignerCreatedBy": "edit",
      "DeliveryAt": "edit",
      "Orderby": "edit",
      "ParticularJobName": "edit",
      "LpmAutoIncrement": "edit",
      "Priority": "edit",
      "Remark": "edit",
      "DrawingAttachment": "edit",
      "RubberReport": "edit",
      "PunchReport": "edit",
      "PlyType": "edit",
      "PlySelectedBy": "view",
      "Blade": "edit",
      "BladeSelectedBy": "view",
      "Creasing": "edit",
      "CreasingSelectedBy": "view",
      "MicroSerrationHalfCut": "edit",
      "MicroSerrationCreasing": "edit",
      "Unknown": "edit",
      "CapsuleType": "edit",
      "Perforation": "edit",
      "PerforationSelectedBy": "view",
      "ZigZagBlade": "edit",
      "ZigZagBladeSelectedBy": "view",
      "RubberType": "edit",
      "RubberSelectedBy": "view",
      "HoleType": "edit",
      "HoleSelectedBy": "view",
      "EmbossStatus": "edit",
      "EmbossPcs": "edit",
      "MaleEmbossType": "edit",
      "X": "edit",
      "Y": "edit",
      "FemaleEmbossType": "edit",
      "X2": "edit",
      "Y2": "edit",
      "StrippingType": "edit",
      "LaserCuttingStatus": "edit",
      "RubberFixingDone": "edit",
      "WhiteProfileRubber": "edit",
      "DesigningStatus": "edit",
      "submitButton": "edit"
    };

    // ✅ Changed collection name here
    await firestore.collection("roles").doc("Designer").set({
      "fields": designerFields
    });

    print("Designer fields uploaded successfully");
  }
}
