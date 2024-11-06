import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';

class Discussion extends StatefulWidget {
  final String id;
  final Map<String, dynamic> userData;
  const Discussion({super.key, required this.id, required this.userData});

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  TextEditingController msg = TextEditingController();

  Future<void> sendMsg(String message) async {
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.id)
        .collection('chat')
        .add({
      'name': widget.userData["name"],
      'username': widget.userData['username'],
      'time': Timestamp.now(),
      'message': message,
    }).then((value) {
      msg.clear();
    }).catchError((error) {
      print(error.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;
    return Scaffold(
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
              "Discussion",
              style: GoogleFonts.epilogue(
                  fontSize: width * 0.02,
                  fontWeight: FontWeight.bold,
                  color: theme ? AppColors.white : AppColors.black),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedChatting01,
              color: theme ? AppColors.white : AppColors.black,
              size: 18,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: TextFormField(
              maxLines: 10,
              minLines: 1,
              controller: msg,
              style: GoogleFonts.epilogue(),
              cursorColor: theme ? AppColors.dark : AppColors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme ? AppColors.white : AppColors.dark,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme ? AppColors.white : AppColors.black,
                    width: 1,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme ? AppColors.white : AppColors.black,
                    width: 1,
                  ),
                ),
                hintText: "Write your message",
                hintStyle: GoogleFonts.epilogue(
                    color: theme ? AppColors.dark : AppColors.white),
                suffixIcon: InkWell(
                  onTap: () {
                    if (msg.text.isEmpty) {
                      CherryToast.error(
                              displayCloseButton: false,
                              toastPosition: Position.top,
                              description: Text(
                                textAlign: TextAlign.start,
                                "Please type a message",
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
                      print(widget.id);
                      sendMsg(msg.text);
                    }
                  },
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCircleArrowUp01,
                    color: theme ? AppColors.dark : AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("projects")
                .doc(widget.id)
                .collection("chat")
                .orderBy("time",
                    descending: false) // Sort by time in ascending order
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No messages found',
                    style: GoogleFonts.epilogue(
                        color: theme ? AppColors.white : AppColors.black),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshot.data!.docs[index];
                  bool isCurrentUser = documentSnapshot['username'] ==
                      widget.userData["username"];

                  return Flexible(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            width: 1,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                      margin: const EdgeInsets.only(
                          left: 10.0, right: 10, bottom: 10),
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                documentSnapshot["name"],
                                style: GoogleFonts.epilogue(
                                  color: isCurrentUser
                                      ? accentColor
                                      : AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                    "@${documentSnapshot["username"]}  ${DateFormat('hh:mm a').format((documentSnapshot['time'] as Timestamp).toDate())}",
                                    style: GoogleFonts.epilogue(
                                        color: Colors.grey[400])),
                              )
                            ],
                          ),
                          Container(
                              margin: const EdgeInsets.only(top: 5.0),
                              child: Text(documentSnapshot['message'],
                                  style: GoogleFonts.epilogue(
                                      color: Colors.white))),
                          // Container(
                          //   margin: const EdgeInsets.only(top: 10.0),
                          //   child: Row(
                          //     mainAxisAlignment:
                          //         MainAxisAlignment.spaceBetween,
                          //     children: <Widget>[
                          //       Row(
                          //         children: <Widget>[
                          //           const Icon(Icons.message,
                          //               color: Colors.white),
                          //           Container(
                          //             margin:
                          //                 const EdgeInsets.only(left: 3.0),
                          //             child: const Text("15",
                          //                 style: TextStyle(
                          //                     color: Colors.white)),
                          //           )
                          //         ],
                          //       ),
                          //       Row(
                          //         children: <Widget>[
                          //           const Icon(Icons.repeat,
                          //               color: Colors.white),
                          //           Container(
                          //             margin:
                          //                 const EdgeInsets.only(left: 3.0),
                          //             child: const Text("15",
                          //                 style: TextStyle(
                          //                     color: Colors.white)),
                          //           )
                          //         ],
                          //       ),
                          //       Row(
                          //         children: <Widget>[
                          //           const Icon(Icons.favorite_border,
                          //               color: Colors.white),
                          //           Container(
                          //             margin:
                          //                 const EdgeInsets.only(left: 3.0),
                          //             child: const Text("15",
                          //                 style: TextStyle(
                          //                     color: Colors.white)),
                          //           )
                          //         ],
                          //       ),
                          //       const Icon(Icons.share, color: Colors.white)
                          //     ],
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          )),
        ),
      ),
    );
  }
}
