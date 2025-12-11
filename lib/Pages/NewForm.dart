import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/GSTSelector.dart';
import 'package:lightatech/FormComponents/AutoIncrementField.dart';
import 'package:lightatech/FormComponents/PrioritySelector.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';
import 'package:lightatech/FormComponents/FlexibleSlider.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';
import 'package:lightatech/FormComponents/AutoCalcTextbox.dart';

class NewForm extends StatefulWidget {
  NewForm({super.key});
  @override
  State<NewForm> createState() => NewFormState();
}

class NewFormState extends State<NewForm> {
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
  final PerforationType = TextEditingController();
  final ZigZagBladeType = TextEditingController();
  final RubberType = TextEditingController();
  final HoleType = TextEditingController();
  final EmbossStatus = TextEditingController();
  final MaleEmbossType = TextEditingController();
  final FemaleEmbossType = TextEditingController();
  final StrippingType = TextEditingController();
  final AutoCreasingStatus = TextEditingController();
  final LaserCuttingStatus = TextEditingController();
  final InvoiceStatus = TextEditingController();
  final ParticularSlider = TextEditingController();
  String HouseNo = "";
  String Appartment = "";
  String Street = "";
  String Pincode = "";

  Map<String, dynamic> buildFormData() {
    return {
      // Basic Info
      "BuyerOrderNo": BuyerOrderNo.text,
      "DeliveryAt": DeliveryAt.text,
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
      "PerforationType": PerforationType.text,
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
      "LaserCuttingStatus": LaserCuttingStatus.text,

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
      "DeliveryCreatedBy": DeliveryCreatedBy.text,

      // Other
      "GSTType": GSTType.text,
      "ParticularJobName": ParticularJobName.text,
      "Priority": Priority.text,
      "PlyType": PlyType.text,
      "Amounts3": Amounts3.text,
      "ParticularSlider": ParticularSlider.text,

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
    PerforationType.clear();
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
    DeliveryCreatedBy.clear();
    GSTType.clear();
    ParticularJobName.clear();
    Priority.clear();
    PlyType.clear();
    Amounts3.clear();
    ParticularSlider.clear();
    AddressOutput.clear();

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

  Future<void> submitForm() async {
    final data = buildFormData();

    try {
      await FirebaseFirestore.instance.collection("jobs").add(data);

      // Clear the form after successful upload
      clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Form submitted successfully!")),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting form")),
      );
    }
  }

  @override
  void initState() {
    super.initState();

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
  }

// Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    BuyerOrderNo.dispose();
    DeliveryAt.dispose();
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
    PerforationType.dispose();
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
    LaserCuttingStatus.dispose();
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
    DeliveryCreatedBy.dispose();
    GSTType.dispose();
    ParticularJobName.dispose();
    Priority.dispose();
    PlyType.dispose();
    Amounts3.dispose();
    ParticularSlider.dispose();
    AddressOutput.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Form")),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Party Name
                SearchableDropdownWithInitial(
                  label: "Party Name *",
                  items: parties,
                  onChanged: (v) {},
                ),

                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Designer Created By",
                  items: parties,
                  onChanged: (v) {
                    DesignerCreatedBy.text = v ?? "";
                  },
                ),

                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Auto Bending Created By",
                  items: parties,
                  onChanged: (v) {},
                ),

                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Laser Cutting Created By",
                  items: parties,
                  onChanged: (v) {},
                ),

                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Accounts Created By",
                  items: parties,
                  onChanged: (v) {},
                ),

                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Emboss Created By",
                  items: parties,
                  onChanged: (v) {},
                ),

                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Manual Bending Created By",
                  items: parties,
                  onChanged: (v) {},
                ),

                const SizedBox(height: 30),

                // GST
                const Text(
                  "GST",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                GSTSelector(
                  selected: "GST",
                  Values: ["GST", "IGST", "Non GST"],
                  onChanged: (v) {},
                ),

                const SizedBox(height: 30),
                TextInput(
                  controller: BuyerOrderNo,
                  label: "Buyer's Order No",
                  hint: "Order Number",
                ),

                const SizedBox(height: 30),

                TextInput(
                  controller: DeliveryAt,
                  label: "Delivery At",
                  hint: "Address",
                ),

                const SizedBox(height: 30),

                // Particular Job Name
                AddableSearchDropdown(
                  label: "Particular Job Name *",
                  items: jobs,
                  onChanged: (v) {},
                  onAdd: (newJob) => jobs.add(newJob),
                ),

                const SizedBox(height: 30),

                // LPM Auto Increment
                AutoIncrementField(value: 1004),

                const SizedBox(height: 30),

                // Priority
                const Text(
                  "Priority",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                PrioritySelector(
                  onChanged: (v) {
                    Priority.text = v ?? "";
                  },
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Remark",
                  hint: "Remark",
                  controller: Remark,
                  initialValue: "NO REMARK",
                ),

                const SizedBox(height: 30),
                // Designing Toggle
                FlexibleToggle(
                  label: "Designing *",
                  inactiveText: "Pending",
                  activeText: "Done",
                  initialValue: false,
                  onChanged: (val) {
                    DesigningStatus.text = val ? "Done" : "Pending";
                  },
                ),

                const SizedBox(height: 30),

                // Punch Report
                const Text(
                  "Punch Report",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                FileUploadBox(
                  onFileSelected: (file) {
                    print("Selected File: ${file.name}");
                    print("Size: ${file.size}");
                    print("Path: ${file.path}");
                  },
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Ups",
                  hint: "ups",
                  controller: Ups,
                  initialValue: "NO",
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Party Work Name",
                  hint: "name",
                  controller: PartyworkName,
                  initialValue: "NO",
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Size",
                  hint: "name",
                  controller: Size,
                  initialValue: "NO",
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Size2",
                  hint: "name",
                  controller: Size2,
                  initialValue: "NO",
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Size3",
                  hint: "name",
                  controller: Size3,
                  initialValue: "NO",
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Size4",
                  hint: "name",
                  controller: Size4,
                  initialValue: "NO",
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Size5",
                  hint: "name",
                  controller: Size5,
                  initialValue: "NO",
                ),

                const SizedBox(height: 30),

                // Size Slider
                const Text(
                  "Sizes",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                FlexibleSlider(max: 10, onChanged: (v) {}),

                const SizedBox(height: 30),

                // Ups_32 Stepper
                const Text(
                  "Ups_32",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                NumberStepper(
                  step: 1,
                  initialValue: 0,
                  controller: Ups_32,
                  onChanged: (val) => print(val),
                ),

                const SizedBox(height: 30),
                // Designing Toggle
                FlexibleToggle(
                  label: "Laser Cutting Punch New",
                  inactiveText: "No",
                  activeText: "Yes",
                  initialValue: false,
                  onChanged: (val) {
                    LaserPunchNew.text = val ? "Yes" : "No";
                  },
                ),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Ply",
                  items: ply,
                  initialValue: "No",
                  onChanged: (v) {
                    PlyType.text = v ?? "";
                  },
                  onAdd: (v) => ply.add(v),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Ply Length",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                NumberStepper(
                  step: 0.1,
                  initialValue: 0.0,
                  controller: PlyLength,
                  onChanged: (val) {
                    PlyLength.text = val.toString();
                    setState(
                      () {},
                    ); // 🔥 force UI refresh so TotalArea updates!
                  },
                ),

                const SizedBox(height: 30),

                const Text(
                  "Ply Breadth",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                NumberStepper(
                  step: 0.1,
                  initialValue: 0.0,
                  controller: PlyBreadth,
                  onChanged: (val) {
                    PlyBreadth.text = val.toString();
                    setState(() {});
                  },
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(
                  label: "Ply Size",
                  value: (() {
                    double length = double.tryParse(PlyLength.text) ?? 0;
                    double breadth = double.tryParse(PlyBreadth.text) ?? 0;
                    double totalArea = length * breadth;

                    return totalArea.toStringAsFixed(1);
                  })(),
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Ply Amount", value: "0"),

                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Blade",
                  items: ply,
                  initialValue: "No",
                  onChanged: (v) {
                    Blade.text = v ?? "";
                  },
                ),

                const SizedBox(height: 30),

                const Text(
                  "Blade Size",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                NumberStepper(
                  step: 1,
                  onChanged: (v) {},
                  controller: BladeSize,
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Blade Amount", value: "0"),

                const SizedBox(height: 30),

                TextInput(
                  label: "Extra",
                  hint: "Extra",
                  controller: Extra,
                  initialValue: "NO",
                ),

                const SizedBox(height: 30),

                const Text(
                  "Capsule Rate",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                NumberStepper(
                  step: 0.01,
                  onChanged: (v) {},
                  controller: CapsuleRate,
                ),

                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Creasing",
                  items: ply,
                  initialValue: "No",
                  onChanged: (v) {
                    Creasing.text = v ?? "";
                  },
                ),

                const SizedBox(height: 30),

                const Text(
                  "Creasing Size",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                NumberStepper(
                  step: 1,
                  onChanged: (v) {},
                  controller: CreasingSize,
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Creasing Amount", value: "0"),

                const SizedBox(height: 30),

                FlexibleSlider(max: 3, onChanged: (v) {}),

                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Rubber Done By",
                  items: ply,
                  onChanged: (v) {
                    RubberDoneBy.text = v ?? "";
                  },
                ),

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "Micro sarration Half cut 23.60",
                  inactiveText: "No",
                  activeText: "Yes",
                  initialValue: false,
                  onChanged: (val) {
                    // Store toggle value if needed
                  },
                ),

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "Micro sarration Creasing 23.60",
                  inactiveText: "No",
                  activeText: "Yes",
                  initialValue: false,
                  onChanged: (val) {
                    // Store toggle value if needed
                  },
                ),

                const SizedBox(height: 30),

                const Text(
                  "WP File",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                FileUploadBox(onFileSelected: (file) {}),

                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Delivery Created By",
                  items: ply,
                  onChanged: (v) {
                    DeliveryCreatedBy.text = v ?? "";
                  },
                ),

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "Delivery",
                  inactiveText: "Pending",
                  activeText: "Done",
                  initialValue: false,
                  onChanged: (val) {
                    DeliveryStatus.text = val ? "Done" : "Pending";
                  },
                ),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Receiver Name",
                  items: jobs,
                  onChanged: (v) {
                    ReceiverName.text = v ?? "";
                  },
                  onAdd: (newJob) => jobs.add(newJob),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Die/Punch Image",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                FileUploadBox(onFileSelected: (file) {}),

                const SizedBox(height: 30),

                const Text(
                  "Invoice Image",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                FileUploadBox(onFileSelected: (file) {}),

                const SizedBox(height: 30),

                const Text(
                  "Courier Receiving Image",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                FileUploadBox(onFileSelected: (file) {}),

                const SizedBox(height: 30),

                TextInput(
                  label: "Delivery URL",
                  hint: "URL",
                  controller: DeliveryURL,
                  initialValue: "URL",
                ),

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "Job Done",
                  inactiveText: "No",
                  activeText: "Yes",
                  onChanged: (v) {
                    // Store toggle value if needed
                  },
                ),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Transport Name",
                  items: jobs,
                  onChanged: (v) {
                    TransportName.text = v ?? "";
                  },
                  onAdd: (newJob) => jobs.add(newJob),
                ),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "House No",
                  items: HouseNoList,
                  onChanged: (v) {
                    HouseNo = v;
                    updateAddress();
                  },
                  onAdd: (newValue) {
                    HouseNoList.add(newValue);
                    HouseNo = newValue;
                    updateAddress();
                  },
                ),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Appartment",
                  items: AppartmentList,
                  onChanged: (v) {
                    Appartment = v;
                    updateAddress();
                  },
                  onAdd: (newValue) {
                    AppartmentList.add(newValue);
                    Appartment = newValue;
                    updateAddress();
                  },
                ),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Street",
                  items: StreetList,
                  onChanged: (v) {
                    Street = v;
                    updateAddress();
                  },
                  onAdd: (newValue) {
                    StreetList.add(newValue);
                    Street = newValue;
                    updateAddress();
                  },
                ),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Pincode",
                  items: PincodeList,
                  onChanged: (v) {
                    Pincode = v;
                    updateAddress();
                  },
                  onAdd: (newValue) {
                    PincodeList.add(newValue);
                    Pincode = newValue;
                    updateAddress();
                  },
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(
                  label: "Full Address",
                  controller: AddressOutput,
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Unknown",
                  hint: "Unknown",
                  controller: Unknown,
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Design Send By",
                  hint: "Name",
                  controller: DesignSendBy,
                ),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Capsule",
                  items: jobs,
                  onChanged: (v) {
                    CapsuleType.text = v ?? "";
                  },
                  onAdd: (newJob) => jobs.add(newJob),
                  initialValue: "No",
                ),

                const SizedBox(height: 30),

                const Text(
                  "Capsule Pcs",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                NumberStepper(
                  step: 0.01,
                  onChanged: (val) {
                    CapsulePcs.text = val.toString();
                    updateCapsuleAmt();
                  },
                  controller: CapsulePcs,
                ),

                const SizedBox(height: 30),

                const Text(
                  "Capsule Rate",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                NumberStepper(
                  step: 0.01,
                  onChanged: (val) {
                    CapsuleRate.text = val.toString();
                    updateCapsuleAmt();
                  },
                  controller: CapsuleRate,
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Capsule Amt", controller: CapsuleAmt),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Perforation",
                  items: jobs,
                  onChanged: (v) {},
                  onAdd: (newJob) => jobs.add(newJob),
                  initialValue: "No",
                ),

                const SizedBox(height: 30),
                const Text(
                  "Perforation Size",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                NumberStepper(
                  step: 1,
                  onChanged: (v) {},
                  controller: PerforationSize,
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Perforation Amount", value: "0"),

                // const SizedBox(height: 30,),
                //
                // AutoCalcTextBox(label: "Perforation Done By", value: "",),
                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Perforation",
                  items: jobs,
                  onChanged: (v) {
                    PerforationType.text = v ?? "";
                  },
                  onAdd: (newJob) => jobs.add(newJob),
                  initialValue: "No",
                ),

                const SizedBox(height: 30),

                const Text(
                  "Zig Zag Blade Size",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 1,
                  onChanged: (v) {},
                  controller: ZigZagBladeSize,
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Zig Zag Blade Amount", value: "0"),

                // const SizedBox(height: 30,),
                //
                // AutoCalcTextBox(label: "Zig Zag Blade Selected By", value: "",),
                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Rubber",
                  items: jobs,
                  onChanged: (v) {
                    RubberType.text = v ?? "";
                  },
                  onAdd: (newJob) => jobs.add(newJob),
                  initialValue: "No",
                ),

                const SizedBox(height: 30),

                //rubber rate is invisible
                const Text(
                  "Rubber Size",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 1,
                  onChanged: (v) {},
                  controller: RubberSize,
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Rubber Amount", value: "0"),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Hole",
                  items: jobs,
                  onChanged: (v) {
                    HoleType.text = v ?? "";
                  },
                  onAdd: (newJob) => jobs.add(newJob),
                  initialValue: "No",
                ),

                const SizedBox(height: 30),

                const Text(
                  "Holes",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 1,
                  onChanged: (v) {},
                  controller: RubberSize,
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Hole Amount", value: "0"),

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "Emboss",
                  inactiveText: "No",
                  activeText: "Yes",
                  onChanged: (v) {
                    EmbossStatus.text = v ? "Yes" : "No";
                  },
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Emboss Pcs",
                  hint: "No of Pcs",
                  controller: EmbossPcs,
                  initialValue: "No",
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Emboss Pcs",
                  hint: "No of Pcs",
                  controller: TotalSize,
                  initialValue: "No",
                ),

                const SizedBox(height: 30),

                const Text(
                  "Minimum Charge Apply",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 1,
                  onChanged: (v) {},
                  controller: MinimumChargeApply,
                ),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Male Emboss",
                  items: jobs,
                  onChanged: (v) {
                    MaleEmbossType.text = v ?? "";
                  },
                  onAdd: (newJob) => jobs.add(newJob),
                  initialValue: "No",
                ),

                const SizedBox(height: 30),

                const Text(
                  "Male Rate",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 0.01,
                  onChanged: (v) {},
                  controller: MaleRate,
                ),

                const SizedBox(height: 30),

                const Text(
                  "X",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 0.01,
                  onChanged: (val) {
                    X.text = val.toString();
                    calculateXY();
                  },
                  controller: X,
                ),

                const SizedBox(height: 30),

                const Text(
                  "Y",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 0.01,
                  onChanged: (val) {
                    Y.text = val.toString();
                    calculateXY();
                  },
                  controller: Y,
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "XY Size", controller: XYSize),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Male Amount", value: "0.00"),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Female Emboss",
                  items: jobs,
                  onChanged: (v) {
                    FemaleEmbossType.text = v ?? "";
                  },
                  onAdd: (newJob) => jobs.add(newJob),
                  initialValue: "No",
                ),

                const SizedBox(height: 30),

                const Text(
                  "Female Rate",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 0.01,
                  onChanged: (v) {},
                  controller: FemaleRate,
                ),

                const SizedBox(height: 30),

                const Text(
                  "X2",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 0.01,
                  onChanged: (val) {
                    X2.text = val.toString();
                    calculateXY();
                  },
                  controller: X2,
                ),

                const SizedBox(height: 30),

                const Text(
                  "Y2",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 0.01,
                  onChanged: (val) {
                    Y2.text = val.toString();
                    calculateXY2();
                  },
                  controller: Y2,
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "XY2 Size", controller: XY2Size),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Female Amount", value: "0"),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Stripping",
                  items: jobs,
                  onChanged: (v) {
                    StrippingType.text = v ?? "";
                  },
                  onAdd: (newJob) => jobs.add(newJob),
                  initialValue: "No",
                ),

                const SizedBox(height: 30),

                const Text(
                  "Stripping Size",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 1,
                  onChanged: (v) {},
                  controller: StrippingSize,
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Stripping Amount", value: "0"),

                const SizedBox(height: 30),
                const Text(
                  "Courier Charges",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                NumberStepper(
                  step: 0.01,
                  onChanged: (v) {},
                  controller: CourierCharges,
                ),

                const SizedBox(height: 30),

                const Text(
                  "Auto Creasing Status",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                GSTSelector(
                  selected: "No",
                  Values: ["Done", "Pending", "No"],
                  onChanged: (v) {
                    AutoCreasingStatus.text = v ?? "";
                  },
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Laser Rate",
                  hint: "Rate",
                  controller: LaserRate,
                ),

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "Laser Cutting Status",
                  inactiveText: "Pending",
                  activeText: "Done",
                  onChanged: (v) {
                    LaserCuttingStatus.text = v ? "Done" : "Pending";
                  },
                ),

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "Invoice",
                  inactiveText: "Pending",
                  activeText: "Done",
                  onChanged: (v) {
                    InvoiceStatus.text = v ? "Done" : "Pending";
                  },
                ),

                const SizedBox(height: 30),

                TextInput(
                  label: "Invoice Printed By",
                  hint: "Name",
                  controller: InvoicePrintedBy,
                ),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Created By", value: ""),

                const SizedBox(height: 30),

                const Text(
                  "Particular",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                FlexibleSlider(max: 3, onChanged: (v) {}),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Amount 1", value: "0"),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Amount 2", value: "0"),

                const SizedBox(height: 30),

                AutoCalcTextBox(label: "Amount 3", value: "0"),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: const Color(0xFFF8D94B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: Text("Submit", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
