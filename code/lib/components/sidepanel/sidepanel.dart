import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:unite/constants/color/color.dart';

class SidePanel extends StatefulWidget {
  const SidePanel({super.key});

  @override
  State<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = false;
  bool isDark = true;
  bool _isHovered = true;
  String page = "home";

  void getDetails() async {
    setState(() {
      isLoading = true;
    });
    final data = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: user!.email)
        .get();

    for (var docs in data.docs) {
      setState(() {
        userData = docs.data();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return isLoading
        ? const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.warningColor,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: isDark ? AppColors.dark : AppColors.white,
            body: Padding(
              padding: EdgeInsets.only(
                  left: !_isHovered ? 0 : 10, right: 10, top: 10, bottom: 10),
              child: Row(
                children: [
                  //Sidepanel
                  MouseRegion(
                    // onEnter: (_) => _onHover(true),
                    // onExit: (_) => _onHover(false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: !_isHovered ? width * 0.04 : width * 0.1,
                      height: double.infinity,
                      decoration: BoxDecoration(
                          border: Border(
                        right: BorderSide(
                          width: 1,
                          color: isDark
                              ? AppColors.grey.withOpacity(0.3)
                              : AppColors.black.withOpacity(0.3),
                        ),
                      )),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      backgroundImage:
                                          AssetImage("lib/assets/logo.jpg"),
                                    ),
                                     if (_isHovered)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered)
                                        Text(
                                          "Unite.",
                                          style: GoogleFonts.epilogue(
                                              color: isDark
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontSize: width * 0.01),
                                        ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      page = "home";
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedChartRose,
                                        color: page == "home"
                                            ? AppColors.warningColor
                                            : !isDark
                                                ? AppColors.dark
                                                : AppColors.grey,
                                      ),
                                      if (_isHovered)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered)
                                        Text(
                                          "Projects",
                                          style: GoogleFonts.epilogue(
                                              color: isDark
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontSize: width * 0.01),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      page = "team";
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedUserGroup,
                                        color: page == "team"
                                            ? AppColors.warningColor
                                            : !isDark
                                                ? AppColors.dark
                                                : AppColors.grey,
                                      ),
                                      if (_isHovered)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered)
                                        Text(
                                          "Teams",
                                          style: GoogleFonts.epilogue(
                                              color: isDark
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontSize: width * 0.01),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      page = "calendar";
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedCalendar03,
                                        color: page == "calendar"
                                            ? AppColors.warningColor
                                            : !isDark
                                                ? AppColors.dark
                                                : AppColors.grey,
                                      ),
                                      if (_isHovered)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered)
                                        Text(
                                          "Calendar",
                                          style: GoogleFonts.epilogue(
                                              color: isDark
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontSize: width * 0.01),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      page = "notes";
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedNote,
                                        color: page == "notes"
                                            ? AppColors.warningColor
                                            : !isDark
                                                ? AppColors.dark
                                                : AppColors.grey,
                                      ),
                                      if (_isHovered)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered)
                                        Text(
                                          "Notes",
                                          style: GoogleFonts.epilogue(
                                              color: isDark
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontSize: width * 0.01),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isHovered = !_isHovered;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: !_isHovered
                                            ? HugeIcons.strokeRoundedArrowRight01
                                            : HugeIcons.strokeRoundedArrowLeft01,
                                        color: !isDark
                                            ? AppColors.dark
                                            : AppColors.grey,
                                      ),
                                       if (_isHovered)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered)
                                        Text(
                                          "Close",
                                          style: GoogleFonts.epilogue(
                                              color: isDark
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontSize: width * 0.01),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons
                                            .strokeRoundedNotification01,
                                        color: !isDark
                                            ? AppColors.dark
                                            : AppColors.grey,
                                      ),
                                      if (_isHovered)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered)
                                        Text(
                                          "Notifications",
                                          style: GoogleFonts.epilogue(
                                              color: isDark
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontSize: width * 0.01),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedSettings01,
                                        color: !isDark
                                            ? AppColors.dark
                                            : AppColors.grey,
                                      ),
                                      if (_isHovered)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered)
                                        Text(
                                          "Settings",
                                          style: GoogleFonts.epilogue(
                                              color: isDark
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontSize: width * 0.01),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: _isHovered
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          userData!["profileImage"]),
                                      radius: 20,
                                    ),
                                    if (_isHovered)
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    if (_isHovered)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userData!["name"],
                                              style: GoogleFonts.epilogue(
                                                  color: isDark
                                                      ? AppColors.white
                                                      : AppColors.black,
                                                  fontSize: width * 0.01),
                                            ),
                                            Text(
                                              userData!["email"],
                                              style: GoogleFonts.epilogue(
                                                  color: isDark
                                                      ? AppColors.white
                                                      : AppColors.black,
                                                  fontSize: width * 0.007),
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
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
