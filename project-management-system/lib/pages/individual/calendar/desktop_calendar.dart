import 'package:calendar_view/calendar_view.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:unite/components/textfield/textfield.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';
import 'package:unite/models/note.dart';
import 'package:uuid/uuid.dart';

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

  Stream<List<Note>> fetchNotesForDate(String formattedDate) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userData!["username"])
        .collection("Calendar")
        .where('date', isEqualTo: formattedDate)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromMap(doc.id, doc.data()))
            .toList());
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

                            // Check if the selected date is today or in the future
                            if (selectedDate.isAtSameMomentAs(DateTime.now()) ||
                                selectedDate.isBefore(DateTime.now().subtract(
                                    Duration(
                                        hours: DateTime.now().hour,
                                        minutes: DateTime.now().minute,
                                        seconds: DateTime.now().second)))) {
                            } else {
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
                          }
                        },
                        monthCellBuilder:
                            (BuildContext context, MonthCellDetails details) {
                          return StreamBuilder<List<Note>>(
                            stream: fetchNotesForDate(
                                DateFormat('yyyy-MM-dd').format(details.date)),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: accentColor,
                                  ),
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
                                    const SizedBox(height: 10),
                                    // Display notes if available
                                    if (notes.isNotEmpty)
                                      Text(
                                        "(${notes.length.toString()})", // Show the count of notes
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

class CreateNoteState extends State<CreateNote>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isUsernameTaken = false;
  List<String> options = [];
  final Uuid uuid = const Uuid();
  List<String> tags = [];
  TextEditingController _date = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _title = TextEditingController();
  List<Note> notes = []; // To store the notes for the selected date

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this); // Two tabs: Create and View Notes
    setState(() {
      options.add(widget.userData!["username"]);
      _date.text = DateFormat('yyyy-MM-dd').format(widget.date);
    });
    fetchNotesForDate();
  }

  // Function to fetch notes for the current date
  Future<void> fetchNotesForDate() async {
    final notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userData!["username"])
        .collection("Calendar");
    final snapshot =
        await notesCollection.where('date', isEqualTo: _date.text).get();
    setState(() {
      notes = snapshot.docs
          .map(
              (doc) => Note.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Add note to Firestore
  Future<void> addNoteToFirestore(Note note) async {
    final notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userData!["username"])
        .collection("Calendar");
    await notesCollection.add(note.toMap());
  }

  void deleteNote(String title, String content) async {
    final notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userData!["username"])
        .collection("Calendar");

    // Query for documents with the matching date
    final querySnapshot = await notesCollection
        .where("title", isEqualTo: title)
        .where("content", isEqualTo: content)
        .get();

    // Check if there are any documents that match the query
    if (querySnapshot.docs.isNotEmpty) {
      // Iterate through the documents and delete them
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      // Optionally show a success message or update the UI
    } else {
      // No notes found for the specified date
      print("No notes found for the given date.");
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
      body: Container(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
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
                    const SizedBox(height: 15),
                    Text(
                      "Tasks (${_date.text})",
                      style: GoogleFonts.epilogue(
                        color: theme ? AppColors.white : AppColors.black,
                        fontSize: width * 0.017,
                        fontWeight: FontWeight.w700,
                      ),
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
            const SizedBox(height: 20),
            // TabBar for switching between "Create Note" and "View Notes"
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "View"),
                Tab(text: "Create"),
              ],
              indicatorColor: accentColor,
              labelColor: accentColor,
              unselectedLabelColor: theme ? Colors.white : Colors.black,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // View Notes Tab
                  // if (notes.length == 0)
                  //   Center(
                  //     child: Text(
                  //       "Add task.",
                  //       style: GoogleFonts.epilogue(
                  //         color: theme ? AppColors.white : AppColors.dark,
                  //       ),
                  //     ),
                  //   ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userData!["username"])
                        .collection("Calendar")
                        .where("date", isEqualTo: _date.text)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "No tasks for this date.",
                            style: GoogleFonts.epilogue(
                              color: theme ? AppColors.white : AppColors.dark,
                            ),
                          ),
                        );
                      }
                      final notes = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return ListTile(
                            title: Text(
                              note['title'],
                              style: GoogleFonts.epilogue(
                                color: theme ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              note['content'],
                              style: GoogleFonts.epilogue(
                                color: theme ? Colors.white : Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            trailing: IconButton(
                              tooltip: "Delete",
                              onPressed: () async {
                                deleteNote(note["title"], note["content"]);
                              },
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedDelete04,
                                color: AppColors.errorColor,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Create Note Tab
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        CustomTextFormField(
                          isDark: theme,
                          labelText: "Title",
                          controller: _title,
                        ),
                        const SizedBox(height: 15),
                        CustomTextFormField(
                          isDark: theme,
                          controller: _description,
                          maxLines: 3,
                          maxLength: 250,
                          labelText: "Description",
                        ),
                        const SizedBox(height: 15),
                        CustomTextFormField(
                          readOnly: true,
                          isDark: theme,
                          controller: _date,
                          labelText: "Date",
                        ),
                        const SizedBox(height: 30),
                        FloatingActionButton(
                          backgroundColor: accentColor,
                          onPressed: () async {
                            if (_title.text.isEmpty &&
                                _description.text.isEmpty) {
                              CherryToast.error(
                                displayCloseButton: false,
                                toastPosition: Position.top,
                                description: Text(
                                  textAlign: TextAlign.start,
                                  "Please provide all required fields.",
                                  style:
                                      GoogleFonts.epilogue(color: Colors.black),
                                ),
                                animationType: AnimationType.fromTop,
                                animationDuration:
                                    const Duration(milliseconds: 1000),
                                autoDismiss: true,
                              ).show(context);
                            } else {
                              final note = Note(
                                content: _description.text,
                                id: uuid.v4(),
                                title: _title.text,
                                date: _date.text,
                              );
                              await addNoteToFirestore(
                                  note); // Add note to Firestore
                              fetchNotesForDate(); // Refresh the list of notes
                              Navigator.pop(context); //
                            }
                          },
                          shape: const CircleBorder(),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedTick02,
                            color: AppColors.black,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
