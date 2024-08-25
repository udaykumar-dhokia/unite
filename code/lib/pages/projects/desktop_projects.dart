import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unite/auth/login/desktop_login.dart';
import 'package:unite/constants/color/color.dart';

class DesktopProjects extends StatefulWidget {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? themeData;
  DesktopProjects({super.key, required this.userData, required this.themeData});

  @override
  State<DesktopProjects> createState() => _DesktopProjectsState();
}

class _DesktopProjectsState extends State<DesktopProjects> {
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  String selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return isLoading
        ? Scaffold(
            backgroundColor:
                widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
            body: const Center(
              child: const CircularProgressIndicator(
                color: AppColors.warningColor,
              ),
            ),
          )
        : Scaffold(
            backgroundColor:
                widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Color(
                int.parse(widget.themeData!["color"]),
              ),
              shape: const CircleBorder(),
              tooltip: "Create Project",
              child: const Icon(Icons.add),
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
                      //     //Search
                      // Container(
                      //   width: width * 0.15,
                      //   margin: const EdgeInsets.only(right: 10),
                      //   child: TextField(
                      //     decoration: InputDecoration(
                      //       hintText: 'Search',
                      //       hintStyle: GoogleFonts.epilogue(
                      //         color: widget.themeData!["mode"]
                      //             ? AppColors.white
                      //             : AppColors.black,
                      //       ),
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(20),
                      //         borderSide: BorderSide(
                      //           color: widget.themeData!["mode"]
                      //               ? AppColors.white
                      //               : AppColors.black,
                      //         ),
                      //       ),
                      //       contentPadding: const EdgeInsets.symmetric(
                      //           vertical: 0, horizontal: 10),
                      //     ),
                      //     style: GoogleFonts.epilogue(
                      //       color: widget.themeData!["mode"]
                      //           ? AppColors.white
                      //           : AppColors.black,
                      //     ),
                      //     onChanged: (value) {
                      //       // Add your search logic here
                      //     },
                      //   ),
                      // ),

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
                                        ? Color(int.parse(
                                            widget.themeData!["color"]))
                                        : widget.themeData!["mode"]
                                            ? AppColors.white
                                            : AppColors.black),
                              ),
                              child: Text(
                                "All",
                                style: GoogleFonts.epilogue(
                                  color: selectedFilter == "All"
                                      ? Color(
                                          int.parse(widget.themeData!["color"]))
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
                                        ? Color(int.parse(
                                            widget.themeData!["color"]))
                                        : widget.themeData!["mode"]
                                            ? AppColors.white
                                            : AppColors.black),
                              ),
                              child: Text(
                                "Ongoing",
                                style: GoogleFonts.epilogue(
                                  color: selectedFilter == "Ongoing"
                                      ? Color(
                                          int.parse(widget.themeData!["color"]))
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
                                        ? Color(int.parse(
                                            widget.themeData!["color"]))
                                        : widget.themeData!["mode"]
                                            ? AppColors.white
                                            : AppColors.black),
                              ),
                              child: Text(
                                "Completed",
                                style: GoogleFonts.epilogue(
                                  color: selectedFilter == "Completed"
                                      ? Color(
                                          int.parse(widget.themeData!["color"]))
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
                ],
              ),
            ),
          );
  }
}
