import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseUploadService {
  /// Strips sub-order suffix from LPM
  /// "LPM-00001-04-26-01" → "LPM-00001-04-26"
  static String _resolveMainJobId(String jobId) {
    final parts = jobId.split('-');
    if (parts.length >= 5) {
      return parts.take(4).join('-');
    }
    return jobId;
  }

  /// Upload file to Firebase Storage and save metadata directly
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
    // Resolve to main job ID (strips "-01" suffix if present)
    final mainJobId = _resolveMainJobId(jobId);
    debugPrint('📁 Resolved jobId: "$jobId" → "$mainJobId"');

    try {
      // 1. Upload to Firebase Storage
      // Create a unique file name to avoid overwrites within the same job/field
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // --- BEGIN STORAGE PATH REFACTOR (NESTED JOBS) ---
      // Developer Notice: Make sure your storage.rules file in Firebase allows writes/reads
      // to the path: jobs/{lpmNumber}/{fieldName}/{file}
      final storagePath = 'jobs/$mainJobId/$fieldName/${timestamp}_$fileName';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      // --- END STORAGE PATH REFACTOR (NESTED JOBS) ---
      
      final metadata = SettableMetadata(
        contentType: mimeType,
      );

      debugPrint('⬆️ Uploading "$fileName" to Firebase Storage...');
      final uploadTask = await storageRef.putData(fileBytes, metadata);
      
      // 2. Get the public download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('✅ Firebase upload success! Download URL: $downloadUrl');

      // 3. Save directly onto jobs/{mainJobId} document in Firestore
      // Uses dot-notation key so other fields are never overwritten
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(mainJobId)
          .set(
        {
          'files': {
            fieldName: {
              'fileId':     storagePath, // Using storage path as ID
              'fileName':   fileName,
              'mimeType':   mimeType,
              'viewUrl':    downloadUrl,
              'uploadedAt': FieldValue.serverTimestamp(),
            },
          },
        },
        SetOptions(merge: true), // merge — never overwrites other fields
      );

      debugPrint('✅ Saved to Firestore at jobs/$mainJobId/files/$fieldName');
      return storagePath; // Return the path as the file ID

    } catch (e) {
      debugPrint('❌ Firebase Upload error: $e');
      return null;
    }
  }
}
