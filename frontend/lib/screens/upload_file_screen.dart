import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import '../constants/endpoints.dart';

class UploadFileScreen extends StatefulWidget {
  final String clubId;
  final String viewerEmail;
  final bool isSecretary; // Add this to determine if user can delete files

  const UploadFileScreen({
    Key? key, 
    required this.clubId, 
    required this.viewerEmail,
    this.isSecretary = false, // Default to false
  }) : super(key: key);

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  List<File> selectedFiles = [];
  Map<String, String> customFilenames = {}; // Original filename -> custom filename
  Map<String, bool> fileVisibility = {}; // Original filename -> visibility (true = public)
  bool isUploading = false;
  double uploadProgress = 0.0;
  String uploadStatus = '';
  List<dynamic> clubFiles = [];
  Map<String, dynamic> storageInfo = {};
  bool isLoadingStorage = true;

  @override
  void initState() {
    super.initState();
    fetchClubFiles();
    fetchStorageInfo();
  }

  Future<void> fetchStorageInfo() async {
    setState(() {
      isLoadingStorage = true;
    });

    try {
      final uri = Uri.parse('${backend.uri}/api/onedrive/storage-info?userEmail=${widget.viewerEmail}');
      final response = await HttpClient().getUrl(uri).then((req) => req.close());

      if (response.statusCode == 200) {
        final jsonData = await response.transform(utf8.decoder).join();
        final decoded = jsonDecode(jsonData);
        setState(() {
          storageInfo = decoded['storage'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching storage info: $e');
    } finally {
      setState(() {
        isLoadingStorage = false;
      });
    }
  }

  Future<void> fetchClubFiles() async {
    try {
      final uri = Uri.parse('${backend.uri}/api/onedrive/list?referenceId=${widget.clubId}&viewerEmail=${widget.viewerEmail}');
      final response = await HttpClient().getUrl(uri).then((req) => req.close());

      if (response.statusCode == 200) {
        final jsonData = await response.transform(utf8.decoder).join();
        final decoded = jsonDecode(jsonData);
        setState(() {
          clubFiles = decoded['files'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load files")));
      }
    } catch (e) {
      debugPrint('Error fetching club files: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      List<File> files = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      setState(() {
        selectedFiles = files;
        
        // Initialize all files as private by default
        for (var file in files) {
          final fileName = path.basename(file.path);
          fileVisibility[fileName] = false;
        }
      });
    }
  }

  void removeSelectedFile(int index) {
    setState(() {
      final fileName = path.basename(selectedFiles[index].path);
      customFilenames.remove(fileName);
      fileVisibility.remove(fileName);
      selectedFiles.removeAt(index);
    });
  }

  void setCustomFilename(String originalFilename, String customFilename) {
    setState(() {
      if (customFilename.isEmpty) {
        customFilenames.remove(originalFilename);
      } else {
        customFilenames[originalFilename] = customFilename;
      }
    });
  }

  void toggleFileVisibility(String originalFilename, bool isPublic) {
    setState(() {
      fileVisibility[originalFilename] = isPublic;
    });
  }

  Future<void> uploadFiles() async {
    if (selectedFiles.isEmpty) return;

    setState(() {
      isUploading = true;
      uploadProgress = 0.0;
      uploadStatus = 'Preparing upload...';
    });

    try {
      final dio = Dio();
      final formData = FormData();

      // Add all files to formData
      for (var file in selectedFiles) {
        final fileName = path.basename(file.path);
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }

      // Add custom filenames if any
      if (customFilenames.isNotEmpty) {
        final customFilenamesList = selectedFiles.map((file) {
          final fileName = path.basename(file.path);
          return customFilenames[fileName] ?? fileName;
        }).toList();
        formData.fields.add(MapEntry('customFilenames', jsonEncode(customFilenamesList)));
      }

      // Determine visibility for each file
      final visibility = selectedFiles.map((file) {
        final fileName = path.basename(file.path);
        return fileVisibility[fileName] == true ? 'public' : 'private';
      }).toList();

      // If all files have the same visibility, use a single value
      final allSameVisibility = visibility.every((v) => v == visibility.first);
      if (allSameVisibility) {
        formData.fields.add(MapEntry('visibility', visibility.first));
      } else {
        formData.fields.add(MapEntry('visibilityList', jsonEncode(visibility)));
      }

      // Add other required fields
      formData.fields.add(MapEntry('category', 'club'));
      formData.fields.add(MapEntry('referenceId', widget.clubId));

      final response = await dio.post(
        '${backend.uri}/api/onedrive/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (total != 0) {
            final percent = sent / total;
            setState(() {
              uploadProgress = percent;
              uploadStatus = percent < 1.0
                  ? "Uploading... ${(percent * 100).toStringAsFixed(0)}%"
                  : "Processing with OneDrive...";
            });
          }
        },
      );

      if (response.statusCode == 200) {
        final filesUploaded = selectedFiles.length;
        setState(() {
          uploadStatus = "Upload complete!";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$filesUploaded file${filesUploaded > 1 ? 's' : ''} uploaded successfully"))
        );
        fetchClubFiles();
        fetchStorageInfo(); // Update storage info after upload
        setState(() {
          selectedFiles = [];
          customFilenames = {};
          fileVisibility = {};
        });
      } else {
        setState(() {
          uploadStatus = "Upload failed";
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed")));
      }
    } catch (e) {
      setState(() {
        uploadStatus = "Error occurred";
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      // Wait a moment to let "Upload complete!" show before resetting
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        isUploading = false;
        uploadProgress = 0.0;
        uploadStatus = '';
      });
    }
  }

  Future<void> downloadFile(String fileId) async {
    try {
      final uri = Uri.parse('${backend.uri}/api/onedrive/download/$fileId?viewerEmail=${widget.viewerEmail}');
      final response = await HttpClient().getUrl(uri).then((req) => req.close());

      if (response.statusCode == 200) {
        final jsonData = await response.transform(utf8.decoder).join();
        final decoded = jsonDecode(jsonData);
        final downloadLink = decoded['downloadLink'];
        
        if (await canLaunchUrl(Uri.parse(downloadLink))) {
          await launchUrl(Uri.parse(downloadLink), mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cannot open file")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to get download link")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      final dio = Dio();
      final response = await dio.delete(
        '${backend.uri}/api/onedrive/file/$fileId',
        data: {
          'userEmail': widget.viewerEmail,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("File deleted successfully")));
        fetchClubFiles();
        fetchStorageInfo(); // Update storage info after deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete file")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget fileItem(Map file) {
    final bool isPublic = file['visibility'] == 'public';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          _getFileIcon(file['mimeType']),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(file['name'] ?? 'Untitled'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${(file['size'] / 1024).toStringAsFixed(1)} KB • ${_formatDate(file['uploadedAt'])}"),
            Row(
              children: [
                Icon(
                  isPublic ? Icons.public : Icons.lock_outline,
                  size: 16,
                  color: isPublic ? Colors.green : Colors.grey,
                ),
                SizedBox(width: 4),
                Text(
                  isPublic ? "Public" : "Private",
                  style: TextStyle(
                    fontSize: 12,
                    color: isPublic ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.download, color: Colors.blue),
              onPressed: () => downloadFile(file['_id']),
              tooltip: 'Download',
            ),
            if (widget.isSecretary)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(file),
                tooltip: 'Delete',
              ),
          ],
        ),
        onTap: () => downloadFile(file['_id']),
      ),
    );
  }

  void _showDeleteConfirmation(Map file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete File"),
          content: Text("Are you sure you want to delete ${file['name']}?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                deleteFile(file['_id']);
              },
            ),
          ],
        );
      },
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    if (mimeType.startsWith('text/')) return Icons.text_snippet;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word') || mimeType.contains('document')) return Icons.article;
    if (mimeType.contains('excel') || mimeType.contains('sheet')) return Icons.table_chart;
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) return Icons.slideshow;
    
    return Icons.insert_drive_file;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    
    final date = DateTime.tryParse(dateString);
    if (date == null) return '';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStorageInfo() {
    if (isLoadingStorage) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (storageInfo.isEmpty) {
      return Center(child: Text("Storage information not available"));
    }
    
    final percentUsed = storageInfo['percentUsed'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "OneDrive Storage",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentUsed / 100,
          backgroundColor: Colors.grey[300],
          color: percentUsed > 90 ? Colors.red : Colors.blue,
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Used: ${storageInfo['usedFormatted'] ?? '0 B'}",
              style: TextStyle(fontSize: 12),
            ),
            Text(
              "Available: ${storageInfo['availableFormatted'] ?? '0 B'}",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        Center(
          child: Text(
            "${percentUsed}% used of ${storageInfo['totalFormatted'] ?? '0 B'}",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  void _showCustomFilenameDialog(File file) {
    final originalFilename = path.basename(file.path);
    final textController = TextEditingController(text: customFilenames[originalFilename] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Custom Filename"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Current filename: $originalFilename"),
            SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: "New filename",
                hintText: "Enter a custom filename",
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setCustomFilename(originalFilename, textController.text.trim());
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Club Files"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchClubFiles();
              fetchStorageInfo();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Storage info card
            Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildStorageInfo(),
              ),
            ),
            
            // Upload section
            Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Upload Files",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    
                    // Button to pick files
                    ElevatedButton.icon(
                      onPressed: isUploading ? null : pickFiles,
                      icon: Icon(Icons.attach_file),
                      label: Text("Select Files"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    
                    // Selected files list
                    if (selectedFiles.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Text(
                        "Selected files (${selectedFiles.length})",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: selectedFiles.length > 3 ? 150 : null,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: selectedFiles.length,
                          itemBuilder: (context, index) {
                            final file = selectedFiles[index];
                            final fileName = path.basename(file.path);
                            final isPublic = fileVisibility[fileName] ?? false;
                            final hasCustomName = customFilenames.containsKey(fileName);
                            
                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                              title: Text(
                                hasCustomName ? "${customFilenames[fileName]} (was: $fileName)" : fileName,
                                style: TextStyle(fontSize: 14),
                              ),
                              subtitle: Row(
                                children: [
                                  Switch(
                                    value: isPublic,
                                    onChanged: (value) => toggleFileVisibility(fileName, value),
                                  ),
                                  Text(isPublic ? "Public" : "Private"),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 20),
                                    onPressed: () => _showCustomFilenameDialog(file),
                                    tooltip: 'Rename',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 20),
                                    onPressed: () => removeSelectedFile(index),
                                    tooltip: 'Remove',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    
                    // Upload button and progress
                    SizedBox(height: 16),
                    if (isUploading) ...[
                      LinearProgressIndicator(value: uploadProgress),
                      SizedBox(height: 8),
                      Center(child: Text(uploadStatus)),
                    ] else if (selectedFiles.isNotEmpty) ...[
                      ElevatedButton(
                        onPressed: uploadFiles,
                        child: Text("Upload ${selectedFiles.length} ${selectedFiles.length == 1 ? 'File' : 'Files'}"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Files list section
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Club Files",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: clubFiles.isEmpty
                            ? Center(child: Text("No files uploaded yet."))
                            : ListView.builder(
                                itemCount: clubFiles.length,
                                itemBuilder: (context, index) {
                                  return fileItem(clubFiles[index]);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
