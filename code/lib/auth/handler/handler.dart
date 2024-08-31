import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unite/auth/login/app_login.dart';
import 'package:unite/auth/login/desktop_login.dart';
import 'package:unite/components/sidepanel/sidepanel.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/pages/projects/app_projects.dart';
import 'package:unite/responsive/layout/responsive_layout.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              color: Colors.black,
            );
          } else {
            if (snapshot.hasData) {
              return ResponsiveLayout(desktopWidget: const SidePanel(), mobileWidget: const AppProjects());
            } else {
              return  ResponsiveLayout(desktopWidget: const DesktopLogin(), mobileWidget: const AppLogin(),);
            }
          }
        },
      ),
    );
  }
}
