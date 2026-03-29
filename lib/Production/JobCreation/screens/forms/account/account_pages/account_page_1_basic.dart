import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import '../../new_form_scope.dart';

class AccountPage1Basic extends StatefulWidget {
  const AccountPage1Basic({super.key});

  @override
  State<AccountPage1Basic> createState() => _AccountPage1BasicState();
}

class _AccountPage1BasicState extends State<AccountPage1Basic> {
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

    final snap = await FirebaseFirestore.instance
        .collection("jobs")
        .doc(lpm)
        .get();

    if (!snap.exists) {
      setState(() => loading = false);
      return;
    }

    final data = snap.data()!;
    final designer = Map<String, dynamic>.from(data["designer"]?["data"] ?? {});
    final account = Map<String, dynamic>.from(data["account"]?["data"] ?? {});

    // 👀 DESIGNER VIEW DATA
    form.PartyName.text = designer["PartyName"] ?? "";
    form.ParticularJobName.text = designer["ParticularJobName"] ?? "";
    form.LpmAutoIncrement.text = lpm;
    form.Priority.text = designer["Priority"] ?? "";
    form.DesigningStatus.text = designer["DesigningStatus"] ?? "";
    form.DesignerCreatedBy.text = designer["DesignerCreatedBy"] ?? "";

    // ✏ ACCOUNT DATA
    form.AccountsCreatedBy.text = account["AccountsCreatedBy"] ?? "";
    form.BuyerOrderNo.text = account["BuyerOrderNo"] ?? "";
    form.OrderBy.text = account["Orderby"] ?? "";
    form.DeliveryAt.text = account["DeliveryAt"] ?? "";
    form.Remark.text = account["Remark"] ?? "";

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          // ===== VIEW FIELDS =====

          if (form.canView("PartyName"))
            TextInput(
              label: "Party Name",
              controller: form.PartyName,
              readOnly: true,
              hint: "",
            ),

          if (form.canView("ParticularJobName")) ...[
            const SizedBox(height: 16),
            TextInput(
              label: "Particular Job Name",
              controller: form.ParticularJobName,
              readOnly: true,
              hint: "",
            ),
          ],

          if (form.canView("LpmAutoIncrement")) ...[
            const SizedBox(height: 16),
            TextInput(
              label: "LPM Number",
              controller: form.LpmAutoIncrement,
              readOnly: true,
              hint: "",
            ),
          ],

          if (form.canView("Priority")) ...[
            const SizedBox(height: 16),
            TextInput(
              label: "Priority",
              controller: form.Priority,
              readOnly: true,
              hint: "",
            ),
          ],

          if (form.canView("DesigningStatus")) ...[
            const SizedBox(height: 16),
            TextInput(
              label: "Designing",
              controller: form.DesigningStatus,
              readOnly: true,
              hint: "",
            ),
          ],

          if (form.canView("DesignerCreatedBy")) ...[
            const SizedBox(height: 16),
            TextInput(
              label: "Designer Created By",
              controller: form.DesignerCreatedBy,
              readOnly: true,
              hint: "",
            ),
          ],

          const SizedBox(height: 30),

          // ===== EDIT FIELDS =====

          if (form.canView("AccountsCreatedBy")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("AccountsCreatedBy"),
              child: Opacity(
                opacity: form.canEdit("AccountsCreatedBy") ? 1 : 0.6,
                child: SearchableDropdownWithInitial(
                  label: "Accounts Created By",
                  items: form.parties,
                  initialValue: form.AccountsCreatedBy.text.isEmpty
                      ? "Select"
                      : form.AccountsCreatedBy.text,
                  onChanged: (v) {
                    form.AccountsCreatedBy.text = (v ?? "").trim();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (form.canView("BuyerOrderNo")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("BuyerOrderNo"),
              child: Opacity(
                opacity: form.canEdit("BuyerOrderNo") ? 1 : 0.6,
                child: TextInput(
                  label: "Buyer's Order No",
                  controller: form.BuyerOrderNo,
                  hint: "Order Number",
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (form.canView("OrderBy")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("OrderBy"),
              child: Opacity(
                opacity: form.canEdit("OrderBy") ? 1 : 0.6,
                child: TextInput(
                  label: "Order By",
                  controller: form.OrderBy,
                  hint: "",
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (form.canView("DeliveryAt")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("DeliveryAt"),
              child: Opacity(
                opacity: form.canEdit("DeliveryAt") ? 1 : 0.6,
                child: TextInput(
                  label: "Delivery At",
                  controller: form.DeliveryAt,
                  hint: "",
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (form.canView("Remark")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("Remark"),
              child: Opacity(
                opacity: form.canEdit("Remark") ? 1 : 0.6,
                child: TextInput(
                  label: "Remark",
                  controller: form.Remark,
                  hint: "",
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],

        ],
      ),
    );
  }
}