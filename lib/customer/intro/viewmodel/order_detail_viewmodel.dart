import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_status.dart';

class OrderDetailViewModel extends ChangeNotifier {
  final Map<String, Map<OrderStatus, bool>> _lpmStepStatus = {};
  final Map<String, bool> _listening = {}; // 👈 prevent duplicate listeners

  Map<OrderStatus, bool> getStepStatus(String lpm) {
    return _lpmStepStatus[lpm] ?? {
      OrderStatus.designing: false,
      OrderStatus.laserCutting: false,
      OrderStatus.autoBending: false,
      OrderStatus.manualBending: false,
      OrderStatus.delivered: false,
    };
  }

  void listenToJob(String lpm) {
    if (_listening[lpm] == true) return;
    _listening[lpm] = true;

    FirebaseFirestore.instance
        .collection('jobs')
        .doc(lpm)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data()!;

      // 👈 each status is inside its own department's data map
      final designerData     = (data['designer']      ?? {})['data'] ?? {};
      final laserData        = (data['laserCutting']  ?? {})['data'] ?? {};
      final autoBendingData  = (data['autoBending']   ?? {})['data'] ?? {};
      final manualBendingData= (data['manualBending'] ?? {})['data'] ?? {};
      final deliveryData     = (data['delivery']      ?? {})['data'] ?? {};



      final designing     = designerData['DesigningStatus']        == 'Done';
      final laserCutting  = laserData['LaserCuttingStatus']        == 'Done';
      final autoBending   = autoBendingData['AutoBendingStatus']   == 'Done';
      final manualBending = manualBendingData['ManualBendingStatus']== 'Done';
      final delivery      = deliveryData['DeliveryStatus']         == 'Done';

      _lpmStepStatus[lpm] = {
        OrderStatus.designing:     designing,
        OrderStatus.laserCutting:  laserCutting,
        OrderStatus.autoBending:   autoBending,
        OrderStatus.manualBending: manualBending,
        OrderStatus.delivered:     delivery,
      };

      notifyListeners();
    });
  }

  void updateFromStatus(String lpm, String status) {
    final normalized = status.toLowerCase().trim();
    switch (normalized) {
      case 'designing':
      case 'inprogress':
        _lpmStepStatus[lpm] = {
          OrderStatus.designing: true,
          OrderStatus.laserCutting: false,
          OrderStatus.autoBending: false,
          OrderStatus.manualBending: false,
          OrderStatus.delivered: false,
        };
        break;
      case 'laser cutting':
      case 'laser':
        _lpmStepStatus[lpm] = {
          OrderStatus.designing: true,
          OrderStatus.laserCutting: true,
          OrderStatus.autoBending: false,
          OrderStatus.manualBending: false,
          OrderStatus.delivered: false,
        };
        break;
      case 'auto bending':
      case 'auto':
        _lpmStepStatus[lpm] = {
          OrderStatus.designing: true,
          OrderStatus.laserCutting: true,
          OrderStatus.autoBending: true,
          OrderStatus.manualBending: false,
          OrderStatus.delivered: false,
        };
        break;
      case 'manual bending':
      case 'manual':
        _lpmStepStatus[lpm] = {
          OrderStatus.designing: true,
          OrderStatus.laserCutting: true,
          OrderStatus.autoBending: true,
          OrderStatus.manualBending: true,
          OrderStatus.delivered: false,
        };
        break;
      case 'delivery':
      case 'delivered':
        _lpmStepStatus[lpm] = {
          OrderStatus.designing: true,
          OrderStatus.laserCutting: true,
          OrderStatus.autoBending: true,
          OrderStatus.manualBending: true,
          OrderStatus.delivered: true,
        };
        break;
    }
    notifyListeners();
  }
}