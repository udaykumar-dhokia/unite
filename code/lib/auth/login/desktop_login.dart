import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:unite/auth/signup/app_signup.dart';
import 'package:unite/auth/signup/desktop_signup.dart';
import 'package:unite/components/sidepanel/sidepanel.dart';
import 'package:unite/components/textfield/textfield.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/pages/projects/desktop_projects.dart';
import 'package:unite/responsive/layout/responsive_layout.dart';

class DesktopLogin extends StatefulWidget {
  const DesktopLogin({super.key});

  @override
  State<DesktopLogin> createState() => _DesktopLoginState();
}

class _DesktopLoginState extends State<DesktopLogin> {
  final List<String> _texts = ["Sync", "Harmony", "Flow"];
  int _index = 0;
  bool forgotPassword = false;
  bool isDark = false;
  bool isOTPSent = false;
  bool isLoading = false;
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _forgotpasswordemail = TextEditingController();

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

  void login(String email, String password) async {
    try {
      setState(() {
        isLoading = true;
      });
      final credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      setState(() {
        isLoading = false;
      });

      CherryToast.success(
              displayCloseButton: false,
              toastPosition: Position.top,
              description: Text(
                textAlign: TextAlign.start,
                "Successfull",
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
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SidePanel()));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      CherryToast.error(
              displayCloseButton: false,
              toastPosition: Position.top,
              description: Text(
                textAlign: TextAlign.start,
                "Something went wrong.",
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
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dark : AppColors.white,
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
                      image: AssetImage("lib/assets/login_back3.jpg"),
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
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.black,
                            AppColors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 10, right: 10),
                    //   child: Align(
                    //       alignment: Alignment.topRight,
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.end,
                    //         children: [
                    //           Text(
                    //             "Toggle theme",
                    //             style: GoogleFonts.epilogue(
                    //                 color: AppColors.white),
                    //           ),
                    //           Switch(
                    //             inactiveTrackColor: AppColors.black,
                    //             activeTrackColor: AppColors.white,
                    //             activeColor: AppColors.black,
                    //             inactiveThumbColor: AppColors.white,
                    //             value: isDark,
                    //             onChanged: (value) {
                    //               setState(() {
                    //                 isDark = value;
                    //               });
                    //             },
                    //           ),
                    //         ],
                    //       )),
                    // ),
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
                                        color: AppColors.warningColor),
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
                                backgroundColor: AppColors.warningColor,
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
                                  !forgotPassword
                                      ? "Login to your account"
                                      : "Recover your password",
                                  style: GoogleFonts.epilogue(
                                      fontWeight: FontWeight.w500,
                                      fontSize: width * 0.01),
                                )),
                              ),
                            ],
                          ),
                          if (!forgotPassword)
                            const SizedBox(
                              height: 12,
                            ),
                          if (!forgotPassword)
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
                                      "Continue exploring",
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
            isLoading
                ? Container(
                    padding: const EdgeInsets.only(left: 100, right: 100),
                    width: (width / 2) - 60,
                    height: height - 100,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.warningColor,
                      ),
                    ),
                  )
                : !forgotPassword
                    ? Align(
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
                                  "Login Account",
                                  style: GoogleFonts.epilogue(
                                      fontSize: width * 0.03,
                                      color: !isDark
                                          ? AppColors.black
                                          : AppColors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: !isDark
                                        ? AppColors.black
                                        : AppColors.white,
                                    child: FaIcon(
                                      FontAwesomeIcons.google,
                                      color: !isDark
                                          ? AppColors.white
                                          : AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  CircleAvatar(
                                    backgroundColor: !isDark
                                        ? AppColors.black
                                        : AppColors.white,
                                    child: FaIcon(
                                      FontAwesomeIcons.github,
                                      color: !isDark
                                          ? AppColors.white
                                          : AppColors.black,
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
                                        color: AppColors.lightGrey
                                            .withOpacity(0.5)),
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
                              CustomTextFormField(
                                isDark: isDark,
                                controller: _email,
                                labelText: "Email",
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              CustomTextFormField(
                                isDark: isDark,
                                controller: _password,
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
                              GestureDetector(
                                onTap: () {
                                  if (_email.text.isNotEmpty &&
                                      _password.text.isNotEmpty) {
                                    login(_email.text, _password.text);
                                  } else {
                                    CherryToast.error(
                                            displayCloseButton: false,
                                            toastPosition: Position.top,
                                            description: Text(
                                              textAlign: TextAlign.start,
                                              "Please fill in all required fields",
                                              style: GoogleFonts.epilogue(
                                                color: Colors.black,
                                              ),
                                            ),
                                            animationType:
                                                AnimationType.fromTop,
                                            animationDuration: const Duration(
                                              milliseconds: 1000,
                                            ),
                                            autoDismiss: true)
                                        .show(context);
                                  }
                                },
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: !isDark
                                          ? AppColors.black
                                          : AppColors.white,
                                    ),
                                    child: Text(
                                      "Login",
                                      style: GoogleFonts.epilogue(
                                          fontSize: width * 0.01,
                                          color: isDark
                                              ? AppColors.black
                                              : AppColors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
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
                                      "Forgot your password? ",
                                      style: GoogleFonts.epilogue(
                                          color: AppColors.grey,
                                          fontSize: width * 0.009),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          forgotPassword = !forgotPassword;
                                        });
                                      },
                                      child: Text(
                                        "Recover",
                                        style: GoogleFonts.epilogue(
                                            color: AppColors.warningColor,
                                            fontSize: width * 0.009),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: GoogleFonts.epilogue(
                                          color: AppColors.grey,
                                          fontSize: width * 0.009),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushReplacement(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                ResponsiveLayout(
                                              desktopWidget:
                                                  const DesktopSignup(),
                                              mobileWidget: const AppSignup(),
                                            ),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              const begin = 0.0;
                                              const end = 1.0;
                                              const curve = Curves.easeInOut;

                                              var tween = Tween(
                                                      begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));

                                              return FadeTransition(
                                                opacity: animation.drive(tween),
                                                child: child,
                                              );
                                            },
                                            transitionDuration: const Duration(
                                                milliseconds: 300),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Try signup",
                                        style: GoogleFonts.epilogue(
                                            color: AppColors.warningColor,
                                            fontSize: width * 0.009),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.only(left: 100, right: 100),
                          width: (width / 2) - 60,
                          height: height - 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    forgotPassword = !forgotPassword;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      right: 20, top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: isDark
                                        ? AppColors.dark
                                        : AppColors.white,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: !isDark
                                            ? AppColors.dark
                                            : AppColors.white,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Back",
                                        style: GoogleFonts.epilogue(
                                            color: !isDark
                                                ? AppColors.dark
                                                : AppColors.white,
                                            fontSize: width * 0.01,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              Center(
                                child: Text(
                                  "Recover Password",
                                  style: GoogleFonts.epilogue(
                                      fontSize: width * 0.03,
                                      color: !isDark
                                          ? AppColors.dark
                                          : AppColors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              CustomTextFormField(
                                isDark: isDark,
                                controller: _forgotpasswordemail,
                                labelText: "Email",
                              ),
                              if (isOTPSent)
                                const SizedBox(
                                  height: 30,
                                ),
                              if (isOTPSent)
                                Center(
                                    child: Text(
                                  "Enter OTP",
                                  style: GoogleFonts.epilogue(
                                      color: AppColors.white),
                                )),
                              if (isOTPSent)
                                const SizedBox(
                                  height: 15,
                                ),
                              if (isOTPSent) Center(child: OTPInput()),
                              const SizedBox(
                                height: 50,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_forgotpasswordemail.text.isNotEmpty) {
                                    setState(() {
                                      isOTPSent = true;
                                    });
                                  } else {
                                    CherryToast.error(
                                            displayCloseButton: false,
                                            toastPosition: Position.top,
                                            description: Text(
                                              textAlign: TextAlign.start,
                                              "Please fill in email address",
                                              style: GoogleFonts.epilogue(
                                                color: Colors.black,
                                              ),
                                            ),
                                            animationType:
                                                AnimationType.fromTop,
                                            animationDuration: const Duration(
                                              milliseconds: 1000,
                                            ),
                                            autoDismiss: true)
                                        .show(context);
                                  }
                                },
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: !isDark
                                          ? AppColors.dark
                                          : AppColors.white,
                                    ),
                                    child: Text(
                                      !isOTPSent ? "Get OTP" : "Validate",
                                      style: GoogleFonts.epilogue(
                                          color: isDark
                                              ? AppColors.dark
                                              : AppColors.white,
                                          fontSize: width * 0.01,
                                          fontWeight: FontWeight.w600),
                                    ),
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
                                      "Don't have an account? ",
                                      style: GoogleFonts.epilogue(
                                          color: AppColors.grey,
                                          fontSize: width * 0.009),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushReplacement(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                ResponsiveLayout(
                                              desktopWidget:
                                                  const DesktopSignup(),
                                              mobileWidget: const AppSignup(),
                                            ),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              const begin = 0.0;
                                              const end = 1.0;
                                              const curve = Curves.easeInOut;

                                              var tween = Tween(
                                                      begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));

                                              return FadeTransition(
                                                opacity: animation.drive(tween),
                                                child: child,
                                              );
                                            },
                                            transitionDuration: const Duration(
                                                milliseconds: 300),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Try signup",
                                        style: GoogleFonts.epilogue(
                                            color: AppColors.warningColor,
                                            fontSize: width * 0.009),
                                      ),
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

class OTPInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.epilogue(
        fontSize: 20,
        color: AppColors.warningColor,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
    );

    return Pinput(
      length: 6,
      defaultPinTheme: defaultPinTheme,
      onCompleted: (pin) {
        print('OTP Entered: $pin');
      },
    );
  }
}
