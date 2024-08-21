import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unite/auth/login/desktop_login.dart';
import 'package:unite/constants/color/color.dart';

class DesktopProjects extends StatefulWidget {
  const DesktopProjects({super.key});

  @override
  State<DesktopProjects> createState() => _DesktopProjectsState();
}

class _DesktopProjectsState extends State<DesktopProjects> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = false;

  void getDetails() async {
    setState(() {
      isLoading = true;
    });
    final data = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: user!.email).get();

    for(var docs in data.docs){
      setState(() {
        userData = docs.data();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? const Scaffold(
      body: Center(
        child: CircularProgressIndicator( color: AppColors.warningColor,),
      ),
    ) :  Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(userData!["name"]),
        actions: [
          IconButton(onPressed: (){
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DesktopLogin()));
          }, icon: const Icon(Icons.logout))
        ],
      ),
    );
  }
}
