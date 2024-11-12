import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:unite/components/createproject/createproject.dart';
import 'package:unite/components/sidepanel/project_sidepanel.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';
import 'package:unite/pages/individual/projects/particular_project.dart';

class DesktopProjects extends StatefulWidget {
  DesktopProjects({super.key, required this.userData, required this.themeData});

  Map<String, dynamic>? themeData;
  Map<String, dynamic>? userData;

  @override
  State<DesktopProjects> createState() => _DesktopProjectsState();
}

class _DesktopProjectsState extends State<DesktopProjects> {
  bool isLoading = false;
  bool isUsernameTaken = false;
  List<String> options = [];
  Map<String, dynamic>? projectData;
  String selectedFilter = "All";
  List<String> tags = [];
  User? user = FirebaseAuth.instance.currentUser;
  bool isNameTaken = false;

  TextEditingController _add = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _name = TextEditingController();

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      options.add(widget.userData!["username"]);
    });
    _checkNameExists();
  }

  Future<void> _checkUsernameExists(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        isUsernameTaken = true;
      });
    } else {
      setState(() {
        isUsernameTaken = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;
    TextEditingController _manager =
        TextEditingController(text: widget.userData!["name"]);

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
            floatingActionButton: !isNameTaken
                ? FloatingActionButton(
                    onPressed: () {
                      SideSheet.right(
                          sheetColor: AppColors.transparent,
                          barrierColor: theme
                              ? AppColors.grey.withOpacity(0.1)
                              : AppColors.black.withOpacity(0.3),
                          width: width * 0.4,
                          context: context,
                          body: CreateProject(
                              userData: widget.userData,
                              themeData: widget.themeData));
                    },
                    backgroundColor: accentColor,
                    shape: const CircleBorder(),
                    tooltip: "Create Project",
                    child: const Icon(
                      Icons.add,
                      color: AppColors.black,
                    ),
                  )
                : null,
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
                    "Projects",
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
                          "Your work",
                          style: GoogleFonts.epilogue(
                            fontSize: width * 0.013,
                            fontWeight: FontWeight.w600,
                            color: widget.themeData!["mode"]
                                ? AppColors.white
                                : AppColors.black,
                          ),
                        ),

                        //Filters & Search
                        Row(
                          children: [
                            //All
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
                                  // color: selectedFilter ==  "All"? Color(int.parse(widget.themeData!["color"])) : AppColors.transparent,
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

                            //Ongoing
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFilter = "Ongoing";
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadiusDirectional.circular(20),
                                  border: Border.all(
                                      color: selectedFilter == "Ongoing"
                                          ? accentColor
                                          : widget.themeData!["mode"]
                                              ? AppColors.white
                                              : AppColors.black),
                                ),
                                child: Text(
                                  "Ongoing",
                                  style: GoogleFonts.epilogue(
                                    color: selectedFilter == "Ongoing"
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

                            //Completed
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFilter = "Completed";
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadiusDirectional.circular(20),
                                  border: Border.all(
                                      color: selectedFilter == "Completed"
                                          ? accentColor
                                          : widget.themeData!["mode"]
                                              ? AppColors.white
                                              : AppColors.black),
                                ),
                                child: Text(
                                  "Completed",
                                  style: GoogleFonts.epilogue(
                                    color: selectedFilter == "Completed"
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

                            //Time
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFilter = "Time";
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadiusDirectional.circular(20),
                                  border: Border.all(
                                      color: selectedFilter == "Time"
                                          ? accentColor
                                          : widget.themeData!["mode"]
                                              ? AppColors.white
                                              : AppColors.black),
                                ),
                                child: Text(
                                  "Time left",
                                  style: GoogleFonts.epilogue(
                                    color: selectedFilter == "Time"
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
                    SingleChildScrollView(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('projects')
                            .where(
                              "members",
                              arrayContains: widget.userData!["username"],
                            )
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

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                'No projects found',
                                style: GoogleFonts.epilogue(
                                    color: widget.themeData!["mode"]
                                        ? AppColors.white
                                        : AppColors.black),
                              ),
                            );
                          }

                          List<QueryDocumentSnapshot> projects =
                              snapshot.data!.docs;

                          // Filter projects based on selectedFilter
                          List<QueryDocumentSnapshot> filteredProjects =
                              projects.where((doc) {
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;
                            DateTime endDate =
                                DateFormat('dd-MM-yyyy').parse(data['endDate']);
                            DateTime now = DateTime.now();
                            int daysLeft = endDate.difference(now).inDays;

                            switch (selectedFilter) {
                              case "Completed":
                                return daysLeft < 0;
                              case "Ongoing":
                                return daysLeft >= 0;
                              case "Time":
                                return true;
                              default:
                                return true;
                            }
                          }).toList();

                          // Sort if necessary
                          if (selectedFilter == "Time") {
                            filteredProjects.sort((a, b) {
                              DateTime endDateA =
                                  DateFormat('dd-MM-yyyy').parse(a['endDate']);
                              DateTime endDateB =
                                  DateFormat('dd-MM-yyyy').parse(b['endDate']);
                              return endDateA
                                  .difference(DateTime.now())
                                  .compareTo(
                                      endDateB.difference(DateTime.now()));
                            });
                          }

                          if (filteredProjects.isEmpty) {
                            return Center(
                              child: Text(
                                'No items found',
                                style: GoogleFonts.epilogue(
                                    color: AppColors.white),
                              ),
                            );
                          }

                          return Container(
                            // height: MediaQuery.of(context).size.height - 200,
                            child: GridView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(8.0),
                              itemCount: filteredProjects.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                              ),
                              itemBuilder: (context, index) {
                                Map<String, dynamic> data =
                                    filteredProjects[index].data()
                                        as Map<String, dynamic>;
                                DateTime endDate = DateFormat('dd-MM-yyyy')
                                    .parse(data['endDate']);
                                DateTime now = DateTime.now();
                                int daysLeft = endDate.difference(now).inDays;

                                List<dynamic> members = data['members'];
                                List<Widget> memberPhotos = [];

                                String documentId = filteredProjects[index].id;

                                for (int i = 1; i < members.length; i++) {
                                  String member = members[i];
                                  memberPhotos.add(
                                    FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(member)
                                          .get(),
                                      builder: (context, memberSnapshot) {
                                        if (memberSnapshot.connectionState ==
                                            ConnectionState.waiting) {
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
                                            memberSnapshot.data!.data()
                                                as Map<String, dynamic>;
                                        String profileUrl =
                                            memberData['profileImage'] ?? '';

                                        return CircleAvatar(
                                          radius: 15,
                                          backgroundImage: profileUrl.isNotEmpty
                                              ? NetworkImage(profileUrl)
                                              : null,
                                          backgroundColor: Colors.grey,
                                        );
                                      },
                                    ),
                                  );
                                }

                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProjectSidePanel(
                                          data: data,
                                          id: documentId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color:
                                        theme ? Colors.black54 : Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'],
                                            style: GoogleFonts.epilogue(
                                              color: accentColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: width * 0.013,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Description: ${data['description'].length > 20 ? data["description"].substring(0, 20) + "..." : data["description"]}",
                                                style: GoogleFonts.epilogue(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'Company/Organisation: ${data['manager']}',
                                                style: GoogleFonts.epilogue(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'Total Members: ${data['members'].length}',
                                                style: GoogleFonts.epilogue(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Row(
                                                children: [
                                                  Text(
                                                    daysLeft < 0
                                                        ? "Completed "
                                                        : '',
                                                    style: GoogleFonts.epilogue(
                                                      color: Colors.grey[600],
                                                      fontSize: width * 0.012,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    daysLeft < 0
                                                        ? "${daysLeft.abs()} "
                                                        : daysLeft == 0
                                                            ? "Deadline Today"
                                                            : '$daysLeft ',
                                                    style: GoogleFonts.epilogue(
                                                      color: daysLeft == 0
                                                          ? AppColors.errorColor
                                                          : Colors.grey[600],
                                                      fontSize: width * 0.012,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    daysLeft < 0
                                                        ? "days ago"
                                                        : daysLeft == 0
                                                            ? ""
                                                            : 'days left.',
                                                    style: GoogleFonts.epilogue(
                                                      color: Colors.grey[600],
                                                      fontSize: width * 0.012,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 50,
                                            child: Stack(
                                              children: List.generate(
                                                  memberPhotos.length, (index) {
                                                return Positioned(
                                                  left: index * 20.0,
                                                  child: memberPhotos[index],
                                                );
                                              }),
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
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
