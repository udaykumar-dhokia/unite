import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';
import 'package:unite/pages/individual/calendar/desktop_calendar.dart';
import 'package:unite/pages/individual/notes/desktop_notes.dart';
import 'package:unite/pages/individual/profile/desktop_company_profile.dart';
import 'package:unite/pages/individual/profile/desktop_profile.dart';
import 'package:unite/pages/individual/projects/desktop_projects.dart';
import 'package:unite/pages/individual/settings/desktop_settings.dart';
import 'package:unite/pages/individual/teams/desktop_teams.dart';

class CompanySidePanel extends StatefulWidget {
  const CompanySidePanel({super.key});

  @override
  State<CompanySidePanel> createState() => _CompanySidePanelState();
}

class _CompanySidePanelState extends State<CompanySidePanel> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? themeData;
  Map<String, dynamic> socialLinks = {};
  bool isLoading = false;
  // bool isDark = false;
  bool _isHovered = false;
  bool _isTextVisible = false;
  Timer? _hoverTimer;
  String page = "notes";

  void getDetails() async {
    setState(() {
      isLoading = true;
    });
    final data = await FirebaseFirestore.instance
        .collection("company")
        .where("email", isEqualTo: user!.email)
        .get();

    for (var docs in data.docs) {
      setState(() {
        userData = docs.data();
      });
    }

    final social = await FirebaseFirestore.instance
        .collection("users")
        .doc(userData!["username"])
        .collection("Social")
        .doc("links")
        .get();
    setState(() {
      socialLinks = social.data() ?? {};
    });

    final theme = await FirebaseFirestore.instance
        .collection("company")
        .doc(userData!["email"])
        .collection("Theme")
        .doc("settings")
        .get();

    setState(() {
      themeData = theme.data();
      // isDark = themeData!["mode"];
      Provider.of<ThemeNotifier>(context, listen: false)
          .updateThemeMode(themeData!["mode"]);
      Provider.of<ThemeNotifier>(context, listen: false)
          .updateAccentColor(Color(int.parse(themeData!["color"])));
    });

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
    // FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    bool isDark = Provider.of<ThemeNotifier>(context).isDarkMode;
    Color accent = Provider.of<ThemeNotifier>(context).accentColor;

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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //CompanySidePanel
                  MouseRegion(
                    // onEnter: (_) => _onHover(true),
                    // onExit: (_) => _onHover(false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 0),
                      width: !_isHovered ? width * 0.04 : width * 0.1,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: !_isHovered
                            ? Border(
                                right: BorderSide(
                                  width: 1,
                                  color: isDark
                                      ? AppColors.grey.withOpacity(0.3)
                                      : AppColors.black.withOpacity(0.3),
                                ),
                              )
                            : null,
                      ),
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
                                      radius: 18,
                                      backgroundImage:
                                          AssetImage("lib/assets/logo.jpg"),
                                    ),
                                    if (_isHovered && _isTextVisible)
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    if (_isHovered && _isTextVisible)
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
                                        size: 22,
                                        icon: HugeIcons.strokeRoundedChartRose,
                                        color: page == "home"
                                            ? accent
                                            : !isDark
                                                ? AppColors.dark
                                                : AppColors.grey,
                                      ),
                                      if (_isHovered && _isTextVisible)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered && _isTextVisible)
                                        Text(
                                          "Projects",
                                          style: GoogleFonts.epilogue(
                                              color: page == "home"
                                                  ? accent
                                                  : isDark
                                                      ? AppColors.white
                                                      : AppColors.black,
                                              fontSize: width * 0.009),
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
                                        size: 22,
                                        icon: HugeIcons.strokeRoundedUserGroup,
                                        color: page == "team"
                                            ? accent
                                            : !isDark
                                                ? AppColors.dark
                                                : AppColors.grey,
                                      ),
                                      if (_isHovered && _isTextVisible)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered && _isTextVisible)
                                        Text(
                                          "Teams",
                                          style: GoogleFonts.epilogue(
                                              color: page == "team"
                                                  ? accent
                                                  : isDark
                                                      ? AppColors.white
                                                      : AppColors.black,
                                              fontSize: width * 0.009),
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
                                        size: 22,
                                        icon: HugeIcons.strokeRoundedCalendar03,
                                        color: page == "calendar"
                                            ? accent
                                            : !isDark
                                                ? AppColors.dark
                                                : AppColors.grey,
                                      ),
                                      if (_isHovered && _isTextVisible)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered && _isTextVisible)
                                        Text(
                                          "Calendar",
                                          style: GoogleFonts.epilogue(
                                              color: page == "calendar"
                                                  ? accent
                                                  : isDark
                                                      ? AppColors.white
                                                      : AppColors.black,
                                              fontSize: width * 0.009),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isHovered = !_isHovered;
                                      _hoverTimer = Timer(
                                          const Duration(milliseconds: 165),
                                          () {
                                        setState(() {
                                          _isTextVisible = !_isTextVisible;
                                        });
                                      });
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        size: 22,
                                        icon: !_isHovered
                                            ? HugeIcons
                                                .strokeRoundedArrowRight01
                                            : HugeIcons
                                                .strokeRoundedArrowLeft01,
                                        color: !isDark
                                            ? AppColors.dark
                                            : AppColors.grey,
                                      ),
                                      if (_isHovered && _isTextVisible)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered && _isTextVisible)
                                        Text(
                                          "Close",
                                          style: GoogleFonts.epilogue(
                                              color: isDark
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontSize: width * 0.009),
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
                                      page = "notifications";
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        size: 22,
                                        icon: HugeIcons
                                            .strokeRoundedNotification01,
                                        color: page == "notifications"
                                            ? accent
                                            : !isDark
                                                ? AppColors.dark
                                                : AppColors.grey,
                                      ),
                                      if (_isHovered && _isTextVisible)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered && _isTextVisible)
                                        Text(
                                          "Notifications",
                                          style: GoogleFonts.epilogue(
                                              color: page == "notifications"
                                                  ? accent
                                                  : isDark
                                                      ? AppColors.white
                                                      : AppColors.black,
                                              fontSize: width * 0.009),
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
                                      page = "settings";
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        size: 22,
                                        icon: HugeIcons.strokeRoundedSettings05,
                                        color: page == "settings"
                                            ? accent
                                            : !isDark
                                                ? AppColors.dark
                                                : AppColors.grey,
                                      ),
                                      if (_isHovered && _isTextVisible)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered && _isTextVisible)
                                        Text(
                                          "Settings",
                                          style: GoogleFonts.epilogue(
                                              color: page == "settings"
                                                  ? accent
                                                  : isDark
                                                      ? AppColors.white
                                                      : AppColors.black,
                                              fontSize: width * 0.009),
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
                                      page = "profile";
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            userData!["profileImage"] == null
                                                ? const AssetImage(
                                                    "lib/assets/user.jpg")
                                                : NetworkImage(
                                                    userData!["profileImage"]),
                                        radius: 15,
                                      ),
                                      if (_isHovered && _isTextVisible)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered && _isTextVisible)
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
                                                    fontSize: width * 0.009),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  //Main page
                  Container(
                    width:
                        !_isHovered ? (width * 0.94) - 20 : (width * 0.9) - 20,
                    child: page == "home"
                        ? DesktopProjects(
                            userData: userData,
                            themeData: themeData,
                          )
                        : page == "profile"
                            ? DesktopCompanyProfile(
                                socialLinks: socialLinks,
                                userData: userData,
                                themeData: themeData,
                              )
                            : page == "settings"
                                ? DesktopSettings(
                                    userData: userData,
                                    themeData: themeData,
                                  )
                                : DesktopTeams(
                                    userData: userData,
                                    themeData: themeData,
                                  ),
                  ),
                ],
              ),
            ),
          );
  }
}
