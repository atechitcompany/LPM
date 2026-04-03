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

      case "LaserCutting":
        return _laser();

      case "Rubber":
        return _rubber();

      case "Emboss":
        return _emboss();

      case "Account":
        return _account();

      case "Delivery":
        return _delivery();

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

    // 🟢 NEW PARALLEL ROUTING TOGGLES 🟢
    "ReqAutoBending": "edit",
    "ReqManualBending": "edit",
    "ReqLaserCutting": "edit",
    "ReqRubber": "edit",
    "ReqEmboss": "edit",
    "ReqAccount": "edit",
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
  };

  static Map<String, String> _manualBending() => {
    "PartyName": "view",
    "LpmAutoIncrement": "view",
    "ParticularJobName": "view",

    // ✏️ Manual bending editable
    "ManualBendingStatus" : "edit",
    "ManualBendingCreatedBy": "edit",
  };

  static Map<String, String> _laser() => {
    // 👀 View fields
    "ParticularJobName": "view",
    "LpmAutoIncrement": "view",
    "PlyType": "view",
    "PlySelectedBy": "view",

    // ✏️ Editable
    "LaserCuttingStatus": "edit",
  };

  static Map<String, String> _rubber() => {
    // 👀 View fields
    "PartyName": "view",
    "ParticularJobName": "view",
    "LpmAutoIncrement": "view",

    // ✏️ Editable
    "RubberStatus": "edit",
    "RubberCreatedBy": "edit",
  };

  static Map<String, String> _emboss() => {
    "PartyName": "view",
    "ParticularJobName": "view",
    "LpmAutoIncrement": "view",
    "DesigningStatus": "view",
    "DrawingAttachment": "view",
    "HoleType": "view",

    "EmbossStatus": "edit",
    "EmbossPcs": "edit",
    "MaleEmbossType": "edit",
    "X": "edit",
    "Y": "edit",
    "FemaleEmbossType": "edit",
  };

  static Map<String, String> _account() => {
    // ===== VIEW ONLY (from Designer) =====
    "PartyName": "view",
    "ParticularJobName": "view",
    "LpmAutoIncrement": "view",
    "Priority": "view",
    "DesigningStatus": "view",
    "DesignerCreatedBy": "view",

    // ===== PAGE 1 =====
    "AccountsCreatedBy": "edit",
    "BuyerOrderNo": "edit",
    "OrderBy": "edit",
    "DeliveryAt": "edit",
    "Remark": "edit",

    // ===== PAGE 2 =====
    "Size2": "edit",
    "Size3": "edit",
    "Size4": "edit",
    "Size5": "edit",
    "Ups_32": "edit",

    // ===== PAGE 3 =====
    "LaserPunchNew": "edit",
    "PlyLength": "edit",
    "PlyBreadth": "edit",
    "BladeSize": "edit",
    "CreasingSize": "edit",
    "MinimumChargeApply": "edit",

    // ===== PAGE 4 =====
    "DeliveryCreatedBy": "edit",
    "DeliveryStatus": "edit",
    "DeliveryURL": "edit",
    "TransportName": "edit",

    // ===== PAGE 5 =====
    "CapsuleRate": "edit",
    "CapsulePcs": "edit",
    "PerforationSize": "edit",
    "ZigZagBladeSize": "edit",
    "RubberSize": "edit",
    "HoleType": "edit",
    "CourierCharges": "edit",

    // ===== PAGE 6 =====
    "TotalSize": "edit",
    "MaleRate": "edit",
    "FemaleRate": "edit",
    "InvoiceStatus": "edit",
    "AccountStatus": "edit",
    "InvoicePrintedBy": "edit",
    "ParticularSlider": "edit",
  };

  static Map<String, String> _delivery() => {
    // ===== VIEW FIELDS (From previous departments) =====
    "PartyName": "view",
    "ParticularJobName": "view",
    "LpmAutoIncrement": "view",
    "DeliveryAt": "view",
    "Remark": "view",
    "AutoBendingCreatedBy": "view",
    "LaserCuttingCreatedBy": "view",
    "AccountsCreatedBy": "view",

    // ===== EDIT FIELDS (For the Delivery team) =====
    "DeliveryStatus": "edit",
    "AddressOutput": "edit",
    "DrawingAttachment": "edit",
    "JobDone": "edit",
  };
}