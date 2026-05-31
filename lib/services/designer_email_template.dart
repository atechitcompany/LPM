// Generates the HTML email template for the Designer department notification.
//
// This template perfectly replicates the visual style of the "Dispatched"
// email, but with content specific to the "Designing is Done" event.

String generateDesignerEmailHtml({
  required String partyName,
  required String productName,
  required String lpmNumber,
  required String orderDate,
  required String designedBy,
  required String designedByTimestamp,
  String? designFileUrl,
  List<Map<String, String>>? attachments,
}) {
  // ── Colors from the reference screenshot ───────────────────────────────
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

  // ── Logo URL (replace with your hosted logo) ──────────────────────────
  const logoUrl = 'https://firebasestorage.googleapis.com/v0/b/light-punch-maker-atech1.firebasestorage.app/o/public_assets%2FLPM.jpg?alt=media&token=7f6679c1-11f2-4c80-a705-5863d3255224';
  // --- BEGIN DEPT-WISE EMAIL ATTACHMENTS FILTER ---
  String designFileSection = '';
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

    designFileSection = '''
    <table width="100%" cellpadding="0" cellspacing="0" style="margin-top: 16px; border: 1px solid $cardSolidBorder; border-radius: 6px; background-color: #FFFFFF;">
      <tr>
        <td style="padding: 24px; text-align: center;">
          <p style="margin: 0 0 16px 0; font-size: 14px; color: $textPrimary; font-weight: bold; font-family: Arial, sans-serif;">Download Designing Files</p>
          $buttonsHtml
        </td>
      </tr>
    </table>
    ''';
  } else if (designFileUrl != null && designFileUrl.isNotEmpty) {
    designFileSection = '''
    <table width="100%" cellpadding="0" cellspacing="0" style="margin-top: 16px; border: 1px solid $cardSolidBorder; border-radius: 6px; background-color: #FFFFFF;">
      <tr>
        <td style="padding: 24px; text-align: center;">
          <p style="margin: 0 0 16px 0; font-size: 14px; color: $textPrimary; font-weight: bold; font-family: Arial, sans-serif;">DESIGN DRAWING</p>
          <a href="$designFileUrl" target="_blank" style="display: inline-block; background-color: $buttonBg; color: #ffffff; text-decoration: none; padding: 12px 24px; border-radius: 4px; font-size: 13px; font-weight: bold; font-family: Arial, sans-serif;">📄 View / Download File</a>
        </td>
      </tr>
    </table>
    ''';
  }
  // --- END DEPT-WISE EMAIL ATTACHMENTS FILTER ---

  // ── Build the full HTML ────────────────────────────────────────────────
  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Designing is Done</title>
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
              <h1 style="margin: 0; color: #ffffff; font-size: 20px; font-weight: bold; font-family: Arial, sans-serif; letter-spacing: 0.5px; text-transform: uppercase;">DESIGNING IS DONE ✅</h1>
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
                Great news! The designing phase for your order has been completed. Here are the details:
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
                  <td style="padding: 8px 0; font-size: 12px; color: $textSecondary; font-family: Arial, sans-serif; font-weight: bold;">Order Date:</td>
                  <td style="padding: 8px 0; font-size: 12px; color: $textPrimary; font-family: Arial, sans-serif; font-weight: bold;">$orderDate</td>
                </tr>
                <tr>
                  <td colspan="2"><div style="height: 1px; border-bottom: 1px dashed $cardSolidBorder; margin: 4px 0;"></div></td>
                </tr>
                <tr>
                  <td style="padding: 8px 0; font-size: 12px; color: $textSecondary; font-family: Arial, sans-serif; font-weight: bold;">Designing Done On:</td>
                  <td style="padding: 8px 0; font-size: 12px; color: $highlightGreen; font-family: Arial, sans-serif; font-weight: bold;">$designedByTimestamp</td>
                </tr>
                <tr>
                  <td colspan="2"><div style="height: 1px; border-bottom: 1px dashed $cardSolidBorder; margin: 4px 0;"></div></td>
                </tr>
                <tr>
                  <td style="padding: 8px 0; font-size: 12px; color: $textSecondary; font-family: Arial, sans-serif; font-weight: bold;">Designed By:</td>
                  <td style="padding: 8px 0; font-size: 12px; color: $textPrimary; font-family: Arial, sans-serif; font-weight: bold;">$designedBy</td>
                </tr>
              </table>

              <!-- DESIGN DRAWING CARD -->
              $designFileSection

              <!-- LIVE STATUS CARD -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-top: 16px; border: 1px solid $cardSolidBorder; border-radius: 6px; background-color: #FFFFFF;">
                <tr>
                  <td style="padding: 16px; text-align: center; border-bottom: 1px solid $cardSolidBorder;">
                    <p style="margin: 0; font-size: 13px; color: $textPrimary; font-weight: bold; font-family: Arial, sans-serif; letter-spacing: 1px;">LIVE STATUS</p>
                  </td>
                </tr>
                <tr>
                  <td style="padding: 24px 16px 32px 16px;">
                    <!-- Stepper Table -->
                    <table width="100%" cellpadding="0" cellspacing="0">
                      <tr>
                        
                        <!-- Step 1: Designing (Completed) -->
                        <td align="center" style="width: 20%; vertical-align: top; position: relative;">
                          <div style="width: 24px; height: 24px; border-radius: 50%; background-color: $buttonBg; color: #ffffff; text-align: center; line-height: 24px; font-size: 14px; font-weight: bold; margin: 0 auto; position: relative; z-index: 2;">✓</div>
                          <p style="margin: 8px 0 0 0; font-size: 10px; color: $textPrimary; font-weight: bold; font-family: Arial, sans-serif;">Designing</p>
                        </td>
                        
                        <!-- Line 1-2 (Blue to Grey) -->
                        <td style="width: 5%; vertical-align: top; padding-top: 11px;">
                          <div style="height: 2px; background: linear-gradient(90deg, $buttonBg 50%, $cardSolidBorder 50%); width: 100%;"></div>
                        </td>
                        
                        <!-- Step 2: Laser Cutting (Pending) -->
                        <td align="center" style="width: 20%; vertical-align: top;">
                          <div style="width: 24px; height: 24px; border-radius: 50%; background-color: $cardBg; border: 2px solid $cardSolidBorder; box-sizing: border-box; text-align: center; line-height: 20px; color: transparent; font-size: 14px; font-weight: bold; margin: 0 auto;"></div>
                          <p style="margin: 8px 0 0 0; font-size: 10px; color: $textSecondary; font-family: Arial, sans-serif;">Laser<br/>Cutting</p>
                        </td>

                        <!-- Line 2-3 (Grey) -->
                        <td style="width: 5%; vertical-align: top; padding-top: 11px;">
                          <div style="height: 2px; background-color: $cardSolidBorder; width: 100%;"></div>
                        </td>

                        <!-- Step 3: Auto Bending (Pending) -->
                        <td align="center" style="width: 20%; vertical-align: top;">
                          <div style="width: 24px; height: 24px; border-radius: 50%; background-color: $cardBg; border: 2px solid $cardSolidBorder; box-sizing: border-box; text-align: center; line-height: 20px; color: transparent; font-size: 14px; font-weight: bold; margin: 0 auto;"></div>
                          <p style="margin: 8px 0 0 0; font-size: 10px; color: $textSecondary; font-family: Arial, sans-serif;">Auto<br/>Bending</p>
                        </td>

                        <!-- Line 3-4 (Grey) -->
                        <td style="width: 5%; vertical-align: top; padding-top: 11px;">
                          <div style="height: 2px; background-color: $cardSolidBorder; width: 100%;"></div>
                        </td>

                        <!-- Step 4: Manual Bending (Pending) -->
                        <td align="center" style="width: 20%; vertical-align: top;">
                          <div style="width: 24px; height: 24px; border-radius: 50%; background-color: $cardBg; border: 2px solid $cardSolidBorder; box-sizing: border-box; text-align: center; line-height: 20px; color: transparent; font-size: 14px; font-weight: bold; margin: 0 auto;"></div>
                          <p style="margin: 8px 0 0 0; font-size: 10px; color: $textSecondary; font-family: Arial, sans-serif;">Manual<br/>Bending</p>
                        </td>

                        <!-- Line 4-5 (Grey) -->
                        <td style="width: 5%; vertical-align: top; padding-top: 11px;">
                          <div style="height: 2px; background-color: $cardSolidBorder; width: 100%;"></div>
                        </td>

                        <!-- Step 5: Out For Delivery (Pending) -->
                        <td align="center" style="width: 20%; vertical-align: top;">
                          <div style="width: 24px; height: 24px; border-radius: 50%; background-color: $cardBg; border: 2px solid $cardSolidBorder; box-sizing: border-box; text-align: center; line-height: 20px; color: transparent; font-size: 14px; font-weight: bold; margin: 0 auto;"></div>
                          <p style="margin: 8px 0 0 0; font-size: 10px; color: $textSecondary; font-family: Arial, sans-serif;">Out For Delivery</p>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>

              <!-- Thank you text -->
              <p style="margin: 24px 0 0 0; text-align: center; font-size: 13px; color: $textSecondary; font-family: Arial, sans-serif;">
                Thank you for choosing Light Punch Maker. We hope to serve you again soon!
              </p>

            </td>
          </tr>

          <!-- FOOTER -->
          <tr>
            <td style="background-color: $footerBg; padding: 24px; text-align: center; font-size: 11px; color: $footerText; font-family: Arial, sans-serif; line-height: 1.6;">
              © 2026 Light Punch Maker. All rights reserved.<br/>
              Powered By A Tech IT Company | Contact: +91 7038333221<br/>
              Gala No. F-16 & F-17, First Floor, Siddharth Ind. Estate, Vasai (E)
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
