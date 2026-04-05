import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

// dart:html is NOT imported here directly — it is only used via conditional
// import below so Android/iOS builds never see it.
// ignore: avoid_web_libraries_in_flutter
import 'web_utils_stub.dart'
if (dart.library.html) 'web_utils.dart' as web_utils;

class FileUploadBox extends StatelessWidget {
  final Function(PlatformFile) onFileSelected;

  const FileUploadBox({
    super.key,
    required this.onFileSelected,
  });

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;

        if (kIsWeb) {
          // Web: create blob URL from bytes
          if (pickedFile.bytes != null) {
            final blobUrl =
            web_utils.createBlobUrl(pickedFile.bytes!);

            final webFile = PlatformFile(
              name: pickedFile.name,
              size: pickedFile.size,
              path: blobUrl,
              bytes: pickedFile.bytes,
            );

            onFileSelected(webFile);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to read file')),
              );
            }
          }
        } else {
          // Android / iOS: use file path directly
          onFileSelected(pickedFile);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickFile(context),
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file,
                color: Colors.grey.shade600, size: 24),
            const SizedBox(width: 8),
            Text(
              'Upload File',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}