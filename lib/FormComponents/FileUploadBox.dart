import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html show Blob, Url;

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
          // For web: Create blob URL from bytes
          if (pickedFile.bytes != null) {
            final blob = html.Blob([pickedFile.bytes!]);
            final blobUrl = html.Url.createObjectUrlFromBlob(blob);

            // Create a new PlatformFile with the blob URL as path
            final webFile = PlatformFile(
              name: pickedFile.name,
              size: pickedFile.size,
              path: blobUrl, // Store blob URL as path for web
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
          // For native platforms: Use the file path directly
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, color: Colors.grey.shade600, size: 24),
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