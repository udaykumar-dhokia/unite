import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unite/components/textfield/textfield.dart';
import 'package:unite/constants/color/color.dart';

class DesktopLogin extends StatefulWidget {
  const DesktopLogin({super.key});

  @override
  State<DesktopLogin> createState() => _DesktopLoginState();
}

class _DesktopLoginState extends State<DesktopLogin> {
  final List<String> _texts = ["Sync", "Harmony", "Flow"];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        _index = (_index + 1) % _texts.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Padding(
        padding:
            const EdgeInsets.only(left: 30, right: 15, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Left Side
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // color: AppColors.white,
                  image: const DecorationImage(
                      image: AssetImage("lib/assets/login_back.jpg"),
                      fit: BoxFit.cover,
                      opacity: 0.9),
                ),
                width: (width / 2) - 60,
                height: height - 100,
                child: Stack(
                  children: [
                    Container(
                      height: height - 100,
                      width: (width / 2) - 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.black,
                            AppColors.black.withOpacity(0.6),
                            AppColors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, bottom: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Unite.",
                              style: GoogleFonts.epilogue(
                                  color: AppColors.white,
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),

                          //Tag line
                          Row(
                            children: [
                              Text("Stay in ",
                                  style: GoogleFonts.epilogue(
                                      fontSize: width * 0.015,
                                      color: AppColors.white)),
                              AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    _texts[_index],
                                    textStyle: GoogleFonts.epilogue(
                                        fontSize: width * 0.015,
                                        color: AppColors.successColor),
                                    speed: const Duration(milliseconds: 200),
                                  ),
                                ],
                                repeatForever: true,
                                isRepeatingAnimation: true,
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          // Timeline
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                radius: 5,
                                backgroundColor: AppColors.successColor,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: width * 0.15,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppColors.white),
                                child: Center(
                                    child: Text(
                                  "Signup to your account",
                                  style: GoogleFonts.epilogue(
                                      fontWeight: FontWeight.w500,
                                      fontSize: width * 0.01),
                                )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: width * 0.15,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppColors.grey.withOpacity(0.2)),
                                child: Center(
                                    child: Text(
                                  "Set up your profile",
                                  style: GoogleFonts.epilogue(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.white,
                                      fontSize: width * 0.01),
                                )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: width * 0.15,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppColors.grey.withOpacity(0.2)),
                                child: Center(
                                  child: Text(
                                    "Explore unimagined",
                                    style: GoogleFonts.epilogue(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.white,
                                        fontSize: width * 0.01),
                                  ),
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
            ),

            //Right Side
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.only(left: 100, right: 100),
                width: (width / 2) - 60,
                height: height - 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Sign Up Account",
                        style: GoogleFonts.epilogue(
                            fontSize: width * 0.03,
                            color: AppColors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.white,
                          child: FaIcon(
                            FontAwesomeIcons.google,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CircleAvatar(
                          backgroundColor: AppColors.white,
                          child: FaIcon(
                            FontAwesomeIcons.github,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                          color: AppColors.lightGrey.withOpacity(0.5),
                        )),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Or",
                          style: GoogleFonts.epilogue(
                              color: AppColors.lightGrey.withOpacity(0.5)),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Divider(
                          color: AppColors.lightGrey.withOpacity(0.5),
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const CustomTextFormField(
                      labelText: "Email",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const CustomTextFormField(
                      labelText: "Password",
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "*Must be at least 8 characters.",
                      style: GoogleFonts.epilogue(
                        color: AppColors.white.withOpacity(0.5),
                        fontSize: width * 0.007,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.white,
                        ),
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.epilogue(
                              fontSize: width * 0.01,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: GoogleFonts.epilogue(color: AppColors.grey, fontSize: width*0.009),
                          ),
                          Text(
                            "Try login",
                            style: GoogleFonts.epilogue(color: AppColors.successColor, fontSize: width*0.009),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
