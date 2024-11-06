import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unite/auth/login/app_login.dart';
import 'package:unite/auth/login/desktop_login.dart';
import 'package:unite/components/sidepanel/sidepanel.dart';
import 'package:unite/components/sidepanel/company_sidepanel.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/pages/individual/projects/app_projects.dart';
import 'package:unite/responsive/layout/responsive_layout.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  Future<bool> _isCompanyUser(String email) async {
    // Check if the current user's email exists in the 'company' collection
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('company').doc(email).get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          User? user = FirebaseAuth.instance.currentUser;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          } else {
            if (snapshot.hasData) {
              // If user is logged in, check if they are in the company collection
              return FutureBuilder<bool>(
                future: _isCompanyUser(user!.email!),
                builder: (context, companySnapshot) {
                  if (companySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    );
                  } else if (companySnapshot.hasData &&
                      companySnapshot.data == true) {
                    // User is a company user
                    return ResponsiveLayout(
                      desktopWidget: const CompanySidePanel(),
                      mobileWidget: const AppProjects(),
                    );
                  } else {
                    // Regular user
                    return ResponsiveLayout(
                      desktopWidget: const SidePanel(),
                      mobileWidget: const AppProjects(),
                    );
                  }
                },
              );
            } else {
              // If no user is logged in, show login screens
              return ResponsiveLayout(
                desktopWidget: const DesktopLogin(),
                mobileWidget: const AppLogin(),
              );
            }
          }
        },
      ),
    );
  }
}
