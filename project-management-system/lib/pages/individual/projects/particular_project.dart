import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';

class ParticularProject extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic>? themeData;
  const ParticularProject(
      {super.key, required this.data, required this.themeData});

  @override
  State<ParticularProject> createState() => _ParticularProjectState();
}

class _ParticularProjectState extends State<ParticularProject> {
  @override
  Widget build(BuildContext context) {
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;
    return Scaffold(
      backgroundColor:
          widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.transparent,
        toolbarHeight: 80,
        title: Container(
          padding: const EdgeInsets.only(
            top: 15,
            bottom: 15,
            left: 10,
            right: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: accentColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Dashboard",
                  style: GoogleFonts.epilogue(
                    fontSize: 18,
                    color: theme ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
              const HugeIcon(
                icon: HugeIcons.strokeRoundedDashboardSquare03,
                color: AppColors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              const HugeIcon(
                icon: HugeIcons.strokeRoundedAppleReminder,
                color: AppColors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              const HugeIcon(
                icon: HugeIcons.strokeRoundedFolder02,
                color: AppColors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
