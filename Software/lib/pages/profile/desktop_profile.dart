import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:unite/constants/color/color.dart';

class DesktopProfile extends StatefulWidget {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? themeData;
  DesktopProfile({super.key, required this.userData, required this.themeData});

  @override
  State<DesktopProfile> createState() => _DesktopProfileState();
}

class _DesktopProfileState extends State<DesktopProfile> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor:
          widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
      appBar: AppBar(
        surfaceTintColor: AppColors.transparent,
        toolbarHeight: 80,
        backgroundColor:
            widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
        title: Text(
          "Profile",
          style: GoogleFonts.epilogue(
              fontSize: width * 0.02,
              fontWeight: FontWeight.bold,
              color: widget.themeData!["mode"]
                  ? AppColors.white
                  : AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Profile
                Container(
                  width: (width * 0.9) * 0.4 - 20,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 10, bottom: 10),
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                  image: NetworkImage(
                                    widget.userData!["bannerImage"],
                                  ),
                                  fit: BoxFit.cover),
                            ),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(
                                  widget.userData!["profileImage"],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.userData!["name"],
                        style: GoogleFonts.epilogue(
                            fontSize: width * 0.015,
                            fontWeight: FontWeight.w500,
                            color: widget.themeData!["mode"]
                                ? AppColors.white
                                : AppColors.black),
                      ),
                      Text(
                        "@${widget.userData!["username"]}",
                        style: GoogleFonts.epilogue(
                            fontSize: width * 0.01,
                            color: widget.themeData!["mode"]
                                ? AppColors.white
                                : AppColors.black),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                        "Personal Details",
                        style: GoogleFonts.epilogue(
                            fontSize: width * 0.012,
                            fontWeight: FontWeight.bold,
                            color: widget.themeData!["mode"]? AppColors.white : AppColors.black
                            ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Email: ${widget.userData!["email"]}",
                        style: GoogleFonts.epilogue(fontSize: width * 0.01, color: widget.themeData!["mode"]? AppColors.white : AppColors.black),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Mobile: ${widget.userData!["mobile"].toString()}",
                        style: GoogleFonts.epilogue(fontSize: width * 0.01, color: widget.themeData!["mode"]? AppColors.white : AppColors.black),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "DOB: ${widget.userData!["dob"]}",
                        style: GoogleFonts.epilogue(fontSize: width * 0.01, color: widget.themeData!["mode"]? AppColors.white : AppColors.black),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Interests: ${widget.userData!["interests"]}",
                        style: GoogleFonts.epilogue(fontSize: width * 0.01, color: widget.themeData!["mode"]? AppColors.white : AppColors.black),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Social",
                        style: GoogleFonts.epilogue(
                            fontSize: width * 0.012,
                            fontWeight: FontWeight.bold, color: widget.themeData!["mode"]? AppColors.white : AppColors.black),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Brand(Brands.linkedin),
                          Brand(Brands.github),
                          Brand(Brands.instagram),
                          Brand(Brands.twitterx),
                        ],
                      ),
                    ],
                  ),
                ),

                //Others
                Column(
                  children: [
                    Container(
                      width: (width * 0.9) * 0.6 - 20,
                      height: height * 0.1,
                    ),
                    // const SizedBox(height: 20,),
                    Container(
                      width: (width * 0.9) * 0.6 - 20,
                      height: height * 0.9,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
