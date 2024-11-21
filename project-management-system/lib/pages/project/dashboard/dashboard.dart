import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:unite/components/infocards/info_card.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';
import 'package:unite/models/card.dart';
import 'package:path/path.dart' as path;

class Dashboard extends StatefulWidget {
  final String id;

  Map<String, dynamic>? userData;

  Dashboard({super.key, required this.userData, required this.id});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isNameTaken = false;
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);
  Map<String, dynamic> projectData = {};
  bool isLoading = false;
  List<Widget> memberPhotos = [];
  File? _file;
  bool _isUploading = false;

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
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('documents/${widget.id}/$fileName');

      // Upload the file
      final uploadTask = await storageRef.putFile(_file!);

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save metadata to Firestore
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.id)
          .collection("document")
          .add({
        'name': fileName,
        'url': downloadUrl,
        'uploadedAt': DateTime.now(),
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
        .collection("document")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .toList(),
        );
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    final data = await FirebaseFirestore.instance
        .collection("projects")
        .doc(widget.id)
        .get();

    List<dynamic> members = data['members'];

    for (int i = 1; i < members.length; i++) {
      String member = members[i];
      memberPhotos.add(
        FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('users').doc(member).get(),
          builder: (context, memberSnapshot) {
            if (memberSnapshot.connectionState == ConnectionState.waiting) {
              return const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey,
              );
            }

            if (memberSnapshot.hasError ||
                !memberSnapshot.hasData ||
                !memberSnapshot.data!.exists) {
              return const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey,
              );
            }

            Map<String, dynamic> memberData =
                memberSnapshot.data!.data() as Map<String, dynamic>;
            print(memberData);
            String profileUrl = memberData['profileImage'] ?? '';
            String memberName = memberData['username'] ?? 'Unknown';

            return Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  memberName,
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Provider.of<ThemeNotifier>(context).isDarkMode
                        ? AppColors.white
                        : AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      );
    }

    setState(() {
      projectData = data.data()!;
      isLoading = false;
    });
  }

  Future<void> _checkNameExists() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: widget.userData!["name"])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        isNameTaken = true;
      });
    } else {
      setState(() {
        isNameTaken = false;
      });
    }
  }

  Future<void> _checkUsernameAndAddMember(String username) async {
  // Check if the username exists
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username)
      .get();

  if (querySnapshot.docs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User does not exist')),
    );
    return;
  }

  // Fetch the current members from the project
  final projectDoc = FirebaseFirestore.instance
      .collection('projects')
      .doc(widget.id); // Use the project ID
  final projectSnapshot = await projectDoc.get();

  if (!projectSnapshot.exists) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project not found')),
    );
    return;
  }

  List<dynamic> currentMembers = projectSnapshot.data()?['members'] ?? [];

  // Check if the user is already a member
  if (currentMembers.contains(username)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User is already a member')),
    );
    return;
  }

  // Add the user to the members list
  currentMembers.add(username);
  await projectDoc.update({'members': currentMembers});

  setState(() {
    memberPhotos.add(
      CircleAvatar(
        child: Text(username[0].toUpperCase()),
      ),
    );
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Member added successfully')),
  );
}


  void _showMilestoneDialog(BuildContext context) {
    final TextEditingController milestoneController = TextEditingController();
    DateTime? selectedDate;

    FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.id)
        .get()
        .then((projectDoc) {
      if (projectDoc.exists) {
        String startDateString =
            projectDoc['startDate']; // Assuming "6-11-2024"
        String endDateString = projectDoc['endDate']; // Assuming "15-11-2024"

        // Parse strings into DateTime objects
        DateTime startDate = DateFormat('d-MM-yyyy').parse(startDateString);
        DateTime endDate = DateFormat('d-MM-yyyy').parse(endDateString);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text("Add Milestone"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: milestoneController,
                        decoration: const InputDecoration(
                          labelText: "Milestone Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: startDate,
                            lastDate: endDate,
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              selectedDate == null
                                  ? "Select Deadline"
                                  : DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!),
                              style: TextStyle(
                                color: selectedDate == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (milestoneController.text.isNotEmpty &&
                            selectedDate != null) {
                          FirebaseFirestore.instance
                              .collection('projects')
                              .doc(widget.id)
                              .collection('milestones')
                              .add({
                            'milestoneName': milestoneController.text,
                            'deadline': selectedDate,
                            'isCompleted': false,
                          }).then((value) {
                            Navigator.pop(context);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                            ),
                          );
                        }
                      },
                      child: const Text("Add"),
                    ),
                  ],
                );
              },
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project not found")),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching project data: $error")),
      );
    });
  }

  


  void _showMemeberDialog(BuildContext context) {
    final TextEditingController _member = TextEditingController();

    FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.id)
        .get()
        .then((projectDoc) {
      if (projectDoc.exists) {

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text("Add Member"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _member,
                        decoration: const InputDecoration(
                          labelText: "Member username",
                          border: OutlineInputBorder(),
                        ),
                      ),

                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_member.text.isNotEmpty) {
                          _checkUsernameAndAddMember(_member.text);
                        }},
                      child: const Text("Add"),
                    ),
                  ],
                );
              },
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project not found")),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching project data: $error")),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkNameExists();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return isLoading
        ? Scaffold(
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
                    "Dashboard",
                    style: GoogleFonts.epilogue(
                        fontSize: width * 0.02,
                        fontWeight: FontWeight.bold,
                        color: theme ? AppColors.white : AppColors.black),
                  ),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedDashboardSquare03,
                    color: theme ? AppColors.white : AppColors.black,
                    size: 18,
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
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
                    "Dashboard",
                    style: GoogleFonts.epilogue(
                      fontSize: width * 0.02,
                      fontWeight: FontWeight.bold,
                      color: theme ? AppColors.white : AppColors.black,
                    ),
                  ),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedDashboardSquare03,
                    color: theme ? AppColors.white : AppColors.black,
                    size: 18,
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: FileInfoCardGridView(
                            color: accentColor,
                            projectId: widget.id,
                            childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: theme
                                ? AppColors.dark.withOpacity(0.9)
                                : AppColors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Members",
                                        style: GoogleFonts.epilogue(
                                          fontSize: width * 0.018,
                                          fontWeight: FontWeight.w500,
                                          color: theme
                                              ? AppColors.white
                                              : AppColors.black,
                                        ),
                                      ),
                                      if (!isNameTaken)
                                      FloatingActionButton(
                                        onPressed: () {
                                          _showMemeberDialog(context);
                                        },
                                        mini: true,
                                        shape: const CircleBorder(),
                                        backgroundColor: accentColor,
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  memberPhotos.isEmpty
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : Container(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: memberPhotos.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    memberPhotos[index],
                                                    const SizedBox(height: 5),
                                                    // Text(
                                                    //   memberNames[index], // Assuming you save the member names here
                                                    //   style: GoogleFonts.epilogue(
                                                    //     fontSize: 12,
                                                    //     fontWeight: FontWeight.w500,
                                                    //     color: theme ? AppColors.white : AppColors.black,
                                                    //   ),
                                                    //   overflow: TextOverflow.ellipsis,
                                                    // ),
                                                  ],
                                                ),
                                              );
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
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: width / 2.5,
                          height: height / 2,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Milestones",
                                      style: GoogleFonts.epilogue(
                                        fontSize: width * 0.018,
                                        fontWeight: FontWeight.w500,
                                        color: theme
                                            ? AppColors.white
                                            : AppColors.dark,
                                      ),
                                    ),
                                    if (!isNameTaken)
                                      FloatingActionButton(
                                        onPressed: () {
                                          _showMilestoneDialog(context);
                                        },
                                        mini: true,
                                        shape: const CircleBorder(),
                                        backgroundColor: accentColor,
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("projects")
                                      .doc(widget.id)
                                      .collection("milestones")
                                      .orderBy("deadline", descending: false)
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    if (snapshot.hasError) {
                                      return const Center(
                                          child: Text('Something went wrong'));
                                    }

                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return Center(
                                        child: Text(
                                          'No milestones found',
                                          style: GoogleFonts.epilogue(
                                            color: theme
                                                ? AppColors.white
                                                : AppColors.black,
                                          ),
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot documentSnapshot =
                                            snapshot.data!.docs[index];
                                        String milestoneName =
                                            documentSnapshot['milestoneName'];
                                        DateTime deadline =
                                            (documentSnapshot['deadline']
                                                    as Timestamp)
                                                .toDate();
                                        bool isCompleted =
                                            documentSnapshot['isCompleted'];

                                        // Function to toggle the isCompleted value
                                        void toggleCompletion() {
                                          FirebaseFirestore.instance
                                              .collection("projects")
                                              .doc(widget.id)
                                              .collection("milestones")
                                              .doc(documentSnapshot.id)
                                              .update({
                                            'isCompleted': !isCompleted
                                          });
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 16.0),
                                          child: Card(
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            color: theme
                                                ? AppColors.dark
                                                : AppColors.white,
                                            child: ListTile(
                                              leading: Icon(
                                                isCompleted
                                                    ? Icons.check_circle
                                                    : Icons.flag,
                                                color: isCompleted
                                                    ? accentColor
                                                    : theme? AppColors.white : AppColors.dark ,
                                                size: 30,
                                              ),
                                              title: Text(
                                                milestoneName,
                                                style: GoogleFonts.epilogue(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  decoration: isCompleted
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                                  color: isCompleted
                                                      ? accentColor
                                                      : (theme
                                                          ? AppColors.white
                                                          : AppColors.black),
                                                ),
                                              ),
                                              subtitle: Text(
                                                "Deadline: ${DateFormat('yyyy-MM-dd').format(deadline)}",
                                                style: GoogleFonts.epilogue(
                                                  fontSize: 14,
                                                  color: theme
                                                      ? AppColors.lightGrey
                                                      : AppColors.darkGrey,
                                                ),
                                              ),
                                              trailing: IconButton(
                                                icon: Icon(
                                                  isCompleted
                                                      ? Icons.undo
                                                      : Icons.done,
                                                  color: isCompleted
                                                      ? AppColors.errorColor
                                                      : accentColor,
                                                ),
                                                onPressed:
                                                    toggleCompletion, // Toggle on click
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: width / 2.5,
                          height: height / 2,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Project Documents",
                                      style: GoogleFonts.epilogue(
                                        fontSize: width * 0.018,
                                        fontWeight: FontWeight.w500,
                                        color: theme
                                            ? AppColors.white
                                            : AppColors.dark,
                                      ),
                                    ),
                                    if (!isNameTaken)
                                      FloatingActionButton(
                                        onPressed:
                                            _isUploading ? null : _FileImage,
                                        mini: true,
                                        shape: const CircleBorder(),
                                        backgroundColor: accentColor,
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  child:
                                      StreamBuilder<List<Map<String, dynamic>>>(
                                    stream: _fetchFiles(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Center(
                                            child: Text('No files found.'));
                                      }

                                      final files = snapshot.data!;
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 16.0),
                                        itemCount: files.length,
                                        itemBuilder: (context, index) {
                                          final file = files[index];
                                          return Card(
                                            elevation: 5,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            color: theme
                                                ? Colors.grey[900]
                                                : AppColors.white,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      HugeIcon(
                                                        icon: HugeIcons
                                                            .strokeRoundedFile02,
                                                        color: theme
                                                            ? AppColors.white
                                                            : AppColors.dark,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          file['name'],
                                                          style: GoogleFonts
                                                              .epilogue(
                                                            color: theme
                                                                ? Colors.white
                                                                : AppColors
                                                                    .dark,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        DateFormat.yMMMd()
                                                            .add_jm()
                                                            .format(file[
                                                                    'uploadedAt']
                                                                .toDate()),
                                                        style: GoogleFonts
                                                            .epilogue(
                                                          color: theme
                                                              ? Colors.white54
                                                              : AppColors.dark,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: IconButton(
                                                      icon: HugeIcon(
                                                        icon: HugeIcons
                                                            .strokeRoundedDownload05,
                                                        color: theme
                                                            ? AppColors.white
                                                            : AppColors.dark,
                                                      ),
                                                      onPressed: () async {
                                                        final url = file[
                                                            'url']; // The URL of the file you want to download

                                                        try {
                                                          final directory =
                                                              await getDownloadsDirectory();
                                                          if (directory ==
                                                              null) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Failed to get storage directory.')),
                                                            );
                                                            return;
                                                          }

                                                          final filePath =
                                                              '${directory.path}/${file['name']}';

                                                          // Download the file using dio
                                                          Dio dio = Dio();
                                                          await dio.download(
                                                              url, filePath);

                                                          // Show a success message
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Downloaded: ${file['name']} to $filePath')),
                                                          );
                                                        } catch (e) {
                                                          // Handle any errors that occur during the download
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Error downloading file: $e')),
                                                          );
                                                        }
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1,
    required this.color,
    required this.projectId,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;
  final String projectId;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("projects")
          .doc(projectId)
          .collection("milestones")
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: color,
          ));
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No milestones found',
              style: GoogleFonts.epilogue(),
            ),
          );
        }

        // Calculate progress
        final totalMilestones = snapshot.data!.docs.length;
        final completedMilestones = snapshot.data!.docs
            .where((doc) => doc['isCompleted'] == true)
            .length;
        final progress =
            totalMilestones > 0 ? completedMilestones / totalMilestones : 0.0;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("projects")
              .doc(projectId)
              .get(),
          builder: (context, projectSnapshot) {
            if (projectSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: color,
              ));
            }

            if (projectSnapshot.hasError) {
              return const Center(child: Text('Error fetching project data'));
            }

            if (!projectSnapshot.hasData || !projectSnapshot.data!.exists) {
              return Center(
                child: Text(
                  'No project found',
                  style: GoogleFonts.epilogue(),
                ),
              );
            }

            final projectData = projectSnapshot.data!;
            String endDateString = projectData['endDate']; // "31-12-2024"
            DateTime endDate =
                _parseDate(endDateString); // Convert string to DateTime
            DateTime now = DateTime.now();
            Duration remainingTime = endDate.difference(now);

            // Calculate total duration for the project
            Duration totalDuration =
                endDate.difference(_parseDate(projectData["startDate"]));

            // Calculate progress percentage for the time left
            double timeLeftPercentage = totalDuration.inMilliseconds > 0
                ? (remainingTime.inMilliseconds / totalDuration.inMilliseconds)
                : 0.0;

            String remainingTimeText = remainingTime.isNegative
                ? "Deadline Passed"
                : "${remainingTime.inDays} days left";

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 2,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Milestone progress card
                  return FileInfoCard(
                    icon: HugeIcons.strokeRoundedActivity01,
                    info: CardInfo(
                      title: "Milestone Progress",
                      color: color,
                      numOfFiles: completedMilestones,
                      percentage: (progress * 100).round(),
                      totalStorage:
                          "$completedMilestones / $totalMilestones completed",
                    ),
                  );
                } else {
                  // Deadline progress card with progress bar
                  return FileInfoCard(
                    icon: Icons
                        .calendar_today, // You can choose an appropriate icon
                    info: CardInfo(
                      title: "Time Left",
                      color: Colors.blue,
                      numOfFiles: 0,
                      percentage: (timeLeftPercentage * 100).round(),
                      totalStorage: remainingTimeText, // Display remaining time
                    ),
                    // progressBar: LinearProgressIndicator(
                    //   value: timeLeftPercentage,
                    //   color: Colors.blue,
                    //   backgroundColor: Colors.grey.shade200,
                    // ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  DateTime _parseDate(String dateString) {
    List<String> parts = dateString.split('-');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    return DateTime(year, month, day);
  }
}
