import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/endpoints.dart';

class UploadFileScreen extends StatefulWidget {
  final String clubId;
  final String viewerEmail;

  const UploadFileScreen({Key? key, required this.clubId, required this.viewerEmail}) : super(key: key);

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  File? selectedFile;
  bool isUploading = false;
  double uploadProgress = 0.0;
  List<dynamic> clubFiles = [];

  @override
  void initState() {
    super.initState();
    fetchClubFiles();
  }

  Future<void> fetchClubFiles() async {
    final uri = Uri.parse('${backend.uri}/api/onedrive/club-files?referenceId=${widget.clubId}&viewerEmail=${widget.viewerEmail}');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        clubFiles = jsonData['files'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load files")));
    }
  }

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

    setState(() {
      isUploading = true;
      uploadProgress = 0.0;
    });

    final uri = Uri.parse('${backend.uri}/api/onedrive/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['category'] = 'club'
      ..fields['referenceId'] = widget.clubId
      ..files.add(await http.MultipartFile.fromPath('file', selectedFile!.path));

    final streamedResponse = await request.send();

    // Monitor progress
    streamedResponse.stream.transform(utf8.decoder).listen((value) {
      final response = jsonDecode(value);
      if (streamedResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Uploaded successfully")));
        fetchClubFiles(); // Refresh file list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed")));
      }
      setState(() => isUploading = false);
    });
  }

  Future<void> downloadFile(String downloadLink) async {
    if (await canLaunchUrl(Uri.parse(downloadLink))) {
      await launchUrl(Uri.parse(downloadLink), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cannot open file")));
    }
  }

  Widget fileItem(Map file) {
    return ListTile(
      leading: Icon(Icons.insert_drive_file),
      title: Text(file['name'] ?? 'Untitled'),
      subtitle: Text("${file['mimeType']} • ${(file['size'] / 1024).toStringAsFixed(2)} KB"),
      trailing: IconButton(
        icon: Icon(Icons.download),
        onPressed: () => downloadFile(file['link']),
      ),
      onTap: () => downloadFile(file['link']), // Preview via browser
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Club Files")),
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isUploading ? null : uploadFile,
              child: isUploading
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(width: 10),
                  Text("Uploading...")
                ],
              )
                  : const Text("Upload"),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const Text("Previous Files", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: clubFiles.isEmpty
                  ? const Center(child: Text("No files uploaded yet."))
                  : ListView.builder(
                itemCount: clubFiles.length,
                itemBuilder: (context, index) {
                  return fileItem(clubFiles[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
