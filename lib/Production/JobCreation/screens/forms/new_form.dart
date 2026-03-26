import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/department_field_access.dart';

import 'new_form_scope.dart';

enum Department {
  Designer,
  AutoBending,
  ManualBending,
  LaserCutting,
  Emboss,
  Rubber,
  Account,
  Delivery,
  Completed,
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

    final location = GoRouterState.of(context).uri.path;
    return location == '/jobform/designer-6';
  }

  bool get _isFirstDesignerPage {
    if (department != "Designer") return false;

    final location = GoRouterState.of(context).uri.path;
    return location == '/jobform/designer-1';
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
  List<String> embossTypes = ["Type A", "Type B", "Type C"];
  List<String> bladeTypes = ["Zig Zag 1", "Zig Zag 2", "Zig Zag 3"];
  List<String> rubberTypes = ["Rubber A", "Rubber B", "Rubber C"];
  List<String> holeTypes = ["Hole 1", "Hole 2", "Hole 3"];
  List<String> capsuleTypes = ["Capsule A", "Capsule B", "Capsule C"];
  List<String> strippingTypes = ["Strip 1", "Strip 2", "Strip 3"];
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
  String? get mode => widget.mode;
  String? get lpm => widget.lpm;

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
  final AutoBendingStatus = TextEditingController();
  final AutoBendingCreatedBy = TextEditingController();
  final LaserCuttingCreatedBy = TextEditingController();
  final AccountsCreatedBy = TextEditingController();
  final EmbossCreatedBy = TextEditingController();
  final ManualBendingStatus = TextEditingController();
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
  final RubberStatus = TextEditingController();
  final RubberCreatedBy = TextEditingController();
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

  void clearDesignerData() {
    PartyName.clear();
    DesignerCreatedBy.clear();
    DeliveryAt.clear();
    Orderby.clear();
    ParticularJobName.clear();
    Priority.clear();
    Remark.clear();


    DesignedBy.clear();

    PlyType.text = "No";
    PlySelectedBy.clear();

    Blade.text = "No";
    BladeSelectedBy.clear();

    Creasing.text = "No";
    CreasingSelectedBy.clear();

    Perforation.text = "No";
    PerforationSelectedBy.clear();

    ZigZagBlade.text = "No";
    ZigZagBladeSelectedBy.clear();

    RubberType.text = "No";
    RubberSelectedBy.clear();

    HoleType.text = "No";
    HoleSelectedBy.clear();

    EmbossStatus.text = "No";
    EmbossPcs.clear();

    MaleEmbossType.text = "No";
    FemaleEmbossType.text = "No";

    X.clear();
    Y.clear();
    X2.clear();
    Y2.clear();

    StrippingType.text = "No";
    LaserCuttingStatus.text = "Pending";
    RubberFixingDone.text = "No";
    WhiteProfileRubber.text = "No";
  }

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
      "ManualBendingStatus": ManualBendingStatus.text,
      "AutobendingStatus": AutoBendingStatus.text,
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
    ManualBendingStatus.clear();
    AutoBendingStatus.clear();
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
    AutoBendingStatus.text = "Pending";
    ManualBendingStatus.text="Pending";
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
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      final year = (now.year % 100).toString().padLeft(2, '0');
      final counterDocId = "${now.year}_$month";

      debugPrint("⏳ Loading LPM... counterDoc=$counterDocId");

      final counterRef = FirebaseFirestore.instance
          .collection("counters")
          .doc(counterDocId);

      // ✅ Set a timeout so it doesn't hang forever if offline
      final snap = await counterRef.get().timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw Exception("Firestore timeout — no internet?"),
      );

      int lastOrderNo = 0;
      if (snap.exists) {
        lastOrderNo = snap.data()?["lastOrderNo"] ?? 0;
      } else {
        await counterRef.set({"lastOrderNo": 0});
      }

      final newOrderNo = (lastOrderNo + 1).toString().padLeft(5, '0');
      final fullLpm = "LPM-$newOrderNo-$month-$year-01";

      debugPrint("✅ LPM Generated: $fullLpm");

      if (mounted) {
        setState(() {
          LpmAutoIncrement.text = fullLpm;
        });
      }

    } catch (e) {
      debugPrint("❌ LPM Load Error: $e");

      // ✅ Fallback: generate a temporary LPM from timestamp (no Firestore needed)
      if (mounted) {
        final now = DateTime.now();
        final month = now.month.toString().padLeft(2, '0');
        final year = (now.year % 100).toString().padLeft(2, '0');
        final tempNo = now.millisecondsSinceEpoch.toString().substring(7); // last 6 digits
        final fallbackLpm = "LPM-TEMP$tempNo-$month-$year-01";

        debugPrint("⚠️ Using fallback LPM: $fallbackLpm");

        setState(() {
          LpmAutoIncrement.text = fallbackLpm;
        });

        // Show a warning to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ No internet — using temporary LPM. Please resubmit when online."),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }



  Future<void> incrementMonthlyCounter() async {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final counterDocId = "${now.year}_$month";

    final counterRef =
    FirebaseFirestore.instance.collection("counters").doc(counterDocId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snap = await transaction.get(counterRef);

      int lastOrderNo = 0;

      if (snap.exists) {
        lastOrderNo = snap.data()?["lastOrderNo"] ?? 0;
      }

      transaction.set(
        counterRef,
        {"lastOrderNo": lastOrderNo + 1},
        SetOptions(merge: true),
      );
    });
  }

  Future<void> submitDesignerForm() async {
    try {
      final fullLpm = LpmAutoIncrement.text.trim();

      debugPrint("📝 Starting Designer Form Submission");
      debugPrint("🔑 Full LPM: $fullLpm");

      // ✅ VALIDATION: Check if LPM is empty
      if (fullLpm.isEmpty) {
        throw Exception("❌ LPM Auto Increment is empty. Cannot submit form.");
      }

      // ✅ VALIDATION: Check LPM format
      // ✅ If editing, LpmAutoIncrement might be the main doc ID (4 parts)
// Append "-01" to make it a valid full LPM
      String resolvedLpm = fullLpm;
      if (fullLpm.split("-").length == 4) {
        resolvedLpm = "$fullLpm-01";
        debugPrint("⚠️ LPM was 4 parts, resolved to: $resolvedLpm");
      }

      final parts = resolvedLpm.split("-");
      debugPrint("🔍 LPM Parts: $parts (Total: ${parts.length} parts)");

      if (parts.length < 5) {
        throw Exception(
            "❌ Invalid LPM format. Expected: LPM-ORDER-MONTH-YEAR-SUB\n"
                "Got: $resolvedLpm (${parts.length} parts instead of 5)"
        );
      }

      // ✅ PARSE: Extract LPM components safely
      String orderNo = parts[1];
      String month = parts[2];
      String year = parts[3];
      String subOrderNo = parts[4];

      debugPrint("✅ Parsed LPM: orderNo=$orderNo, month=$month, year=$year, sub=$subOrderNo");

      // ✅ BUILD: Create main order ID
      final mainOrderId = "LPM-$orderNo-$month-$year";
      debugPrint("📋 Main Order ID: $mainOrderId");

      // ✅ GET: References
      final mainOrderRef = FirebaseFirestore.instance.collection("jobs").doc(mainOrderId);
      final itemRef = mainOrderRef.collection("items").doc(subOrderNo);

      debugPrint("📌 Document References created");

      // ✅ VALIDATE: Required fields for Designer
      if (PartyName.text.trim().isEmpty) {
        throw Exception("❌ Party Name is required");
      }
      if (ParticularJobName.text.trim().isEmpty) {
        throw Exception("❌ Particular Job Name is required");
      }

      debugPrint("✅ Required fields validated");

      // ✅ BUILD: Form data
      final data = buildFormData();
      debugPrint("📦 Form data prepared: ${data.keys.length} fields");

      // ✅ SAVE: Main order document
      debugPrint("💾 Writing main order document...");
      final isDesigningDone = DesigningStatus.text.trim().toLowerCase() == "done";

      await mainOrderRef.set({
        "orderNo": orderNo,
        "month": month,
        "year": year,
        "currentDepartment": isDesigningDone ? "AutoBending" : "Designer",
        "visibleTo": isDesigningDone
            ? ["Designer", "AutoBending"]
            : ["Designer"],
        "designer": {
          "submitted": true,
          "submittedAt": FieldValue.serverTimestamp(),
          "submittedBy": DesignerCreatedBy.text.isNotEmpty
              ? DesignerCreatedBy.text
              : "Unknown",
          "data": data,
        },
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint("✅ Main order document written");

      // ✅ SAVE: Sub-order item document
      debugPrint("💾 Writing sub-order item document...");
      await itemRef.set({
        "fullLpm": resolvedLpm,
        "subOrderNo": subOrderNo,
        "currentDepartment": isDesigningDone ? "AutoBending" : "Designer",
        "visibleTo": isDesigningDone
            ? ["Designer", "AutoBending"]
            : ["Designer"],
        "status": "InProgress",
        "designer": {
          "submitted": true,
          "submittedAt": FieldValue.serverTimestamp(),
          "submittedBy": DesignerCreatedBy.text.isNotEmpty
              ? DesignerCreatedBy.text
              : "Unknown",
          "data": data,
        },
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Sub-order item document written");

      // ✅ INCREMENT: Monthly counter
      debugPrint("⏱️ Incrementing monthly counter...");
      await incrementMonthlyCounter();
      debugPrint("✅ Monthly counter incremented");

      debugPrint("🎉 Designer form submission successful!");

    } catch (e, stackTrace) {
      debugPrint("❌ ERROR in submitDesignerForm: $e");
      debugPrint("📍 Stack trace: $stackTrace");
      rethrow; // Re-throw to be caught by submitForm()
    }
  }

  Future<void> submitDepartmentForm(String nextDepartment) async {
    final data = buildFormData();
    final lpm = LpmAutoIncrement.text;

    // 🔥 Detect AutoBending status
    final isDone = AutoBendingStatus.text.trim().toLowerCase() == "done";

    await FirebaseFirestore.instance
        .collection("jobs")
        .doc(lpm)
        .update({
      "${_deptKey(department)}.submitted": true,
      "${_deptKey(department)}.data": data,

      // ✅ Only move forward if Done
      "currentDepartment": isDone ? nextDepartment : department,

      // ✅ Only add ManualBending if Done
      if (isDone)
        "visibleTo": FieldValue.arrayUnion([nextDepartment]),

      "updatedAt": FieldValue.serverTimestamp(),
    });
  }


// 🔧 FIXED submitForm() Method
// Replace the existing submitForm() in new_form.dart with this version

  Future<void> submitForm() async {
    try {
      debugPrint("🚀 Starting form submission...");

      if (department == "Designer") {
        // ✅ Designer: use submitDesignerForm() which writes to the "jobs"
        //    collection with the correct nested structure expected by the
        //    dashboard (designer.submitted, designer.data, etc.)
        await submitDesignerForm();
      } else {
        // ✅ Other departments: use submitDepartmentForm()
        final nextDept = _nextDepartment(department);
        await submitDepartmentForm(nextDept);
      }

      debugPrint("✅ Form submitted successfully!");

      // ✅ Show success message and navigate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Form submitted successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to dashboard
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/dashboard');
        }
      }

    } on FirebaseException catch (e) {
      debugPrint("❌ Firebase Error: ${e.code} - ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Firebase Error: ${e.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Unexpected Error: $e");
      debugPrint("📍 Stack Trace: $stackTrace");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// ✅ Validates all required fields
  String? _validateRequiredFields() {
    // Required fields for Designer module
    if (LpmAutoIncrement.text.trim().isEmpty) {
      return "❌ LPM Auto Increment is required";
    }
    if (PartyName.text.trim().isEmpty) {
      return "❌ Party Name is required";
    }
    if (ParticularJobName.text.trim().isEmpty) {
      return "❌ Particular Job Name is required";
    }
    // Add more validations as needed
    return null; // ✅ All validations passed
  }

  /// ✅ Cleans and sanitizes form data to prevent index errors
  Map<String, dynamic> _sanitizeFormData(Map<String, dynamic> rawData) {
    final cleanData = <String, dynamic>{};

    rawData.forEach((key, value) {
      // ✅ Skip null values
      if (value == null) {
        debugPrint("⏭️  Skipping null field: $key");
        return;
      }

      // ✅ Skip empty strings
      if (value is String && value.trim().isEmpty) {
        debugPrint("⏭️  Skipping empty field: $key");
        return;
      }

      // ✅ Skip empty lists
      if (value is List && value.isEmpty) {
        debugPrint("⏭️  Skipping empty list: $key");
        return;
      }

      // ✅ Skip empty maps
      if (value is Map && value.isEmpty) {
        debugPrint("⏭️  Skipping empty map: $key");
        return;
      }

      // ✅ Keep valid values
      cleanData[key] = value;
    });

    return cleanData;
  }

  /// 🔍 Debug helper - prints all form field values
  void debugPrintFormData() {
    debugPrint("""
  ╔════════════════════ FORM DATA DEBUG ════════════════════╗
  LpmAutoIncrement: ${LpmAutoIncrement.text}
  PartyName: ${PartyName.text}
  DesignerCreatedBy: ${DesignerCreatedBy.text}
  DeliveryAt: ${DeliveryAt.text}
  Orderby: ${Orderby.text}
  ParticularJobName: ${ParticularJobName.text}
  Priority: ${Priority.text}
  Remark: ${Remark.text}
  DesigningStatus: ${DesigningStatus.text}
  PlyType: ${PlyType.text}
  Blade: ${Blade.text}
  Creasing: ${Creasing.text}
  Perforation: ${Perforation.text}
  ZigZagBlade: ${ZigZagBlade.text}
  RubberType: ${RubberType.text}
  HoleType: ${HoleType.text}
  ╚═══════════════════════════════════════════════════════════╝
  """);
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
    AutoBendingStatus.dispose();
    ManualBendingStatus.dispose();
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
    RubberStatus.dispose();
    RubberCreatedBy.dispose();
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
    debugPrint(
      'NEWFORM BUILD → '
          'dept=${widget.department}, '
          'lpm=${widget.lpm}, '
          'mode=${widget.mode}, '
          'uri=${GoRouterState.of(context).uri}',
    );
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
                    // ✅ Previous → goes back one page
                    // ✅ Hidden on page 1 (no previous page to go to)
                    if (!_isFirstDesignerPage)
                      TextButton(
                        onPressed: () {
                          if (context.canPop()) context.pop();
                        },
                        child: const Text(
                          "Previous",
                          style: TextStyle(color: Colors.amber),
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    // ✅ Next → hidden on last page (Submit button in page 6 handles it)
                    if (!(department == "Designer" && isLastDesignerPage))
                      TextButton(
                        onPressed: _goNext,
                        child: const Text(
                          "Next",
                          style: TextStyle(color: Colors.amber),
                        ),
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
    final uri = GoRouterState.of(context).uri;
    final path = uri.path; // 👈 IMPORTANT: path only

    const designerPages = [
      '/jobform/designer-1',
      '/jobform/designer-2',
      '/jobform/designer-3',
      '/jobform/designer-4',
      '/jobform/designer-5',
      '/jobform/designer-6',
    ];

    final index = designerPages.indexOf(path);

    if (index != -1 && index < designerPages.length - 1) {
      context.push(
        designerPages[index + 1] + '?${uri.query}', // 👈 preserve params
      );
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
      "LaserCutting",
      "Rubber",
      "Emboss",
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
      case "LaserCutting":
        return "laserCutting";
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