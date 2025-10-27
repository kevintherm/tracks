import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/utils/app_colors.dart';

class ScheduleFragment extends StatefulWidget {
  const ScheduleFragment({super.key});

  @override
  State<ScheduleFragment> createState() => _ScheduleFragmentState();
}

class _ScheduleFragmentState extends State<ScheduleFragment> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Schedule",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Pressable(
                onTap: () {},
                child: Icon(Iconsax.weight_1_outline, size: 32),
              ),
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
            todayBuilder: _calendarBuild,
            selectedBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
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
              Text(
                "24 October, 2025",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300]!,
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.grey[200]!,
                      offset: const Offset(0, -1),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Push Day",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Iconsax.arrow_right_3_outline, size: 24),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Iconsax.clock_outline, size: 24),
                          const SizedBox(width: 8),
                          Text("Duration: ~1.5 hours"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(
                                alpha: 0.25,
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 12,
                              ),
                              child: Text(
                                "24 Oct, 2025",
                                style: GoogleFonts.inter(
                                  color: AppColors.darkSecondary,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                          Text("💀", style: GoogleFonts.inter(fontSize: 24)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
