import "package:cherry_toast/cherry_toast.dart";
import "package:cherry_toast/resources/arrays.dart";
import "package:chips_choice/chips_choice.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:hugeicons/hugeicons.dart";
import "package:provider/provider.dart";
import "package:unite/components/textfield/textfield.dart";
import "package:unite/constants/color/color.dart";
import "package:unite/constants/theme/themehandler.dart";

class CreateProject extends StatefulWidget {
  CreateProject({super.key, required this.userData, required this.themeData});

  Map<String, dynamic>? themeData;
  Map<String, dynamic>? userData;

  @override
  State<CreateProject> createState() => CreateProjectState();
}

class CreateProjectState extends State<CreateProject> {
  bool isUsernameTaken = false;
  List<String> options = [];
  List<String> tags = [];

  TextEditingController _add = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _dob = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      options.add(widget.userData!["username"]);
    });
  }

  Future<int> createProject() async {
    try {
      final data = {
        "name": _name.text,
        "description": _description.text,
        "manager": widget.userData!["username"],
        "members": options,
        "endDate": _dob.text,
        "startDate":
            "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
      };
      final cred =
          await FirebaseFirestore.instance.collection("projects").add(data);
      await FirebaseFirestore.instance
          .collection("projects")
          .doc(cred.id)
          .collection("chat")
          .add({});
      return 1;
    } catch (e) {
      return 0;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;
    TextEditingController _manager =
        TextEditingController(text: widget.userData!["name"]);
    return Scaffold(
      backgroundColor: AppColors.transparent,
      floatingActionButton: FloatingActionButton(
          backgroundColor: accentColor,
          onPressed: () async {
            if (_name.text.isEmpty && _description.text.isEmpty) {
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
                      animationType: AnimationType.fromTop,
                      animationDuration: const Duration(
                        milliseconds: 1000,
                      ),
                      autoDismiss: true)
                  .show(context);
            } else if (options.length == 1) {
              CherryToast.error(
                      displayCloseButton: false,
                      toastPosition: Position.top,
                      description: Text(
                        textAlign: TextAlign.start,
                        "Add at least one member to continue.",
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
            } else {
              int result = await createProject();
              if (result == 0) {
                CherryToast.error(
                        displayCloseButton: false,
                        toastPosition: Position.top,
                        description: Text(
                          textAlign: TextAlign.start,
                          "Failed to create project.",
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
                Navigator.pop(context);
              } else {
                CherryToast.success(
                        displayCloseButton: false,
                        toastPosition: Position.top,
                        description: Text(
                          textAlign: TextAlign.start,
                          "Successfully create the project.",
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
                Navigator.pop(context);
              }
            }
          },
          shape: const CircleBorder(),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedTick02,
            color: AppColors.black,
            size: 25,
          )),
      body: Container(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HugeIcon(
                      size: 40,
                      icon: HugeIcons.strokeRoundedChartRose,
                      color: accentColor,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Create Project",
                      style: GoogleFonts.epilogue(
                          color: theme ? AppColors.white : AppColors.black,
                          fontSize: width * 0.017,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: HugeIcon(
                    size: 20,
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: theme ? AppColors.white : AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 80,
            ),
            CustomTextFormField(
              isDark: theme,
              labelText: "Name",
              controller: _name,
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextFormField(
              controller: _manager,
              isDark: theme,
              readOnly: true,
              labelText: "Project Manager",
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextFormField(
              isDark: theme,
              controller: _description,
              maxLines: 3,
              maxLength: 250,
              labelText: "Description",
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextFormField(
              isDark: theme,
              controller: _dob,
              readOnly: true,
              keyboardType: TextInputType.datetime,
              suffixIcon: Icons.calendar_month_outlined,
              labelText: "Deadline",
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomTextFormField(
                    isDark: theme,
                    controller: _add,
                    onChanged: (value) {
                      _checkUsernameExists(value);
                    },
                    labelText: "Add members",
                  ),
                ),
                if (isUsernameTaken &&
                    _add.text.isNotEmpty &&
                    !options.contains(_add.text))
                  const SizedBox(
                    width: 10,
                  ),
                if (isUsernameTaken &&
                    _add.text.isNotEmpty &&
                    !options.contains(_add.text))
                  FloatingActionButton(
                    onPressed: () {},
                    shape: const CircleBorder(),
                    mini: true,
                    backgroundColor: accentColor,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          options.add(_add.text);
                          _add.clear();
                        });
                      },
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedAdd01,
                        color: AppColors.black,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            if (!isUsernameTaken && _add.text.isNotEmpty)
              const SizedBox(
                height: 5,
              ),
            if (!isUsernameTaken && _add.text.isNotEmpty)
              Text(
                "No such user available",
                style: GoogleFonts.epilogue(
                    color: AppColors.errorColor, fontSize: width * 0.01),
              ),
            if (isUsernameTaken && _add.text.isNotEmpty)
              const SizedBox(
                height: 5,
              ),
            if (isUsernameTaken && _add.text.isNotEmpty)
              Text(
                "${_add.text} is available",
                style: GoogleFonts.epilogue(
                    color: AppColors.successColor, fontSize: width * 0.01),
              ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Team Members (${options.length})",
              style: GoogleFonts.epilogue(
                  fontSize: width * 0.01,
                  color: theme ? AppColors.white : AppColors.black),
            ),
            ChipsChoice<String>.multiple(
              scrollPhysics: const BouncingScrollPhysics(),
              value: options,
              choiceTrailingBuilder: (item, i) =>
                  item.value != widget.userData!["username"]
                      ? GestureDetector(
                          onTap: () {
                            setState(
                              () {
                                options.remove(item.value);
                              },
                            );
                          },
                          child: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        )
                      : null,
              onChanged: (val) => setState(() => tags = val),
              choiceItems: C2Choice.listFrom<String, String>(
                source: options,
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
          ],
        ),
      ),
    );
  }
}
