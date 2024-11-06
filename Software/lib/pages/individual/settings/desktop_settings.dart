import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';

class DesktopSettings extends StatefulWidget {
  Map<String, dynamic>? themeData;
  Map<String, dynamic>? userData;
  DesktopSettings({super.key, required this.themeData, required this.userData});

  @override
  State<DesktopSettings> createState() => _DesktopSettingsState();
}

class _DesktopSettingsState extends State<DesktopSettings> {
  String? selectedColor;
  String? selectedTheme;

  void changeTheme(String theme) async {
    // Update the theme in Firestore
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userData!["username"])
        .collection("Theme")
        .doc("settings")
        .update({"mode": theme == "light" ? false : true});

    // Update the local state to reflect the theme change
    setState(() {
      selectedTheme = theme;
      widget.themeData!["mode"] = theme == "dark";
      Provider.of<ThemeNotifier>(context, listen: false)
          .updateThemeMode(selectedTheme == "light" ? false : true);
    });
  }

  void changeColor(String theme) async {
    // Update the theme in Firestore
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userData!["username"])
        .collection("Theme")
        .doc("settings")
        .update({"color": theme == "yellow" ? "0xFFFFC107" : theme == "green"? "0xFF4CAF50" : theme == "blue"? "0xFF2196F3" : "0xffAA00FF"});

    // Update the local state to reflect the theme change
    setState(() {
      selectedColor = theme;
      Provider.of<ThemeNotifier>(context, listen: false).updateAccentColor(
        Color(
          theme == "yellow" ? 0xFFFFC107 : theme == "green"? 0xFF4CAF50 : theme == "blue"? 0xFF2196F3 : 0xffAA00FF,
        ),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedTheme = widget.themeData!["mode"] ? "dark" : "light";
    selectedColor = widget.themeData!["color"] == "0xFFFFC107" ? "yellow" : widget.themeData!["color"] == "0xFF4CAF50"? "green": widget.themeData!["color"] == "0xFF2196F3"? "blue": "purple";
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    String selectedAccent = accentColor==Color(0xffAA00FF) ? "purple" : accentColor==Color(0xFF4CAF50) ? "green" : accentColor == Color(0xFFFFC107)? "yellow" : "blue";

    return Scaffold(
      backgroundColor:
          widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
      appBar: AppBar(
        surfaceTintColor: AppColors.transparent,
        toolbarHeight: 80,
        backgroundColor:
            widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
        title: Text(
          "Settings",
          style: GoogleFonts.epilogue(
            fontSize: width * 0.02,
            fontWeight: FontWeight.bold,
            color:
                widget.themeData!["mode"] ? AppColors.white : AppColors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 10),
        child: Column(
          children: [
            //Accent Color
            Container(
              width: (width * 0.94) - 30,
              height: height / 7,
              decoration: BoxDecoration(
                // color: AppColors.lightGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Accent Color",
                        style: GoogleFonts.epilogue(
                          fontSize: width * 0.012,
                          fontWeight: FontWeight.w600,
                          color: widget.themeData!["mode"]
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      ),
                      Text(
                        "Personalize your experience by changing the accent color.",
                        style: GoogleFonts.epilogue(
                          fontSize: width * 0.009,
                          color: widget.themeData!["mode"]
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      )
                    ],
                  ),

                  //Colors
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = "yellow";
                          });
                          changeColor("yellow");
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.warningColor,
                          child: selectedAccent == "yellow"
                              ? const Icon(Icons.check)
                              : null,
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = "green";
                          });
                          changeColor("green");
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.successColor,
                          child: selectedAccent == "green"
                              ? const Icon(Icons.check)
                              : null,
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = "blue";
                          });
                          changeColor("blue");
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.infoColor,
                          child: selectedAccent == "blue"
                              ? const Icon(Icons.check)
                              : null,
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = "purple";
                          });
                          changeColor("purple");
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              AppColors.purple,
                          child: selectedAccent == "purple"
                              ? const Icon(Icons.check)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //Theme
            Container(
              width: (width * 0.94) - 30,
              height: height / 7,
              decoration: BoxDecoration(
                // color: AppColors.lightGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Theme",
                        style: GoogleFonts.epilogue(
                          fontSize: width * 0.012,
                          fontWeight: FontWeight.w600,
                          color: widget.themeData!["mode"]
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      ),
                      Text(
                        "Switch between light and dark themes to suit your preference.",
                        style: GoogleFonts.epilogue(
                          fontSize: width * 0.009,
                          color: widget.themeData!["mode"]
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      )
                    ],
                  ),

                  //Colors
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTheme = "light";
                            changeTheme("light");
                          });
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: widget.themeData!["mode"]
                              ? AppColors.white
                              : AppColors.lightGrey.withOpacity(0.3),
                          child: selectedTheme == "light"
                              ? const Icon(Icons.check)
                              : null,
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTheme = "dark";
                            changeTheme("dark");
                          });
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.black,
                          child: selectedTheme == "dark"
                              ? const Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
