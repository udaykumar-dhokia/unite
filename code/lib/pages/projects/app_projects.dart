import 'package:flutter/material.dart';
import 'package:unite/constants/color/color.dart';

class AppProjects extends StatefulWidget {
  const AppProjects({super.key});

  @override
  State<AppProjects> createState() => _AppProjectsState();
}

class _AppProjectsState extends State<AppProjects> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.successColor,
    );
  }
}