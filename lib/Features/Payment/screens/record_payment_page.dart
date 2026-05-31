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
  List<String> filteredJobs = [];
  List<String> selectedJobs = [];
  Map<String, String> jobLpmMap = {};
  bool isLoadingJobs = false;

  final PaymentMaterialService _paymentMaterialService = PaymentMaterialService();
  List<PaymentMaterialModel> billMaterials = [];
  bool isLoadingBill = false;

  final TextEditingController _jobSearchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _dropdownOpen = false;
  List<String> _filteredDropdownJobs = [];

  @override
  void initState() {
    super.initState();
    _jobSearchController.addListener(() {
      final query = _jobSearchController.text.toLowerCase();
      setState(() {
        _filteredDropdownJobs = filteredJobs.where((j) => j.toLowerCase().contains(query)).toList();
      });
      if (_dropdownOpen) _rebuildOverlay();
    });
  }

  @override
  void dispose() {
    _closeDropdown();
    _jobSearchController.dispose();
    super.dispose();
  }

  void _openDropdown() {
    _filteredDropdownJobs = List.from(filteredJobs);
    _dropdownOpen = true;
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _dropdownOpen = false;
  }

  void _rebuildOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 400,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(14),
            child: StatefulBuilder(
              builder: (ctx, setOverlayState) {
                return Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _filteredDropdownJobs.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text("No jobs found", style: TextStyle(color: Colors.grey.shade400)),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: _filteredDropdownJobs.length,
                    itemBuilder: (_, i) {
                      final job = _filteredDropdownJobs[i];
                      final selected = selectedJobs.contains(job);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              selectedJobs.remove(job);
                            } else {
                              selectedJobs.add(job);
                            }
                          });
                          _rebuildOverlay();
                          fetchBillMaterials();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          color: selected ? Colors.indigo.shade50 : Colors.transparent,
                          child: Row(
                            children: [
                              Icon(
                                selected ? Icons.check_box : Icons.check_box_outline_blank,
                                color: selected ? Colors.indigo : Colors.grey.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(job, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: selected ? Colors.indigo.shade700 : Colors.grey.shade800, fontSize: 14))),
                              if (jobLpmMap[job] != null)
                                Text(jobLpmMap[job]!, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchBillMaterials() async {
    if (selectedJobs.isEmpty) {
      setState(() { billMaterials = []; });
      return;
    }
    setState(() { isLoadingBill = true; });
    try {
      final List<PaymentMaterialModel> all = [];
      int srCounter = 1;
      for (final job in selectedJobs) {
        final materials = await _paymentMaterialService.fetchMaterialsForJob(job);
        for (final m in materials) {
          all.add(PaymentMaterialModel(
            srNo: srCounter++,
            material: m.material,
            materialName: m.materialName,
            rate: m.rate,
            quantityOrSize: m.quantityOrSize,
            amount: m.amount,
          ));
        }
      }
      setState(() { billMaterials = all; isLoadingBill = false; });
    } catch (e) {
      debugPrint("❌ Error loading bill: $e");
      setState(() { isLoadingBill = false; });
    }
  }

  Future<void> fetchJobsForClient(String clientName) async {
    if (clientName == "No" || clientName.trim().isEmpty) {
      setState(() { filteredJobs = []; selectedJobs = []; jobLpmMap = {}; billMaterials = []; });
      return;
    }
    setState(() { isLoadingJobs = true; });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("jobs")
          .where("designer.data.PartyName", isEqualTo: clientName)
          .get();

      final paymentsSnapshot = await FirebaseFirestore.instance.collection("payments").get();
      final recordedLpms = paymentsSnapshot.docs.map((d) => d.id).toSet();

      final List<String> jobs = [];
      final Map<String, String> lpmMap = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final designerData = Map<String, dynamic>.from(data["designer"]?["data"] ?? {});
        final jobName = (designerData["particularJobName"] ?? "").toString().trim();
        final lpm = (designerData["LPMNumber"] ?? designerData["lpmNumber"] ?? designerData["lpm"] ?? "").toString().trim();
        final docId = lpm.isNotEmpty ? lpm : doc.id;
        if (jobName.isNotEmpty && !recordedLpms.contains(docId)) {
          jobs.add(jobName);
          lpmMap[jobName] = docId;
        }
      }
      jobs.sort();
      setState(() { filteredJobs = jobs; jobLpmMap = lpmMap; selectedJobs = []; isLoadingJobs = false; });
    } catch (e) {
      debugPrint("❌ Error fetching jobs: $e");
      setState(() { isLoadingJobs = false; });
    }
  }

  String get combinedLpmNumber => selectedJobs.map((j) => jobLpmMap[j] ?? "").where((l) => l.isNotEmpty).join("_");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Record Payment")),
      body: GestureDetector(
        onTap: _closeDropdown,
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
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
                  _closeDropdown();
                  fetchJobsForClient(value);
                },
              ),
              const SizedBox(height: 20),
              if (isLoadingJobs)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (filteredJobs.isNotEmpty) ...[
                Text("Select Jobs", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 15)),
                const SizedBox(height: 8),
                CompositedTransformTarget(
                  link: _layerLink,
                  child: GestureDetector(
                    onTap: () {
                      if (_dropdownOpen) {
                        _closeDropdown();
                      } else {
                        _jobSearchController.clear();
                        _openDropdown();
                      }
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _dropdownOpen ? Colors.indigo.shade400 : Colors.grey.shade300, width: _dropdownOpen ? 1.5 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.work_outline, size: 18, color: Colors.indigo.shade400),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _dropdownOpen
                                ? TextField(
                              controller: _jobSearchController,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: "Search jobs...",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onTap: () {},
                            )
                                : Text(
                              selectedJobs.isEmpty ? "Select jobs..." : "${selectedJobs.length} job(s) selected",
                              style: TextStyle(color: selectedJobs.isEmpty ? Colors.grey.shade400 : Colors.grey.shade800, fontSize: 14),
                            ),
                          ),
                          Icon(_dropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                ),
                if (selectedJobs.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: selectedJobs.map((j) => Chip(
                      label: Text(j, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.indigo.shade50,
                      deleteIconColor: Colors.indigo,
                      labelStyle: TextStyle(color: Colors.indigo.shade700),
                      onDeleted: () {
                        setState(() { selectedJobs.remove(j); });
                        if (_dropdownOpen) _rebuildOverlay();
                        fetchBillMaterials();
                      },
                    )).toList(),
                  ),
                ],
              ],
              const SizedBox(height: 30),
              if (isLoadingBill)
                const Center(child: CircularProgressIndicator())
              else if (billMaterials.isNotEmpty)
                PaymentBillTable(
                  materials: billMaterials,
                  selectedClient: selectedClient,
                  selectedJob: selectedJobs.join(", "),
                  lpmNumber: combinedLpmNumber,
                ),
            ],
          ),
        ),
      ),
    );
  }
}