import 'package:flutter/material.dart';

class DepartmentFieldAccess {
  static Map<String, String> access(String department) {
    switch (department) {
      case "Designer":
        return _designer();

      case "AutoBending":
        return _autoBending();

      case "ManualBending":
        return _manualBending();

      default:
        return {};
    }
  }

  static Map<String, String> _designer() => {
    // ===== PAGE 1 =====
    "PartyName": "edit",
    "DesignerCreatedBy": "edit",
    "DeliveryAt": "edit",
    "Orderby": "edit",
    "ParticularJobName": "edit",
    "LpmAutoIncrement": "edit",

    // ===== PAGE 2 =====
    "Priority": "edit",
    "Remark": "edit",
    "DesigningStatus": "edit",
    "DrawingAttachment": "edit",
    "RubberReport": "edit",
    "PunchReport": "edit",
    "PlyType": "edit",
    "PlySelectedBy": "edit",

    // ===== PAGE 3 =====
    "Blade": "edit",
    "BladeSelectedBy": "edit",
    "Creasing": "edit",
    "CreasingSelectedBy": "edit",
    "MicroSerrationHalfCut": "edit",
    "MicroSerrationCreasing": "edit",
    "Unknown": "edit",
    "CapsuleType": "edit",

    // ===== PAGE 4 =====
    "Perforation": "edit",
    "PerforationSelectedBy": "edit",
    "ZigZagBlade": "edit",
    "ZigZagBladeSelectedBy": "edit",
    "RubberType": "edit",
    "RubberSelectedBy": "edit",
    "HoleType": "edit",
    "HoleSelectedBy": "edit",
    "EmbossStatus": "edit",
    "EmbossPcs": "edit",

    // ===== PAGE 5 =====
    "MaleEmbossType": "edit",
    "X": "edit",
    "Y": "edit",
    "FemaleEmbossType": "edit",
    "X2": "edit",
    "Y2": "edit",

    // ===== PAGE 6 =====
    "StrippingType": "edit",
    "LaserCuttingStatus": "edit",
    "RubberFixingDone": "edit",
    "WhiteProfileRubber": "edit",
    "submitButton": "edit",

  };



  static Map<String, String> _autoBending() => {
    // 👀 Designer fields
    "PartyName": "view",
    "DeliveryAt": "view",
    "ParticularJobName": "view",
    "LpmAutoIncrement": "view",
    "Priority": "view",

    // ✏ Autobending fields
    "AutoCreasing": "edit",
    "AutoCreasingStatus": "edit",
    "LaserCuttingStatus": "edit",

    // ❌ hidden
    "AccountsCreatedBy": "hide",
  };

  static Map<String, String> _manualBending() => {
    "PartyName": "view",
    "LpmAutoIncrement": "view",
    "ParticularJobName": "view",

    // ✏️ Manual bending editable
    "ManualBendingCreatedBy": "edit",


    // ❌ Others hidden
    "AutoBendingCreatedBy": "hide",
  };
}
