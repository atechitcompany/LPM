import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/drive_upload_service.dart';

class FilePreviewCard extends StatefulWidget {
  final String fileId;
  final String fileName;
  final String mimeType;
  final String viewUrl;

  const FilePreviewCard({
    super.key,
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    required this.viewUrl,
  });

  @override
  State<FilePreviewCard> createState() => _FilePreviewCardState();
}

class _FilePreviewCardState extends State<FilePreviewCard> {
  Uint8List? _previewBytes;
  bool _loadingPreview = false;

  bool get _isImage =>
      widget.mimeType.startsWith('image/');

  @override
  void initState() {
    super.initState();
    // Auto-load preview for images
    if (_isImage) _loadPreview();
  }

  Future<void> _loadPreview() async {
    setState(() => _loadingPreview = true);
    final bytes = await DriveUploadService.downloadFile(widget.fileId);
    setState(() {
      _previewBytes    = bytes;
      _loadingPreview  = false;
    });
  }

  Future<void> _openInBrowser() async {
    final url = Uri.parse(widget.viewUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // File name row
            Row(
              children: [
                Icon(
                  _isImage ? Icons.image : Icons.insert_drive_file,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Preview area
            if (_isImage) ...[
              if (_loadingPreview)
                const Center(child: CircularProgressIndicator())
              else if (_previewBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _previewBytes!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const Text('Could not load preview'),
            ] else ...[
              // Non-image: show icon + tap to open
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insert_drive_file,
                        size: 40, color: Colors.grey.shade500),
                    const SizedBox(height: 6),
                    Text(
                      widget.mimeType == 'application/pdf'
                          ? 'PDF Document'
                          : 'File',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Download / Open button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openInBrowser,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Open / Download'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}