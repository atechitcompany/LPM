import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriveUploadService {

  static const String _folderId = '0ALfDi6AdYMHbUk9PVA';

  static Future<Map<String, dynamic>> _loadServiceAccount() async {
    final jsonStr = await rootBundle.loadString('assets/service_account.json');
    return jsonDecode(jsonStr);
  }

  static Future<String?> _getAccessToken() async {
    try {
      final sa = await _loadServiceAccount();
      final privateKeyPem = sa['private_key'] as String;
      final clientEmail   = sa['client_email'] as String;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final jwt = JWT({
        'iss': clientEmail,
        'sub': clientEmail,
        'aud': 'https://oauth2.googleapis.com/token',
        'scope': 'https://www.googleapis.com/auth/drive',
        'iat': now,
        'exp': now + 3600,
      });

      final token = jwt.sign(
        RSAPrivateKey(privateKeyPem),
        algorithm: JWTAlgorithm.RS256,
      );

      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        debugPrint('❌ Token error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error getting token: $e');
      return null;
    }
  }

  /// Strips sub-order suffix from LPM
  /// "LPM-00001-04-26-01" → "LPM-00001-04-26"
  static String _resolveMainJobId(String jobId) {
    final parts = jobId.split('-');
    if (parts.length >= 5) {
      return parts.take(4).join('-');
    }
    return jobId;
  }

  /// Upload file to Google Drive and save metadata directly
  /// on the jobs/{mainJobId} document in Firestore.
  ///
  /// [jobId]     — full or main LPM (auto-resolved to main)
  /// [fieldName] — e.g. "DrawingAttachment", "RubberReport", "PunchReport"
  static Future<String?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String jobId,
    required String fieldName,
    String mimeType = 'application/octet-stream',
  }) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      debugPrint('❌ Could not get access token');
      return null;
    }

    // ✅ Always resolve to main job ID (strips "-01" suffix if present)
    final mainJobId = _resolveMainJobId(jobId);
    debugPrint('📁 Resolved jobId: "$jobId" → "$mainJobId"');

    try {
      final uri = Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files'
            '?uploadType=multipart'
            '&supportsAllDrives=true'
            '&includeItemsFromAllDrives=true',
      );

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $accessToken';

      // ✅ No 'driveId' in metadata — only in query params
      final metadata = jsonEncode({
        'name': fileName,
        'mimeType': mimeType,
        'parents': [_folderId],
      });

      request.files.add(
        http.MultipartFile.fromString(
          'metadata',
          metadata,
          contentType: MediaType('application', 'json'),
        ),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      debugPrint('⬆️ Uploading "$fileName" to Drive...');
      final streamed  = await request.send();
      final response  = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data   = jsonDecode(response.body);
        final fileId = data['id'] as String;

        debugPrint('✅ Drive upload success! File ID: $fileId');

        // ✅ Save directly onto jobs/{mainJobId} document
        // Uses dot-notation key so other fields are never overwritten
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(mainJobId)
            .set(
          {
            'files': {
              fieldName: {
                'fileId':     fileId,
                'fileName':   fileName,
                'mimeType':   mimeType,
                'viewUrl':    'https://drive.google.com/file/d/$fileId/view',
                'uploadedAt': FieldValue.serverTimestamp(),
              },
            },
          },
          SetOptions(merge: true), // ✅ merge — never overwrites other fields
        );

        debugPrint('✅ Saved to Firestore at jobs/$mainJobId/files/$fieldName');
        return fileId;

      } else {
        debugPrint('❌ Drive upload failed [${response.statusCode}]: ${response.body}');
        return null;
      }

    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return null;
    }
  }

  /// Fetch file bytes from Drive (for preview)
  static Future<Uint8List?> downloadFile(String fileId) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) return null;

    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/drive/v3/files/$fileId'
              '?alt=media&supportsAllDrives=true&includeItemsFromAllDrives=true',
        ),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('❌ Download failed [${response.statusCode}]: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Download error: $e');
      return null;
    }
  }
}