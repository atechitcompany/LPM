// Generates the HTML email template for ANY department notification.
//
// This template is generic and dynamically adapts to the department 
// that triggers it (e.g. Auto Bending, Manual Bending, Emboss).

String generateDepartmentEmailHtml({
  required String departmentName,
  required String partyName,
  required String productName,
  required String lpmNumber,
  required String actionDoneByLabel,
  required String actionDoneBy,
  required String actionTimestampLabel,
  required String actionTimestamp,
  required Map<String, bool> stepStatus,
  String? fileUrl,
  String? fileLabel = "ATTACHED FILE",
  List<Map<String, String>>? attachments,
}) {
  // ── Colors from the established design system ──────────────────────────────
  const headerBg = '#2C3E50';
  const greetingColor = '#D35400';
  const textPrimary = '#2C3E50';
  const textSecondary = '#7F8C8D';
  const cardBg = '#F8F9F9';
  const cardBorder = '#BDC3C7';
  const cardSolidBorder = '#E5E7E9';
  const highlightBlue = '#2980B9';
  const highlightGreen = '#27AE60';
  const buttonBg = '#3498DB';
  const footerBg = '#ECF0F1';
  const footerText = '#95A5A6';

  // ── Logo URL (Firebase Storage) ──────────────────────────
  const logoUrl = 'https://firebasestorage.googleapis.com/v0/b/light-punch-maker-atech1.firebasestorage.app/o/public_assets%2FLPM.jpg?alt=media&token=7f6679c1-11f2-4c80-a705-5863d3255224';
  
  // --- BEGIN DEPT-WISE EMAIL ATTACHMENTS FILTER ---
  String fileSection = '';
  if (attachments != null && attachments.isNotEmpty) {
    final buttonsHtml = attachments.map((att) {
      final label = att['label'] ?? 'View / Download File';
      final url = att['url'] ?? '';
      return '''
      <div style="margin-bottom: 12px;">
        <a href="$url" target="_blank" style="display: inline-block; background-color: $buttonBg; color: #ffffff; text-decoration: none; padding: 12px 24px; border-radius: 4px; font-size: 13px; font-weight: bold; font-family: Arial, sans-serif;">📄 $label</a>
      </div>
      ''';
    }).join('\n');

    fileSection = '''
    <table width="100%" cellpadding="0" cellspacing="0" style="margin-top: 16px; border: 1px solid $cardSolidBorder; border-radius: 6px; background-color: #FFFFFF;">
      <tr>
        <td style="padding: 24px; text-align: center;">
          <p style="margin: 0 0 16px 0; font-size: 14px; color: $textPrimary; font-weight: bold; font-family: Arial, sans-serif;">Download ${departmentName} Files</p>
          $buttonsHtml
        </td>
      </tr>
    </table>
    ''';
  } else if (fileUrl != null && fileUrl.isNotEmpty) {
    fileSection = '''
    <table width="100%" cellpadding="0" cellspacing="0" style="margin-top: 16px; border: 1px solid $cardSolidBorder; border-radius: 6px; background-color: #FFFFFF;">
      <tr>
        <td style="padding: 24px; text-align: center;">
          <p style="margin: 0 0 16px 0; font-size: 14px; color: $textPrimary; font-weight: bold; font-family: Arial, sans-serif;">$fileLabel</p>
          <a href="$fileUrl" target="_blank" style="display: inline-block; background-color: $buttonBg; color: #ffffff; text-decoration: none; padding: 12px 24px; border-radius: 4px; font-size: 13px; font-weight: bold; font-family: Arial, sans-serif;">📄 View / Download File</a>
        </td>
      </tr>
    </table>
    ''';
  }
  // --- END DEPT-WISE EMAIL ATTACHMENTS FILTER ---

  // ── Dynamic Live Status Stepper Logic ──
  // 1. Separate into done and pending
  final doneSteps = stepStatus.entries
      .where((e) => e.value == true)
      .map((e) => e.key)
      .toList();
      
  final pendingSteps = stepStatus.entries
      .where((e) => e.value == false)
      .map((e) => e.key)
      .toList();
      
  // 2. If Delivered is true, hide all pending stages
  final isDelivered = stepStatus["Delivered"] == true;
  final orderedSteps = isDelivered ? doneSteps : [...doneSteps, ...pendingSteps];
  
  // 3. Build HTML for each step
  String stepperCellsHtml = "";
  for (int i = 0; i < orderedSteps.length; i++) {
    final stepName = orderedSteps[i];
    final isCompleted = stepStatus[stepName] == true;
    final isLast = (i == orderedSteps.length - 1);
    final isLastCompleted = (isLast && isCompleted);
    
    // Circle styling
    String circleBg = cardBg;
    String circleBorder = '2px solid $cardSolidBorder';
    String circleContent = '';
    String circleTextColor = 'transparent';
    
    if (isLastCompleted) {
      circleBg = highlightGreen; // Solid Green
      circleBorder = '2px solid $highlightGreen';
      circleContent = '✓';
      circleTextColor = '#ffffff';
    } else if (isCompleted) {
      circleBg = buttonBg; // Solid Blue
      circleBorder = '2px solid $buttonBg';
      circleContent = '✓';
      circleTextColor = '#ffffff';
    }
    
    // Format label (add breaks for long words)
    String formattedLabel = stepName.replaceAll(' ', '<br/>');
    
    stepperCellsHtml += '''
    <td align="center" style="width: ${100 / orderedSteps.length}%; vertical-align: top; position: relative;">
      <div style="width: 24px; height: 24px; border-radius: 50%; background-color: $circleBg; border: $circleBorder; box-sizing: border-box; text-align: center; line-height: 20px; color: $circleTextColor; font-size: 14px; font-weight: bold; margin: 0 auto; position: relative; z-index: 2;">$circleContent</div>
      <p style="margin: 8px 0 0 0; font-size: 10px; color: ${isCompleted ? textPrimary : textSecondary}; font-weight: ${isCompleted ? 'bold' : 'normal'}; font-family: Arial, sans-serif;">$formattedLabel</p>
    </td>
    ''';
    
    // Add connector line except for the last step
    if (!isLast) {
      final nextStep = orderedSteps[i + 1];
      final isNextCompleted = stepStatus[nextStep] == true;
      String lineBg = isNextCompleted 
          ? buttonBg 
          : (isCompleted ? 'linear-gradient(90deg, $buttonBg 50%, $cardSolidBorder 50%)' : cardSolidBorder);
          
      stepperCellsHtml += '''
      <td style="width: 2%; vertical-align: top; padding-top: 11px;">
        <div style="height: 2px; background: $lineBg; background-color: ${isNextCompleted ? buttonBg : cardSolidBorder}; width: 100%;"></div>
      </td>
      ''';
    }
  }
  
  final liveStatusSection = '''
  <table width="100%" cellpadding="0" cellspacing="0" style="margin-top: 16px; border: 1px solid $cardSolidBorder; border-radius: 6px; background-color: #FFFFFF;">
    <tr>
      <td style="padding: 16px; text-align: center; border-bottom: 1px solid $cardSolidBorder;">
        <p style="margin: 0; font-size: 13px; color: $textPrimary; font-weight: bold; font-family: Arial, sans-serif; letter-spacing: 1px;">LIVE JOB STATUS</p>
      </td>
    </tr>
    <tr>
      <td style="padding: 24px 16px 32px 16px; overflow-x: auto;">
        <!-- Stepper Table -->
        <table width="100%" cellpadding="0" cellspacing="0">
          <tr>
            $stepperCellsHtml
          </tr>
        </table>
      </td>
    </tr>
  </table>
  ''';

  // ── Build the full HTML ────────────────────────────────────────────────
  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${departmentName.toUpperCase()} IS DONE</title>
</head>
<body style="margin: 0; padding: 0; background-color: #ffffff; font-family: Arial, Helvetica, sans-serif;">

  <table width="100%" cellpadding="0" cellspacing="0">
    <tr>
      <td align="center">
        <!-- MAX WIDTH CONTAINER -->
        <table width="600" cellpadding="0" cellspacing="0" style="max-width: 600px; width: 100%; margin: 0 auto; background-color: #ffffff;">

          <!-- HEADER -->
          <tr>
            <td style="background-color: $headerBg; padding: 30px 20px; text-align: center;">
              <div style="background-color: #ffffff; padding: 4px; border-radius: 6px; display: inline-block; margin-bottom: 16px;">
                <img src="$logoUrl" alt="LPM Logo" width="60" height="60" style="display: block; border-radius: 4px;" />
              </div>
              <h1 style="margin: 0; color: #ffffff; font-size: 20px; font-weight: bold; font-family: Arial, sans-serif; letter-spacing: 0.5px; text-transform: uppercase;">${departmentName.toUpperCase()} IS DONE ✅</h1>
            </td>
          </tr>

          <!-- BODY CONTENT -->
          <tr>
            <td style="padding: 30px 24px;">
              
              <!-- Greeting -->
              <p style="margin: 0 0 16px 0; font-size: 14px; color: $greetingColor; font-weight: bold; font-family: Arial, sans-serif;">
                Hello ${partyName.toUpperCase()},
              </p>
              
              <!-- Message -->
              <p style="margin: 0 0 24px 0; font-size: 13px; color: $textPrimary; line-height: 1.5; font-family: Arial, sans-serif;">
                Great news! The ${departmentName.toLowerCase()} phase for your order has been completed. Here are the details:
              </p>

              <!-- ORDER DETAILS CARD (Dashed) -->
              <table width="100%" cellpadding="0" cellspacing="0" style="border: 1px dashed $cardBorder; border-radius: 6px; background-color: $cardBg; padding: 16px;">
                <tr>
                  <td style="padding: 8px 0; font-size: 12px; color: $textSecondary; font-family: Arial, sans-serif; font-weight: bold; width: 35%;">Product Name:</td>
                  <td style="padding: 8px 0; font-size: 12px; color: $textPrimary; font-family: Arial, sans-serif; font-weight: bold;">$productName</td>
                </tr>
                <tr>
                  <td colspan="2"><div style="height: 1px; border-bottom: 1px dashed $cardSolidBorder; margin: 4px 0;"></div></td>
                </tr>
                <tr>
                  <td style="padding: 8px 0; font-size: 12px; color: $textSecondary; font-family: Arial, sans-serif; font-weight: bold;">Tracking ID<br/>(LPM):</td>
                  <td style="padding: 8px 0; font-size: 13px; color: $highlightBlue; font-family: Arial, sans-serif; font-weight: bold;">$lpmNumber</td>
                </tr>
                <tr>
                  <td colspan="2"><div style="height: 1px; border-bottom: 1px dashed $cardSolidBorder; margin: 4px 0;"></div></td>
                </tr>
                <tr>
                  <td style="padding: 8px 0; font-size: 12px; color: $textSecondary; font-family: Arial, sans-serif; font-weight: bold;">$actionDoneByLabel:</td>
                  <td style="padding: 8px 0; font-size: 13px; color: $textPrimary; font-family: Arial, sans-serif; font-weight: bold;">${actionDoneBy.isEmpty ? '-' : actionDoneBy}</td>
                </tr>
                <tr>
                  <td colspan="2"><div style="height: 1px; border-bottom: 1px dashed $cardSolidBorder; margin: 4px 0;"></div></td>
                </tr>
                <tr>
                  <td style="padding: 8px 0; font-size: 12px; color: $textSecondary; font-family: Arial, sans-serif; font-weight: bold;">$actionTimestampLabel:</td>
                  <td style="padding: 8px 0; font-size: 12px; color: $highlightGreen; font-family: Arial, sans-serif; font-weight: bold;">${actionTimestamp.isEmpty ? '-' : actionTimestamp}</td>
                </tr>
              </table>

              <!-- DYNAMIC ATTACHMENT SECTION -->
              $fileSection

              <!-- DYNAMIC LIVE STATUS SECTION -->
              $liveStatusSection
              
              <!-- Thank you text -->
              <p style="margin: 24px 0 0 0; text-align: center; font-size: 13px; color: $textSecondary; font-family: Arial, sans-serif;">
                Thank you for choosing Light Punch Maker. We hope to serve you again soon!
              </p>

            </td>
          </tr>

          <!-- FOOTER -->
          <tr>
            <td style="background-color: $footerBg; padding: 24px; text-align: center; border-radius: 0 0 8px 8px;">
              <p style="margin: 0 0 8px 0; font-size: 12px; color: $footerText; font-family: Arial, sans-serif; font-weight: bold;">
                LIGHT PUNCH MAKER
              </p>
              <p style="margin: 0; font-size: 11px; color: $footerText; font-family: Arial, sans-serif;">
                This is an automated notification from your production pipeline.<br/>Please do not reply directly to this email.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
  
</body>
</html>
  ''';
}
