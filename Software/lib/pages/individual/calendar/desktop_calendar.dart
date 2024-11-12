import 'package:calendar_view/calendar_view.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:unite/components/textfield/textfield.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';
import 'package:unite/models/note.dart';

class DesktopCalendar extends StatefulWidget {
  Map<String, dynamic>? themeData;
  Map<String, dynamic>? userData;
  DesktopCalendar({super.key, required this.userData, required this.themeData});

  @override
  State<DesktopCalendar> createState() => _DesktopCalendarState();
}

class _DesktopCalendarState extends State<DesktopCalendar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;

  Future<void> addNoteToFirestore(Note note) async {
    final notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userData!["username"])
        .collection("Calendar");
    await notesCollection.add(note.toMap());
  }

  Future<List<Note>> fetchNotesForDate(DateTime date) async {
    setState(() {
      isLoading = true;
    });
    final notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userData!["username"])
        .collection("Calendar");
    final snapshot = await notesCollection
        .where('date', isEqualTo: date.toIso8601String())
        .get();
    setState(() {
      isLoading = false;
    });
    return snapshot.docs
        .map((doc) => Note.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;

    return CalendarControllerProvider(
      controller: EventController(),
      child: Scaffold(
        backgroundColor:
            widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
        appBar: AppBar(
          surfaceTintColor: AppColors.transparent,
          toolbarHeight: 80,
          backgroundColor:
              widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Calendar",
                style: GoogleFonts.epilogue(
                  fontSize: width * 0.02,
                  fontWeight: FontWeight.bold,
                  color: widget.themeData!["mode"]
                      ? AppColors.white
                      : AppColors.black,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: accentColor,
            labelColor: accentColor,
            labelStyle: GoogleFonts.epilogue(),
            overlayColor:
                WidgetStateProperty.all<Color>(accentColor.withOpacity(0.2)),
            unselectedLabelColor: theme ? AppColors.white : AppColors.black,
            tabs: const [
              Tab(
                text: "Month",
              ),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          width: (width * 0.94) - 30,
          height: height,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SfCalendar(
                        onTap: (calendarTapDetails) {
                          if (calendarTapDetails.targetElement ==
                              CalendarElement.calendarCell) {
                            final DateTime selectedDate =
                                calendarTapDetails.date!;

                            SideSheet.right(
                              sheetColor: AppColors.transparent,
                              barrierColor: theme
                                  ? AppColors.grey.withOpacity(0.1)
                                  : AppColors.black.withOpacity(0.3),
                              width: width * 0.4,
                              context: context,
                              body: CreateNote(
                                userData: widget.userData,
                                themeData: widget.themeData,
                                date: selectedDate,
                              ),
                            );
                          }
                        },
                        monthCellBuilder:
                            (BuildContext context, MonthCellDetails details) {
                          return FutureBuilder<List<Note>>(
                            future: fetchNotesForDate(details.date),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final notes = snapshot.data ?? [];
                              bool isToday = details.date.year ==
                                      DateTime.now().year &&
                                  details.date.month == DateTime.now().month &&
                                  details.date.day == DateTime.now().day;
                              Color cellBackgroundColor = isToday
                                  ? accentColor
                                  : theme
                                      ? AppColors.dark
                                      : AppColors.white;

                              return Container(
                                decoration: BoxDecoration(
                                  color: cellBackgroundColor,
                                  border: Border.all(
                                      color: theme
                                          ? Colors.white
                                          : AppColors.black,
                                      width: 0.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      details.date.day.toString(),
                                      style: GoogleFonts.epilogue(
                                        color: isToday
                                            ? AppColors.black
                                            : theme
                                                ? Colors.white
                                                : AppColors.black,
                                      ),
                                    ),
                                    // Display notes if available
                                    if (notes.isNotEmpty)
                                      Text(
                                        notes[0]
                                            .content, // Show the first note (or adjust as needed)
                                        style: GoogleFonts.epilogue(
                                            fontSize: 10,
                                            color: theme
                                                ? Colors.white
                                                : AppColors.black),
                                        textAlign: TextAlign.center,
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        view: CalendarView.month,
                        headerStyle:
                            CalendarHeaderStyle(backgroundColor: accentColor),
                        backgroundColor: AppColors.white,
                        viewHeaderStyle: ViewHeaderStyle(
                          dateTextStyle: GoogleFonts.epilogue(),
                          dayTextStyle: GoogleFonts.epilogue(),
                          backgroundColor: accentColor.withOpacity(0.2),
                        ),
                        cellBorderColor: accentColor,
                        selectionDecoration: BoxDecoration(
                          color: accentColor.withOpacity(0.2),
                        ),
                      ),
                      // SfCalendar(
                      //   view: CalendarView.week,
                      //   headerStyle:
                      //       CalendarHeaderStyle(backgroundColor: accentColor),
                      //   backgroundColor: AppColors.white,
                      // ),
                      // SfCalendar(
                      //   view: CalendarView.timelineDay,
                      //   headerStyle:
                      //       CalendarHeaderStyle(backgroundColor: accentColor),
                      //   backgroundColor: AppColors.white,
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateNote extends StatefulWidget {
  CreateNote({
    super.key,
    required this.userData,
    required this.themeData,
    required this.date,
  });

  Map<String, dynamic>? themeData;
  Map<String, dynamic>? userData;
  final DateTime date;
  @override
  State<CreateNote> createState() => CreateNoteState();
}

class CreateNoteState extends State<CreateNote> {
  bool isUsernameTaken = false;
  List<String> options = [];
  List<String> tags = [];

  TextEditingController _date = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _title = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      options.add(widget.userData!["username"]);
      _date.text = widget.date.toString();
    });
  }

  Future<int> createTeam() async {
    try {
      final data = {
        "name": _title.text,
        "description": _description.text,
        "lead": widget.userData!["username"],
        "members": options,
        "createdAt":
            "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
      };
      await FirebaseFirestore.instance.collection("teams").add(data);
      return 1;
    } catch (e) {
      return 0;
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
            if (_title.text.isEmpty && _description.text.isEmpty) {
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
              int result = await createTeam();
              if (result == 0) {
                CherryToast.error(
                        displayCloseButton: false,
                        toastPosition: Position.top,
                        description: Text(
                          textAlign: TextAlign.start,
                          "Failed to create Team.",
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
                          "Successfully create the Team.",
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
                      icon: HugeIcons.strokeRoundedTask01,
                      color: accentColor,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Create Tasks",
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
              labelText: "Title",
              controller: _title,
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
              controller: _date,
              labelText: "Date",
            ),
          ],
        ),
      ),
    );
  }
}
