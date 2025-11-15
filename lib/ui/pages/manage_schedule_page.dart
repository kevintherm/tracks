import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/repositories/schedule_repository.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/assign_schedule_page.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/fuzzy_search.dart';
import 'package:tracks/utils/toast.dart';

class ManageSchedulePage extends StatefulWidget {
  const ManageSchedulePage({super.key});

  @override
  State<ManageSchedulePage> createState() => _ManageSchedulePageState();
}

class _ManageSchedulePageState extends State<ManageSchedulePage> {
  final searchController = TextEditingController();
  Timer? _debounce;
  String search = "";

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  final now = DateTime.now().toUtc();

  Widget? _calendarBuild(context, day, focusedDay) {
    List<Color?> colors = [
      Colors.grey[200],
      Colors.green[200],
      Colors.green[300],
      Colors.green[500],
    ];

    Color? color = colors[0];
    Color textColor = color == Colors.green[500] ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text('${day.day}', style: TextStyle(color: textColor)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 150), () {
        setState(() {
          search = searchController.text;
        });
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleRepo = context.read<ScheduleRepository>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Pressable(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Iconsax.arrow_left_2_outline, size: 24),
                  ),
                  Text(
                    "Manage Schedule",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 1),
                ],
              ),
            ),

            TableCalendar(
              firstDay: DateTime.utc(now.year, now.month, 1),
              lastDay: DateTime.utc(now.year, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  if (selectedDay == _selectedDay) {
                    _selectedDay = now;
                    _focusedDay = now;
                  } else {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  }
                });
              },
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                leftChevronVisible: false,
                rightChevronIcon: Icon(Iconsax.arrow_right_3_outline),
                headerMargin: EdgeInsets.only(left: 16),
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  if (day.weekday == DateTime.sunday) {
                    final text = DateFormat.E().format(day);

                    return Center(
                      child: Text(text, style: TextStyle(color: Colors.red)),
                    );
                  }

                  return null;
                },
                // outsideBuilder: _calendarBuild,
                defaultBuilder: _calendarBuild,
                todayBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 0),
                      Text(
                        DateFormat("dd MMM, y").format(_selectedDay ?? now),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Tooltip(
                        message: 'Assign a schedule to this day',
                        child: Pressable(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AssignSchedulePage(
                                  selectedDate: _selectedDay ?? now,
                                ),
                              ),
                            );
                          },
                          child: Icon(Iconsax.edit_outline),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  StreamBuilder(
                    stream: scheduleRepo.watchSchedulesForDate(
                      _selectedDay ?? now,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                                    
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Something went wrong: ${snapshot.error}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                                    
                      final List<Schedule> schedules = snapshot.data ?? [];
                      List<Schedule> filtered = schedules;
                                    
                      if (search.isNotEmpty) {
                        filtered = FuzzySearch.search(
                          items: schedules,
                          query: search,
                          getSearchableText: (e) {
                            e.workout.load();
                            return e.workout.value!.name;
                          },
                          threshold: 0.1,
                        );
                      } else {
                        filtered = schedules.toList()
                          ..sort(
                            (a, b) => b.updatedAt.compareTo(a.updatedAt),
                          );
                      }
                                    
                      if (schedules.isEmpty) {
                        return Center(
                          child: Text(
                            "No schedules available.",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }
                                    
                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            "No matching schedules found.",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }
                                    
                      return ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 1,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return Dismissible(
                            key: ValueKey(index),
                            direction: DismissDirection.horizontal,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                color: Colors.green[200],
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red[200],
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              if (direction ==
                                  DismissDirection.endToStart) {
                                Toast(
                                  context,
                                ).success(content: Text("Swipe left"));
                              } else {
                                Toast(
                                  context,
                                ).success(content: Text("Swipe right"));
                              }
                            },
                            child: Pressable(
                              onTap: () {},
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        32,
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(
                                            16.0,
                                          ),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      16,
                                                    ),
                                                child: Image.asset(
                                                  'assets/drawings/not-found.jpg',
                                                  width: 100,
                                                  height: 100,
                                                ),
                                              ),
                                    
                                              const SizedBox(width: 16),
                                    
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      "Push Up",
                                                      style:
                                                          GoogleFonts.inter(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                          ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              MingCute
                                                                  .fire_line,
                                                              size: 16,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              "32 Kkal",
                                                              style: GoogleFonts.inter(
                                                                fontSize:
                                                                    14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .grey[600],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              MingCute
                                                                  .refresh_3_line,
                                                              size: 16,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              "12x",
                                                              style: GoogleFonts.inter(
                                                                fontSize:
                                                                    14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .grey[600],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          MingCute
                                                              .barbell_line,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          "Chest, Triceps, Shoulders",
                                                          style: GoogleFonts.inter(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
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
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
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
