import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/PrioritySelector.dart';

// ── Helpers (reuse from designer_widgets) ─────────────────────────────────────

Widget _sectionLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: Colors.black87, letterSpacing: 0.1)),
);

Widget _fieldCard({required Widget child}) => Container(
  margin: const EdgeInsets.only(bottom: 16),
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
  ),
  child: child,
);

// ── Step Header ───────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int currentStep;
  const _StepHeader({required this.currentStep});

  static const _labels = ['Basic\nInfo', 'Materials\n& Tools', 'Emboss\n& More', 'Customer\nFields'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        color: isActive ? Colors.black : isDone ? Colors.black54 : Colors.black38,
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
                child: Container(height: 3, color: isActive || isDone ? const Color(0xFFF8D94B) : Colors.grey.shade200));
          }),
        ),
      ]),
    );
  }
}

// ── Main Screen ───────────────────────────────────────────────────────────────

class CustomerQuotationFormScreen extends StatefulWidget {
  final String docId;
  const CustomerQuotationFormScreen({super.key, required this.docId});

  @override
  State<CustomerQuotationFormScreen> createState() => _CustomerQuotationFormScreenState();
}

class _CustomerQuotationFormScreenState extends State<CustomerQuotationFormScreen> {
  int _step = 1;
  bool _loading = true;
  bool _saving = false;

  // ── Page 1 ──
  final _partyName = TextEditingController();
  final _jobName = TextEditingController();
  final _deliveryAt = TextEditingController();
  final _orderBy = TextEditingController();
  final _remark = TextEditingController();
  String? _priority;

  // ── Page 2 ──
  final _plyType = TextEditingController();
  final _blade = TextEditingController();
  final _creasing = TextEditingController();
  final _perforation = TextEditingController();
  final _zigZagBlade = TextEditingController();
  final _rubberType = TextEditingController();
  final _holeType = TextEditingController();
  final _strippingType = TextEditingController();
  final _capsuleType = TextEditingController();

  // ── Page 3 ──
  final _embossStatus = TextEditingController();
  final _embossPcs = TextEditingController();
  final _maleEmbossType = TextEditingController();
  final _femaleEmbossType = TextEditingController();

  // ── Page 4 ──
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
  bool _quoteDesignDone = false;

  // ── Dropdown lists ──
  List<String> _customerNames = [];
  List<String> _plyItems = ["No"];
  List<String> _bladeItems = ["No"];
  List<String> _creasingItems = ["No"];
  List<String> _perforationItems = ["No"];
  List<String> _zigZagBladeItems = ["No"];
  List<String> _rubberItems = ["No"];
  List<String> _holeItems = ["No"];
  List<String> _strippingItems = ["No"];
  List<String> _capsuleItems = ["No"];
  List<String> _maleEmbossItems = ["No"];
  List<String> _femaleEmbossItems = ["No"];

  static const _rubberOptions = ['With Rubber', 'Without Rubber'];

  @override
  void initState() {
    super.initState();
    _fetchAllDropdowns();
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
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _fetchCollection(String col, String field, List<String> list, Function(List<String>) onDone) async {
    try {
      final snap = await FirebaseFirestore.instance.collection(col).get();
      final items = snap.docs.map((d) => (d.data()[field] ?? '').toString()).where((v) => v.isNotEmpty).toList();
      if (mounted) setState(() => onDone(["No", ...items]));
    } catch (e) { debugPrint("❌ $col: $e"); }
  }

  Future<void> _fetchAllDropdowns() async {
    // Customers
    try {
      final snap = await FirebaseFirestore.instance.collection('customers').get();
      final names = snap.docs.map((d) => d.data()['Party Names']?.toString() ?? '').where((v) => v.isNotEmpty).toList()..sort();
      if (mounted) setState(() => _customerNames = names);
    } catch (e) { debugPrint("❌ customers: $e"); }

    await Future.wait([
      _fetchCollection("Plys", "Plys", _plyItems, (v) => _plyItems = v),
      _fetchCollection("Blades", "Blades", _bladeItems, (v) => _bladeItems = v),
      _fetchCollection("Creasings", "Creasings", _creasingItems, (v) => _creasingItems = v),
      _fetchCollection("Perforations", "Perforations", _perforationItems, (v) => _perforationItems = v),
      _fetchCollection("Zig Zags Blades", "Zig Zags Blades", _zigZagBladeItems, (v) => _zigZagBladeItems = v),
      _fetchCollection("Rubbers", "Rubbers", _rubberItems, (v) => _rubberItems = v),
      _fetchCollection("Holes", "Holes", _holeItems, (v) => _holeItems = v),
      _fetchCollection("Strippings", "Strippings", _strippingItems, (v) => _strippingItems = v),
      _fetchCollection("Capsules", "Capsules", _capsuleItems, (v) => _capsuleItems = v),
    ]);

    // Male & Female Emboss (special field names)
    try {
      final snap = await FirebaseFirestore.instance.collection("Males Embosse").get();
      final items = snap.docs.map((d) => (d.data()['Males Embosse '] ?? d.data()['Males Embosse'] ?? '').toString().trim()).where((v) => v.isNotEmpty && v != "No").toList();
      if (mounted) setState(() => _maleEmbossItems = ["No", ...items]);
    } catch (e) { debugPrint("❌ Males Embosse: $e"); }

    try {
      final snap = await FirebaseFirestore.instance.collection("Females Emobosse").get();
      final items = snap.docs.map((d) => (d.data()['Females Emobosse '] ?? d.data()['Females Emobosse'] ?? '').toString().trim()).where((v) => v.isNotEmpty && v != "No").toList();
      if (mounted) setState(() => _femaleEmbossItems = ["No", ...items]);
    } catch (e) { debugPrint("❌ Females Emobosse: $e"); }
  }

  Future<void> _load() async {
    try {
      var doc = await FirebaseFirestore.instance.collection('quotation_pending').doc(widget.docId).get();
      if (!doc.exists) {
        doc = await FirebaseFirestore.instance.collection('demo_customer_form').doc(widget.docId).get();
      }
      final raw = doc.data() ?? {};
      // Normalize: support both camelCase (demo_customer_form) and PascalCase (quotation_pending)
      final d = {
        'PartyName': raw['PartyName'] ?? raw['partyName'] ?? '',
        'ParticularJobName': raw['ParticularJobName'] ?? raw['jobName'] ?? '',
        'DeliveryAt': raw['DeliveryAt'] ?? raw['deliveryAt'] ?? '',
        'OrderBy': raw['OrderBy'] ?? raw['orderBy'] ?? '',
        'Remark': raw['Remark'] ?? raw['remark'] ?? '',
        'PlyType': raw['PlyType'] ?? raw['plyType'] ?? 'No',
        'Blade': raw['Blade'] ?? raw['blade'] ?? 'No',
        'Creasing': raw['Creasing'] ?? raw['creasing'] ?? 'No',
        'Perforation': raw['Perforation'] ?? raw['perforation'] ?? 'No',
        'ZigZagBlade': raw['ZigZagBlade'] ?? raw['zigZagBlade'] ?? 'No',
        'RubberType': raw['RubberType'] ?? raw['rubberType'] ?? 'No',
        'HoleType': raw['HoleType'] ?? raw['holeType'] ?? 'No',
        'StrippingType': raw['StrippingType'] ?? raw['strippingType'] ?? 'No',
        'CapsuleType': raw['CapsuleType'] ?? raw['capsuleType'] ?? 'No',
        'EmbossStatus': raw['EmbossStatus'] ?? raw['embossStatus'] ?? 'No',
        'EmbossPcs': raw['EmbossPcs'] ?? raw['embossPcs'] ?? '',
        'MaleEmbossType': raw['MaleEmbossType'] ?? raw['maleEmbossType'] ?? '',
        'FemaleEmbossType': raw['FemaleEmbossType'] ?? raw['femaleEmbossType'] ?? '',
        'MachineName': raw['MachineName'] ?? raw['machineName'] ?? '',
        'PlywoodSizeGriper': raw['PlywoodSizeGriper'] ?? raw['plywoodSizeGriper'] ?? '',
        'CuttingRule': raw['CuttingRule'] ?? raw['cuttingRule'] ?? '',
        'CreasingRule': raw['CreasingRule'] ?? raw['creasingRule'] ?? '',
        'MaterialToPunch': raw['MaterialToPunch'] ?? raw['materialToPunch'] ?? '',
        'Flute': raw['Flute'] ?? raw['flute'] ?? '',
        'BoardCompressedThickness': raw['BoardCompressedThickness'] ?? raw['boardCompressedThickness'] ?? '',
        'CenterNotch': raw['CenterNotch'] ?? raw['centerNotch'] ?? '',
        'PlywoodThickness': raw['PlywoodThickness'] ?? raw['plywoodThickness'] ?? '',
        'Partinex': raw['Partinex'] ?? raw['partinex'] ?? '',
        'Nicking': raw['Nicking'] ?? raw['nicking'] ?? '',
        'Broaching': raw['Broaching'] ?? raw['broaching'] ?? '',
        'BladeWelding': raw['BladeWelding'] ?? raw['bladeWelding'] ?? '',
        'StrippingMaleFemale': raw['StrippingMaleFemale'] ?? raw['strippingMaleFemale'] ?? '',
        'SanwitchDie': raw['SanwitchDie'] ?? raw['sanwitchDie'] ?? '',
        'RubberOrWithout': raw['RubberOrWithout'] ?? raw['rubberOrWithout'] ?? '',
        'quoteDesignDone': raw['quoteDesignDone'] ?? false,
      };
      setState(() {
        _partyName.text = d['PartyName']?.toString() ?? '';
        _jobName.text = d['ParticularJobName']?.toString() ?? '';
        _deliveryAt.text = d['DeliveryAt']?.toString() ?? '';
        _orderBy.text = d['OrderBy']?.toString() ?? '';
        _remark.text = d['Remark']?.toString() ?? '';
        _plyType.text = d['PlyType']?.toString() ?? 'No';
        _blade.text = d['Blade']?.toString() ?? 'No';
        _creasing.text = d['Creasing']?.toString() ?? 'No';
        _perforation.text = d['Perforation']?.toString() ?? 'No';
        _zigZagBlade.text = d['ZigZagBlade']?.toString() ?? 'No';
        _rubberType.text = d['RubberType']?.toString() ?? 'No';
        _holeType.text = d['HoleType']?.toString() ?? 'No';
        _strippingType.text = d['StrippingType']?.toString() ?? 'No';
        _capsuleType.text = d['CapsuleType']?.toString() ?? 'No';
        _embossStatus.text = d['EmbossStatus']?.toString() ?? 'No';
        _embossPcs.text = d['EmbossPcs']?.toString() ?? '';
        _maleEmbossType.text = d['MaleEmbossType']?.toString() ?? '';
        _femaleEmbossType.text = d['FemaleEmbossType']?.toString() ?? '';
        _machineName.text = d['MachineName']?.toString() ?? '';
        _plywoodSizeGriper.text = d['PlywoodSizeGriper']?.toString() ?? '';
        _cuttingRule.text = d['CuttingRule']?.toString() ?? '';
        _creasingRule.text = d['CreasingRule']?.toString() ?? '';
        _materialToPunch.text = d['MaterialToPunch']?.toString() ?? '';
        _flute.text = d['Flute']?.toString() ?? '';
        _boardCompressedThickness.text = d['BoardCompressedThickness']?.toString() ?? '';
        _centerNotch.text = d['CenterNotch']?.toString() ?? '';
        _plywoodThickness.text = d['PlywoodThickness']?.toString() ?? '';
        _partinex.text = d['Partinex']?.toString() ?? '';
        _nicking.text = d['Nicking']?.toString() ?? '';
        _broaching.text = d['Broaching']?.toString() ?? '';
        _bladeWelding.text = d['BladeWelding']?.toString() ?? '';
        _strippingMaleFemale.text = d['StrippingMaleFemale']?.toString() ?? '';
        _sanwitchDie.text = d['SanwitchDie']?.toString() ?? '';
        final rawRubber = d['RubberOrWithout']?.toString() ?? '';
        _rubberOrWithout = _rubberOptions.firstWhere((o) => o.toLowerCase() == rawRubber.toLowerCase(), orElse: () => '');
        if (_rubberOrWithout!.isEmpty) _rubberOrWithout = null;
        _quoteDesignDone = d['quoteDesignDone'] == true;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Load error: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {

    if (_partyName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Party Name is required')));
      return;
    }
    setState(() => _saving = true);
    try {

      final data = {
        'PartyName': _partyName.text.trim(),
        'ParticularJobName': _jobName.text.trim(),
        'DeliveryAt': _deliveryAt.text.trim(),
        'OrderBy': _orderBy.text.trim(),
        'Remark': _remark.text.trim(),
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



      String saveDocId = widget.docId;
      if (!widget.docId.startsWith('QUOTE-')) {
        final now = DateTime.now();
        final month = now.month.toString().padLeft(2, '0');
        final year = (now.year % 100).toString().padLeft(2, '0');
        final counterRef = FirebaseFirestore.instance.collection("counters").doc("QUOTE_${now.year}_$month");
        await FirebaseFirestore.instance.runTransaction((tx) async {
          final snap = await tx.get(counterRef);
          int lastNo = snap.exists ? (snap.data()?["lastNo"] ?? 0) : 0;
          final newNo = lastNo + 1;
          tx.set(counterRef, {"lastNo": newNo}, SetOptions(merge: true));
          saveDocId = "QUOTE-${newNo.toString().padLeft(5, '0')}-$month-$year-01";
        });
      }
      await FirebaseFirestore.instance.collection('quotation_pending').doc(saveDocId).set({
        ...data,
        'quoteDesignDone': _quoteDesignDone,
        'createdAt': FieldValue.serverTimestamp(),  // ADD THIS
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // Mark original demo_customer_form doc as submitted
      if (!widget.docId.startsWith('QUOTE-')) {
        await FirebaseFirestore.instance
            .collection('demo_customer_form')
            .doc(widget.docId)
            .update({'quotationSubmitted': true});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quotation updated'), backgroundColor: Colors.green));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Pages ─────────────────────────────────────────────────────────────────

  Widget _page1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Party Name *'),
      SearchableDropdownWithInitial(
        label: "",
        items: _customerNames,
        initialValue: _partyName.text.isEmpty ? null : _partyName.text,
        onChanged: (v) => setState(() => _partyName.text = (v ?? '').trim()),
      ),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Job Name'),
      TextInput(label: "", hint: "Enter job name", controller: _jobName),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Priority'),
      PrioritySelector(
        initialValue: _priority ?? '',
        onChanged: (v) => setState(() => _priority = v),
      ),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Remark'),
      TextInput(label: "", hint: "Add a remark", controller: _remark),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Delivery At'),
      TextInput(label: "", hint: "Address", controller: _deliveryAt),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Order By'),
      TextInput(label: "", hint: "Name", controller: _orderBy),
    ])),
  ]);

  Widget _page2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Ply Type'),
      AddableSearchDropdown(label: "", items: _plyItems, initialValue: _plyType.text.isEmpty ? "No" : _plyType.text, firestoreCollection: "Plys", firestoreField: "Plys", onChanged: (v) => setState(() => _plyType.text = v ?? "No"), onAdd: (item) => setState(() => _plyItems.add(item))),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Blade'),
      SearchableDropdownWithInitial(label: "", items: _bladeItems, initialValue: _blade.text.isEmpty ? "No" : _blade.text, onChanged: (v) => setState(() => _blade.text = v ?? "No")),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Creasing'),
      SearchableDropdownWithInitial(label: "", items: _creasingItems, initialValue: _creasing.text.isEmpty ? "No" : _creasing.text, onChanged: (v) => setState(() => _creasing.text = v ?? "No")),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Perforation'),
      AddableSearchDropdown(label: "", items: _perforationItems, initialValue: _perforation.text.isEmpty ? "No" : _perforation.text, firestoreCollection: "Perforations", firestoreField: "Perforations", onChanged: (v) => setState(() => _perforation.text = v ?? "No"), onAdd: (item) => setState(() => _perforationItems.add(item))),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Zig Zag Blade'),
      AddableSearchDropdown(label: "", items: _zigZagBladeItems, initialValue: _zigZagBlade.text.isEmpty ? "No" : _zigZagBlade.text, firestoreCollection: "Zig Zags Blades", firestoreField: "Zig Zags Blades", onChanged: (v) => setState(() => _zigZagBlade.text = v ?? "No"), onAdd: (item) => setState(() => _zigZagBladeItems.add(item))),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Rubber Type'),
      AddableSearchDropdown(label: "", items: _rubberItems, initialValue: _rubberType.text.isEmpty ? "No" : _rubberType.text, firestoreCollection: "Rubbers", firestoreField: "Rubbers", onChanged: (v) => setState(() => _rubberType.text = v ?? "No"), onAdd: (item) => setState(() => _rubberItems.add(item))),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Hole Type'),
      AddableSearchDropdown(label: "", items: _holeItems, initialValue: _holeType.text.isEmpty ? "No" : _holeType.text, firestoreCollection: "Holes", firestoreField: "Holes", onChanged: (v) => setState(() => _holeType.text = v ?? "No"), onAdd: (item) => setState(() => _holeItems.add(item))),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Stripping Type'),
      AddableSearchDropdown(label: "", items: _strippingItems, initialValue: _strippingType.text.isEmpty ? "No" : _strippingType.text, firestoreCollection: "Strippings", firestoreField: "Strippings", onChanged: (v) => setState(() => _strippingType.text = v ?? "No"), onAdd: (item) => setState(() => _strippingItems.add(item))),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Capsule Type'),
      AddableSearchDropdown(label: "", items: _capsuleItems, initialValue: _capsuleType.text.isEmpty ? "No" : _capsuleType.text, firestoreCollection: "Capsules", firestoreField: "Capsules", onChanged: (v) => setState(() => _capsuleType.text = v ?? "No"), onAdd: (item) => setState(() => _capsuleItems.add(item))),
    ])),
  ]);

  Widget _page3() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Emboss'),
      FlexibleToggle(label: "", inactiveText: "No", activeText: "Yes", initialValue: _embossStatus.text.toLowerCase() == 'yes', onChanged: (v) => setState(() => _embossStatus.text = v ? 'Yes' : 'No')),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Emboss Pcs'),
      TextInput(label: "", hint: "No of Pcs", controller: _embossPcs),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Male Emboss'),
      AddableSearchDropdown(label: "", items: _maleEmbossItems, initialValue: _maleEmbossType.text.isEmpty ? "No" : _maleEmbossType.text, firestoreCollection: "Males Embosse", firestoreField: "Males Embosse", onChanged: (v) => setState(() => _maleEmbossType.text = v ?? ""), onAdd: (item) => setState(() => _maleEmbossItems.add(item))),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Female Emboss'),
      AddableSearchDropdown(label: "", items: _femaleEmbossItems, initialValue: _femaleEmbossType.text.isEmpty ? "No" : _femaleEmbossType.text, firestoreCollection: "Females Emobosse", firestoreField: "Females Emobosse", onChanged: (v) => setState(() => _femaleEmbossType.text = v ?? ""), onAdd: (item) => setState(() => _femaleEmbossItems.add(item))),
    ])),
  ]);

  Widget _page4() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Machine Name'),
      TextInput(label: "", hint: "Machine name", controller: _machineName),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Ply Wood Size & Griper'),
      TextInput(label: "", hint: "e.g. 30x40, Griper 5mm", controller: _plywoodSizeGriper),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Rubber Or Without Rubber'),
      SearchableDropdownWithInitial(label: "", items: _rubberOptions, initialValue: _rubberOrWithout, onChanged: (v) => setState(() => _rubberOrWithout = v)),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Cutting Rule'),
      TextInput(label: "", hint: "Cutting rule details", controller: _cuttingRule),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Creasing Rule'),
      TextInput(label: "", hint: "Creasing rule details", controller: _creasingRule),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Material To Punch'),
      TextInput(label: "", hint: "Material description", controller: _materialToPunch),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Flute'),
      TextInput(label: "", hint: "Flute type", controller: _flute),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Board Compressed Thickness'),
      TextInput(label: "", hint: "e.g. 4mm", controller: _boardCompressedThickness),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Center Notch'),
      TextInput(label: "", hint: "Center notch details", controller: _centerNotch),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Ply Wood Thickness'),
      TextInput(label: "", hint: "e.g. 18mm", controller: _plywoodThickness),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Partinex'),
      TextInput(label: "", hint: "Partinex details", controller: _partinex),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Nicking'),
      TextInput(label: "", hint: "Nicking details", controller: _nicking),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Broaching'),
      TextInput(label: "", hint: "Broaching details", controller: _broaching),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Blade Welding'),
      TextInput(label: "", hint: "Blade welding details", controller: _bladeWelding),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Stripping Male & Female'),
      TextInput(label: "", hint: "Stripping details", controller: _strippingMaleFemale),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Sanwitch Die'),
      TextInput(label: "", hint: "Sanwitch die details", controller: _sanwitchDie),
    ])),
    _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Quote Design Done'),
      FlexibleToggle(
        label: "",
        inactiveText: "Pending",
        activeText: "Done",
        initialValue: _quoteDesignDone,
        onChanged: (v) => setState(() => _quoteDesignDone = v),
      ),
    ])),
  ]);

  @override
  Widget build(BuildContext context) {
    final isLast = _step == 4;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back, size: 22), onPressed: () => context.pop()),
        title: const Text('Edit Quotation', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(56), child: _StepHeader(currentStep: _step)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_step == 1) _page1(),
          if (_step == 2) _page2(),
          if (_step == 3) _page3(),
          if (_step == 4) _page4(),
        ]),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(children: [
          if (_step > 1) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Color(0xFFF8D94B), width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Prev', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _saving ? null : () { if (isLast) { _save(); } else { setState(() => _step++); } },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF8D94B), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text(isLast ? 'Save Quotation' : 'Next', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }
}