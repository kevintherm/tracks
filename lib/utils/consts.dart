import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

const String env = "local";
const String appName = "Factual";
const String appVersion = "0.0.1";
const String backendUrlAndroid = 'http://10.0.2.2:8090';
const String fatalError = "Oops, something went wrong. Please try again later.";
const String defaultAvatar = 'https://i.pravatar.cc/300';
const Duration snackBarShort = Duration(seconds: 1, milliseconds: 500);
const Duration snackBarMedium = Duration(seconds: 3);
const Duration snackBarLong = Duration(seconds: 5);
const int scheduleIncludedSessionRange = 120; // 2 Hours after scheduled time
const String tracksAccountID = "1do4ojehzkmjgaj";

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

Widget getImage(
  String? imagePath, {
  String? pendingPath,
  double width = 100,
  double height = 100,
}) {
  // Shimmer placeholder
  Widget shimmerPlaceholder = Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(width: width, height: height, color: Colors.white),
  );

  // Error/fallback placeholder
  Widget errorPlaceholder = Image.asset(
    'assets/drawings/not-found.jpg',
    width: width,
    height: height,
    fit: BoxFit.cover,
  );

  // Priority 1: Check for pending local image
  final hasPendingImage = pendingPath != null && File(pendingPath).existsSync();
  if (hasPendingImage) {
    return Image.file(
      File(pendingPath),
      width: width,
      height: height,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: frame != null ? child : shimmerPlaceholder,
        );
      },
      errorBuilder: (context, error, stackTrace) => errorPlaceholder,
    );
  }

  // Priority 2: Check for network image from thumbnail (backend URL only)
  if (imagePath != null && imagePath.isNotEmpty) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => shimmerPlaceholder,
        errorWidget: (context, url, error) => errorPlaceholder,
      );
    }
  }

  // Priority 3: Fallback to not-found.jpg
  return errorPlaceholder;
}

Widget getSafeImage(
  String imagePath, {
  double width = 100,
  double height = 100,
}) {
  // Shimmer placeholder
  Widget shimmerPlaceholder = Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(width: width, height: height, color: Colors.white),
  );

  // Error/fallback placeholder
  Widget errorPlaceholder = Image.asset(
    'assets/drawings/not-found.jpg',
    width: width,
    height: height,
    fit: BoxFit.cover,
  );

  // Priority 1: Check for pending local image
  final hasPendingImage = File(imagePath).existsSync();
  if (hasPendingImage) {
    return Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: frame != null ? child : shimmerPlaceholder,
        );
      },
      errorBuilder: (context, error, stackTrace) => errorPlaceholder,
    );
  }

  log('$imagePath');

  // Priority 2: Check for network image from thumbnail (backend URL only)
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return CachedNetworkImage(
      imageUrl: imagePath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => shimmerPlaceholder,
      errorWidget: (context, url, error) => errorPlaceholder,
    );
  }

  // Priority 3: Fallback to not-found.jpg
  return errorPlaceholder;
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
          .map((e) => e.thumbnail ?? '')
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

extension CompactNumber on int {
  String toCompact() {
    if (this < 1000) return toString();

    if (this < 1000000) {
      return _format(this / 1000, 'k');
    } else {
      return _format(this / 1000000, 'M');
    }
  }

  String _format(double v, String suffix) {
    String result = v.toStringAsFixed(1).replaceAll('.', ',');
    if (result.endsWith(',0')) {
      result = result.substring(0, result.length - 2);
    }
    return '$result$suffix';
  }
}

bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

enum PBCollections {
  posts("posts"),
  trendingWorkouts("trending_workouts"),
  trendingCreators("trending_creators"),
  users("users"),
  schedules("schedules"),
  workoutExercises("workout_exercises"),
  workouts("workouts"),
  exercises("exercises"),
  muscles("muscles"),
  exerciseMuscles("exercise_muscles"),
  sessions("sessions"),
  sessionExercises("session_exercises"),
  sessionSets("session_sets");

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

String getFileName(String input) {
  if (input.isEmpty) return '';

  // Try URL first
  final uri = Uri.tryParse(input);

  if (uri != null && uri.hasScheme && uri.pathSegments.isNotEmpty) {
    return Uri.decodeComponent(uri.pathSegments.last);
  }

  // Fallback: treat as file path or filename
  final parts = input.split(RegExp(r'[\\/]+'));
  return parts.isNotEmpty ? parts.last : '';
}

String getPBURL(String? id, String? filename, String collection) {
  return PocketBaseService.instance.client.files
      .getURL(RecordModel({'id': id, 'collectionName': collection}), filename ?? '')
      .toString();
}
