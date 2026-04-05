import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PendingFormEditScreen extends StatefulWidget {
  final String lpm;

  const PendingFormEditScreen({
    super.key,
    required this.lpm,
  });

  @override
  State<PendingFormEditScreen> createState() => _PendingFormEditScreenState();
}

class _PendingFormEditScreenState extends State<PendingFormEditScreen> {
  late Future<DocumentSnapshot> _docFuture;
  bool _isSubmitting = false;

  // Form controllers for Designer to fill
  late TextEditingController designedByController;
  late TextEditingController plyTypeController;
  late TextEditingController plySelectedByController;
  late TextEditingController bladeController;
  late TextEditingController bladeSelectedByController;
  late TextEditingController creasingController;
  late TextEditingController creasingSelectedByController;
  late TextEditingController capsuleTypeController;
  late TextEditingController unknownController;
  late TextEditingController perforationController;
  late TextEditingController perforationSelectedByController;
  late TextEditingController zigZagBladeController;
  late TextEditingController zigZagBladeSelectedByController;
  late TextEditingController rubberTypeController;
  late TextEditingController rubberSelectedByController;
  late TextEditingController holeTypeController;
  late TextEditingController holeSelectedByController;
  late TextEditingController embossStatusController;
  late TextEditingController embossPcsController;
  late TextEditingController maleEmbossTypeController;
  late TextEditingController femaleEmbossTypeController;
  late TextEditingController xController;
  late TextEditingController yController;
  late TextEditingController x2Controller;
  late TextEditingController y2Controller;
  late TextEditingController strippingTypeController;
  late TextEditingController laserCuttingStatusController;
  late TextEditingController rubberFixingDoneController;
  late TextEditingController whiteProfileRubberController;

  @override
  void initState() {
    super.initState();

    // Initialize all controllers
    designedByController = TextEditingController();
    plyTypeController = TextEditingController(text: "No");
    plySelectedByController = TextEditingController();
    bladeController = TextEditingController(text: "No");
    bladeSelectedByController = TextEditingController();
    creasingController = TextEditingController(text: "No");
    creasingSelectedByController = TextEditingController();
    capsuleTypeController = TextEditingController();
    unknownController = TextEditingController();
    perforationController = TextEditingController(text: "No");
    perforationSelectedByController = TextEditingController();
    zigZagBladeController = TextEditingController(text: "No");
    zigZagBladeSelectedByController = TextEditingController();
    rubberTypeController = TextEditingController(text: "No");
    rubberSelectedByController = TextEditingController();
    holeTypeController = TextEditingController(text: "No");
    holeSelectedByController = TextEditingController();
    embossStatusController = TextEditingController(text: "No");
    embossPcsController = TextEditingController();
    maleEmbossTypeController = TextEditingController(text: "No");
    femaleEmbossTypeController = TextEditingController(text: "No");
    xController = TextEditingController();
    yController = TextEditingController();
    x2Controller = TextEditingController();
    y2Controller = TextEditingController();
    strippingTypeController = TextEditingController(text: "No");
    laserCuttingStatusController = TextEditingController(text: "Pending");
    rubberFixingDoneController = TextEditingController(text: "No");
    whiteProfileRubberController = TextEditingController(text: "No");

    _docFuture = FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.lpm)
        .get();
  }

  @override
  void dispose() {
    designedByController.dispose();
    plyTypeController.dispose();
    plySelectedByController.dispose();
    bladeController.dispose();
    bladeSelectedByController.dispose();
    creasingController.dispose();
    creasingSelectedByController.dispose();
    capsuleTypeController.dispose();
    unknownController.dispose();
    perforationController.dispose();
    perforationSelectedByController.dispose();
    zigZagBladeController.dispose();
    zigZagBladeSelectedByController.dispose();
    rubberTypeController.dispose();
    rubberSelectedByController.dispose();
    holeTypeController.dispose();
    holeSelectedByController.dispose();
    embossStatusController.dispose();
    embossPcsController.dispose();
    maleEmbossTypeController.dispose();
    femaleEmbossTypeController.dispose();
    xController.dispose();
    yController.dispose();
    x2Controller.dispose();
    y2Controller.dispose();
    strippingTypeController.dispose();
    laserCuttingStatusController.dispose();
    rubberFixingDoneController.dispose();
    whiteProfileRubberController.dispose();
    super.dispose();
  }

  // ✅ Submit form and move to completed
  Future<void> _submitForm() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      // Update the job document
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.lpm)
          .update({
        "designer.submitted": true,
        "designer.data.designedBy": designedByController.text,
        "designer.data.plyType": plyTypeController.text,
        "designer.data.plySelectedBy": plySelectedByController.text,
        "designer.data.blade": bladeController.text,
        "designer.data.bladeSelectedBy": bladeSelectedByController.text,
        "designer.data.creasing": creasingController.text,
        "designer.data.creasingSelectedBy": creasingSelectedByController.text,
        "designer.data.capsuleType": capsuleTypeController.text,
        "designer.data.unknown": unknownController.text,
        "designer.data.perforation": perforationController.text,
        "designer.data.perforationSelectedBy":
        perforationSelectedByController.text,
        "designer.data.zigZagBlade": zigZagBladeController.text,
        "designer.data.zigZagBladeSelectedBy":
        zigZagBladeSelectedByController.text,
        "designer.data.rubberType": rubberTypeController.text,
        "designer.data.rubberSelectedBy": rubberSelectedByController.text,
        "designer.data.holeType": holeTypeController.text,
        "designer.data.holeSelectedBy": holeSelectedByController.text,
        "designer.data.embossStatus": embossStatusController.text,
        "designer.data.embossPcs": embossPcsController.text,
        "designer.data.maleEmbossType": maleEmbossTypeController.text,
        "designer.data.femaleEmbossType": femaleEmbossTypeController.text,
        "designer.data.x": xController.text,
        "designer.data.y": yController.text,
        "designer.data.x2": x2Controller.text,
        "designer.data.y2": y2Controller.text,
        "designer.data.strippingType": strippingTypeController.text,
        "designer.data.laserCuttingStatus": laserCuttingStatusController.text,
        "designer.data.rubberFixingDone": rubberFixingDoneController.text,
        "designer.data.whiteProfileRubber":
        whiteProfileRubberController.text,
        "status": "completed",
        "currentDepartment": "AutoBending",
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Form submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Auto-close after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Complete Form - LPM: ${widget.lpm}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _docFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Form not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final designerData = data["designer"]?["data"] ?? {};

          // Pre-fill with customer data (read-only display)
          final name = designerData["name"] ?? "N/A";
          final partyName = designerData["partyName"] ?? "N/A";
          final jobName = designerData["particularJobName"] ?? "N/A";
          final deliveryAt = designerData["deliveryAt"] ?? "N/A";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ CUSTOMER DATA (READ-ONLY)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "📋 Customer Data (Pre-filled)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildReadOnlyRow("Name", name),
                      _buildReadOnlyRow("Party", partyName),
                      _buildReadOnlyRow("Job", jobName),
                      _buildReadOnlyRow("Delivery At", deliveryAt),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ✅ DESIGNER TO FILL
                const Text(
                  "🎨 Complete Designer Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                _buildTextField("Designed By", designedByController),
                _buildTextField("Ply Type", plyTypeController),
                _buildTextField("Ply Selected By", plySelectedByController),
                _buildTextField("Blade", bladeController),
                _buildTextField("Blade Selected By", bladeSelectedByController),
                _buildTextField("Creasing", creasingController),
                _buildTextField("Creasing Selected By",
                    creasingSelectedByController),
                _buildTextField("Capsule Type", capsuleTypeController),
                _buildTextField("Unknown", unknownController),
                _buildTextField("Perforation", perforationController),
                _buildTextField("Perforation Selected By",
                    perforationSelectedByController),
                _buildTextField("Zig Zag Blade", zigZagBladeController),
                _buildTextField("Zig Zag Blade Selected By",
                    zigZagBladeSelectedByController),
                _buildTextField("Rubber Type", rubberTypeController),
                _buildTextField("Rubber Selected By",
                    rubberSelectedByController),
                _buildTextField("Hole Type", holeTypeController),
                _buildTextField(
                    "Hole Selected By", holeSelectedByController),
                _buildTextField("Emboss Status", embossStatusController),
                _buildTextField("Emboss Pcs", embossPcsController),
                _buildTextField("Male Emboss Type", maleEmbossTypeController),
                _buildTextField(
                    "Female Emboss Type", femaleEmbossTypeController),
                _buildTextField("X", xController),
                _buildTextField("Y", yController),
                _buildTextField("X2", x2Controller),
                _buildTextField("Y2", y2Controller),
                _buildTextField("Stripping Type", strippingTypeController),
                _buildTextField(
                    "Laser Cutting Status", laserCuttingStatusController),
                _buildTextField(
                    "Rubber Fixing Done", rubberFixingDoneController),
                _buildTextField(
                    "White Profile Rubber", whiteProfileRubberController),

                const SizedBox(height: 24),

                // ✅ SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: _isSubmitting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Icon(Icons.check_circle),
                    label: Text(_isSubmitting ? 'Submitting...' : 'Submit Form'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}