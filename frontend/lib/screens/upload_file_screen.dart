import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../constants/endpoints.dart';

class UploadFileScreen extends StatefulWidget {
  final String clubId;

  const UploadFileScreen({Key? key, required this.clubId}) : super(key: key);

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  File? selectedFile;
  bool isUploading = false;
  String? uploadedLink;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadFile() async {
    if (selectedFile == null) return;

    setState(() => isUploading = true);

    final uri = Uri.parse('${backend.uri}/api/onedrive/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['clubId'] = widget.clubId
      ..files.add(await http.MultipartFile.fromPath('file', selectedFile!.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(responseBody);
      setState(() => uploadedLink = json['downloadLink']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed")));
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload File")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text("Pick File"),
            ),
            const SizedBox(height: 20),
            if (selectedFile != null) Text("Selected: ${selectedFile!.path.split('/').last}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isUploading ? null : uploadFile,
              child: isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Upload"),
            ),
            if (uploadedLink != null) ...[
              const SizedBox(height: 20),
              Text("Download Link:"),
              SelectableText(uploadedLink!, style: const TextStyle(color: Colors.blue)),
            ],
          ],
        ),
      ),
    );
  }
}
