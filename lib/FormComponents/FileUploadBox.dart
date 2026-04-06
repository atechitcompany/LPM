import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/drive_upload_service.dart';

class FileUploadBox extends StatefulWidget {
  final Function(PlatformFile) onFileSelected;
  final String jobId;      // ✅ NEW
  final String fieldName;  // ✅ NEW e.g. "DrawingAttachment"

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
  bool    _isUploading    = false;
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

    final driveFileId = await DriveUploadService.uploadFile(
      fileBytes: pickedFile.bytes!,
      fileName:  pickedFile.name,
      jobId:     widget.jobId,      // ✅ pass job ID
      fieldName: widget.fieldName,  // ✅ pass field name
    );

    if (context.mounted) {
      if (driveFileId != null) {
        setState(() {
          _isUploading     = false;
          _uploadedFileName = pickedFile.name;
        });
        widget.onFileSelected(pickedFile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${pickedFile.name}" uploaded!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Upload failed. Please try again.'),
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
                _uploadedFileName != null
                    ? Icons.check_circle
                    : Icons.upload_file,
                color: _uploadedFileName != null
                    ? Colors.green
                    : Colors.grey.shade600,
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