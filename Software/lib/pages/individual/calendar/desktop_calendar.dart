import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
              // Tab(
              //   text: "Week",
              // ),
              // Tab(
              //   text: "Day",
              // ),
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
                        monthCellBuilder:
                            (BuildContext context, MonthCellDetails details) {
                          DateTime today = DateTime.now();
                          bool isToday = details.date.year == today.year &&
                              details.date.month == today.month &&
                              details.date.day == today.day;
                          Color cellBackgroundColor = isToday? accentColor : theme
                              ? AppColors.dark
                              : AppColors.white; // Example color

                          return Container(
                            decoration: BoxDecoration(
                              color:
                                  cellBackgroundColor, // Apply the custom background color
                              border: Border.all(
                                  color:theme? Colors.white : AppColors.black,
                                  width:
                                      0.5), // Optional: border around the cell
                            ),
                            child: Center(
                              child: Text(
                                details.date.day
                                    .toString(), // Display the day of the month
                                style: GoogleFonts.epilogue(
                                  color: isToday? AppColors.black : theme? Colors.white : AppColors.black,
                                ),
                              ),
                            ),
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
                      SfCalendar(
                        view: CalendarView.week,
                        headerStyle:
                            CalendarHeaderStyle(backgroundColor: accentColor),
                        backgroundColor: AppColors.white,
                      ),
                      SfCalendar(
                        view: CalendarView.timelineDay,
                        headerStyle:
                            CalendarHeaderStyle(backgroundColor: accentColor),
                        backgroundColor: AppColors.white,
                      ),
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
