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
  // Access Control Map - Set to true to show field, false to hide
  Map<String, bool> fieldAccess = {
    // Basic Info
    'partyName': true,
    'designerCreatedBy': true,
    'autoBendingCreatedBy': true,
    'laserCuttingCreatedBy': true,
    'accountsCreatedBy': true,
    'embossCreatedBy': true,
    'manualBendingCreatedBy': true,
    'gst': true,
    'buyerOrderNo': true,
    'deliveryAt': true,
    'Orderby': true,
    'particularJobName': true,
    'lpmAutoIncrement': true,
    'priority': true,
    'remark': true,
    'designingToggle': true,
    'DrawingAttachment': true,
    'punchReport': true,
    'ups': true,
    'partyWorkName': true,
    'size': true,
    'size2': true,
    'size3': true,
    'size4': true,
    'size5': true,
    'sizesSlider': true,
    'ups32Stepper': true,
    'laserCuttingPunchNew': true,

    // Ply
    'plyDropdown': true,
    'plyLength': true,
    'plyBreadth': true,
    'plySize': true,
    'plyAmount': true,

    // Blade
    'blade': true,
    'bladeSize': true,
    'bladeAmount': true,

    // Extra
    'extra': true,

    // Capsule Rate
    'capsuleRate': true,

    // Creasing
    'creasing': true,
    'creasingSize': true,
    'creasingAmount': true,
    'creasingSlider': true,
    'rubberDoneBy': true,
    'microSerrationHalfCut': true,
    'microSerrationCreasing': true,
    'wpFile': true,
    'deliveryCreatedBy': true,
    'deliveryToggle': true,
    'receiverName': true,
    'diePunchImage': true,
    'invoiceImage': true,
    'courierReceivingImage': true,
    'deliveryUrl': true,
    'jobDone': true,
    'transportName': true,

    // Address
    'houseNo': true,
    'appartment': true,
    'street': true,
    'pincode': true,
    'fullAddress': true,
    'unknown': true,
    'designSendBy': true,

    // Capsule
    'capsule': true,
    'capsulePcs': true,
    'capsuleRateField': true,
    'capsuleAmt': true,

    // Perforation
    'perforationDropdown': true,
    'perforationSize': true,
    'perforationAmount': true,
    'ZigZagBlade': true,

    // Zig Zag
    'zigZagBladeSize': true,
    'zigZagBladeAmount': true,

    // Rubber
    'rubber': true,
    'rubberSize': true,
    'rubberAmount': true,

    // Hole
    'hole': true,
    'holes': true,
    'holeAmount': true,

    // Emboss
    'embossToggle': true,
    'embossPcs': true,
    'embossPcsField': true,
    'minimumChargeApply': true,
    'maleEmboss': true,
    'maleRate': true,
    'xField': true,
    'yField': true,
    'xySize': true,
    'maleAmount': true,
    'femaleEmboss': true,
    'femaleRate': true,
    'x2Field': true,
    'y2Field': true,
    'xy2Size': true,
    'femaleAmount': true,

    // Stripping
    'stripping': true,
    'strippingSize': true,
    'strippingAmount': true,

    // Courier & Laser
    'courierCharges': true,
    'autoCreasingStatus': true,
    'laserRate': true,
    'laserCuttingStatus': true,
    'invoiceToggle': true,
    'invoicePrintedBy': true,
    'createdBy': true,
    'particular': true,
    'amount1': true,
    'amount2': true,
    'amount3': true,
    'submitButton': true,
  };

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
  final LaserCuttingStatus = TextEditingController();
  final InvoiceStatus = TextEditingController();
  final ParticularSlider = TextEditingController();
  String HouseNo = "";
  String Appartment = "";
  String Street = "";
  String Pincode = "";
  String User = "";

  Map<String, dynamic> buildFormData() {
    return {
      // Basic Info
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Form submitted successfully!")));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting form")));
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
                if ((fieldAccess['partyName'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  SearchableDropdownWithInitial(
                    label: "Party Name *",
                    items: parties,
                    onChanged: (v) {},
                  ),

                if ((fieldAccess['partyName'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['designerCreatedBy'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  SearchableDropdownWithInitial(
                    label: "Designer Created By",
                    items: parties,
                    onChanged: (v) {
                      DesignerCreatedBy.text = v ?? "";
                    },
                  ),

                if ((fieldAccess['designerCreatedBy'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['autoBendingCreatedBy'] ?? false) ||
                    User == "Admin")
                  SearchableDropdownWithInitial(
                    label: "Auto Bending Created By",
                    items: parties,
                    onChanged: (v) {},
                  ),

                if ((fieldAccess['autoBendingCreatedBy'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['laserCuttingCreatedBy'] ?? false) ||
                    User == "Admin")
                  SearchableDropdownWithInitial(
                    label: "Laser Cutting Created By",
                    items: parties,
                    onChanged: (v) {},
                  ),

                if ((fieldAccess['laserCuttingCreatedBy'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['accountsCreatedBy'] ?? false) ||
                    User == "Admin")
                  SearchableDropdownWithInitial(
                    label: "Accounts Created By",
                    items: parties,
                    onChanged: (v) {},
                  ),

                if ((fieldAccess['accountsCreatedBy'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['embossCreatedBy'] ?? false) ||
                    User == "Admin")
                  SearchableDropdownWithInitial(
                    label: "Emboss Created By",
                    items: parties,
                    onChanged: (v) {},
                  ),

                if ((fieldAccess['embossCreatedBy'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['manualBendingCreatedBy'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  SearchableDropdownWithInitial(
                    label: "Manual Bending Created By",
                    items: parties,
                    onChanged: (v) {},
                  ),

                if ((fieldAccess['manualBendingCreatedBy'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                // GST
                if ((fieldAccess['gst'] ?? false) || User == "Admin")
                  const Text(
                    "GST",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['gst'] ?? false) || User == "Admin")
                  GSTSelector(
                    selected: "GST",
                    Values: ["GST", "IGST", "Non GST"],
                    onChanged: (v) {},
                  ),

                if ((fieldAccess['gst'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['buyerOrderNo'] ?? false) || User == "Admin")
                  TextInput(
                    controller: BuyerOrderNo,
                    label: "Buyer's Order No",
                    hint: "Order Number",
                  ),

                if ((fieldAccess['buyerOrderNo'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['deliveryAt'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  TextInput(
                    controller: DeliveryAt,
                    label: "Delivery At",
                    hint: "Address",
                  ),

                if ((fieldAccess['deliveryAt'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['Orderby'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  TextInput(
                    controller: Orderby,
                    label: "Order By",
                    hint: "Name",
                  ),

                if ((fieldAccess['Orderby'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                // Particular Job Name
                if ((fieldAccess['particularJobName'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Particular Job Name *",
                    items: jobs,
                    onChanged: (v) {},
                    onAdd: (newJob) => jobs.add(newJob),
                  ),

                if ((fieldAccess['particularJobName'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                // LPM Auto Increment
                if ((fieldAccess['lpmAutoIncrement'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AutoIncrementField(value: 1004),

                if ((fieldAccess['lpmAutoIncrement'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                // Priority
                if ((fieldAccess['priority'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const Text(
                    "Priority",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['priority'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  PrioritySelector(
                    onChanged: (v) {
                      Priority.text = v ?? "";
                    },
                  ),

                if ((fieldAccess['priority'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['remark'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  TextInput(
                    label: "Remark",
                    hint: "Remark",
                    controller: Remark,
                    initialValue: "NO REMARK",
                  ),

                if ((fieldAccess['remark'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                // Designing Toggle
                if ((fieldAccess['designingToggle'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  FlexibleToggle(
                    label: "Designing *",
                    inactiveText: "Pending",
                    activeText: "Done",
                    initialValue: false,
                    onChanged: (val) {
                      DesigningStatus.text = val ? "Done" : "Pending";
                    },
                  ),

                if ((fieldAccess['designingToggle'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                // Punch Report
                if ((fieldAccess['DrawingAttachment'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const Text(
                    "Drawing Attachment",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['DrawingAttachment'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  FileUploadBox(
                    onFileSelected: (file) {
                      print("Selected File: ${file.name}");
                      print("Size: ${file.size}");
                      print("Path: ${file.path}");
                    },
                  ),

                if ((fieldAccess['DrawingAttachment'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['punchReport'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const Text(
                    "Punch Report",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['punchReport'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  FileUploadBox(
                    onFileSelected: (file) {
                      print("Selected File: ${file.name}");
                      print("Size: ${file.size}");
                      print("Path: ${file.path}");
                    },
                  ),

                if ((fieldAccess['punchReport'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['ups'] ?? false) || User == "Admin")
                  TextInput(
                    label: "Ups",
                    hint: "ups",
                    controller: Ups,
                    initialValue: "NO",
                  ),

                if ((fieldAccess['ups'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['partyWorkName'] ?? false) || User == "Admin")
                  TextInput(
                    label: "Party Work Name",
                    hint: "name",
                    controller: PartyworkName,
                    initialValue: "NO",
                  ),

                if ((fieldAccess['partyWorkName'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['size'] ?? false) || User == "Admin")
                  TextInput(
                    label: "Size",
                    hint: "name",
                    controller: Size,
                    initialValue: "NO",
                  ),

                if ((fieldAccess['size'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['size2'] ?? false) || User == "Admin")
                  TextInput(
                    label: "Size2",
                    hint: "name",
                    controller: Size2,
                    initialValue: "NO",
                  ),

                if ((fieldAccess['size2'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['size3'] ?? false) || User == "Admin")
                  TextInput(
                    label: "Size3",
                    hint: "name",
                    controller: Size3,
                    initialValue: "NO",
                  ),

                if ((fieldAccess['size3'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['size4'] ?? false) || User == "Admin")
                  TextInput(
                    label: "Size4",
                    hint: "name",
                    controller: Size4,
                    initialValue: "NO",
                  ),

                if ((fieldAccess['size4'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['size5'] ?? false) || User == "Admin")
                  TextInput(
                    label: "Size5",
                    hint: "name",
                    controller: Size5,
                    initialValue: "NO",
                  ),

                if ((fieldAccess['size5'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                // Size Slider
                if ((fieldAccess['sizesSlider'] ?? false) || User == "Admin")
                  const Text(
                    "Sizes",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['sizesSlider'] ?? false) || User == "Admin")
                  FlexibleSlider(max: 10, onChanged: (v) {}),

                if ((fieldAccess['sizesSlider'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                // Ups_32 Stepper
                if ((fieldAccess['ups32Stepper'] ?? false) || User == "Admin")
                  const Text(
                    "Ups_32",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['ups32Stepper'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 1,
                    initialValue: 0,
                    controller: Ups_32,
                    onChanged: (val) => print(val),
                  ),

                if ((fieldAccess['ups32Stepper'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                // Laser Cutting Punch New Toggle
                if ((fieldAccess['laserCuttingPunchNew'] ?? false) ||
                    User == "Admin")
                  FlexibleToggle(
                    label: "Laser Cutting Punch New",
                    inactiveText: "No",
                    activeText: "Yes",
                    initialValue: false,
                    onChanged: (val) {
                      LaserPunchNew.text = val ? "Yes" : "No";
                    },
                  ),

                if ((fieldAccess['laserCuttingPunchNew'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['plyDropdown'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Ply",
                    items: ply,
                    initialValue: "No",
                    onChanged: (v) {
                      PlyType.text = v ?? "";
                    },
                    onAdd: (v) => ply.add(v),
                  ),

                if ((fieldAccess['plyDropdown'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['plyLength'] ?? false) || User == "Admin")
                  const Text(
                    "Ply Length",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['plyLength'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 0.1,
                    initialValue: 0.0,
                    controller: PlyLength,
                    onChanged: (val) {
                      PlyLength.text = val.toString();
                      setState(() {});
                    },
                  ),

                if ((fieldAccess['plyLength'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['plyBreadth'] ?? false) || User == "Admin")
                  const Text(
                    "Ply Breadth",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['plyBreadth'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 0.1,
                    initialValue: 0.0,
                    controller: PlyBreadth,
                    onChanged: (val) {
                      PlyBreadth.text = val.toString();
                      setState(() {});
                    },
                  ),

                if ((fieldAccess['plyBreadth'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['plySize'] ?? false) || User == "Admin")
                  AutoCalcTextBox(
                    label: "Ply Size",
                    value: (() {
                      double length = double.tryParse(PlyLength.text) ?? 0;
                      double breadth = double.tryParse(PlyBreadth.text) ?? 0;
                      double totalArea = length * breadth;

                      return totalArea.toStringAsFixed(1);
                    })(),
                  ),

                if ((fieldAccess['plySize'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['plyAmount'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Ply Amount", value: "0"),

                if ((fieldAccess['plyAmount'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['blade'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  SearchableDropdownWithInitial(
                    label: "Blade",
                    items: ply,
                    initialValue: "No",
                    onChanged: (v) {
                      Blade.text = v ?? "";
                    },
                  ),

                if ((fieldAccess['blade'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['bladeSize'] ?? false) || User == "Admin")
                  const Text(
                    "Blade Size",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['bladeSize'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 1,
                    onChanged: (v) {},
                    controller: BladeSize,
                  ),

                if ((fieldAccess['bladeSize'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['bladeAmount'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Blade Amount", value: "0"),

                if ((fieldAccess['bladeAmount'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['extra'] ?? false) || User == "Admin")
                  TextInput(
                    label: "Extra",
                    hint: "Extra",
                    controller: Extra,
                    initialValue: "NO",
                  ),

                if ((fieldAccess['extra'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['capsuleRate'] ?? false) || User == "Admin")
                  const Text(
                    "Capsule Rate",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['capsuleRate'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 0.01,
                    onChanged: (v) {},
                    controller: CapsuleRate,
                  ),

                if ((fieldAccess['capsuleRate'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['creasing'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  SearchableDropdownWithInitial(
                    label: "Creasing",
                    items: ply,
                    initialValue: "No",
                    onChanged: (v) {
                      Creasing.text = v ?? "";
                    },
                  ),

                if ((fieldAccess['creasing'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['creasingSize'] ?? false) || User == "Admin")
                  const Text(
                    "Creasing Size",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['creasingSize'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 1,
                    onChanged: (v) {},
                    controller: CreasingSize,
                  ),

                if ((fieldAccess['creasingSize'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['creasingAmount'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Creasing Amount", value: "0"),

                if ((fieldAccess['creasingAmount'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['creasingSlider'] ?? false) || User == "Admin")
                  FlexibleSlider(max: 3, onChanged: (v) {}),

                if ((fieldAccess['creasingSlider'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['rubberDoneBy'] ?? false) || User == "Admin")
                  SearchableDropdownWithInitial(
                    label: "Rubber Done By",
                    items: ply,
                    onChanged: (v) {
                      RubberDoneBy.text = v ?? "";
                    },
                  ),

                if ((fieldAccess['rubberDoneBy'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['microSerrationHalfCut'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  FlexibleToggle(
                    label: "Micro sarration Half cut 23.60",
                    inactiveText: "No",
                    activeText: "Yes",
                    initialValue: false,
                    onChanged: (val) {
                      // Store toggle value if needed
                    },
                  ),

                if ((fieldAccess['microSerrationHalfCut'] ?? false) ||
                    User == "Designer")
                  const SizedBox(height: 30),

                if ((fieldAccess['microSerrationCreasing'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  FlexibleToggle(
                    label: "Micro sarration Creasing 23.60",
                    inactiveText: "No",
                    activeText: "Yes",
                    initialValue: false,
                    onChanged: (val) {
                      // Store toggle value if needed
                    },
                  ),

                if ((fieldAccess['microSerrationCreasing'] ?? false) ||
                    User == "Designer")
                  const SizedBox(height: 30),

                if ((fieldAccess['wpFile'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const Text(
                    "WP File",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['wpFile'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  FileUploadBox(onFileSelected: (file) {}),

                if ((fieldAccess['wpFile'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['deliveryCreatedBy'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  SearchableDropdownWithInitial(
                    label: "Delivery Created By",
                    items: ply,
                    onChanged: (v) {
                      DeliveryCreatedBy.text = v ?? "";
                    },
                  ),

                if ((fieldAccess['deliveryCreatedBy'] ?? false) ||
                    User == "Designer")
                  const SizedBox(height: 30),

                if ((fieldAccess['deliveryToggle'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  FlexibleToggle(
                    label: "Delivery",
                    inactiveText: "Pending",
                    activeText: "Done",
                    initialValue: false,
                    onChanged: (val) {
                      DeliveryStatus.text = val ? "Done" : "Pending";
                    },
                  ),

                if ((fieldAccess['deliveryToggle'] ?? false) ||
                    User == "Designer")
                  const SizedBox(height: 30),

                if ((fieldAccess['receiverName'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Receiver Name",
                    items: jobs,
                    onChanged: (v) {
                      ReceiverName.text = v ?? "";
                    },
                    onAdd: (newJob) => jobs.add(newJob),
                  ),

                if ((fieldAccess['receiverName'] ?? false) ||
                    User == "Designer")
                  const SizedBox(height: 30),

                if ((fieldAccess['diePunchImage'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const Text(
                    "Die/Punch Image",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['diePunchImage'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  FileUploadBox(onFileSelected: (file) {}),

                if ((fieldAccess['diePunchImage'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['invoiceImage'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const Text(
                    "Invoice Image",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['invoiceImage'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  FileUploadBox(onFileSelected: (file) {}),

                if ((fieldAccess['invoiceImage'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['courierReceivingImage'] ?? false) ||
                    User == "Admin")
                  const Text(
                    "Courier Receiving Image",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['courierReceivingImage'] ?? false) ||
                    User == "Admin")
                  FileUploadBox(onFileSelected: (file) {}),

                if ((fieldAccess['courierReceivingImage'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['deliveryUrl'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  TextInput(
                    label: "Delivery URL",
                    hint: "URL",
                    controller: DeliveryURL,
                    initialValue: "URL",
                  ),

                if ((fieldAccess['deliveryUrl'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['jobDone'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  FlexibleToggle(
                    label: "Job Done",
                    inactiveText: "No",
                    activeText: "Yes",
                    onChanged: (v) {
                      // Store toggle value if needed
                    },
                  ),

                if ((fieldAccess['jobDone'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['transportName'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Transport Name",
                    items: jobs,
                    onChanged: (v) {
                      TransportName.text = v ?? "";
                    },
                    onAdd: (newJob) => jobs.add(newJob),
                  ),

                if ((fieldAccess['transportName'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['houseNo'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
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

                if ((fieldAccess['houseNo'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['appartment'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
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

                if ((fieldAccess['appartment'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['street'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
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

                if ((fieldAccess['street'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['pincode'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
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

                if ((fieldAccess['pincode'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['fullAddress'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AutoCalcTextBox(
                    label: "Full Address",
                    controller: AddressOutput,
                  ),

                if ((fieldAccess['fullAddress'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['unknown'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  TextInput(
                    label: "Unknown",
                    hint: "Unknown",
                    controller: Unknown,
                  ),

                if ((fieldAccess['unknown'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['designSendBy'] ?? false) || User == "Admin")
                  TextInput(
                    label: "Design Send By",
                    hint: "Name",
                    controller: DesignSendBy,
                  ),

                if ((fieldAccess['designSendBy'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['capsule'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Capsule",
                    items: jobs,
                    onChanged: (v) {
                      CapsuleType.text = v ?? "";
                    },
                    onAdd: (newJob) => jobs.add(newJob),
                    initialValue: "No",
                  ),

                if ((fieldAccess['capsule'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['capsulePcs'] ?? false) || User == "Admin")
                  const Text(
                    "Capsule Pcs",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['capsulePcs'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 0.01,
                    onChanged: (val) {
                      CapsulePcs.text = val.toString();
                      updateCapsuleAmt();
                    },
                    controller: CapsulePcs,
                  ),

                if ((fieldAccess['capsulePcs'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['capsuleRateField'] ?? false) ||
                    User == "Admin")
                  const Text(
                    "Capsule Rate",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['capsuleRateField'] ?? false) ||
                    User == "Admin")
                  NumberStepper(
                    step: 0.01,
                    onChanged: (val) {
                      CapsuleRate.text = val.toString();
                      updateCapsuleAmt();
                    },
                    controller: CapsuleRate,
                  ),

                if ((fieldAccess['capsuleRateField'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['capsuleAmt'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Capsule Amt", controller: CapsuleAmt),

                if ((fieldAccess['capsuleAmt'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['perforationDropdown'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Perforation",
                    items: jobs,
                    onChanged: (v) {},
                    onAdd: (newJob) => jobs.add(newJob),
                    initialValue: "No",
                  ),

                if ((fieldAccess['perforationDropdown'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['perforationSize'] ?? false) ||
                    User == "Admin")
                  const Text(
                    "Perforation Size",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['perforationSize'] ?? false) ||
                    User == "Admin")
                  NumberStepper(
                    step: 1,
                    onChanged: (v) {},
                    controller: PerforationSize,
                  ),

                if ((fieldAccess['perforationSize'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['perforationAmount'] ?? false) ||
                    User == "Admin")
                  AutoCalcTextBox(label: "Perforation Amount", value: "0"),

                if ((fieldAccess['perforationAmount'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['ZigZagBlade'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Zig Zag Blade",
                    items: jobs,
                    onChanged: (v) {
                      ZigZagBlade.text = v ?? "";
                    },
                    onAdd: (newJob) => jobs.add(newJob),
                    initialValue: "No",
                  ),

                if ((fieldAccess['ZigZagBlade'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['zigZagBladeSize'] ?? false) ||
                    User == "Admin")
                  const Text(
                    "Zig Zag Blade Size",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['zigZagBladeSize'] ?? false) ||
                    User == "Admin")
                  NumberStepper(
                    step: 1,
                    onChanged: (v) {},
                    controller: ZigZagBladeSize,
                  ),

                if ((fieldAccess['zigZagBladeSize'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['zigZagBladeAmount'] ?? false) ||
                    User == "Admin")
                  AutoCalcTextBox(label: "Zig Zag Blade Amount", value: "0"),

                if ((fieldAccess['zigZagBladeAmount'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['rubber'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Rubber",
                    items: jobs,
                    onChanged: (v) {
                      RubberType.text = v ?? "";
                    },
                    onAdd: (newJob) => jobs.add(newJob),
                    initialValue: "No",
                  ),

                if ((fieldAccess['rubber'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['rubberSize'] ?? false) || User == "Admin")
                  const Text(
                    "Rubber Size",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['rubberSize'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 1,
                    onChanged: (v) {},
                    controller: RubberSize,
                  ),

                if ((fieldAccess['rubberSize'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['rubberAmount'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Rubber Amount", value: "0"),

                if ((fieldAccess['rubberAmount'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['hole'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Hole",
                    items: jobs,
                    onChanged: (v) {
                      HoleType.text = v ?? "";
                    },
                    onAdd: (newJob) => jobs.add(newJob),
                    initialValue: "No",
                  ),

                if ((fieldAccess['hole'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['holes'] ?? false) || User == "Admin")
                  const Text(
                    "Holes",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['holes'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 1,
                    onChanged: (v) {},
                    controller: RubberSize,
                  ),

                if ((fieldAccess['holes'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['holeAmount'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Hole Amount", value: "0"),

                if ((fieldAccess['holeAmount'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['embossToggle'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  FlexibleToggle(
                    label: "Emboss",
                    inactiveText: "No",
                    activeText: "Yes",
                    onChanged: (v) {
                      EmbossStatus.text = v ? "Yes" : "No";
                    },
                  ),

                if ((fieldAccess['embossToggle'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['embossPcs'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  TextInput(
                    label: "Emboss Pcs",
                    hint: "No of Pcs",
                    controller: EmbossPcs,
                    initialValue: "No",
                  ),

                if ((fieldAccess['embossPcs'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['embossPcsField'] ?? false) || User == "Admin")
                  TextInput(
                    label: "Emboss Pcs",
                    hint: "No of Pcs",
                    controller: TotalSize,
                    initialValue: "No",
                  ),

                if ((fieldAccess['embossPcsField'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['minimumChargeApply'] ?? false) ||
                    User == "Admin")
                  const Text(
                    "Minimum Charge Apply",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['minimumChargeApply'] ?? false) ||
                    User == "Admin")
                  NumberStepper(
                    step: 1,
                    onChanged: (v) {},
                    controller: MinimumChargeApply,
                  ),

                if ((fieldAccess['minimumChargeApply'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['maleEmboss'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Male Emboss",
                    items: jobs,
                    onChanged: (v) {
                      MaleEmbossType.text = v ?? "";
                    },
                    onAdd: (newJob) => jobs.add(newJob),
                    initialValue: "No",
                  ),

                if ((fieldAccess['maleEmboss'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['maleRate'] ?? false) || User == "Admin")
                  const Text(
                    "Male Rate",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['maleRate'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 0.01,
                    onChanged: (v) {},
                    controller: MaleRate,
                  ),

                if ((fieldAccess['maleRate'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['xField'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const Text(
                    "X",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['xField'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  NumberStepper(
                    step: 0.01,
                    onChanged: (val) {
                      X.text = val.toString();
                      calculateXY();
                    },
                    controller: X,
                  ),

                if ((fieldAccess['xField'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['yField'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const Text(
                    "Y",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['yField'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  NumberStepper(
                    step: 0.01,
                    onChanged: (val) {
                      Y.text = val.toString();
                      calculateXY();
                    },
                    controller: Y,
                  ),

                if ((fieldAccess['yField'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['xySize'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "XY Size", controller: XYSize),

                if ((fieldAccess['xySize'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['maleAmount'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Male Amount", value: "0.00"),

                if ((fieldAccess['maleAmount'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['femaleEmboss'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Female Emboss",
                    items: jobs,
                    onChanged: (v) {
                      FemaleEmbossType.text = v ?? "";
                    },
                    onAdd: (newJob) => jobs.add(newJob),
                    initialValue: "No",
                  ),

                if ((fieldAccess['femaleEmboss'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['femaleRate'] ?? false) || User == "Admin")
                  const Text(
                    "Female Rate",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['femaleRate'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 0.01,
                    onChanged: (v) {},
                    controller: FemaleRate,
                  ),

                if ((fieldAccess['femaleRate'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['x2Field'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const Text(
                    "X2",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['x2Field'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  NumberStepper(
                    step: 0.01,
                    onChanged: (val) {
                      X2.text = val.toString();
                      calculateXY();
                    },
                    controller: X2,
                  ),

                if ((fieldAccess['x2Field'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['y2Field'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const Text(
                    "Y2",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['y2Field'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  NumberStepper(
                    step: 0.01,
                    onChanged: (val) {
                      Y2.text = val.toString();
                      calculateXY2();
                    },
                    controller: Y2,
                  ),

                if ((fieldAccess['y2Field'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['xy2Size'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "XY2 Size", controller: XY2Size),

                if ((fieldAccess['xy2Size'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['femaleAmount'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Female Amount", value: "0"),

                if ((fieldAccess['femaleAmount'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['stripping'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  AddableSearchDropdown(
                    label: "Stripping",
                    items: jobs,
                    onChanged: (v) {
                      StrippingType.text = v ?? "";
                    },
                    onAdd: (newJob) => jobs.add(newJob),
                    initialValue: "No",
                  ),

                if ((fieldAccess['stripping'] ?? false) ||
                    User == "Designer" ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['strippingSize'] ?? false) || User == "Admin")
                  const Text(
                    "Stripping Size",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['strippingSize'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 1,
                    onChanged: (v) {},
                    controller: StrippingSize,
                  ),

                if ((fieldAccess['strippingSize'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['strippingAmount'] ?? false) ||
                    User == "Admin")
                  AutoCalcTextBox(label: "Stripping Amount", value: "0"),

                if ((fieldAccess['strippingAmount'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['courierCharges'] ?? false) || User == "Admin")
                  const Text(
                    "Courier Charges",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                if ((fieldAccess['courierCharges'] ?? false) || User == "Admin")
                  NumberStepper(
                    step: 0.01,
                    onChanged: (v) {},
                    controller: CourierCharges,
                  ),

                if ((fieldAccess['courierCharges'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['autoCreasingStatus'] ?? false) ||
                    User == "Admin")
                  const Text(
                    "Auto Creasing Status",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['autoCreasingStatus'] ?? false) ||
                    User == "Admin")
                  GSTSelector(
                    selected: "No",
                    Values: ["Done", "Pending", "No"],
                    onChanged: (v) {
                      AutoCreasingStatus.text = v ?? "";
                    },
                  ),

                if ((fieldAccess['autoCreasingStatus'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['laserRate'] ?? false) || User == "Admin")
                  TextInput(
                    label: "Laser Rate",
                    hint: "Rate",
                    controller: LaserRate,
                  ),

                if ((fieldAccess['laserRate'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['laserCuttingStatus'] ?? false) ||
                    User == "Admin")
                  FlexibleToggle(
                    label: "Laser Cutting Status",
                    inactiveText: "Pending",
                    activeText: "Done",
                    onChanged: (v) {
                      LaserCuttingStatus.text = v ? "Done" : "Pending";
                    },
                  ),

                if ((fieldAccess['laserCuttingStatus'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['invoiceToggle'] ?? false) || User == "Admin")
                  FlexibleToggle(
                    label: "Invoice",
                    inactiveText: "Pending",
                    activeText: "Done",
                    onChanged: (v) {
                      InvoiceStatus.text = v ? "Done" : "Pending";
                    },
                  ),

                if ((fieldAccess['invoiceToggle'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['invoicePrintedBy'] ?? false) ||
                    User == "Admin")
                  TextInput(
                    label: "Invoice Printed By",
                    hint: "Name",
                    controller: InvoicePrintedBy,
                  ),

                if ((fieldAccess['invoicePrintedBy'] ?? false) ||
                    User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['createdBy'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Created By", value: ""),

                if ((fieldAccess['createdBy'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['particular'] ?? false) || User == "Admin")
                  const Text(
                    "Particular",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                if ((fieldAccess['particular'] ?? false) || User == "Admin")
                  FlexibleSlider(max: 3, onChanged: (v) {}),

                if ((fieldAccess['particular'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['amount1'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Amount 1", value: "0"),

                if ((fieldAccess['amount1'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['amount2'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Amount 2", value: "0"),

                if ((fieldAccess['amount2'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['amount3'] ?? false) || User == "Admin")
                  AutoCalcTextBox(label: "Amount 3", value: "0"),

                if ((fieldAccess['amount3'] ?? false) || User == "Admin")
                  const SizedBox(height: 30),

                if ((fieldAccess['submitButton'] ?? false) || User == "Admin")
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
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
