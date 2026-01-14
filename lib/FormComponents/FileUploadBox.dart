import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadBox extends StatefulWidget {
  final Function(PlatformFile file) onFileSelected;

  const FileUploadBox({super.key, required this.onFileSelected});

  @override
  State<FileUploadBox> createState() => _FileUploadBoxState();
}

class _FileUploadBoxState extends State<FileUploadBox> {
  PlatformFile? selectedFile;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // you can make it true for multiple files
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;
      });

      widget.onFileSelected(selectedFile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pickFile,
      child: Container(
        height: 55,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: selectedFile == null
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.upload_file, size: 25),
              SizedBox(width: 8),
              Text("Drop here to attach or upload"),

            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.insert_drive_file,
                  size: 25, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                selectedFile!.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${(selectedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB",
                style:
                const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
