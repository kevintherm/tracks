import 'package:flutter/material.dart';

/// Single Row Calendar Widget with optional navigation
class SingleRowCalendarPager extends StatefulWidget {
  final DateTime? initialStartDate;
  final int days;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final double height;
  final bool showNavigation;
  final bool showMonthLabel;

  const SingleRowCalendarPager({
    super.key,
    this.initialStartDate,
    this.days = 7,
    this.selectedDate,
    this.onDateSelected,
    this.height = 72,
    this.showNavigation = true,
    this.showMonthLabel = true,
  });

  @override
  State<SingleRowCalendarPager> createState() => _SingleRowCalendarPagerState();
}

class _SingleRowCalendarPagerState extends State<SingleRowCalendarPager> {
  late DateTime _currentStart;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.initialStartDate != null) {
      _currentStart = widget.initialStartDate!;
    } else {
      final now = DateTime.now();
      _currentStart = now.subtract(Duration(days: now.weekday - 1)); // Monday
    }
    _selected = widget.selectedDate;
  }

  @override
  void didUpdateWidget(covariant SingleRowCalendarPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selected = widget.selectedDate;
    }
  }

  void _nextWeek() {
    setState(() {
      _currentStart = _currentStart.add(Duration(days: widget.days));
    });
  }

  void _prevWeek() {
    setState(() {
      _currentStart = _currentStart.subtract(Duration(days: widget.days));
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekEnd = _currentStart.add(Duration(days: widget.days - 1));
    final monthLabel =
        '${_monthName(_currentStart.month)} ${_currentStart.year}${_currentStart.month != weekEnd.month ? ' - ${_monthName(weekEnd.month)} ${weekEnd.year}' : ''}';

    final today = DateTime.now();
    final cells = List<DateTime>.generate(
      widget.days,
      (i) => _currentStart.add(Duration(days: i)),
    );

    return Column(
      children: [
        // Header with back/next buttons and month label
        if (widget.showNavigation || widget.showMonthLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.showNavigation)
                  IconButton(
                    onPressed: _prevWeek,
                    icon: const Icon(Icons.chevron_left, size: 32),
                  )
                else
                  const SizedBox(width: 48),
                if (widget.showMonthLabel)
                  Text(
                    monthLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (widget.showNavigation)
                  IconButton(
                    onPressed: _nextWeek,
                    icon: const Icon(Icons.chevron_right, size: 32),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),

        // The single-row calendar
        SizedBox(
          height: widget.height,
          child: Table(
            columnWidths: {
              for (int i = 0; i < widget.days; i++) i: const FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: cells.map((date) {
                  final isToday = _isSameDate(date, today);
                  final isSelected =
                      _selected != null && _isSameDate(date, _selected!);

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selected = date);
                      widget.onDateSelected?.call(date);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.15),
                        ),
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.12)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekdayShort(date.weekday),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.16)
                                  : null,
                            ),
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekdayShort(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1) % 7];
  }

  String _monthName(int m) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[m - 1];
  }
}
