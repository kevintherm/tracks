import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';

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

Widget getImage(String? imagePath) {
  final hasLocalImage = imagePath != null && File(imagePath).existsSync();

  Image image = Image.asset(
    'assets/drawings/not-found.jpg',
    width: 100,
    height: 100,
    fit: BoxFit.cover,
  );

  if (hasLocalImage) {
    image = Image.file(
      File(imagePath),
      width: 100,
      height: 100,
      fit: BoxFit.cover,
    );
  }

  return image;
}

enum PBCollections {
  workoutExercises("workoutExercises"),
  workouts("workouts"),
  exercises("exercises"),
  muscles("muscles"),
  exerciseMuscles("exercise_muscles");

  final String value;
  const PBCollections(this.value);
}
