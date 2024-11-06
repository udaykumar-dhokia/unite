import 'dart:math';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:unite/components/textfield/textfield.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';

class DesktopTeams extends StatefulWidget {
  DesktopTeams({super.key, required this.userData, required this.themeData});

  Map<String, dynamic>? themeData;
  Map<String, dynamic>? userData;

  @override
  State<DesktopTeams> createState() => _DesktopTeamsState();
}

class _DesktopTeamsState extends State<DesktopTeams> {
  bool isLoading = false;
  bool isUsernameTaken = false;
  List<String> options = [];
  Map<String, dynamic>? teamData;
  User? user = FirebaseAuth.instance.currentUser;

  TextEditingController _add = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.userData != null && widget.userData!.containsKey("username")) {
        options.add(widget.userData!["username"]);
      }
    });
  }

  Future<void> _checkUsernameExists(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    setState(() {
      isUsernameTaken = querySnapshot.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;
    TextEditingController _manager = TextEditingController(
      text: widget.userData != null && widget.userData!.containsKey("name")
          ? widget.userData!["name"]
          : '',
    );

    return isLoading
        ? Scaffold(
            backgroundColor:
                widget.themeData != null && widget.themeData!["mode"]
                    ? AppColors.dark
                    : AppColors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            ),
          )
        : Scaffold(
            backgroundColor:
                widget.themeData != null && widget.themeData!["mode"]
                    ? AppColors.dark
                    : AppColors.white,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                SideSheet.right(
                    sheetColor: AppColors.transparent,
                    barrierColor: theme
                        ? AppColors.grey.withOpacity(0.1)
                        : AppColors.black.withOpacity(0.3),
                    width: width * 0.4,
                    context: context,
                    body: CreateTeam(
                        userData: widget.userData,
                        themeData: widget.themeData));
              },
              backgroundColor: accentColor,
              shape: const CircleBorder(),
              tooltip: "Create Team",
              child: const Icon(
                Icons.add,
                color: AppColors.black,
              ),
            ),
            appBar: AppBar(
              surfaceTintColor: AppColors.transparent,
              toolbarHeight: 80,
              backgroundColor:
                  widget.themeData != null && widget.themeData!["mode"]
                      ? AppColors.dark
                      : AppColors.white,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Teams",
                    style: GoogleFonts.epilogue(
                      fontSize: width * 0.02,
                      fontWeight: FontWeight.bold,
                      color:
                          widget.themeData != null && widget.themeData!["mode"]
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
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your workforce",
                          style: GoogleFonts.epilogue(
                            fontSize: width * 0.013,
                            fontWeight: FontWeight.w600,
                            color: widget.themeData != null &&
                                    widget.themeData!["mode"]
                                ? AppColors.white
                                : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('teams')
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

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No items found',
                              style:
                                  GoogleFonts.epilogue(color: AppColors.white),
                            ),
                          );
                        }

                        List<QueryDocumentSnapshot> Teams = snapshot.data!.docs;

                        return Container(
                          height: MediaQuery.of(context).size.height - 200,
                          child: GridView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8.0),
                            itemCount: Teams.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2.3,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemBuilder: (context, index) {
                              Map<String, dynamic> data =
                                  Teams[index].data() as Map<String, dynamic>;
                          
                              List<dynamic> members = data['members'] ?? [];
                              List<Widget> memberPhotos = [];
                          
                              for (String member in members) {
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
                          
                              return Card(
                                color: theme ? Colors.black54 : Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'] ?? 'No name',
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
                                          const SizedBox(height: 5),
                                          Text(
                                            "Description: ${data['description'] ?? 'No description'}",
                                            style: GoogleFonts.epilogue(
                                              color: theme
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontSize: width * 0.01,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Team Lead: ${data['lead'] ?? 'Not assigned'}",
                                            style: GoogleFonts.epilogue(
                                              color: theme
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontSize: width * 0.01,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 10),
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
                                          const SizedBox(height: 0),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class CreateTeam extends StatefulWidget {
  CreateTeam({super.key, required this.userData, required this.themeData});

  Map<String, dynamic>? themeData;
  Map<String, dynamic>? userData;
  @override
  State<CreateTeam> createState() => CreateTeamState();
}

class CreateTeamState extends State<CreateTeam> {
  bool isUsernameTaken = false;
  List<String> options = [];
  List<String> tags = [];

  TextEditingController _add = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _dob = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      options.add(widget.userData!["username"]);
    });
  }

  Future<int> createTeam() async {
    try {
      final data = {
        "name": _name.text,
        "description": _description.text,
        "lead": widget.userData!["username"],
        "members": options,
        "createdAt":
            "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
      };
      await FirebaseFirestore.instance.collection("teams").add(data);
      return 1;
    } catch (e) {
      return 0;
    }
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
            } else if (options.length == 1) {
              CherryToast.error(
                      displayCloseButton: false,
                      toastPosition: Position.top,
                      description: Text(
                        textAlign: TextAlign.start,
                        "Add at least one member to continue.",
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
              int result = await createTeam();
              if (result == 0) {
                CherryToast.error(
                        displayCloseButton: false,
                        toastPosition: Position.top,
                        description: Text(
                          textAlign: TextAlign.start,
                          "Failed to create Team.",
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
                          "Successfully create the Team.",
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
                      icon: HugeIcons.strokeRoundedUserGroup,
                      color: accentColor,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Create Team",
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
              labelText: "Name",
              controller: _name,
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextFormField(
              controller: _manager,
              isDark: theme,
              readOnly: true,
              labelText: "Team Lead",
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextFormField(
              isDark: theme,
              controller: _description,
              maxLines: 3,
              maxLength: 250,
              labelText: "Description",
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomTextFormField(
                    isDark: theme,
                    controller: _add,
                    onChanged: (value) {
                      _checkUsernameExists(value);
                    },
                    labelText: "Add members",
                  ),
                ),
                if (isUsernameTaken &&
                    _add.text.isNotEmpty &&
                    !options.contains(_add.text))
                  const SizedBox(
                    width: 10,
                  ),
                if (isUsernameTaken &&
                    _add.text.isNotEmpty &&
                    !options.contains(_add.text))
                  FloatingActionButton(
                    onPressed: () {},
                    shape: const CircleBorder(),
                    mini: true,
                    backgroundColor: accentColor,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          options.add(_add.text);
                          _add.clear();
                        });
                      },
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedAdd01,
                        color: AppColors.black,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            if (!isUsernameTaken && _add.text.isNotEmpty)
              const SizedBox(
                height: 5,
              ),
            if (!isUsernameTaken && _add.text.isNotEmpty)
              Text(
                "No such user available",
                style: GoogleFonts.epilogue(
                    color: AppColors.errorColor, fontSize: width * 0.01),
              ),
            if (isUsernameTaken && _add.text.isNotEmpty)
              const SizedBox(
                height: 5,
              ),
            if (isUsernameTaken && _add.text.isNotEmpty)
              Text(
                "${_add.text} is available",
                style: GoogleFonts.epilogue(
                    color: AppColors.successColor, fontSize: width * 0.01),
              ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Team Members (${options.length})",
              style: GoogleFonts.epilogue(
                  fontSize: width * 0.01,
                  color: theme ? AppColors.white : AppColors.black),
            ),
            ChipsChoice<String>.multiple(
              scrollPhysics: const BouncingScrollPhysics(),
              value: options,
              choiceTrailingBuilder: (item, i) =>
                  item.value != widget.userData!["username"]
                      ? GestureDetector(
                          onTap: () {
                            setState(
                              () {
                                options.remove(item.value);
                              },
                            );
                          },
                          child: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        )
                      : null,
              onChanged: (val) => setState(() => tags = val),
              choiceItems: C2Choice.listFrom<String, String>(
                source: options,
                value: (i, v) => v,
                label: (i, v) => v,
              ),
              wrapped: true,
              choiceCheckmark: true,
              choiceStyle: C2ChipStyle.filled(
                selectedStyle: C2ChipStyle(
                  backgroundColor: accentColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(25),
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
