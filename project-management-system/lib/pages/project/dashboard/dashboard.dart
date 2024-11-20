import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:unite/components/createproject/createproject.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';

class Dashboard extends StatefulWidget {
  final String id;

  Map<String, dynamic>? userData;

  Dashboard({super.key, required this.userData, required this.id});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isNameTaken = false;
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);
  Map<String, dynamic> projectData = {};
  bool isLoading = false;
  List<Widget> memberPhotos = [];

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    final data = await FirebaseFirestore.instance
        .collection("projects")
        .doc(widget.id)
        .get();

    List<dynamic> members = data['members'];

    for (int i = 1; i < members.length; i++) {
  String member = members[i];
  memberPhotos.add(
    FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(member).get(),
      builder: (context, memberSnapshot) {
        if (memberSnapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            radius: 15,
            backgroundColor: Colors.grey,
          );
        }

        if (memberSnapshot.hasError ||
            !memberSnapshot.hasData ||
            !memberSnapshot.data!.exists) {
          return const CircleAvatar(
            radius: 15,
            backgroundColor: Colors.grey,
          );
        }

        Map<String, dynamic> memberData =
            memberSnapshot.data!.data() as Map<String, dynamic>;
          print(memberData);
        String profileUrl = memberData['profileImage'] ?? '';
        String memberName = memberData['username'] ?? 'Unknown';

        return Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage:
                  profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
              backgroundColor: Colors.grey,
            ),
            SizedBox(height: 5),
            Text(
              memberName,
              style: GoogleFonts.epilogue(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Provider.of<ThemeNotifier>(context).isDarkMode
                    ? AppColors.white
                    : AppColors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    ),
  );
}


    setState(() {
      projectData = data.data()!;
      isLoading = false;
    });
  }

  Future<void> _checkNameExists() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: widget.userData!["name"])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        isNameTaken = true;
      });
    } else {
      setState(() {
        isNameTaken = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return isLoading
        ? Scaffold(
            backgroundColor: theme ? AppColors.dark : AppColors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              surfaceTintColor: AppColors.transparent,
              toolbarHeight: 80,
              backgroundColor: theme ? AppColors.dark : AppColors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dashboard",
                    style: GoogleFonts.epilogue(
                        fontSize: width * 0.02,
                        fontWeight: FontWeight.bold,
                        color: theme ? AppColors.white : AppColors.black),
                  ),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedDashboardSquare03,
                    color: theme ? AppColors.white : AppColors.black,
                    size: 18,
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
  backgroundColor: theme ? AppColors.dark : AppColors.white,
  appBar: AppBar(
    automaticallyImplyLeading: false,
    surfaceTintColor: AppColors.transparent,
    toolbarHeight: 80,
    backgroundColor: theme ? AppColors.dark : AppColors.white,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Dashboard",
          style: GoogleFonts.epilogue(
            fontSize: width * 0.02,
            fontWeight: FontWeight.bold,
            color: theme ? AppColors.white : AppColors.black,
          ),
        ),
        HugeIcon(
          icon: HugeIcons.strokeRoundedDashboardSquare03,
          color: theme ? AppColors.white : AppColors.black,
          size: 18,
        ),
      ],
    ),
  ),
  body: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: theme ? AppColors.dark.withOpacity(0.9) : AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Analysis",
                          style: GoogleFonts.epilogue(
                            fontSize: width * 0.018,
                            fontWeight: FontWeight.w500,
                            color: theme ? AppColors.white : AppColors.black,
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: DashedCircularProgressBar.aspectRatio(
                                aspectRatio: 2,
                                valueNotifier: _valueNotifier,
                                progress: 37,
                                startAngle: 225,
                                sweepAngle: 270,
                                foregroundColor: accentColor,
                                backgroundColor: const Color(0xffeeeeee),
                                foregroundStrokeWidth: 15,
                                backgroundStrokeWidth: 15,
                                animation: true,
                                seekSize: 6,
                                seekColor: const Color(0xffeeeeee),
                                child: Center(
                                  child: ValueListenableBuilder(
                                    valueListenable: _valueNotifier,
                                    builder: (_, double value, __) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${value.toInt()}%',
                                          style: GoogleFonts.epilogue(
                                            color: theme ? AppColors.white : AppColors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: width * 0.02,
                                          ),
                                        ),
                                        Text(
                                          'Progress',
                                          style: GoogleFonts.epilogue(
                                            color: theme ? AppColors.white : AppColors.dark,
                                            fontWeight: FontWeight.w400,
                                            fontSize: width * 0.01,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: DashedCircularProgressBar.aspectRatio(
                                aspectRatio: 2,
                                valueNotifier: _valueNotifier,
                                progress: 73,
                                startAngle: 225,
                                sweepAngle: 270,
                                foregroundColor: accentColor,
                                backgroundColor: const Color(0xffeeeeee),
                                foregroundStrokeWidth: 15,
                                backgroundStrokeWidth: 15,
                                animation: true,
                                seekSize: 6,
                                seekColor: const Color(0xffeeeeee),
                                child: Center(
                                  child: ValueListenableBuilder(
                                    valueListenable: _valueNotifier,
                                    builder: (_, double value, __) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${value.toInt()}%',
                                          style: GoogleFonts.epilogue(
                                            color: theme ? AppColors.white : AppColors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: width * 0.02,
                                          ),
                                        ),
                                        Text(
                                          'Deadline',
                                          style: GoogleFonts.epilogue(
                                            color: theme ? AppColors.white : AppColors.dark,
                                            fontWeight: FontWeight.w400,
                                            fontSize: width * 0.01,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: theme ? AppColors.dark.withOpacity(0.9) : AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Details",
                          style: GoogleFonts.epilogue(
                            fontSize: width * 0.018,
                            fontWeight: FontWeight.w500,
                            color: theme ? AppColors.white : AppColors.black,
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                child: Stack(
                                  children: List.generate(memberPhotos.length, (index) {
                                    return Positioned(
                                      left: index * 30.0,
                                      child: memberPhotos[index],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

  }
}
