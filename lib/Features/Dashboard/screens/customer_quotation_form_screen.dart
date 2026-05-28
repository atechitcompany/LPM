import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _sectionLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          letterSpacing: 0.1)),
);

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
          offset: const Offset(0, 2))
    ],
  ),
  child: child,
);

InputDecoration _inputDeco(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300)),
  enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300)),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFF8D94B), width: 2)),
  contentPadding:
  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  filled: true,
  fillColor: const Color(0xFFF7F8FA),
);

Widget _tf(TextEditingController c, String hint, {int maxLines = 1}) =>
    TextField(
        controller: c,
        maxLines: maxLines,
        decoration: _inputDeco(hint),
        style: const TextStyle(fontSize: 14, color: Colors.black87));

// ── Step Header ───────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int currentStep;
  const _StepHeader({required this.currentStep});

  static const _labels = [
    'Basic\nInfo',
    'Materials\n& Tools',
    'Emboss\n& More',
    'Customer\nFields',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: List.generate(_labels.length, (i) {
                final isActive = i + 1 == currentStep;
                final isDone = i + 1 < currentStep;
                return Expanded(
                  child: Text(_labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isActive
                              ? Colors.black
                              : isDone
                              ? Colors.black54
                              : Colors.black38,
                          height: 1.3)),
                );
              }),
            ),
          ),
          Row(
            children: List.generate(_labels.length, (i) {
              final isActive = i + 1 == currentStep;
              final isDone = i + 1 < currentStep;
              return Expanded(
                child: Container(
                  height: 3,
                  color: isActive || isDone
                      ? const Color(0xFFF8D94B)
                      : Colors.grey.shade200,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Main Screen ───────────────────────────────────────────────────────────────

class CustomerQuotationFormScreen extends StatefulWidget {
  final String docId;
  const CustomerQuotationFormScreen({super.key, required this.docId});

  @override
  State<CustomerQuotationFormScreen> createState() =>
      _CustomerQuotationFormScreenState();
}

class _CustomerQuotationFormScreenState
    extends State<CustomerQuotationFormScreen> {
  int _step = 1;
  bool _loading = true;
  bool _saving = false;

  // ── Page 1: Basic Info ──
  final _partyName = TextEditingController();
  final _jobName = TextEditingController();
  final _deliveryAt = TextEditingController();
  final _orderBy = TextEditingController();
  final _remark = TextEditingController();
  String? _priority;

  // ── Page 2: Materials & Tools ──
  final _plyType = TextEditingController();
  final _blade = TextEditingController();
  final _creasing = TextEditingController();
  final _perforation = TextEditingController();
  final _zigZagBlade = TextEditingController();
  final _rubberType = TextEditingController();
  final _holeType = TextEditingController();
  final _strippingType = TextEditingController();
  final _capsuleType = TextEditingController();

  // ── Page 3: Emboss & More ──
  final _embossStatus = TextEditingController();
  final _embossPcs = TextEditingController();
  final _maleEmbossType = TextEditingController();
  final _femaleEmbossType = TextEditingController();

  // ── Page 4: Customer Fields ──
  final _machineName = TextEditingController();
  final _plywoodSizeGriper = TextEditingController();
  final _cuttingRule = TextEditingController();
  final _creasingRule = TextEditingController();
  final _materialToPunch = TextEditingController();
  final _flute = TextEditingController();
  final _boardCompressedThickness = TextEditingController();
  final _centerNotch = TextEditingController();
  final _plywoodThickness = TextEditingController();
  final _partinex = TextEditingController();
  final _nicking = TextEditingController();
  final _broaching = TextEditingController();
  final _bladeWelding = TextEditingController();
  final _strippingMaleFemale = TextEditingController();
  final _sanwitchDie = TextEditingController();
  String? _rubberOrWithout;

  static const _rubberOptions = ['With Rubber', 'Without Rubber'];
  static const _priorityOptions = [
    'Blade Change',
    'Important',
    'Hold',
    'Cancel',
    'Emergency'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _partyName, _jobName, _deliveryAt, _orderBy, _remark,
      _plyType, _blade, _creasing, _perforation, _zigZagBlade,
      _rubberType, _holeType, _strippingType, _capsuleType,
      _embossStatus, _embossPcs, _maleEmbossType, _femaleEmbossType,
      _machineName, _plywoodSizeGriper, _cuttingRule, _creasingRule,
      _materialToPunch, _flute, _boardCompressedThickness, _centerNotch,
      _plywoodThickness, _partinex, _nicking, _broaching, _bladeWelding,
      _strippingMaleFemale, _sanwitchDie,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('demo_customer_form')
          .doc(widget.docId)
          .get();
      final d = doc.data() ?? {};
      final dd = <String, dynamic>{}; // demo_customer_form is flat, no nesting

      setState(() {
        _partyName.text = d['partyName']?.toString() ?? dd['PartyName'] ?? '';
        _jobName.text = d['jobName']?.toString() ?? dd['ParticularJobName'] ?? '';
        _deliveryAt.text = d['deliveryAt']?.toString() ?? dd['DeliveryAt'] ?? '';
        _orderBy.text = d['orderBy']?.toString() ?? dd['OrderBy'] ?? '';
        _remark.text = d['remark']?.toString() ?? dd['Remark'] ?? '';
        _priority = _priorityOptions.contains(d['priority'] ?? dd['Priority'])
            ? (d['priority'] ?? dd['Priority'])
            : null;

        _plyType.text = d['plyType']?.toString() ?? dd['PlyType'] ?? 'No';
        _blade.text = d['blade']?.toString() ?? dd['Blade'] ?? 'No';
        _creasing.text = d['creasing']?.toString() ?? dd['Creasing'] ?? 'No';
        _perforation.text = d['perforation']?.toString() ?? dd['Perforation'] ?? 'No';
        _zigZagBlade.text = d['zigZagBlade']?.toString() ?? dd['ZigZagBlade'] ?? 'No';
        _rubberType.text = d['rubberType']?.toString() ?? dd['RubberType'] ?? 'No';
        _holeType.text = d['holeType']?.toString() ?? dd['HoleType'] ?? 'No';
        _strippingType.text = d['strippingType']?.toString() ?? dd['StrippingType'] ?? 'No';
        _capsuleType.text = d['capsuleType']?.toString() ?? dd['CapsuleType'] ?? 'No';

        _embossStatus.text = d['embossStatus']?.toString() ?? dd['EmbossStatus'] ?? 'No';
        _embossPcs.text = d['embossPcs']?.toString() ?? dd['EmbossPcs'] ?? '';
        _maleEmbossType.text = d['maleEmbossType']?.toString() ?? dd['MaleEmbossType'] ?? '';
        _femaleEmbossType.text = d['femaleEmbossType']?.toString() ?? dd['FemaleEmbossType'] ?? '';

        _machineName.text = d['machineName']?.toString() ?? dd['MachineName'] ?? '';
        _plywoodSizeGriper.text = d['plywoodSizeGriper']?.toString() ?? dd['PlywoodSizeGriper'] ?? '';
        _cuttingRule.text = d['cuttingRule']?.toString() ?? dd['CuttingRule'] ?? '';
        _creasingRule.text = d['creasingRule']?.toString() ?? dd['CreasingRule'] ?? '';
        _materialToPunch.text = d['materialToPunch']?.toString() ?? dd['MaterialToPunch'] ?? '';
        _flute.text = d['flute']?.toString() ?? dd['Flute'] ?? '';
        _boardCompressedThickness.text = d['boardCompressedThickness']?.toString() ?? dd['BoardCompressedThickness'] ?? '';
        _centerNotch.text = d['centerNotch']?.toString() ?? dd['CenterNotch'] ?? '';
        _plywoodThickness.text = d['plywoodThickness']?.toString() ?? dd['PlywoodThickness'] ?? '';
        _partinex.text = d['partinex']?.toString() ?? dd['Partinex'] ?? '';
        _nicking.text = d['nicking']?.toString() ?? dd['Nicking'] ?? '';
        _broaching.text = d['broaching']?.toString() ?? dd['Broaching'] ?? '';
        _bladeWelding.text = d['bladeWelding']?.toString() ?? dd['BladeWelding'] ?? '';
        _strippingMaleFemale.text = d['strippingMaleFemale']?.toString() ?? dd['StrippingMaleFemale'] ?? '';
        _sanwitchDie.text = d['sanwitchDie']?.toString() ?? dd['SanwitchDie'] ?? '';
        final rawRubber = d['rubberOrWithout']?.toString() ?? '';
        _rubberOrWithout = _rubberOptions.firstWhere(
              (o) => o.toLowerCase() == rawRubber.toLowerCase(),
          orElse: () => '',
        );
        if (_rubberOrWithout!.isEmpty) _rubberOrWithout = null;

        _loading = false;
      });
    } catch (e) {
      debugPrint('Load error: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_partyName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Party Name is required')));
      return;
    }
    setState(() => _saving = true);
    try {
      final designerData = {
        'PartyName': _partyName.text.trim(),
        'ParticularJobName': _jobName.text.trim(),
        'DeliveryAt': _deliveryAt.text.trim(),
        'OrderBy': _orderBy.text.trim(),
        'Remark': _remark.text.trim(),
        'Priority': _priority ?? '',
        'PlyType': _plyType.text.trim(),
        'Blade': _blade.text.trim(),
        'Creasing': _creasing.text.trim(),
        'Perforation': _perforation.text.trim(),
        'ZigZagBlade': _zigZagBlade.text.trim(),
        'RubberType': _rubberType.text.trim(),
        'HoleType': _holeType.text.trim(),
        'StrippingType': _strippingType.text.trim(),
        'CapsuleType': _capsuleType.text.trim(),
        'EmbossStatus': _embossStatus.text.trim(),
        'EmbossPcs': _embossPcs.text.trim(),
        'MaleEmbossType': _maleEmbossType.text.trim(),
        'FemaleEmbossType': _femaleEmbossType.text.trim(),
        'MachineName': _machineName.text.trim(),
        'PlywoodSizeGriper': _plywoodSizeGriper.text.trim(),
        'CuttingRule': _cuttingRule.text.trim(),
        'CreasingRule': _creasingRule.text.trim(),
        'MaterialToPunch': _materialToPunch.text.trim(),
        'Flute': _flute.text.trim(),
        'BoardCompressedThickness': _boardCompressedThickness.text.trim(),
        'CenterNotch': _centerNotch.text.trim(),
        'PlywoodThickness': _plywoodThickness.text.trim(),
        'Partinex': _partinex.text.trim(),
        'Nicking': _nicking.text.trim(),
        'Broaching': _broaching.text.trim(),
        'BladeWelding': _bladeWelding.text.trim(),
        'StrippingMaleFemale': _strippingMaleFemale.text.trim(),
        'SanwitchDie': _sanwitchDie.text.trim(),
        'RubberOrWithout': _rubberOrWithout ?? '',
      };

      await FirebaseFirestore.instance
          .collection('quotation_pending')
          .doc(widget.docId)
          .set({
        ...designerData,
        'sourceDocId': widget.docId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Quotation updated'), backgroundColor: Colors.green));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Pages ─────────────────────────────────────────────────────────────────

  Widget _page1() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Party Name *'),
        _tf(_partyName, 'Party name'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Job Name'),
        _tf(_jobName, 'Enter job name'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Priority'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _priorityOptions.map((p) {
            final selected = _priority == p;
            return GestureDetector(
              onTap: () => setState(() => _priority = selected ? null : p),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFF8D94B) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: selected ? const Color(0xFFF8D94B) : Colors.grey.shade300),
                ),
                child: Text(p,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
              ),
            );
          }).toList(),
        ),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Remark'),
        _tf(_remark, 'Add a remark', maxLines: 2),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Delivery At'),
        _tf(_deliveryAt, 'Address'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Order By'),
        _tf(_orderBy, 'Name'),
      ])),
    ],
  );

  Widget _page2() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Ply Type'),
        _tf(_plyType, 'e.g. No, Single, Double'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Blade'),
        _tf(_blade, 'e.g. No, Type A'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Creasing'),
        _tf(_creasing, 'e.g. No'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Perforation'),
        _tf(_perforation, 'Perforation details'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Zig Zag Blade'),
        _tf(_zigZagBlade, 'e.g. No'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Rubber Type'),
        _tf(_rubberType, 'e.g. No'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Hole Type'),
        _tf(_holeType, 'e.g. No'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Stripping Type'),
        _tf(_strippingType, 'e.g. No'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Capsule Type'),
        _tf(_capsuleType, 'e.g. No'),
      ])),
    ],
  );

  Widget _page3() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Emboss'),
        _buildToggle(
          value: _embossStatus.text.toLowerCase() == 'yes',
          onChanged: (v) => setState(() => _embossStatus.text = v ? 'Yes' : 'No'),
          inactiveText: 'No',
          activeText: 'Yes',
        ),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Emboss Pcs'),
        _tf(_embossPcs, 'No of Pcs'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Male Emboss'),
        _tf(_maleEmbossType, 'e.g. No'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Female Emboss'),
        _tf(_femaleEmbossType, 'e.g. No'),
      ])),
    ],
  );

  Widget _page4() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Machine Name'),
        _tf(_machineName, 'Machine name'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Ply Wood Size & Griper'),
        _tf(_plywoodSizeGriper, 'e.g. 30x40, Griper 5mm'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Rubber Or Without Rubber'),
        DropdownButtonFormField<String>(
          value: _rubberOrWithout,
          hint: Text('Select option',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          decoration: _inputDeco(''),
          items: _rubberOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => _rubberOrWithout = v),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Cutting Rule'),
        _tf(_cuttingRule, 'Cutting rule details'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Creasing Rule'),
        _tf(_creasingRule, 'Creasing rule details'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Material To Punch'),
        _tf(_materialToPunch, 'Material description'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Flute'),
        _tf(_flute, 'Flute type'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Board Compressed Thickness'),
        _tf(_boardCompressedThickness, 'e.g. 4mm'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Center Notch'),
        _tf(_centerNotch, 'Center notch details'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Ply Wood Thickness'),
        _tf(_plywoodThickness, 'e.g. 18mm'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Partinex'),
        _tf(_partinex, 'Partinex details'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Nicking'),
        _tf(_nicking, 'Nicking details'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Broaching'),
        _tf(_broaching, 'Broaching details'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Blade Welding'),
        _tf(_bladeWelding, 'Blade welding details'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Stripping Male & Female'),
        _tf(_strippingMaleFemale, 'Stripping details'),
      ])),
      _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Sanwitch Die'),
        _tf(_sanwitchDie, 'Sanwitch die details'),
      ])),
    ],
  );

  Widget _buildToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String inactiveText,
    required String activeText,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          color: const Color(0xFFF7F8FA),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value ? activeText : inactiveText,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFFF8D94B),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _step == 4;

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
        title: const Text('Edit Quotation',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _StepHeader(currentStep: _step),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_step == 1) _page1(),
            if (_step == 2) _page2(),
            if (_step == 3) _page3(),
            if (_step == 4) _page4(),
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
                offset: const Offset(0, -2))
          ],
        ),
        child: Row(
          children: [
            if (_step > 1) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFF8D94B), width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Prev',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: _saving
                    ? null
                    : () {
                  if (isLast) {
                    _save();
                  } else {
                    setState(() => _step++);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8D94B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                    : Text(isLast ? 'Save Quotation' : 'Next',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}