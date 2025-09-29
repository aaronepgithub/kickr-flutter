import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kickr_flutter/bluetooth/ftms_service.dart';
import 'package:kickr_flutter/gpx/course_repository.dart';
import 'package:kickr_flutter/highscore/high_score_repository.dart';
import 'package:kickr_flutter/ui/screens/course_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CourseRepository>(
          create: (context) => CourseRepository(),
        ),
        RepositoryProvider<FtmsService>(
          create: (context) => FtmsService(),
        ),
        RepositoryProvider<HighScoreRepository>(
          create: (context) => HighScoreRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'KICKR Control',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const CourseSelectionScreen(),
      ),
    );
  }
}