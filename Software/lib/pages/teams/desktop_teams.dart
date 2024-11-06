import 'package:flutter/material.dart';
import 'package:unite/constants/color/color.dart';

class DesktopTeams extends StatefulWidget {
  const DesktopTeams({super.key});

  @override
  State<DesktopTeams> createState() => _DesktopTeamsState();
}

class _DesktopTeamsState extends State<DesktopTeams> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.successColor,
    );
  }
}