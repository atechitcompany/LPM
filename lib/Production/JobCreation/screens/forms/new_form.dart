import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'new_form_scope.dart';

class NewForm extends StatefulWidget {
  final Widget child;

  const NewForm({super.key, required this.child});

  @override
  State<NewForm> createState() => NewFormState();
}

class NewFormState extends State<NewForm> {
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
  //new
  final TextEditingController DesignedBy = TextEditingController();

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
    //new
    DesignedBy.dispose();


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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _goPrev,
                    child: const Text("Previous"),
                  ),
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

  void _goNext() {
    final location = GoRouterState.of(context).uri.toString();

    const pages = [
      '/jobform/designer-1',
      '/jobform/designer-2',
      '/jobform/designer-3',
      '/jobform/auto-bending',
      '/jobform/manual-bending',
      '/jobform/laser',
      '/jobform/rubber',
      '/jobform/emboss',
      '/jobform/delivery',
    ];

    final index = pages.indexOf(location);
    if (index != -1 && index < pages.length - 1) {
      context.go(pages[index + 1]);
    }
  }

  void _goPrev() {
    final location = GoRouterState.of(context).uri.toString();

    const pages = [
      '/jobform/designer-1',
      '/jobform/designer-2',
      '/jobform/designer-3',
      '/jobform/auto-bending',
      '/jobform/manual-bending',
      '/jobform/laser',
      '/jobform/rubber',
      '/jobform/emboss',
      '/jobform/delivery',
    ];

    final index = pages.indexOf(location);
    if (index > 0) {
      context.go(pages[index - 1]);
    }
  }
}
