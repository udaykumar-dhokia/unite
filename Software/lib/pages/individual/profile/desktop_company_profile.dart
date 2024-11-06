import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:unite/components/textfield/textfield.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';

class DesktopCompanyProfile extends StatefulWidget {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? themeData;
  Map<String, dynamic> socialLinks;
  DesktopCompanyProfile(
      {super.key,
      required this.userData,
      required this.themeData,
      required this.socialLinks});

  @override
  State<DesktopCompanyProfile> createState() => _DesktopCompanyProfileState();
}

class _DesktopCompanyProfileState extends State<DesktopCompanyProfile> {
  List<String> tags = [];
  List<String> temp = [];
  bool areLinks = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var i in widget.userData!["companyTags"]) {
      tags.add(i);
    }
    // FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Scaffold(
      backgroundColor:
          widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
      appBar: AppBar(
        surfaceTintColor: AppColors.transparent,
        toolbarHeight: 80,
        backgroundColor:
            widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Profile",
              style: GoogleFonts.epilogue(
                  fontSize: width * 0.02,
                  fontWeight: FontWeight.bold,
                  color: widget.themeData!["mode"]
                      ? AppColors.white
                      : AppColors.black),
            ),
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedLogout01,
                color: theme ? AppColors.white : AppColors.black,
                size: 18,
              ),
            ),
          ],
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
                            padding:
                                const EdgeInsets.only(left: 10, bottom: 10),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Personal Details",
                            style: GoogleFonts.epilogue(
                                fontSize: width * 0.012,
                                fontWeight: FontWeight.bold,
                                color: widget.themeData!["mode"]
                                    ? AppColors.white
                                    : AppColors.black),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedEditUser02,
                              color: theme ? AppColors.white : AppColors.black,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Email: ${widget.userData!["email"]}",
                        style: GoogleFonts.epilogue(
                            fontSize: width * 0.01,
                            color: widget.themeData!["mode"]
                                ? AppColors.white
                                : AppColors.black),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Mobile: ${widget.userData!["contact"].toString().split(".")[0]}",
                        style: GoogleFonts.epilogue(
                            fontSize: width * 0.01,
                            color: widget.themeData!["mode"]
                                ? AppColors.white
                                : AppColors.black),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "DOB: ${widget.userData!["established"]}",
                        style: GoogleFonts.epilogue(
                            fontSize: width * 0.01,
                            color: widget.themeData!["mode"]
                                ? AppColors.white
                                : AppColors.black),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Company Tags",
                        style: GoogleFonts.epilogue(
                            fontSize: width * 0.01,
                            color: widget.themeData!["mode"]
                                ? AppColors.white
                                : AppColors.black),
                      ),
                      ChipsChoice<String>.multiple(
                        scrollPhysics: const BouncingScrollPhysics(),
                        value: tags,
                        onChanged: (val) => setState(() => temp = val),
                        choiceItems: C2Choice.listFrom<String, String>(
                          source: tags,
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
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Social",
                            style: GoogleFonts.epilogue(
                                fontSize: width * 0.012,
                                fontWeight: FontWeight.bold,
                                color: widget.themeData!["mode"]
                                    ? AppColors.white
                                    : AppColors.black),
                          ),
                          Row(
                            children: [
                              Opacity(
                                opacity: widget.socialLinks.isEmpty ? 1 : 0,
                                child: const HugeIcon(
                                  icon:
                                      HugeIcons.strokeRoundedInformationCircle,
                                  color: AppColors.errorColor,
                                  size: 18,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => FluidDialog(
                                      // Set the first page of the dialog.
                                      rootPage: FluidDialogPage(
                                        decoration: const BoxDecoration(
                                            color: AppColors.transparent),
                                        alignment: Alignment.center,
                                        builder: (context) => editSocial(
                                          width: width,
                                          height: height,
                                          theme: theme,
                                          accentColor: accentColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: HugeIcon(
                                  icon: widget.socialLinks.isNotEmpty
                                      ? HugeIcons.strokeRoundedPencilEdit01
                                      : HugeIcons.strokeRoundedAdd01,
                                  color:
                                      theme ? AppColors.white : AppColors.black,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Opacity(
                        opacity: widget.socialLinks.isNotEmpty ? 1 : 0.3,
                        child: Row(
                          children: [
                            const Icon(
                              Bootstrap.linkedin,
                              color: AppColors.infoColor,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Icon(
                              Bootstrap.github,
                              color: AppColors.lightGrey,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Icon(
                              Bootstrap.twitter_x,
                              color: AppColors.lightGrey,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Bootstrap.reddit,
                              color: Colors.deepOrange[900],
                            ),
                          ],
                        ),
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

class editSocial extends StatefulWidget {
  editSocial({
    super.key,
    required this.width,
    required this.height,
    required this.theme,
    required this.accentColor,
  });

  final double width;
  final double height;
  bool theme;
  Color accentColor;

  @override
  State<editSocial> createState() => _editSocialState();
}

class _editSocialState extends State<editSocial> {
  TextEditingController _linkedin = TextEditingController();
  TextEditingController _git = TextEditingController();
  TextEditingController _x = TextEditingController();
  TextEditingController _reddit = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      width: widget.width * 0.5,
      height: widget.height * 0.55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: widget.theme ? AppColors.dark : AppColors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Social Profile",
                style: GoogleFonts.epilogue(
                  color: widget.theme ? AppColors.white : AppColors.black,
                  fontSize: widget.width * 0.018,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: HugeIcon(
                  size: 20,
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: widget.theme ? AppColors.white : AppColors.black,
                ),
              ),
            ],
          ),
          Column(
            children: [
              CustomTextFormField(
                prefixIcon: Bootstrap.linkedin,
                isDark: widget.theme,
                controller: _linkedin,
                labelText: "Linkedin",
              ),
              const SizedBox(
                height: 8,
              ),
              CustomTextFormField(
                controller: _git,
                prefixIcon: Bootstrap.github,
                isDark: widget.theme,
                labelText: "GitHub",
              ),
              const SizedBox(
                height: 8,
              ),
              CustomTextFormField(
                controller: _x,
                prefixIcon: Bootstrap.twitter_x,
                isDark: widget.theme,
                labelText: "X",
              ),
              const SizedBox(
                height: 8,
              ),
              CustomTextFormField(
                controller: _reddit,
                prefixIcon: Bootstrap.reddit,
                isDark: widget.theme,
                labelText: "Reddit",
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: widget.accentColor,
              onPressed: () {},
              child: GestureDetector(
                onTap: () {
                  if (_linkedin.text.isEmpty ||
                      _x.text.isEmpty ||
                      _reddit.text.isEmpty ||
                      _git.text.isEmpty) {
                    CherryToast.error(
                            displayCloseButton: false,
                            toastPosition: Position.top,
                            description: Text(
                              textAlign: TextAlign.start,
                              "Please fill up all the details.",
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
                },
                child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedTick02,
                    color: AppColors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
