import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:lightatech/Production/JobCreation/screens/forms/new_form_scope.dart';

import 'account_pages/account_page_1_basic.dart';
import 'account_pages/account_page_2_sizes.dart';
import 'account_pages/account_page_3_ply.dart';
import 'account_pages/account_page_4_delivery.dart';
import 'account_pages/account_page_5_charges.dart';
import 'account_pages/account_page_6_review.dart';

class AccountFormFlow extends StatefulWidget {
  const AccountFormFlow({super.key});

  @override
  State<AccountFormFlow> createState() => _AccountFormFlowState();
}

class _AccountFormFlowState extends State<AccountFormFlow> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final int totalPages = 6;

  bool loading = true;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final form = NewFormScope.of(context);
    final lpm = form.LpmAutoIncrement.text;

    if (lpm.isEmpty) {
      setState(() => loading = false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection("jobs")
          .doc(lpm)
          .get();

      if (!snap.exists) {
        setState(() => loading = false);
        return;
      }

      final data = snap.data()!;

      // ── Designer data (read-only) ──
      final designer = Map<String, dynamic>.from(
        data["designer"]?["data"] ?? {},
      );

      // ── Account data (editable) ──
      final account = Map<String, dynamic>.from(
        data["account"]?["data"] ?? {},
      );

      // Read-only from designer
      form.PartyName.text = designer["PartyName"] ?? "";
      form.ParticularJobName.text = designer["ParticularJobName"] ?? "";
      form.LpmAutoIncrement.text = lpm;
      form.DesigningStatus.text = designer["DesigningStatus"] ?? "";
      form.DesignerCreatedBy.text = designer["DesignerCreatedBy"] ?? "";

      // Editable account fields
      form.AccountsCreatedBy.text = account["AccountsCreatedBy"] ?? "";
      form.BuyerOrderNo.text = account["BuyerOrderNo"] ?? "";
      form.Ups.text = account["Ups"] ?? "NO";
      form.Size.text = account["Size"] ?? "NO";
      form.Size2.text = account["Size2"] ?? "NO";
      form.Size3.text = account["Size3"] ?? "NO";
      form.Size4.text = account["Size4"] ?? "NO";
      form.Size5.text = account["Size5"] ?? "NO";
      form.Ups_32.text = account["Ups_32"] ?? "";
      form.LaserPunchNew.text = account["LaserPunchNew"] ?? "No";
      form.PlyLength.text = account["PlyLength"] ?? "";
      form.PlyBreadth.text = account["PlyBreadth"] ?? "";
      form.BladeSize.text = account["BladeSize"] ?? "";
      form.CreasingSize.text = account["CreasingSize"] ?? "";
      form.MinimumChargeApply.text = account["MinimumChargeApply"] ?? "";
      form.DeliveryStatus.text = account["DeliveryStatus"] ?? "Pending";
      form.DeliveryURL.text = account["DeliveryURL"] ?? "";
      form.TransportName.text = account["TransportName"] ?? "";
      form.CapsuleRate.text = account["CapsuleRate"] ?? "";
      form.CapsulePcs.text = account["CapsulePcs"] ?? "";
      form.PerforationSize.text = account["PerforationSize"] ?? "";
      form.ZigZagBladeSize.text = account["ZigZagBladeSize"] ?? "";
      form.RubberSize.text = account["RubberSize"] ?? "";
      form.CourierCharges.text = account["CourierCharges"] ?? "";
      form.TotalSize.text = account["TotalSize"] ?? "";
      form.MaleRate.text = account["MaleRate"] ?? "";
      form.FemaleRate.text = account["FemaleRate"] ?? "";
      form.InvoiceStatus.text = account["InvoiceStatus"] ?? "No";
      form.InvoicePrintedBy.text = account["InvoicePrintedBy"] ?? "";
      form.Unknown.text = account["Unknown"] ?? "";
      form.Extra.text = account["Extra"] ?? "";

      debugPrint("✅ AccountFormFlow loaded data from Firestore");
    } catch (e) {
      debugPrint("❌ Error loading account data: $e");
    }

    setState(() => loading = false);
  }

  Future<void> _saveAndSubmit() async {
    final form = NewFormScope.of(context);
    final lpm = form.LpmAutoIncrement.text.trim();

    if (lpm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("LPM is empty, cannot save")),
      );
      return;
    }

    try {
      final isDone =
          form.InvoiceStatus.text.trim().toLowerCase() == "yes" ||
              form.InvoiceStatus.text.trim().toLowerCase() == "done";

      final accountData = {
        "AccountsCreatedBy": form.AccountsCreatedBy.text,
        "BuyerOrderNo": form.BuyerOrderNo.text,
        "Ups": form.Ups.text,
        "Size": form.Size.text,
        "Size2": form.Size2.text,
        "Size3": form.Size3.text,
        "Size4": form.Size4.text,
        "Size5": form.Size5.text,
        "Ups_32": form.Ups_32.text,
        "LaserPunchNew": form.LaserPunchNew.text,
        "PlyLength": form.PlyLength.text,
        "PlyBreadth": form.PlyBreadth.text,
        "BladeSize": form.BladeSize.text,
        "CreasingSize": form.CreasingSize.text,
        "MinimumChargeApply": form.MinimumChargeApply.text,
        "DeliveryStatus": form.DeliveryStatus.text,
        "DeliveryURL": form.DeliveryURL.text,
        "TransportName": form.TransportName.text,
        "CapsuleRate": form.CapsuleRate.text,
        "CapsulePcs": form.CapsulePcs.text,
        "PerforationSize": form.PerforationSize.text,
        "ZigZagBladeSize": form.ZigZagBladeSize.text,
        "RubberSize": form.RubberSize.text,
        "CourierCharges": form.CourierCharges.text,
        "TotalSize": form.TotalSize.text,
        "MaleRate": form.MaleRate.text,
        "FemaleRate": form.FemaleRate.text,
        "InvoiceStatus": form.InvoiceStatus.text,
        "InvoicePrintedBy": form.InvoicePrintedBy.text,
        "Unknown": form.Unknown.text,
        "Extra": form.Extra.text,
      };

      final updateData = {
        "account": {
          "submitted": true,
          "data": accountData,
        },
        "currentDepartment": isDone ? "Delivery" : "Account",
        "updatedAt": FieldValue.serverTimestamp(),
      };

      if (isDone) {
        updateData["visibleTo"] = FieldValue.arrayUnion(["Delivery"]);
      }

      await FirebaseFirestore.instance
          .collection("jobs")
          .doc(lpm)
          .set(updateData, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Form submitted successfully")),
      );

      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Account Form (${_currentPage + 1}/$totalPages)"),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: const [
                AccountPage1Basic(),
                AccountPage2Sizes(),
                AccountPage3Ply(),
                AccountPage4Delivery(),
                AccountPage5Charges(),
                AccountPage6Review(),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [

                // BACK BUTTON
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (_currentPage == 0) {
                        context.go('/dashboard');
                      } else {
                        _controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: const Text("Back"),
                  ),
                ),

                const SizedBox(width: 12),

                // NEXT / SUBMIT BUTTON
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == totalPages - 1) {
                        _saveAndSubmit();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      _currentPage == totalPages - 1 ? "Submit" : "Next",
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}