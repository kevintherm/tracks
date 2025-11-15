import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/repositories/schedule_repository.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/single_row_calendar_pager.dart';
import 'package:tracks/ui/pages/assign_schedule_page.dart';
import 'package:tracks/ui/pages/manage_schedule_page.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/fuzzy_search.dart';
import 'package:tracks/utils/toast.dart';

class ScheduleFragment extends StatefulWidget {
  const ScheduleFragment({super.key});

  @override
  State<ScheduleFragment> createState() => _ScheduleFragmentState();
}

class _ScheduleFragmentState extends State<ScheduleFragment> {
  final searchController = TextEditingController();
  Timer? _debounce;
  String search = "";

  DateTime selectedDate = DateTime.now();

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
              Tooltip(
                message: 'Manage schedule and see \npast session history.',
                child: Pressable(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageSchedulePage(),
                      ),
                    );
                  },
                  child: Icon(Iconsax.setting_outline, size: 32),
                ),
              ),
            ],
          ),
        ),

        SingleRowCalendarPager(
          showNavigation: false,
          showMonthLabel: false,
          onDateSelected: (value) {
            setState(() {
              selectedDate = value;
            });
          },
          selectedDate: selectedDate,
          initialStartDate: DateTime.utc(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day - 2,
          ),
        ),

        _SearchBar(controller: searchController),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder(
              stream: scheduleRepo.watchSchedulesForDate(selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final schedule = filtered[index];
                    final workout = schedule.workout.value!;

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
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red[200],
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          Toast(context).success(content: Text("Delete"));
                          return false;
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AssignSchedulePage(schedule: schedule),
                            ),
                          );
                          return false;
                        }
                      },
                      child: Pressable(
                        onTap: () {},
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: Colors.white,
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: getImage(
                                            workout.thumbnailFallback,
                                            width: 80,
                                            height: 80,
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                workout.name,
                                                style: GoogleFonts.inter(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        MingCute.fire_line,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '32 Kkal',
                                                        style:
                                                            GoogleFonts.inter(
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
                                                  const SizedBox(width: 16),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        MingCute.refresh_3_line,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        "12x",
                                                        style:
                                                            GoogleFonts.inter(
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
                                              Row(
                                                children: [
                                                  Icon(
                                                    MingCute.barbell_line,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    workout.excerpt,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey[600],
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
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: const Icon(Iconsax.search_normal_1_outline, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 250),
                    child: Text(
                      'Searching for `${controller.text}`',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  Pressable(
                    onTap: () {
                      controller.text = "";
                      FocusScope.of(context).unfocus();
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
