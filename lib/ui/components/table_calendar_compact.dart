import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracks/utils/app_colors.dart';

class TableCalendarCompact extends StatefulWidget {
  final List<DateTime> selectedDates;
  final ValueChanged<List<DateTime>>? onSelectionChanged;

  const TableCalendarCompact({
    super.key,
    this.selectedDates = const [],
    this.onSelectionChanged,
  });

  @override
  State<TableCalendarCompact> createState() => _TableCalendarCompactState();
}

class _TableCalendarCompactState extends State<TableCalendarCompact> {
  DateTime _focusedDay = DateTime.now();
  late List<DateTime> _selectedDates;

  final now = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    _selectedDates = List.from(widget.selectedDates);
  }

  bool _isDateSelected(DateTime day) {
    return _selectedDates.any(
      (selectedDate) =>
          selectedDate.year == day.year &&
          selectedDate.month == day.month &&
          selectedDate.day == day.day,
    );
  }

  void _toggleDateSelection(DateTime day) {
    setState(() {
      if (_isDateSelected(day)) {
        _selectedDates.removeWhere(
          (selectedDate) =>
              selectedDate.year == day.year &&
              selectedDate.month == day.month &&
              selectedDate.day == day.day,
        );
      } else {
        _selectedDates.add(day);
      }
    });
    widget.onSelectionChanged?.call(_selectedDates);
  }

  Widget? _calendarBuild(context, day, focusedDay) {
    final isSelected = _isDateSelected(day);
    final isToday = isSameDay(day, DateTime.now());

    return GestureDetector(
      onTap: () => _toggleDateSelection(day),
      child: Container(
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : isToday
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : isToday
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(now.year, now.month, 1),
      lastDay: DateTime.utc(now.year, now.month + 1, 0),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => _isDateSelected(day),
      onDaySelected: (selectedDay, focusedDay) {
        _toggleDateSelection(selectedDay);
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      daysOfWeekHeight: 32,
      rowHeight: 40,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(
          Iconsax.arrow_left_2_outline,
          size: 20,
          color: AppColors.primary,
        ),
        rightChevronIcon: Icon(
          Iconsax.arrow_right_3_outline,
          size: 20,
          color: AppColors.primary,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headerPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
        weekendStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.red[300],
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        cellMargin: const EdgeInsets.all(2),
      ),
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          final text = DateFormat.E().format(day)[0];
          final isWeekend =
              day.weekday == DateTime.saturday ||
              day.weekday == DateTime.sunday;

          return Center(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isWeekend ? Colors.red[300] : Colors.grey[600],
              ),
            ),
          );
        },
        defaultBuilder: _calendarBuild,
        todayBuilder: (context, day, focusedDay) {
          final isSelected = _isDateSelected(day);
          return GestureDetector(
            onTap: () => _toggleDateSelection(day),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.lightPrimary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
          );
        },
        selectedBuilder: (context, day, focusedDay) {
          return GestureDetector(
            onTap: () => _toggleDateSelection(day),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
