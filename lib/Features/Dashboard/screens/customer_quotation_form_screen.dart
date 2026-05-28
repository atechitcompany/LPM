import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

// ── Section label ─────────────────────────────────────────────────────────────
Widget _sectionLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      letterSpacing: 0.1,
    ),
  ),
);

// ── Card wrapper ──────────────────────────────────────────────────────────────
Widget _fieldCard({required Widget child}) => Container(
  margin: const EdgeInsets.only(bottom: 16),
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: child,
);

// ── Text field widget ─────────────────────────────────────────────────────────
Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
}) =>
    TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
          borderSide: const BorderSide(color: Color(0xFFF8D94B), width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
      ),
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    );

// ── Dropdown widget ───────────────────────────────────────────────────────────
Widget _buildDropdown({
  required String hint,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) =>
    DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
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
          borderSide: const BorderSide(color: Color(0xFFF8D94B), width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    );

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CustomerQuotationFormScreen extends StatefulWidget {
  final String docId; // existing demo_customer_form doc id
  const CustomerQuotationFormScreen({super.key, required this.docId});

  @override
  State<CustomerQuotationFormScreen> createState() =>
      _CustomerQuotationFormScreenState();
}

class _CustomerQuotationFormScreenState
    extends State<CustomerQuotationFormScreen> {
  // Controllers
  final _partyName = TextEditingController();
  final _deliveryAt = TextEditingController();
  final _jobName = TextEditingController();
  final _machineName = TextEditingController();
  final _plywoodSizeGriper = TextEditingController();
  final _cuttingRule = TextEditingController();
  final _creasingRule = TextEditingController();
  final _materialToPunch = TextEditingController();
  final _flute = TextEditingController();
  final _boardCompressedThickness = TextEditingController();
  final _centerNotch = TextEditingController();
  final _plywoodThickness = TextEditingController();
  final _perforation = TextEditingController();
  final _partinex = TextEditingController();
  final _nicking = TextEditingController();
  final _broaching = TextEditingController();
  final _bladeWelding = TextEditingController();
  final _strippingMaleFemale = TextEditingController();
  final _sanwitchDie = TextEditingController();

  String? _rubberOrWithout;
  bool _loading = true;
  bool _saving = false;

  static const _rubberOptions = ['With Rubber', 'Without Rubber'];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    for (final c in [
      _partyName, _deliveryAt, _jobName, _machineName,
      _plywoodSizeGriper, _cuttingRule, _creasingRule,
      _materialToPunch, _flute, _boardCompressedThickness,
      _centerNotch, _plywoodThickness, _perforation,
      _partinex, _nicking, _broaching, _bladeWelding,
      _strippingMaleFemale, _sanwitchDie,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('demo_customer_form')
          .doc(widget.docId)
          .get();
      final d = doc.data() ?? {};
      setState(() {
        _partyName.text = d['partyName']?.toString() ?? '';
        _deliveryAt.text = d['deliveryAt']?.toString() ?? '';
        _jobName.text = d['jobName']?.toString() ?? '';
        _machineName.text = d['machineName']?.toString() ?? '';
        _plywoodSizeGriper.text = d['plywoodSizeGriper']?.toString() ?? '';
        _rubberOrWithout = _rubberOptions.contains(d['rubberOrWithout'])
            ? d['rubberOrWithout']
            : null;
        _cuttingRule.text = d['cuttingRule']?.toString() ?? '';
        _creasingRule.text = d['creasingRule']?.toString() ?? '';
        _materialToPunch.text = d['materialToPunch']?.toString() ?? '';
        _flute.text = d['flute']?.toString() ?? '';
        _boardCompressedThickness.text =
            d['boardCompressedThickness']?.toString() ?? '';
        _centerNotch.text = d['centerNotch']?.toString() ?? '';
        _plywoodThickness.text = d['plywoodThickness']?.toString() ?? '';
        _perforation.text = d['perforation']?.toString() ?? '';
        _partinex.text = d['partinex']?.toString() ?? '';
        _nicking.text = d['nicking']?.toString() ?? '';
        _broaching.text = d['broaching']?.toString() ?? '';
        _bladeWelding.text = d['bladeWelding']?.toString() ?? '';
        _strippingMaleFemale.text = d['strippingMaleFemale']?.toString() ?? '';
        _sanwitchDie.text = d['sanwitchDie']?.toString() ?? '';
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading quotation: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_partyName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Party Name is required')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('demo_customer_form')
          .doc(widget.docId)
          .update({
        'partyName': _partyName.text.trim(),
        'deliveryAt': _deliveryAt.text.trim(),
        'jobName': _jobName.text.trim(),
        'machineName': _machineName.text.trim(),
        'plywoodSizeGriper': _plywoodSizeGriper.text.trim(),
        'rubberOrWithout': _rubberOrWithout ?? '',
        'cuttingRule': _cuttingRule.text.trim(),
        'creasingRule': _creasingRule.text.trim(),
        'materialToPunch': _materialToPunch.text.trim(),
        'flute': _flute.text.trim(),
        'boardCompressedThickness': _boardCompressedThickness.text.trim(),
        'centerNotch': _centerNotch.text.trim(),
        'plywoodThickness': _plywoodThickness.text.trim(),
        'perforation': _perforation.text.trim(),
        'partinex': _partinex.text.trim(),
        'nicking': _nicking.text.trim(),
        'broaching': _broaching.text.trim(),
        'bladeWelding': _bladeWelding.text.trim(),
        'strippingMaleFemale': _strippingMaleFemale.text.trim(),
        'sanwitchDie': _sanwitchDie.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quotation updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Quotation',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Party Name *'),
                _buildTextField(controller: _partyName, hint: 'Party name'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Delivery At'),
                _buildTextField(controller: _deliveryAt, hint: 'Delivery address'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Job Name'),
                _buildTextField(controller: _jobName, hint: 'Job name'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Machine Name'),
                _buildTextField(controller: _machineName, hint: 'Machine name'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Ply Wood Size & Griper'),
                _buildTextField(controller: _plywoodSizeGriper, hint: 'e.g. 30x40, Griper 5mm'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Rubber Or Without Rubber'),
                _buildDropdown(
                  hint: 'Select option',
                  value: _rubberOrWithout,
                  items: _rubberOptions,
                  onChanged: (v) => setState(() => _rubberOrWithout = v),
                ),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Cutting Rule'),
                _buildTextField(controller: _cuttingRule, hint: 'Cutting rule details'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Creasing Rule'),
                _buildTextField(controller: _creasingRule, hint: 'Creasing rule details'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Material To Punch'),
                _buildTextField(controller: _materialToPunch, hint: 'Material description'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Flute'),
                _buildTextField(controller: _flute, hint: 'Flute type'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Board Compressed Thickness'),
                _buildTextField(controller: _boardCompressedThickness, hint: 'e.g. 4mm'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Center Notch'),
                _buildTextField(controller: _centerNotch, hint: 'Center notch details'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Ply Wood Thickness'),
                _buildTextField(controller: _plywoodThickness, hint: 'e.g. 18mm'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Perforation'),
                _buildTextField(controller: _perforation, hint: 'Perforation details'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Partinex'),
                _buildTextField(controller: _partinex, hint: 'Partinex details'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Nicking'),
                _buildTextField(controller: _nicking, hint: 'Nicking details'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Broaching'),
                _buildTextField(controller: _broaching, hint: 'Broaching details'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Blade Welding'),
                _buildTextField(controller: _bladeWelding, hint: 'Blade welding details'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Stripping Male & Female'),
                _buildTextField(controller: _strippingMaleFemale, hint: 'Stripping details'),
              ]),
            ),
            _fieldCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Sanwitch Die'),
                _buildTextField(controller: _sanwitchDie, hint: 'Sanwitch die details'),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF8D94B),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _saving
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
          )
              : const Text(
            'Save Quotation',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }
}