import 'package:flutter/material.dart';
import 'package:unite/constants/color/color.dart';

class DesktopProjects extends StatefulWidget {
  const DesktopProjects({super.key});

  @override
  State<DesktopProjects> createState() => _DesktopProjectsState();
}

class _DesktopProjectsState extends State<DesktopProjects> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.successColor,
    );
  }
}