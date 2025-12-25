import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracks/auth_gate.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/exercise_muscles.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/session.dart';
import 'package:tracks/models/session_exercise.dart';
import 'package:tracks/models/session_set.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/models/workout_exercises.dart';
import 'package:tracks/providers/navigation_provider.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/repositories/muscle_repository.dart';
import 'package:tracks/repositories/schedule_repository.dart';
import 'package:tracks/repositories/session_repository.dart';
import 'package:tracks/repositories/workout_repository.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/services/import_service.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracks/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PocketBaseService.initialize();

  final pb = PocketBaseService.instance.client;
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(prefs);

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      ExerciseSchema,
      MuscleSchema,
      ExerciseMusclesSchema,
      WorkoutSchema,
      WorkoutExercisesSchema,
      ScheduleSchema,
      SessionSchema,
      SessionExerciseSchema,
      SessionSetSchema,
    ],
    directory: dir.path,
    inspector: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        Provider<AuthService>.value(value: authService),
        Provider<Isar>.value(value: isar),
        Provider<SharedPreferences>.value(value: prefs),
        Provider(create: (context) => ImportService(context.read<Isar>())),

        Provider(
          create: (context) => ExerciseRepository(
            context.read<Isar>(),
            pb,
            context.read<AuthService>(),
          ),
        ),
        Provider(
          create: (context) => MuscleRepository(
            context.read<Isar>(),
            pb,
            context.read<AuthService>(),
          ),
        ),
        Provider(
          create: (context) => WorkoutRepository(
            context.read<Isar>(),
            pb,
            context.read<AuthService>(),
          ),
        ),
        Provider(
          create: (context) => ScheduleRepository(
            context.read<Isar>(),
            pb,
            context.read<AuthService>(),
          ),
        ),
        Provider(
          create: (context) => SessionRepository(
            context.read<Isar>(),
            pb,
            context.read<AuthService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tracks',
      themeMode: ThemeMode.light,
      theme: _buildLightTheme(context),
      darkTheme: _buildDarkTheme(context),
      home: const AuthGate(),
    );
  }

  ThemeData _buildLightTheme(BuildContext context) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.lightPrimary),
      textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      scaffoldBackgroundColor: Colors.grey[100],
      cardColor: Colors.white,
      cardTheme: const CardThemeData(color: Colors.white),
    );
  }

  ThemeData _buildDarkTheme(BuildContext context) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
    );
  }
}
