/// Defines the EXACT fields that each department's form renders,
/// in the order they should appear in JobSummaryScreen.
///
/// Rules:
///  - Only keys that are actually rendered in the form (visible to user) are listed.
///  - "SelectedBy" / timestamp fields are included only when their parent field
///    has a non-"No" value — that conditional is handled in JobSummaryScreen.
///  - Internal-only keys (controllers that exist but are never shown) are excluded.
///  - The order here matches the visual order inside each form page.

class JobSummaryFieldConfig {
  JobSummaryFieldConfig._();

  // ── DESIGNER (Pages 1–4) ─────────────────────────────────────────────────
  //
  // Page 1  : PartyName, ParticularJobName, Priority, Remark, DeliveryAt,
  //           Orderby
  // Page 2  : PlyType, (PlySelectedBy), Blade, (BladeSelectedBy),
  //           Creasing, (CreasingSelectedBy), Perforation,
  //           (PerforationSelectedBy), ZigZagBlade, (ZigZagBladeSelectedBy),
  //           RubberType, (RubberSelectedBy), HoleType, (HoleSelectedBy),
  //           StrippingType, CapsuleType
  // Page 3  : EmbossStatus, (EmbossPcs), (MaleEmbossType), (FemaleEmbossType)
  // Page 4  : RubberFixingDone, WhiteProfileRubber,
  //           DesigningStatus, (DesignedBy), (DesignedByTimestamp),
  //           SendApproval
  //
  // "Orderby" is the actual Firestore key (note lowercase 'b').
  // Fields in parentheses are conditionally shown; we still list them here
  // and let JobSummaryScreen decide whether to hide them if the value is
  // empty / "No" / "-".
  static const List<String> designer = [
    "PartyName",
    "ParticularJobName",
    "Priority",
    "Remark",
    "DeliveryAt",
    "Orderby",
    // Page 2
    "PlyType",
    "PlySelectedBy",
    "Blade",
    "BladeSelectedBy",
    "Creasing",
    "CreasingSelectedBy",
    "Perforation",
    "PerforationSelectedBy",
    "ZigZagBlade",
    "ZigZagBladeSelectedBy",
    "RubberType",
    "RubberSelectedBy",
    "HoleType",
    "HoleSelectedBy",
    "StrippingType",
    "CapsuleType",
    // Page 3
    "EmbossStatus",
    "EmbossPcs",
    "MaleEmbossType",
    "FemaleEmbossType",
    // Page 4
    "RubberFixingDone",
    "WhiteProfileRubber",
    "DesigningStatus",
    "DesignedBy",
    "DesignedByTimestamp",
    "SendApproval",
  ];

  // ── AUTO BENDING ─────────────────────────────────────────────────────────
  // View-only (from designer): PartyName, DeliveryAt, Orderby,
  //   ParticularJobName, LpmAutoIncrement, Priority  — these live in
  //   designer.data, not autoBending.data, so they are NOT in this list.
  //
  // Own editable fields (stored in autoBending.data):
  static const List<String> autoBending = [
    "AutoBendingStatus",
    "AutoBendingCreatedByName",
    "AutoBendingCreatedByTimestamp",
    "AutoCreasing",
    "AutoCreasingStatus",
  ];

  // ── MANUAL BENDING ───────────────────────────────────────────────────────
  static const List<String> manualBending = [
    "ManualBendingStatus",
    "ManualBendingCreatedByName",
    "ManualBendingCreatedByTimestamp",
  ];

  // ── LASER CUTTING ────────────────────────────────────────────────────────
  // PlyType / PlySelectedBy are view-only copies from designer.data inside
  // the Laser form, but they are NOT saved into laserCutting.data, so they
  // are excluded here (they already appear under Designer Details).
  static const List<String> laserCutting = [
    "LaserCuttingStatus",
    "LaserCuttingCreatedByName",
    "LaserCuttingCreatedByTimestamp",
  ];

  // ── RUBBER ───────────────────────────────────────────────────────────────
  static const List<String> rubber = [
    "RubberStatus",
    "RubberCreatedBy",
  ];

  // ── EMBOSS ───────────────────────────────────────────────────────────────
  // No Emboss form was provided; keep empty so the section is skipped
  // entirely until the form is wired up.
  static const List<String> emboss = [];

  // ── LOOKUP MAP ───────────────────────────────────────────────────────────
  // Keyed by the Firestore department key used in JobSummaryScreen.
  static const Map<String, List<String>> byDepartmentKey = {
    "designer":      designer,
    "autoBending":   autoBending,
    "manualBending": manualBending,
    "laserCutting":  laserCutting,
    "rubber":        rubber,
    "emboss":        emboss,
  };

  /// Returns a filtered & ordered copy of [rawData] that contains only
  /// the keys present in the whitelist for [departmentKey].
  ///
  /// A key is included as long as it is in the whitelist — even if the
  /// value is null, empty, or "No". The summary screen will display "-"
  /// for those, matching exactly what the form shows the user.
  ///
  /// The ONLY reason a key is excluded is if it was never in the form
  /// (i.e. it's an old deleted controller that still exists in Firestore).
  static Map<String, dynamic> filter(
      String departmentKey,
      Map<String, dynamic> rawData,
      ) {
    final whitelist = byDepartmentKey[departmentKey];
    if (whitelist == null || whitelist.isEmpty) return {};

    final result = <String, dynamic>{};
    for (final key in whitelist) {
      // Always include whitelisted keys, using null if not yet in Firestore.
      // This ensures every form field appears in the summary, filled or not.
      result[key] = rawData[key];
    }
    return result;
  }
}