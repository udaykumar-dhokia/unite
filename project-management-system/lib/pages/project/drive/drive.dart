import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class Drive extends StatefulWidget {
  String id;
  final Map<String, dynamic> userData;
  Drive({super.key, required this.id, required this.userData});

  @override
  State<Drive> createState() => _DriveState();
}

class _DriveState extends State<Drive> {
  bool _isUploading = false;
  File? _file;

  Future<void> _FileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      print(result);

      // Set the selected file to state
      setState(() {
        _file = File(result.files.single.path!);
      });

      // Start the upload process
      await _uploadFile();
    } else {
      // Handle case where no file was selected
      print("No file selected");
    }
  }

  // Function to select and upload a file

  Future<void> _uploadFile() async {
    if (_file == null) return;

    try {
      setState(() {
        _isUploading = true;
      });

      // Extract only the file name
      final fileName = path.basename(_file!.path);
      final storageRef =
          FirebaseStorage.instance.ref().child('drive/${widget.id}/$fileName');

      // Upload the file
      final uploadTask = await storageRef.putFile(_file!);

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save metadata to Firestore
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.id)
          .collection("drive")
          .add({
        'name': fileName,
        'url': downloadUrl,
        'uploadedAt': DateTime.now(),
        'by': widget.userData["username"],
      });

      // Notify user of success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully!')),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _file = null;
      });
    }
  }

  // Function to fetch files from Firestore
  Stream<List<Map<String, dynamic>>> _fetchFiles() {
    return FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.id)
        .collection("drive")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;
    var width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _FileImage,
        shape: const CircleBorder(),
        backgroundColor: accentColor,
        child: _isUploading
            ? const CircularProgressIndicator(color: AppColors.white)
            : const HugeIcon(
                icon: HugeIcons.strokeRoundedFileUpload,
                color: AppColors.white),
      ),
      backgroundColor: theme ? AppColors.dark : AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: AppColors.transparent,
        toolbarHeight: 80,
        backgroundColor: theme ? AppColors.dark : AppColors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Drive",
              style: GoogleFonts.epilogue(
                fontSize: width * 0.02,
                fontWeight: FontWeight.bold,
                color: theme ? AppColors.white : AppColors.black,
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedFolder01,
              color: theme ? AppColors.white : AppColors.black,
              size: 18,
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No files found.'));
          }

          final files = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // Number of columns
              crossAxisSpacing: 10, // Spacing between columns
              mainAxisSpacing: 10, // Spacing between rows
              childAspectRatio: 1.7, // Aspect ratio for card size
            ),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: theme? Colors.grey[900] : AppColors.white ,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          HugeIcon(icon: HugeIcons.strokeRoundedFile02, color: theme? AppColors.white : AppColors.dark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              overflow:
                                  TextOverflow.ellipsis,
                              file['name'],
                              style: GoogleFonts.epilogue(
                                color: theme ? Colors.white : AppColors.dark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "@${file['by']}",
                            style: GoogleFonts.epilogue(color:theme? Colors.white70: AppColors.dark),
                          ),
                          Text(
                            DateFormat.yMMMd()
                                .add_jm()
                                .format(file['uploadedAt'].toDate()),
                            style: GoogleFonts.epilogue(color: theme? Colors.white54 : AppColors.dark),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedDownload05 , color: theme? AppColors.white: AppColors.dark),
                          onPressed: () async {
                            final url = file['url'];
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Download URL copied: $url')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
