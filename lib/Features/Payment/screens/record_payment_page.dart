import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import '../models/payment_material_model.dart';
import '../services/payment_material_service.dart';
import '../widgets/payment_bill_table.dart';

class RecordPaymentPage extends StatefulWidget {
  const RecordPaymentPage({super.key});

  @override
  State<RecordPaymentPage> createState() => _RecordPaymentPageState();
}

class _RecordPaymentPageState extends State<RecordPaymentPage> {
  String selectedClient = "No";
  String selectedJob = "No";
  String selectedLpmNumber = "";
  List<String> filteredJobs = [];
  bool isLoadingJobs = false;

  final PaymentMaterialService _paymentMaterialService = PaymentMaterialService();
  List<PaymentMaterialModel> billMaterials = [];
  bool isLoadingBill = false;

  Future<void> fetchBillMaterials() async {
    if (selectedJob == "No") {
      setState(() { billMaterials = []; });
      return;
    }
    setState(() { isLoadingBill = true; });
    try {
      final materials = await _paymentMaterialService.fetchMaterialsForJob(selectedJob);
      setState(() { billMaterials = materials; isLoadingBill = false; });
    } catch (e) {
      debugPrint("❌ Error loading bill: $e");
      setState(() { isLoadingBill = false; });
    }
  }

  Future<void> fetchJobsForClient(String clientName) async {
    if (clientName == "No" || clientName.trim().isEmpty) {
      setState(() { filteredJobs = []; selectedJob = "No"; selectedLpmNumber = ""; });
      return;
    }
    setState(() { isLoadingJobs = true; });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("jobs")
          .where("designer.data.PartyName", isEqualTo: clientName)
          .get();

      // Fetch already recorded payment doc IDs
      final paymentsSnapshot = await FirebaseFirestore.instance.collection("payments").get();
      final recordedLpms = paymentsSnapshot.docs.map((d) => d.id).toSet();

      final List<String> jobs = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final designerData = Map<String, dynamic>.from(data["designer"]?["data"] ?? {});
        final jobName = (designerData["particularJobName"] ?? "").toString().trim();
        final lpm = (designerData["LPMNumber"] ?? designerData["lpmNumber"] ?? designerData["lpm"] ?? "").toString().trim();
        // Only include jobs whose LPM is not already in payments
        if (jobName.isNotEmpty && !recordedLpms.contains(lpm.isNotEmpty ? lpm : doc.id)) {
          jobs.add(jobName);
        }
      }
      jobs.sort();
      setState(() { filteredJobs = jobs; selectedJob = "No"; selectedLpmNumber = ""; isLoadingJobs = false; });
    } catch (e) {
      debugPrint("❌ Error fetching jobs: $e");
      setState(() { isLoadingJobs = false; });
    }
  }

  Future<void> fetchLpmForJob(String jobName) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("jobs")
          .where("designer.data.particularJobName", isEqualTo: jobName)
          .where("designer.data.PartyName", isEqualTo: selectedClient)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final designerData = Map<String, dynamic>.from(data["designer"]?["data"] ?? {});
        final lpm = (designerData["LPMNumber"] ?? designerData["lpmNumber"] ?? designerData["lpm"] ?? "").toString().trim();
        setState(() { selectedLpmNumber = lpm.isNotEmpty ? lpm : snapshot.docs.first.id; });
      }
    } catch (e) {
      debugPrint("❌ Error fetching LPM: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Record Payment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchableDropdownWithInitial(
              label: "Select Client",
              firestoreCollection: "customers",
              firestoreField: "Party Names",
              initialValue: selectedClient,
              onChanged: (value) {
                setState(() { selectedClient = value; });
                fetchJobsForClient(value);
              },
            ),
            const SizedBox(height: 20),
            if (isLoadingJobs)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else
              SearchableDropdownWithInitial(
                label: "Select Job",
                items: filteredJobs,
                initialValue: selectedJob,
                onChanged: (value) async {
                  setState(() { selectedJob = value; });
                  await fetchLpmForJob(value);
                  await fetchBillMaterials();
                },
              ),
            const SizedBox(height: 30),
            if (isLoadingBill)
              const Center(child: CircularProgressIndicator())
            else if (billMaterials.isNotEmpty)
              PaymentBillTable(
                materials: billMaterials,
                selectedClient: selectedClient,
                selectedJob: selectedJob,
                lpmNumber: selectedLpmNumber,
              ),
          ],
        ),
      ),
    );
  }
}