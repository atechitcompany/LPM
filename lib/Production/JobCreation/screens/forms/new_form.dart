import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/department_field_access.dart';

import 'new_form_scope.dart';

enum Department {
  Designer,
  AutoBending,
  ManualBending,
  Lasercut,
  Emboss,
  Rubber,
  Account,
  Delivery,
}

class NewForm extends StatefulWidget {
  final Widget child;
  final String department;
  final String? lpm;
  final String? mode;

  const NewForm({super.key,
    required this.child,
    required this.department,
    this.lpm,
    this.mode,
  });

  @override
  State<NewForm> createState() => NewFormState();

}

class NewFormState extends State<NewForm> {
  late String department;
  late bool isEditMode;
  bool get isLastDesignerPage {
    if (department != "Designer") return false;

    final location = GoRouterState.of(context).uri.toString();
    return location == '/jobform/designer-6';
  }

  bool get isJobFormRoute {
    final location = GoRouterState.of(context).uri.toString();
    return location.startsWith('/jobform');
  }

  String fieldPermission(String key) {
    final access = DepartmentFieldAccess.access(department);
    return access[key] ?? "hide";
  }

  bool canView(String key) => fieldPermission(key) != "hide";

  bool canEdit(String key) =>
      fieldPermission(key) == "edit" && isEditMode;



  List<String> parties = ["Tata", "Jindal", "Infosys"];
  List<String> jobs = ["Laser", "Bending", "Cutting"];
  List<String> ply = [
    "No",
    "18mm CHW Ply",
    "18mm White Birch",
    "18mm Blue Birch",
  ];
  List<String> HouseNoList = ["101", "102", "103", "104", "B1-22"];
  List<String> AppartmentList = [
    "Om Heights",
    "Green Palace",
    "Skyline Residency",
    "Sai Apartment",
  ];
  List<String> StreetList = [
    "Link Road",
    "M.G. Road",
    "Station Road",
    "SV Road",
  ];
  List<String> PincodeList = ["400104", "400058", "400064", "400092"];

  final BuyerOrderNo = TextEditingController();
  final DeliveryAt = TextEditingController();
  final Orderby = TextEditingController();
  final Remark = TextEditingController();
  final Ups = TextEditingController();
  final PartyworkName = TextEditingController();
  final Size = TextEditingController();
  final Size2 = TextEditingController();
  final Size3 = TextEditingController();
  final Size4 = TextEditingController();
  final Size5 = TextEditingController();
  final Ups_32 = TextEditingController();
  final PlyLength = TextEditingController();
  final PlyBreadth = TextEditingController();
  final BladeSize = TextEditingController();
  final Extra = TextEditingController();
  final CapsuleRate = TextEditingController();
  final CreasingSize = TextEditingController();
  final DeliveryURL = TextEditingController();
  final Unknown = TextEditingController();
  final AddressOutput = TextEditingController();
  final DesignSendBy = TextEditingController();
  final CapsulePcs = TextEditingController();
  final CapsuleAmt = TextEditingController();
  final PerforationSize = TextEditingController();
  final ZigZagBladeSize = TextEditingController();
  final RubberSize = TextEditingController();
  final EmbossPcs = TextEditingController();
  final TotalSize = TextEditingController();
  final MinimumChargeApply = TextEditingController();
  final MaleRate = TextEditingController();
  final X = TextEditingController();
  final Y = TextEditingController();
  final XYSize = TextEditingController();
  final FemaleRate = TextEditingController();
  final X2 = TextEditingController();
  final Y2 = TextEditingController();
  final XY2Size = TextEditingController();
  final StrippingSize = TextEditingController();
  final CourierCharges = TextEditingController();
  final LaserRate = TextEditingController();
  final InvoicePrintedBy = TextEditingController();
  final CreatedBy = TextEditingController();
  final Amounts3 = TextEditingController();
  final DesignerCreatedBy = TextEditingController();
  final AutoBendingCreatedBy = TextEditingController();
  final LaserCuttingCreatedBy = TextEditingController();
  final AccountsCreatedBy = TextEditingController();
  final EmbossCreatedBy = TextEditingController();
  final ManualBendingCreatedBy = TextEditingController();
  final ManualBendingFittingDoneBy = TextEditingController();
  final GSTType = TextEditingController();
  final ParticularJobName = TextEditingController();
  final Priority = TextEditingController();
  final DesigningStatus = TextEditingController();
  final LaserPunchNew = TextEditingController();
  final PlyType = TextEditingController();
  final Blade = TextEditingController();
  final Creasing = TextEditingController();
  final RubberDoneBy = TextEditingController();
  final DeliveryCreatedBy = TextEditingController();
  final DeliveryStatus = TextEditingController();
  final ReceiverName = TextEditingController();
  final TransportName = TextEditingController();
  final CapsuleType = TextEditingController();
  final ZigZagBlade = TextEditingController();
  final ZigZagBladeType = TextEditingController();
  final RubberType = TextEditingController();
  final HoleType = TextEditingController();
  final EmbossStatus = TextEditingController();
  final MaleEmbossType = TextEditingController();
  final FemaleEmbossType = TextEditingController();
  final StrippingType = TextEditingController();
  final AutoCreasingStatus = TextEditingController();
  final LaserDoneBy = TextEditingController();
  final LaserCuttingStatus = TextEditingController();
  final AutoBendingDoneBy = TextEditingController();
  final InvoiceStatus = TextEditingController();
  final ParticularSlider = TextEditingController();
  final RubberFixingDone = TextEditingController();
  final WhiteProfileRubber = TextEditingController();
  final Perforation = TextEditingController();

  //new
  final PartyName = TextEditingController();
  final TextEditingController DesignedBy = TextEditingController();
  final TextEditingController PlySelectedBy = TextEditingController();
  final TextEditingController BladeSelectedBy = TextEditingController();
  final TextEditingController CreasingSelectedBy = TextEditingController();
  final TextEditingController PerforationSelectedBy = TextEditingController();
  final TextEditingController ZigZagBladeSelectedBy = TextEditingController();
  final TextEditingController RubberSelectedBy = TextEditingController();
  final TextEditingController HoleSelectedBy = TextEditingController();
  final LpmAutoIncrement = TextEditingController();
  final JobDone = TextEditingController();



  bool AutoCreasing = false;


  String HouseNo = "";
  String Appartment = "";
  String Street = "";
  String Pincode = "";
  String User = "";

  Map<String, dynamic> buildFormData() {
    return {
      // Basic Info
      "LpmAutoIncrement": LpmAutoIncrement.text,

      "BuyerOrderNo": BuyerOrderNo.text,
      "DeliveryAt": DeliveryAt.text,
      "Orderby": Orderby.text,
      "Remark": Remark.text,
      "Ups": Ups.text,
      "PartyworkName": PartyworkName.text,
      "Size": Size.text,
      "Size2": Size2.text,
      "Size3": Size3.text,
      "Size4": Size4.text,
      "Size5": Size5.text,
      "Ups_32": Ups_32.text,

      // Ply
      "PlyLength": PlyLength.text,
      "PlyBreadth": PlyBreadth.text,

      // Blade
      "Blade": Blade.text,
      "BladeSize": BladeSize.text,

      // Extra
      "Extra": Extra.text,

      // Creasing
      "Creasing": Creasing.text,
      "CreasingSize": CreasingSize.text,

      // Capsule
      "CapsuleType": CapsuleType.text,
      "CapsuleRate": CapsuleRate.text,
      "CapsulePcs": CapsulePcs.text,
      "CapsuleAmt": CapsuleAmt.text,

      // Perforation
      "ZigZagBlade": ZigZagBlade.text,
      "PerforationSize": PerforationSize.text,

      // ZigZag
      "ZigZagBladeType": ZigZagBladeType.text,
      "ZigZagBladeSize": ZigZagBladeSize.text,

      // Rubber
      "RubberType": RubberType.text,
      "RubberSize": RubberSize.text,
      "RubberDoneBy": RubberDoneBy.text,

      // Hole
      "HoleType": HoleType.text,

      // Emboss
      "EmbossPcs": EmbossPcs.text,
      "TotalSize": TotalSize.text,
      "MinimumChargeApply": MinimumChargeApply.text,

      // Male emboss
      "MaleEmbossType": MaleEmbossType.text,
      "MaleRate": MaleRate.text,
      "X": X.text,
      "Y": Y.text,
      "XYSize": XYSize.text,

      // Female emboss
      "FemaleEmbossType": FemaleEmbossType.text,
      "FemaleRate": FemaleRate.text,
      "X2": X2.text,
      "Y2": Y2.text,
      "XY2Size": XY2Size.text,

      // Stripping
      "StrippingType": StrippingType.text,
      "StrippingSize": StrippingSize.text,

      // Courier
      "CourierCharges": CourierCharges.text,

      // Laser
      "LaserPunchNew": LaserPunchNew.text,
      "LaserRate": LaserRate.text,
      "LaserDoneBy": LaserDoneBy.text,
      "LaserCuttingStatus": LaserCuttingStatus.text,
      "AutoBendingDoneBy": AutoBendingDoneBy.text,

      // Address fields
      "FullAddress": AddressOutput.text,
      "DeliveryURL": DeliveryURL.text,

      // Additional fields
      "Unknown": Unknown.text,
      "DesignSendBy": DesignSendBy.text,
      "ReceiverName": ReceiverName.text,
      "TransportName": TransportName.text,

      // Status fields
      "DesigningStatus": DesigningStatus.text,
      "DeliveryStatus": DeliveryStatus.text,
      "EmbossStatus": EmbossStatus.text,
      "AutoCreasingStatus": AutoCreasingStatus.text,
      "InvoiceStatus": InvoiceStatus.text,

      // Created By
      "InvoicePrintedBy": InvoicePrintedBy.text,
      "CreatedBy": CreatedBy.text,
      "DesignerCreatedBy": DesignerCreatedBy.text,
      "AutoBendingCreatedBy": AutoBendingCreatedBy.text,
      "LaserCuttingCreatedBy": LaserCuttingCreatedBy.text,
      "AccountsCreatedBy": AccountsCreatedBy.text,
      "EmbossCreatedBy": EmbossCreatedBy.text,
      "ManualBendingCreatedBy": ManualBendingCreatedBy.text,
      "ManualBendingFittingDoneBy": ManualBendingFittingDoneBy.text,
      "DeliveryCreatedBy": DeliveryCreatedBy.text,

      // Other
      "GSTType": GSTType.text,
      "PartyName": PartyName.text,
      "ParticularJobName": ParticularJobName.text,
      "Priority": Priority.text,
      "PlyType": PlyType.text,
      "Amounts3": Amounts3.text,
      "ParticularSlider": ParticularSlider.text,

      "RubberFixingDone": RubberFixingDone.text,
      "WhiteProfileRubber": WhiteProfileRubber.text,

      "Timestamp": DateTime.now().toIso8601String(),
    };
  }

  void updateAddress() {
    String fullAddress = "$HouseNo, $Appartment, $Street, $Pincode"
        .replaceAll(", ,", ",") // remove blank commas
        .replaceAll(" ,", ",")
        .trim();

    AddressOutput.text = fullAddress;
    setState(() {});
  }

  void updateCapsuleAmt() {
    double pcs = double.tryParse(CapsulePcs.text) ?? 0;
    double rate = double.tryParse(CapsuleRate.text) ?? 0;

    double total = pcs * rate;

    CapsuleAmt.text = total.toStringAsFixed(2);
    setState(() {});
  }

  void calculateXY() {
    double xVal = double.tryParse(X.text) ?? 0;
    double yVal = double.tryParse(Y.text) ?? 0;

    final result = xVal * yVal;

    XYSize.text = result.toStringAsFixed(2);
    setState(() {});
  }

  void calculateXY2() {
    double xVal = double.tryParse(X2.text) ?? 0;
    double yVal = double.tryParse(Y2.text) ?? 0;

    final result = xVal * yVal;

    XY2Size.text = result.toStringAsFixed(2);
    setState(() {});
  }

  // ---------- add this inside NewFormState ----------

  void clearForm() {
    // Clear all text controllers
    BuyerOrderNo.clear();
    DeliveryAt.clear();
    Orderby.clear();
    Remark.clear();
    Ups.clear();
    PartyworkName.clear();
    Size.clear();
    Size2.clear();
    Size3.clear();
    Size4.clear();
    Size5.clear();
    Ups_32.clear();
    PlyLength.clear();
    PlyBreadth.clear();
    Blade.clear();
    BladeSize.clear();
    Extra.clear();
    Creasing.clear();
    CreasingSize.clear();
    CapsuleType.clear();
    CapsuleRate.clear();
    CapsulePcs.clear();
    CapsuleAmt.clear();
    ZigZagBlade.clear();
    PerforationSize.clear();
    ZigZagBladeType.clear();
    ZigZagBladeSize.clear();
    RubberType.clear();
    RubberSize.clear();
    RubberDoneBy.clear();
    HoleType.clear();
    EmbossPcs.clear();
    TotalSize.clear();
    MinimumChargeApply.clear();
    MaleEmbossType.clear();
    MaleRate.clear();
    X.clear();
    Y.clear();
    XYSize.clear();
    FemaleEmbossType.clear();
    FemaleRate.clear();
    X2.clear();
    Y2.clear();
    XY2Size.clear();
    StrippingType.clear();
    StrippingSize.clear();
    CourierCharges.clear();
    LaserPunchNew.clear();
    LaserRate.clear();
    LaserDoneBy.clear();
    LaserCuttingStatus.clear();

    DeliveryURL.clear();
    Unknown.clear();
    DesignSendBy.clear();
    ReceiverName.clear();
    TransportName.clear();
    DesigningStatus.clear();
    DeliveryStatus.clear();
    EmbossStatus.clear();
    AutoCreasingStatus.clear();
    InvoiceStatus.clear();
    InvoicePrintedBy.clear();
    CreatedBy.clear();
    DesignerCreatedBy.clear();
    AutoBendingCreatedBy.clear();
    LaserCuttingCreatedBy.clear();
    AccountsCreatedBy.clear();
    EmbossCreatedBy.clear();
    ManualBendingCreatedBy.clear();
    ManualBendingFittingDoneBy.clear();
    DeliveryCreatedBy.clear();
    GSTType.clear();
    ParticularJobName.clear();
    Priority.clear();
    PlyType.clear();
    Amounts3.clear();
    ParticularSlider.clear();
    AddressOutput.clear();
    RubberFixingDone.clear();
    WhiteProfileRubber.clear();
    //new
    // ✅ clear new fields
    DesignedBy.clear();
    PlySelectedBy.clear();
    BladeSelectedBy.clear();
    CreasingSelectedBy.clear();
    PerforationSelectedBy.clear();
    ZigZagBladeSelectedBy.clear();
    RubberSelectedBy.clear();
    HoleSelectedBy.clear();
    Perforation.clear();
    PartyName.clear();



    Remark.text = "NO REMARK";
    Ups.text = "NO";
    PartyworkName.text = "NO";
    Size.text = "NO";
    Size2.text = "NO";
    Size3.text = "NO";
    Size4.text = "NO";
    Size5.text = "NO";
    DeliveryURL.text = "URL";
    EmbossPcs.text = "No";
    TotalSize.text = "No";
    Unknown.text = "";
    // Add all fields that have initialValue

    // Example Toggles (default values):
    DesigningStatus.text = "Pending";
    DeliveryStatus.text = "Pending";
    InvoiceStatus.text = "Pending";
    LaserCuttingStatus.text = "Pending";
    LaserPunchNew.text = "No";


    // Dropdowns default
    PlyType.text = "No";
    Creasing.text = "No";
    // Reset dropdown / address selection state
    setState(() {
      HouseNo = "";
      Appartment = "";
      Street = "";
      Pincode = "";
    });
  }

  Future<void> loadCurrentLpm() async {
    try {
      final counterRef =
      FirebaseFirestore.instance.collection("counters").doc("jobCounter");

      final snap = await counterRef.get();

      int last = 1000;

      if (snap.exists) {
        final val = snap.data()?["lastLpm"];

        if (val is int) {
          last = val;
        } else if (val is String) {
          last = int.tryParse(val) ?? 1000;
        }
      } else {
        await counterRef.set({"lastLpm": 1000});
        last = 1000;
      }

      LpmAutoIncrement.text = (last + 1).toString();
      setState(() {});
    } catch (e) {
      print("❌ loadCurrentLpm error: $e");
      // ✅ fallback so UI doesn't spin forever
      LpmAutoIncrement.text = "1001";
      setState(() {});
    }
  }



  Future<void> incrementLpmAfterSubmit() async {
    final counterRef =
    FirebaseFirestore.instance.collection("counters").doc("jobCounter");

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snap = await transaction.get(counterRef);

      int last = 1000;
      if (snap.exists) {
        last = (snap.data()?["lastLpm"] ?? 1000);
      }

      transaction.set(counterRef, {"lastLpm": last + 1}, SetOptions(merge: true));
    });
  }

  Future<void> submitDesignerForm() async {
    final data = buildFormData();

    final lpm = LpmAutoIncrement.text; // 🔥 unique ID

    final jobRef =
    FirebaseFirestore.instance.collection("jobs").doc(lpm);

    await jobRef.set({
      "lpm": lpm,
      "currentDepartment": "AutoBending",
      "status": "InProgress",

      "designer": {
        "submitted": true,
        "data": data,
      },

      "autoBending": {"submitted": false},
      "manualBending": {"submitted": false},
      "laserCut": {"submitted": false},
      "emboss": {"submitted": false},
      "rubber": {"submitted": false},
      "account": {"submitted": false},
      "delivery": {"submitted": false},

      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    await incrementLpmAfterSubmit();
  }

  Future<void> submitDepartmentForm(String nextDepartment) async {
    final data = buildFormData();

    final lpm = LpmAutoIncrement.text; // already loaded

    await FirebaseFirestore.instance
        .collection("jobs")
        .doc(lpm)
        .update({
      "${_deptKey(department)}.submitted": true,
      "${_deptKey(department)}.data": data,
      "currentDepartment": nextDepartment,
      "updatedAt": FieldValue.serverTimestamp(),
  });
  }



  Future<void> submitForm() async {
    try {
      if (department == "Designer") {
        await submitDesignerForm();
      } else {
        await submitDepartmentForm(_nextDepartment(department));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Form submitted successfully")),
      );

      context.pop(); // back to dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _loadJob(String lpm) async {
    final doc = await FirebaseFirestore.instance
        .collection("jobs")
        .doc(lpm)
        .get();

    final data = doc.data()!;
    final designer = data["designer"]?["data"] ?? {};
    final autobending = data["autoBending"]?["data"] ?? {};

    PartyName.text = designer["PartyName"] ?? "";
    DeliveryAt.text = designer["DeliveryAt"] ?? "";
    ParticularJobName.text = designer["ParticularJobName"] ?? "";

    AutoCreasingStatus.text =
        autobending["AutoCreasingStatus"] ?? "";
  }



  @override
  void initState() {
    super.initState();
    isEditMode = widget.mode == 'edit';
    department = widget.department;

    if (widget.lpm != null) {
      // 🔥 Existing job
      LpmAutoIncrement.text = widget.lpm!;
    } else {
      // 🔥 New job (Designer only)
      loadCurrentLpm();
    }

    if (widget.lpm != null) {
      _loadJob(widget.lpm!);
    }

    // defaults
    Remark.text = "NO REMARK";
    Ups.text = "NO";
    PartyworkName.text = "NO";
    Size.text = "NO";
    Size2.text = "NO";
    Size3.text = "NO";
    Size4.text = "NO";
    Size5.text = "NO";
    DeliveryURL.text = "URL";

    DesigningStatus.text = "Pending";
    DeliveryStatus.text = "Pending";
    InvoiceStatus.text = "Pending";
    LaserCuttingStatus.text = "Pending";
    LaserPunchNew.text = "No";

    PlyType.text = "No";
    Creasing.text = "No";
  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    BuyerOrderNo.dispose();
    DeliveryAt.dispose();
    Orderby.dispose();
    Remark.dispose();
    Ups.dispose();
    PartyworkName.dispose();
    Size.dispose();
    Size2.dispose();
    Size3.dispose();
    Size4.dispose();
    Size5.dispose();
    Ups_32.dispose();
    PlyLength.dispose();
    PlyBreadth.dispose();
    Blade.dispose();
    BladeSize.dispose();
    Extra.dispose();
    Creasing.dispose();
    CreasingSize.dispose();
    CapsuleType.dispose();
    CapsuleRate.dispose();
    CapsulePcs.dispose();
    CapsuleAmt.dispose();
    ZigZagBlade.dispose();
    PerforationSize.dispose();
    ZigZagBladeType.dispose();
    ZigZagBladeSize.dispose();
    RubberType.dispose();
    RubberSize.dispose();
    RubberDoneBy.dispose();
    HoleType.dispose();
    EmbossPcs.dispose();
    TotalSize.dispose();
    MinimumChargeApply.dispose();
    MaleEmbossType.dispose();
    MaleRate.dispose();
    X.dispose();
    Y.dispose();
    XYSize.dispose();
    FemaleEmbossType.dispose();
    FemaleRate.dispose();
    X2.dispose();
    Y2.dispose();
    XY2Size.dispose();
    StrippingType.dispose();
    StrippingSize.dispose();
    CourierCharges.dispose();
    LaserPunchNew.dispose();
    LaserRate.dispose();
    LaserDoneBy.dispose();
    LaserCuttingStatus.dispose();
    AutoBendingDoneBy.dispose();
    DeliveryURL.dispose();
    Unknown.dispose();
    DesignSendBy.dispose();
    ReceiverName.dispose();
    TransportName.dispose();
    DesigningStatus.dispose();
    DeliveryStatus.dispose();
    EmbossStatus.dispose();
    AutoCreasingStatus.dispose();
    InvoiceStatus.dispose();
    InvoicePrintedBy.dispose();
    CreatedBy.dispose();
    DesignerCreatedBy.dispose();
    AutoBendingCreatedBy.dispose();
    LaserCuttingCreatedBy.dispose();
    AccountsCreatedBy.dispose();
    EmbossCreatedBy.dispose();
    ManualBendingCreatedBy.dispose();
    ManualBendingFittingDoneBy.dispose();
    DeliveryCreatedBy.dispose();
    GSTType.dispose();
    ParticularJobName.dispose();
    Priority.dispose();
    PlyType.dispose();
    Amounts3.dispose();
    ParticularSlider.dispose();
    AddressOutput.dispose();
    RubberFixingDone.dispose();
    WhiteProfileRubber.dispose();
    //new
    DesignedBy.dispose();
    PlySelectedBy.dispose();
    BladeSelectedBy.dispose();
    CreasingSelectedBy.dispose();
    PerforationSelectedBy.dispose();
    ZigZagBladeSelectedBy.dispose();
    RubberSelectedBy.dispose();
    HoleSelectedBy.dispose();
    Perforation.dispose();
    PartyName.dispose();

    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    return NewFormScope(
      form: this,
      child: Scaffold(
        body: Column(
          children: [
            // 🔹 FORM PAGE
            Expanded(child: widget.child),

            // 🔹 PREV / NEXT BUTTONS
            if (isJobFormRoute)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _goPrev,
                      child: const Text("Previous"),
                    ),

                    if (!(department == "Designer" && isLastDesignerPage))
                      ElevatedButton(
                        onPressed: _goNext,
                        child: const Text("Next"),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -------- Navigation Logic --------

  void _goDesignerNext() {
    final location = GoRouterState.of(context).uri.toString();

    const designerPages = [
      '/jobform/designer-1',
      '/jobform/designer-2',
      '/jobform/designer-3',
      '/jobform/designer-4',
      '/jobform/designer-5',
      '/jobform/designer-6',
    ];

    final index = designerPages.indexOf(location);
    if (index != -1 && index < designerPages.length - 1) {
      context.push(designerPages[index + 1]);
    }
  }


  void _goNext() {
    if (department == "Designer") {
      _goDesignerNext();
    }
  }


  void _goPrev() {
    if (context.canPop()) {
      context.pop(); // ✅ Goes back without rebuilding state
    }
  }
  String _nextDepartment(String current) {
    const flow = [
      "Designer",
      "AutoBending",
      "ManualBending",
      "Lasercut",
      "Emboss",
      "Rubber",
      "Account",
      "Delivery",
    ];

    final index = flow.indexOf(current);
    if (index == -1 || index == flow.length - 1) {
      return "Completed";
    }

    return flow[index + 1];
  }

  String _deptKey(String dept) {
    switch (dept) {
      case "Designer":
        return "designer";
      case "AutoBending":
        return "autoBending";
      case "ManualBending":
        return "manualBending";
      case "Lasercut":
        return "laserCut";
      case "Emboss":
        return "emboss";
      case "Rubber":
        return "rubber";
      case "Account":
        return "account";
      case "Delivery":
        return "delivery";
      default:
        throw Exception("Unknown department: $dept");
    }
  }

}
