import 'dart:math';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:unite/components/textfield/textfield.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';

class DesktopNotes extends StatefulWidget {
  DesktopNotes({super.key, required this.userData, required this.themeData});

  Map<String, dynamic>? themeData;
  Map<String, dynamic>? userData;

  @override
  State<DesktopNotes> createState() => _DesktopNotesState();
}

class _DesktopNotesState extends State<DesktopNotes> {
  bool isLoading = false;
  List<String> options = [];
  String selectedFilter = "All";
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    setState(() {
      options.add(widget.userData!["username"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;

    return isLoading
        ? Scaffold(
            backgroundColor:
                widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            ),
          )
        : Scaffold(
            backgroundColor:
                widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                SideSheet.right(
                    sheetColor: AppColors.transparent,
                    barrierColor: theme
                        ? AppColors.grey.withOpacity(0.1)
                        : AppColors.black.withOpacity(0.3),
                    width: width * 0.4,
                    context: context,
                    body: CreateNote(
                        userData: widget.userData,
                        themeData: widget.themeData));
              },
              backgroundColor: accentColor,
              shape: const CircleBorder(),
              tooltip: "Create Note",
              child: const Icon(
                Icons.add,
                color: AppColors.black,
              ),
            ),
            appBar: AppBar(
              surfaceTintColor: AppColors.transparent,
              toolbarHeight: 80,
              backgroundColor:
                  widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Notes",
                    style: GoogleFonts.epilogue(
                      fontSize: width * 0.02,
                      fontWeight: FontWeight.bold,
                      color: widget.themeData!["mode"]
                          ? AppColors.white
                          : AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            body: Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              width: (width * 0.94) - 30,
              height: height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Takings",
                          style: GoogleFonts.epilogue(
                            fontSize: width * 0.013,
                            fontWeight: FontWeight.w600,
                            color: widget.themeData!["mode"]
                                ? AppColors.white
                                : AppColors.black,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFilter = "All";
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadiusDirectional.circular(20),
                                  border: Border.all(
                                      color: selectedFilter == "All"
                                          ? accentColor
                                          : widget.themeData!["mode"]
                                              ? AppColors.white
                                              : AppColors.black),
                                ),
                                child: Text(
                                  "All",
                                  style: GoogleFonts.epilogue(
                                    color: selectedFilter == "All"
                                        ? accentColor
                                        : widget.themeData!["mode"]
                                            ? AppColors.white
                                            : AppColors.black,
                                    fontSize: width * 0.009,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFilter = "Ascending";
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadiusDirectional.circular(20),
                                  border: Border.all(
                                      color: selectedFilter == "Ascending"
                                          ? accentColor
                                          : widget.themeData!["mode"]
                                              ? AppColors.white
                                              : AppColors.black),
                                ),
                                child: Text(
                                  "Ascending",
                                  style: GoogleFonts.epilogue(
                                    color: selectedFilter == "Ascending"
                                        ? accentColor
                                        : widget.themeData!["mode"]
                                            ? AppColors.white
                                            : AppColors.black,
                                    fontSize: width * 0.009,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFilter = "Descending";
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadiusDirectional.circular(20),
                                  border: Border.all(
                                      color: selectedFilter == "Descending"
                                          ? accentColor
                                          : widget.themeData!["mode"]
                                              ? AppColors.white
                                              : AppColors.black),
                                ),
                                child: Text(
                                  "Descending",
                                  style: GoogleFonts.epilogue(
                                    color: selectedFilter == "Descending"
                                        ? accentColor
                                        : widget.themeData!["mode"]
                                            ? AppColors.white
                                            : AppColors.black,
                                    fontSize: width * 0.009,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userData!["username"])
                          .collection('Notes')
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Something went wrong'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No items found',
                              style: GoogleFonts.epilogue(
                                color: widget.themeData!["mode"]
                                    ? AppColors.white
                                    : AppColors.black,
                              ),
                            ),
                          );
                        }

                        // Extracting and sorting the notes based on priority
                        List<QueryDocumentSnapshot> notes = snapshot.data!.docs;

                        // Sort the notes by priority (1 = High, 2 = Moderate, 3 = Low)
                        notes.sort((a, b) {
                          var aPriority = a['priority'] as int;
                          var bPriority = b['priority'] as int;
                          return selectedFilter == "Ascending"
                              ? aPriority.compareTo(bPriority)
                              : bPriority.compareTo(aPriority);
                        });

                        return InkWell(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              var note =
                                  notes[index].data() as Map<String, dynamic>;
                              String docId = notes[index].id;

                              String title = note['title'];
                              String priority = note['priority'] == 1
                                  ? "High"
                                  : note['priority'] == 2
                                      ? "Moderate"
                                      : "Low";
                              String body = note['body'];

                              return InkWell(
                                onTap: () {
                                  final combinedData = notes[index].data() as Map<String, dynamic>;
                                  combinedData.addAll({"docId": docId});

                                  showDialog(
                                    context: context,
                                    builder: (context) => FluidDialog(
                                      rootPage: FluidDialogPage(
                                        decoration: const BoxDecoration(
                                            color: AppColors.transparent),
                                        alignment: Alignment.center,
                                        builder: (context) => NoteDetails(
                                          width: width,
                                          height: height,
                                          theme: theme,
                                          accentColor: accentColor,
                                          data: combinedData,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: widget.themeData!["mode"]
                                      ? Colors.black54
                                      : Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: GoogleFonts.epilogue(
                                                  color: accentColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.015,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),

                                              const SizedBox(height: 8.0),
                                              Text(
                                                body,
                                                style: GoogleFonts.epilogue(
                                                  color:
                                                      widget.themeData!["mode"]
                                                          ? Colors.white70
                                                          : Colors.black87,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.fade,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'Priority: $priority',
                                                style: GoogleFonts.epilogue(
                                                  color:
                                                      widget.themeData!["mode"]
                                                          ? Colors.white70
                                                          : Colors.black87,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(widget
                                                      .userData!["username"])
                                                  .collection('Notes')
                                                  .doc(docId)
                                                  .delete();
                                            } catch (e) {
                                              // Handle error
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Error deleting note: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: const HugeIcon(
                                            icon:
                                                HugeIcons.strokeRoundedDelete04,
                                            color: AppColors.errorColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

class CreateNote extends StatefulWidget {
  CreateNote({super.key, required this.userData, required this.themeData});

  Map<String, dynamic>? themeData;
  Map<String, dynamic>? userData;

  @override
  State<CreateNote> createState() => CreateNoteState();
}

class CreateNoteState extends State<CreateNote> {
  int priority = 2; // Default priority

  TextEditingController _description = TextEditingController();
  TextEditingController _name = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<int> createNote() async {
    try {
      final data = {
        "title": _name.text, // Note title
        "body": _description.text, // Note body
        "priority": priority, // Note priority (High, Mid, Low)
        "createdAt": // Created date
            "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
        "timeStamp":
            "${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}",
      };
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userData!["username"])
          .collection("Notes")
          .add(data);
      return 1;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.transparent,
      floatingActionButton: FloatingActionButton(
          backgroundColor: accentColor,
          onPressed: () async {
            if (_name.text.isEmpty && _description.text.isEmpty) {
              CherryToast.error(
                      displayCloseButton: false,
                      toastPosition: Position.top,
                      description: Text(
                        textAlign: TextAlign.start,
                        "Please provide all required fields.",
                        style: GoogleFonts.epilogue(
                          color: Colors.black,
                        ),
                      ),
                      animationType: AnimationType.fromTop,
                      animationDuration: const Duration(
                        milliseconds: 1000,
                      ),
                      autoDismiss: true)
                  .show(context);
            } else {
              int result = await createNote();
              if (result == 0) {
                CherryToast.error(
                        displayCloseButton: false,
                        toastPosition: Position.top,
                        description: Text(
                          textAlign: TextAlign.start,
                          "Failed to create note.",
                          style: GoogleFonts.epilogue(
                            color: Colors.black,
                          ),
                        ),
                        animationType: AnimationType.fromTop,
                        animationDuration: const Duration(
                          milliseconds: 1000,
                        ),
                        autoDismiss: true)
                    .show(context);
                Navigator.pop(context);
              } else {
                CherryToast.success(
                        displayCloseButton: false,
                        toastPosition: Position.top,
                        description: Text(
                          textAlign: TextAlign.start,
                          "Successfully created the note.",
                          style: GoogleFonts.epilogue(
                            color: Colors.black,
                          ),
                        ),
                        animationType: AnimationType.fromTop,
                        animationDuration: const Duration(
                          milliseconds: 1000,
                        ),
                        autoDismiss: true)
                    .show(context);
                Navigator.pop(context);
              }
            }
          },
          shape: const CircleBorder(),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedTick02,
            color: AppColors.black,
            size: 25,
          )),
      body: Container(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HugeIcon(
                      size: 40,
                      icon: HugeIcons.strokeRoundedNote,
                      color: accentColor,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Create Note",
                      style: GoogleFonts.epilogue(
                          color: theme ? AppColors.white : AppColors.black,
                          fontSize: width * 0.017,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: HugeIcon(
                    size: 20,
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: theme ? AppColors.white : AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 80,
            ),
            CustomTextFormField(
              isDark: theme,
              labelText: "Title",
              controller: _name,
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextFormField(
              isDark: theme,
              controller: _description,
              maxLines: 3,
              labelText: "Description",
            ),
            const SizedBox(
              height: 30,
            ),
            // Priority selection
            Text(
              "Priority",
              style: GoogleFonts.epilogue(
                fontWeight: FontWeight.w600,
                  fontSize: width * 0.011,
                  color: theme ? AppColors.white : AppColors.black),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ChoiceChip(
                  label: Text("high",
                      style: GoogleFonts.epilogue(
                          color: priority == 1
                              ? AppColors.white
                              : AppColors.black)),
                  selected: priority == 1,
                  selectedColor: accentColor,
                  onSelected: (selected) {
                    setState(() {
                      priority = 1;
                    });
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: Text("moderate",
                      style: GoogleFonts.epilogue(
                          color: priority == 2
                              ? AppColors.white
                              : AppColors.black)),
                  selected: priority == 2,
                  selectedColor: accentColor,
                  onSelected: (selected) {
                    setState(() {
                      priority = 2;
                    });
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: Text("low",
                      style: GoogleFonts.epilogue(
                          color: priority == 3
                              ? AppColors.white
                              : AppColors.black)),
                  selected: priority == 3,
                  selectedColor: accentColor,
                  onSelected: (selected) {
                    setState(() {
                      priority = 3;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NoteDetails extends StatefulWidget {
  const NoteDetails({
    super.key,
    required this.width,
    required this.height,
    required this.theme,
    required this.accentColor,
    required this.data,
  });

  final double width;
  final data;
  final double height;
  final bool theme;
  final Color accentColor;

  @override
  State<NoteDetails> createState() => _NoteDetailsState();
}

class _NoteDetailsState extends State<NoteDetails> {
  TextEditingController _linkedin = TextEditingController();
  TextEditingController _git = TextEditingController();
  TextEditingController _x = TextEditingController();
  TextEditingController _reddit = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: widget.width * 0.5,
      height: widget.height * 0.55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: widget.theme ? AppColors.dark : AppColors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.data["title"],
                style: GoogleFonts.epilogue(
                  color: widget.theme ? AppColors.white : AppColors.black,
                  fontSize: widget.width * 0.018,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: HugeIcon(
                  size: 20,
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: widget.theme ? AppColors.white : AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                widget.data["body"],
                style: GoogleFonts.epilogue(
                  color: widget.theme ? AppColors.white : AppColors.black,
                  fontSize: widget.width * 0.01, // Adjust font size as needed
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: widget.accentColor,
                onPressed: () async {},
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedEdit01,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: AppColors.errorColor,
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.data!["username"])
                      .collection('Notes')
                      .doc(widget.data["docId"])
                      .delete();
                  Navigator.pop(context);
                },
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedDelete04,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
