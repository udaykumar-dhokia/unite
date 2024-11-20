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
import 'package:unite/pages/individual/profile/desktop_profile.dart';
import 'package:unite/pages/individual/projects/desktop_projects.dart';
import 'package:unite/pages/individual/settings/desktop_settings.dart';
import 'package:unite/pages/individual/teams/desktop_teams.dart';
import 'package:unite/pages/individual/uniteai/uniteai.dart';
import 'package:unite/pages/project/calendar/project_calendar.dart';
import 'package:unite/pages/project/dashboard/dashboard.dart';
import 'package:unite/pages/project/discussion/discussion.dart';
import 'package:unite/pages/project/drive/drive.dart';

class CompanyProjectSidePanel extends StatefulWidget {
  final Map<String, dynamic> data;
  final String id;
  const CompanyProjectSidePanel({super.key, required this.data, required this.id});

  @override
  State<CompanyProjectSidePanel> createState() => _CompanyProjectSidePanelState();
}

class _CompanyProjectSidePanelState extends State<CompanyProjectSidePanel> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? themeData;
  Map<String, dynamic> socialLinks = {};
  bool isLoading = false;
  // bool isDark = false;
  bool _isHovered = true;
  bool _isTextVisible = true;
  Timer? _hoverTimer;
  String page = "home";

  void getDetails() async {
    setState(() {
      isLoading = true;
    });
    final data = await FirebaseFirestore.instance
        .collection("company")
        .doc(user!.email)
        .get();

      setState(() {
        userData = data.data();
      });

    final theme = await FirebaseFirestore.instance
        .collection("company")
        .doc(user!.email)
        .collection("Theme")
        .doc("settings")
        .get();

    print(theme.data());
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
                  //Sidepanel
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
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        size: 22,
                                        icon:
                                            HugeIcons.strokeRoundedArrowLeft01,
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
                                          "Back",
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
                                const SizedBox(
                                  height: 20,
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
                                        icon: HugeIcons
                                            .strokeRoundedDashboardSquare03,
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
                                          "Dashboard",
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
                                      page = "chat";
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        size: 22,
                                        icon: HugeIcons.strokeRoundedChatting01,
                                        color: page == "chat"
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
                                          "Discussion",
                                          style: GoogleFonts.epilogue(
                                              color: page == "chat"
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
                                      page = "drive";
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        size: 22,
                                        icon: HugeIcons.strokeRoundedFolder01,
                                        color: page == "drive"
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
                                          "Drive",
                                          style: GoogleFonts.epilogue(
                                              color: page == "drive"
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
                                        icon: HugeIcons.strokeRoundedCalendar02,
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
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      page = "uniteai";
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: _isHovered
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          HugeIcon(
                                            size: 22,
                                            icon: HugeIcons
                                                .strokeRoundedGoogleGemini,
                                            color: page == "uniteai"
                                                ? accent
                                                : !isDark
                                                    ? AppColors.dark
                                                    : AppColors.grey,
                                          ),
                                          Positioned(
                                            top:
                                                -10, // Place "new" above the icon
                                            left:
                                                10, // Center align with the icon
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: accent,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                "new",
                                                style: GoogleFonts.epilogue(
                                                  color: Colors.white,
                                                  fontSize:
                                                      8, // Small font for the badge
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_isHovered && _isTextVisible)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (_isHovered && _isTextVisible)
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Text(
                                              "unite.ai",
                                              style: GoogleFonts.epilogue(
                                                color: page == "uniteai"
                                                    ? accent
                                                    : isDark
                                                        ? AppColors.white
                                                        : AppColors.black,
                                                fontSize: width * 0.009,
                                              ),
                                            ),
                                          ],
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
                                // const SizedBox(
                                //   height: 20,
                                // ),
                                // GestureDetector(
                                //   onTap: () {
                                //     setState(() {
                                //       page = "settings";
                                //     });
                                //   },
                                //   child: Row(
                                //     mainAxisAlignment: _isHovered
                                //         ? MainAxisAlignment.start
                                //         : MainAxisAlignment.center,
                                //     children: [
                                //       HugeIcon(
                                //         size: 22,
                                //         icon: HugeIcons.strokeRoundedSettings05,
                                //         color: page == "settings"
                                //             ? accent
                                //             : !isDark
                                //                 ? AppColors.dark
                                //                 : AppColors.grey,
                                //       ),
                                //       if (_isHovered && _isTextVisible)
                                //         const SizedBox(
                                //           width: 10,
                                //         ),
                                //       if (_isHovered && _isTextVisible)
                                //         Text(
                                //           "Settings",
                                //           style: GoogleFonts.epilogue(
                                //               color: page == "settings"
                                //                   ? accent
                                //                   : isDark
                                //                       ? AppColors.white
                                //                       : AppColors.black,
                                //               fontSize: width * 0.009),
                                //         ),
                                //     ],
                                //   ),
                                // ),
                                // const SizedBox(
                                //   height: 20,
                                // ),
                                // GestureDetector(
                                //   onTap: () {
                                //     setState(() {
                                //       page = "profile";
                                //     });
                                //   },
                                //   child: Row(
                                //     mainAxisAlignment: _isHovered
                                //         ? MainAxisAlignment.start
                                //         : MainAxisAlignment.center,
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.center,
                                //     children: [
                                //       CircleAvatar(
                                //         backgroundImage:
                                //             userData!["profileImage"] == null
                                //                 ? const AssetImage(
                                //                     "lib/assets/user.jpg")
                                //                 : NetworkImage(
                                //                     userData!["profileImage"]),
                                //         radius: 15,
                                //       ),
                                //       if (_isHovered && _isTextVisible)
                                //         const SizedBox(
                                //           width: 10,
                                //         ),
                                //       if (_isHovered && _isTextVisible)
                                //         Expanded(
                                //           child: Column(
                                //             crossAxisAlignment:
                                //                 CrossAxisAlignment.start,
                                //             children: [
                                //               Text(
                                //                 userData!["name"],
                                //                 style: GoogleFonts.epilogue(
                                //                     color: isDark
                                //                         ? AppColors.white
                                //                         : AppColors.black,
                                //                     fontSize: width * 0.009),
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //     ],
                                //   ),
                                // ),
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
                        ? Dashboard(
                            id: widget.id,
                            userData: userData,
                          )
                        : page == "chat"
                            ? Discussion(
                                id: widget.id,
                                userData: userData!,
                              )
                            : page == "calendar"
                                ? ProjectCalendar(
                                  id: widget.id,
                                    userData: userData,
                                    themeData: themeData,
                                  )
                                : page == "calendar"
                                    ? ProjectCalendar(
                                      userData: userData,
                                      themeData: themeData,
                                      id: widget.id,
                                    )
                                    : page == "uniteai"? CodeUtilitiesHome(themeData: themeData, userData: userData) : Drive(
                                      id: widget.id,
                                userData: userData!,

                                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
