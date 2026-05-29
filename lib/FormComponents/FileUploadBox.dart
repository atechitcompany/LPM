import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FileUploadBox extends StatefulWidget {
  final Function(PlatformFile) onFileSelected;
  final String jobId;
  final String fieldName;

  const FileUploadBox({
    super.key,
    required this.onFileSelected,
    required this.jobId,
    required this.fieldName,
  });

  @override
  State<FileUploadBox> createState() => _FileUploadBoxState();
}

class _FileUploadBoxState extends State<FileUploadBox> {
  bool _isUploading = false;
  String? _uploadedFileName;

  Future<void> _pickAndUpload(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final pickedFile = result.files.first;

    if (pickedFile.bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Could not read file')),
        );
      }
      return;
    }

    setState(() => _isUploading = true);

    try {
      final path = 'uploads/${widget.jobId}/${widget.fieldName}/${pickedFile.name}';
      final ref = FirebaseStorage.instance.ref(path);
      await ref.putData(pickedFile.bytes!);

      if (context.mounted) {
        setState(() {
          _isUploading = false;
          _uploadedFileName = pickedFile.name;
        });
        widget.onFileSelected(pickedFile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${pickedFile.name}" uploaded!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isUploading ? null : () => _pickAndUpload(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _uploadedFileName != null
                ? Colors.green.shade400
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _uploadedFileName != null
              ? Colors.green.shade50
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isUploading)
              const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                _uploadedFileName != null ? Icons.check_circle : Icons.upload_file,
                color: _uploadedFileName != null ? Colors.green : Colors.grey.shade600,
                size: 24,
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _isUploading
                    ? 'Uploading...'
                    : _uploadedFileName ?? 'Upload File',
                style: TextStyle(
                  color: _uploadedFileName != null
                      ? Colors.green.shade700
                      : Colors.grey.shade700,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}