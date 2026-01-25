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
    "Blade": "edit",
  };
}
