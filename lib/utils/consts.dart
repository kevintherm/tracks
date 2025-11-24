import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:timeago/timeago.dart' as timeago;

const String env = "local";
const String appName = "Factual";
const String appVersion = "0.0.1";
const String backendUrlAndroid = 'http://10.0.2.2:8090';
const String fatalError = "Oops, something went wrong. Please try again later.";
const String defaultAvatar = 'https://i.pravatar.cc/300';
const Duration snackBarShort = Duration(seconds: 1, milliseconds: 500);
const Duration snackBarMedium = Duration(seconds: 3);
const Duration snackBarLong = Duration(seconds: 5);

String errorClient(ClientException e) {
  log(e.toString());
  if (env == 'production') return fatalError;

  return e.response['message'] ?? fatalError;
}

String errorFatal(Exception e) {
  log(e.toString());

  return fatalError;
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  String? title,
  String? text,
}) async {
  return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title ?? 'Confirm'),
          content: Text(text ?? 'Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            PrimaryButton(
              onTap: () => Navigator.of(context).pop(true),
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ) ??
      false;
}

Widget getImage(String? imagePath, {double width = 100, double height = 100}) {
  final hasLocalImage = imagePath != null && File(imagePath).existsSync();

  Image image = Image.asset(
    'assets/drawings/not-found.jpg',
    width: width,
    height: height,
    fit: BoxFit.cover,
  );

  if (hasLocalImage) {
    image = Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => image,
    );
  }

  return image;
}

Widget getImageColage(
  List<String> imagesPath, {
  double width = 100,
  double height = 100,
}) {
  final images = <String>[];

  for (final path in imagesPath) {
    if (File(path).existsSync()) {
      images.add(path);
    }
  }

  while (images.length < 3) {
    images.add('assets/drawings/not-found.jpg');
  }

  return SizedBox(
    width: width,
    height: height,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: getImage(images[0], width: width, height: height),
          ),
          Flexible(
            flex: 1,
            child: Column(
              children: [
                Expanded(child: getImage(images[1])),
                Expanded(child: getImage(images[2])),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget getWorkoutColage(
  Workout workout, {
  double width = 100,
  double height = 100,
}) {
  final images = <String>[];

  images.add(workout.thumbnailFallback);

  if (workout.exercises.isNotEmpty) {
    images.addAll(
      workout.exercises
          .map((e) => e.thumbnailLocal ?? '')
          .where((t) => t.isNotEmpty)
          .take(3)
          .toList(),
    );
  }

  while (images.length < 3) {
    images.add(workout.thumbnailFallback);
  }

  return getImageColage(images, width: width, height: height);
}

File? getFile(String? filePath) {
  final exists = filePath != null && File(filePath).existsSync();

  return exists ? File(filePath) : null;
}

extension StringCap on String {
  String capitalize() {
    return split(
      ' ',
    ).map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}

bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

enum PBCollections {
  schedules("schedules"),
  workoutExercises("workout_exercises"),
  workouts("workouts"),
  exercises("exercises"),
  muscles("muscles"),
  exerciseMuscles("exercise_muscles");

  final String value;
  const PBCollections(this.value);
}

String dateFormat(DateTime date) {
  return DateFormat('EEEE dd MMM, y').format(date);
}

String timeFormat(DateTime date) {
  return DateFormat('H:mm').format(date);
}

String dateToHumans(DateTime date, {DateTime? from}) {
  from = from ?? DateTime.now();
  return timeago.format(
    date,
    allowFromNow: true,
    clock: from,
    // locale: "en_short",
  );
}

extension DateFormatExt on DateTime {
  String get yMMMd => DateFormat.yMMMd().format(this);

  String get md => DateFormat.MMMd().format(this);
}

extension DurationFormat on Duration {
  String get hhmmss {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(inHours);
    final m = two(inMinutes.remainder(60));
    final s = two(inSeconds.remainder(60));
    return "$h:$m:$s";
  }

  String get mmss {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(inMinutes);
    final s = two(inSeconds.remainder(60));
    return "$m:$s";
  }

  String get hM {
    final h = inHours;
    final m = inMinutes.remainder(60);

    if (h > 0 && m > 0) return "${h}h${m}m";
    if (h > 0) return "${h}h";
    return "${m}m";
  }
}

extension OrdinalExt on int {
  String get ordinal {
    final mod10 = this % 10;
    final mod100 = this % 100;

    if (mod10 == 1 && mod100 != 11) return "${this}st";
    if (mod10 == 2 && mod100 != 12) return "${this}nd";
    if (mod10 == 3 && mod100 != 13) return "${this}rd";
    return "${this}th";
  }
}