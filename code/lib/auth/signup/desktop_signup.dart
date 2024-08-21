import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unite/auth/login/app_login.dart';
import 'package:unite/auth/login/desktop_login.dart';
import 'package:unite/components/textfield/textfield.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/pages/projects/desktop_projects.dart';
import 'package:unite/responsive/layout/responsive_layout.dart';

class DesktopSignup extends StatefulWidget {
  const DesktopSignup({super.key});

  @override
  State<DesktopSignup> createState() => _DesktopSignupState();
}

class _DesktopSignupState extends State<DesktopSignup> {
  final List<String> _texts = ["Sync", "Harmony", "Flow"];
  int _index = 0;
  bool isDetails = false;
  bool isDark = false;
  bool isUsernameTaken = false;
  bool isLoading = false;
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _dob = TextEditingController();
  File? _bannerImage;
  File? _profileImage;
  List<String> tags = [];
  List<String> options = [
    'Project Manager',
    'Team Lead',
    'Developer',
    'Designer',
    'Tester',
    'Business Analyst',
    'Product Owner',
    'Stakeholder',
    'Client',
    'QA Engineer',
  ];

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

  Future<void> _pickBannerImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        _bannerImage = File(result.files.single.path!);
      });
    }
  }

  // Method to pick profile image
  Future<void> _pickProfileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      print(result);
      setState(() {
        _profileImage = File(result.files.single.path!);
      });
    } else {
      // User canceled the picker
      print("No file selected");
    }
  }

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

  void signup(String email, String password, final data) async {
    try {
      setState(() {
        isLoading = true;
      });
      final credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(data["username"])
          .set(data);

      String fileName = 'profile_images/${data["username"]}/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
      

      UploadTask uploadTask = firebaseStorageRef.putFile(
        _profileImage!,
        SettableMetadata(contentType: 'image/png'),
      );

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("users").doc(data["username"]).update({"profileImage": downloadUrl});


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
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DesktopProjects()));
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
                              if (!isDetails)
                                const CircleAvatar(
                                  radius: 5,
                                  backgroundColor: AppColors.warningColor,
                                ),
                              if (!isDetails)
                                const SizedBox(
                                  width: 10,
                                ),
                              Container(
                                width: width * 0.15,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: !isDetails
                                      ? AppColors.white
                                      : AppColors.grey.withOpacity(0.2),
                                ),
                                child: Center(
                                    child: Text(
                                  "Signup your account",
                                  style: GoogleFonts.epilogue(
                                    fontWeight: FontWeight.w500,
                                    fontSize: width * 0.01,
                                    color: !isDetails
                                        ? AppColors.black
                                        : AppColors.white,
                                  ),
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
                              if (isDetails)
                                const CircleAvatar(
                                  radius: 5,
                                  backgroundColor: AppColors.warningColor,
                                ),
                              if (isDetails)
                                const SizedBox(
                                  width: 10,
                                ),
                              Container(
                                width: width * 0.15,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: !isDetails
                                      ? AppColors.grey.withOpacity(0.2)
                                      : AppColors.white,
                                ),
                                child: Center(
                                    child: Text(
                                  "Set up your profile",
                                  style: GoogleFonts.epilogue(
                                      fontWeight: FontWeight.w500,
                                      color: isDetails
                                          ? AppColors.black
                                          : AppColors.white,
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
                : !isDetails
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
                                  "Sign Up Account",
                                  style: GoogleFonts.epilogue(
                                      fontSize: width * 0.03,
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.black,
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
                                      color: isDark
                                          ? AppColors.black
                                          : AppColors.white,
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
                                      color: isDark
                                          ? AppColors.black
                                          : AppColors.white,
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
                                controller: _name,
                                labelText: "Name",
                              ),
                              const SizedBox(
                                height: 15,
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
                                suffixIcon: Icons.visibility,
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
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(_email.text)) {
                                    CherryToast.error(
                                            displayCloseButton: false,
                                            toastPosition: Position.top,
                                            description: Text(
                                              textAlign: TextAlign.start,
                                              "Please provide valid email.",
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
                                  } else if (_password.text.length < 6) {
                                    CherryToast.error(
                                            displayCloseButton: false,
                                            toastPosition: Position.top,
                                            description: Text(
                                              textAlign: TextAlign.start,
                                              "Password should be at least 6 characters.",
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
                                  } else if (_name.text.isNotEmpty &&
                                      _email.text.isNotEmpty &&
                                      _password.text.isNotEmpty) {
                                    setState(() {
                                      isDetails = !isDetails;
                                    });
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
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.black,
                                    ),
                                    child: Text(
                                      "Sign Up",
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
                                      "Already have an account? ",
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
                                                  const DesktopLogin(),
                                              mobileWidget: const AppLogin(),
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
                                        "Try login",
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
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    "Set up your profile",
                                    style: GoogleFonts.epilogue(
                                      fontSize: width * 0.03,
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _pickBannerImage();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 10),
                                    height: 180,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      image: _bannerImage != null
                                          ? DecorationImage(
                                              image: FileImage(
                                                _bannerImage!,
                                              ),
                                              fit: BoxFit.cover)
                                          : null,
                                      color: AppColors.lightGrey,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Stack(
                                      children: [
                                        if (_bannerImage == null)
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Add Banner",
                                              style: GoogleFonts.epilogue(
                                                  fontSize: width * 0.01,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: CircleAvatar(
                                              radius: 40,
                                              backgroundImage: _profileImage !=
                                                      null
                                                  ? FileImage(_profileImage!)
                                                  : const AssetImage(
                                                      "lib/assets/user.jpg"),
                                              backgroundColor: AppColors.white,
                                              child: GestureDetector(
                                                onTap: () {
                                                  _pickProfileImage();
                                                },
                                                child: const Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor:
                                                        AppColors.dark,
                                                    child: Icon(
                                                      Icons.add,
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                TextFormField(
                                  cursorColor: AppColors.warningColor,
                                  style: GoogleFonts.epilogue(
                                      color: !isDark
                                          ? AppColors.black
                                          : AppColors.white),
                                  onChanged: (value) {
                                    _checkUsernameExists(value);
                                  },
                                  controller: _username,
                                  decoration: InputDecoration(
                                    labelStyle: GoogleFonts.epilogue(
                                        color: !isDark
                                            ? AppColors.black
                                            : AppColors.white),
                                    labelText: "Username",
                                    border: const UnderlineInputBorder(),
                                    enabledBorder: const UnderlineInputBorder(),
                                    focusedBorder: const UnderlineInputBorder(),
                                  ),
                                ),
                                if (isUsernameTaken &&
                                    _username.text.isNotEmpty)
                                  const SizedBox(
                                    height: 5,
                                  ),
                                if (isUsernameTaken)
                                  Text(
                                    "${_username.text} is already taken.",
                                    style: GoogleFonts.epilogue(
                                        color: AppColors.errorColor,
                                        fontSize: width * 0.008),
                                  ),
                                if (!isUsernameTaken &&
                                    _username.text.isNotEmpty)
                                  const SizedBox(
                                    height: 5,
                                  ),
                                if (!isUsernameTaken &&
                                    _username.text.isNotEmpty)
                                  Text(
                                    "${_username.text} is available.",
                                    style: GoogleFonts.epilogue(
                                        color: AppColors.successColor,
                                        fontSize: width * 0.008),
                                  ),
                                const SizedBox(
                                  height: 15,
                                ),
                                CustomTextFormField(
                                  isDark: isDark,
                                  controller: _mobile,
                                  keyboardType: TextInputType.phone,
                                  labelText: "Mobile",
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                CustomTextFormField(
                                  isDark: isDark,
                                  controller: _dob,
                                  keyboardType: TextInputType.datetime,
                                  suffixIcon: Icons.calendar_month_outlined,
                                  labelText: "Date of Birth",
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  "Select options that best describes you",
                                  style: GoogleFonts.epilogue(
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.black),
                                ),
                                ChipsChoice<String>.multiple(
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  value: tags,
                                  onChanged: (val) =>
                                      setState(() => tags = val),
                                  choiceItems:
                                      C2Choice.listFrom<String, String>(
                                    source: options,
                                    value: (i, v) => v,
                                    label: (i, v) => v,
                                  ),
                                  wrapped: true,
                                  choiceCheckmark: true,
                                  choiceStyle: C2ChipStyle.filled(
                                    selectedStyle: const C2ChipStyle(
                                      backgroundColor: AppColors.warningColor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (_name.text.isEmpty ||
                                        _password.text.isEmpty ||
                                        _email.text.isEmpty ||
                                        _username.text.isEmpty ||
                                        tags.isEmpty) {
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
                                              animationType:
                                                  AnimationType.fromTop,
                                              animationDuration: const Duration(
                                                milliseconds: 1000,
                                              ),
                                              autoDismiss: true)
                                          .show(context);
                                    } else if (_mobile.text.isEmpty ||
                                        !RegExp(r'^\d{10}$')
                                            .hasMatch(_mobile.text)) {
                                      CherryToast.error(
                                              displayCloseButton: false,
                                              toastPosition: Position.top,
                                              description: Text(
                                                textAlign: TextAlign.start,
                                                "Please provide valid mobile number.",
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
                                    } else if (isUsernameTaken) {
                                      CherryToast.error(
                                              displayCloseButton: false,
                                              toastPosition: Position.top,
                                              description: Text(
                                                textAlign: TextAlign.start,
                                                "Username already taken.",
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
                                    } else {
                                      final data = {
                                        "name": _name.text,
                                        "email": _email.text,
                                        "password": _password.text,
                                        "dob": _dob.text,
                                        "username": _username.text,
                                        "interests": tags,
                                        "mobile": double.parse(_mobile.text),
                                      };
                                      signup(_email.text, _password.text, data);
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
                                        "Get Started",
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
