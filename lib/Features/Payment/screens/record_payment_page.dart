import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import '../models/payment_material_model.dart';
import '../services/payment_material_service.dart';
import '../widgets/payment_bill_table.dart';

class RecordPaymentPage extends StatefulWidget {
  const RecordPaymentPage({super.key});

  @override
  State<RecordPaymentPage> createState() =>
      _RecordPaymentPageState();
}

class _RecordPaymentPageState
    extends State<RecordPaymentPage> {

  String selectedClient = "No";

  String selectedJob = "No";

  List<String> filteredJobs = [];

  bool isLoadingJobs = false;

  final PaymentMaterialService
  _paymentMaterialService =
  PaymentMaterialService();

  List<PaymentMaterialModel>
  billMaterials = [];

  bool isLoadingBill = false;
  /// =========================
  /// FETCH JOBS BASED ON CLIENT
  /// =========================

  Future<void> fetchBillMaterials() async {

    if (selectedJob == "No") {

      setState(() {
        billMaterials = [];
      });

      return;
    }

    setState(() {
      isLoadingBill = true;
    });

    try {

      final materials =
      await _paymentMaterialService
          .fetchMaterialsForJob(
        selectedJob,
      );

      setState(() {

        billMaterials = materials;

        isLoadingBill = false;
      });

    } catch (e) {

      debugPrint(
          "❌ Error loading bill: $e");

      setState(() {
        isLoadingBill = false;
      });
    }
  }

  Future<void> fetchJobsForClient(
      String clientName,
      ) async {

    if (clientName == "No" ||
        clientName.trim().isEmpty) {

      setState(() {
        filteredJobs = [];
        selectedJob = "No";
      });

      return;
    }

    setState(() {
      isLoadingJobs = true;
    });

    try {

      final snapshot =
      await FirebaseFirestore.instance
          .collection("jobs")
          .where(
        "designer.data.PartyName",
        isEqualTo: clientName,
      )
          .get();

      final List<String> jobs = [];

      for (final doc in snapshot.docs) {

        final data = doc.data();

        final designerData =
        Map<String, dynamic>.from(
          data["designer"]?["data"] ?? {},
        );

        final jobName =
        (designerData["particularJobName"] ?? "")
            .toString()
            .trim();

        if (jobName.isNotEmpty) {
          jobs.add(jobName);
        }
      }

      jobs.sort();

      setState(() {

        filteredJobs = jobs;

        selectedJob = "No";

        isLoadingJobs = false;
      });

    } catch (e) {

      debugPrint(
          "❌ Error fetching jobs: $e");

      setState(() {
        isLoadingJobs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          "Record Payment",
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            /// =========================
            /// SELECT CLIENT
            /// =========================

            SearchableDropdownWithInitial(

              label: "Select Client",

              firestoreCollection: "customers",

              firestoreField: "Party Names",

              initialValue: selectedClient,

              onChanged: (value) {

                setState(() {
                  selectedClient = value;
                });

                /// FETCH FILTERED JOBS
                fetchJobsForClient(value);
              },
            ),

            const SizedBox(height: 20),

            /// =========================
            /// SELECT JOB
            /// =========================

            if (isLoadingJobs)

              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child:
                  CircularProgressIndicator(),
                ),
              )

            else

              SearchableDropdownWithInitial(

                label: "Select Job",

                items: filteredJobs,

                initialValue: selectedJob,

                onChanged: (value) async {

                  setState(() {
                    selectedJob = value;
                  });

                  await fetchBillMaterials();
                },
              ),

            const SizedBox(height: 30),

            if (isLoadingBill)

              const Center(
                child: CircularProgressIndicator(),
              )

            else if (billMaterials.isNotEmpty)

              PaymentBillTable(
                materials: billMaterials,
              ),
          ],
        ),
      ),
    );
  }
}