import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:unite/components/createproject/createproject.dart';
import 'package:unite/components/infocards/info_card.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';
import 'package:unite/models/card.dart';

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
                            borderRadius: BorderRadius.circular(1),
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
              Text(
                "Members",
                style: GoogleFonts.epilogue(
                  fontSize: width * 0.018,
                  fontWeight: FontWeight.w500,
                  color: theme ? AppColors.white : AppColors.black,
                ),
              ),
              const SizedBox(height: 15),
              // Display members in a horizontal list
              memberPhotos.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      height: 100, // Adjust based on your design needs
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: memberPhotos.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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
                      mainAxisAlignment: MainAxisAlignment.start,
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
                                                    ? Colors.green
                                                    : (accentColor),
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
                                                      ? Colors.grey
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
                                                      ? Colors.green
                                                      : theme
                                                          ? AppColors.white
                                                          : AppColors.black,
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
            Duration totalDuration = endDate.difference(_parseDate(projectData["startDate"]));
            
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
                    icon: Icons.calendar_today, // You can choose an appropriate icon
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
