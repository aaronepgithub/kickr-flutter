import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kickr_flutter/bloc/course_selection_bloc.dart';
import 'package:kickr_flutter/bloc/course_selection_event.dart';
import 'package:kickr_flutter/bloc/course_selection_state.dart';
import 'package:kickr_flutter/bluetooth/ftms_service.dart';
import 'package:kickr_flutter/gpx/course.dart';
import 'package:kickr_flutter/gpx/course_repository.dart';
import 'package:kickr_flutter/highscore/high_score_repository.dart';
import 'package:kickr_flutter/ui/screens/ride_screen.dart';

class CourseSelectionScreen extends StatelessWidget {
  const CourseSelectionScreen({super.key});

  void _onCourseSelected(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Ride Type'),
        content: const Text('How would you like to ride?'),
        actions: [
          TextButton(
            child: const Text('Simulated Ride'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RideScreen(course: course, isSimulated: true),
                ),
              );
            },
          ),
          TextButton(
            child: const Text('Real Ride'),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final ftmsService = context.read<FtmsService>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              final connected = await ftmsService.connect();

              if (connected) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RideScreen(course: course),
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Could not connect to a trainer. Please ensure it is available and try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseSelectionBloc(
        context.read<CourseRepository>(),
        context.read<HighScoreRepository>(),
      )..add(LoadCourses()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select a Course'),
        ),
        body: BlocBuilder<CourseSelectionBloc, CourseSelectionState>(
          builder: (context, state) {
            if (state is CoursesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CoursesLoaded) {
              return ListView.builder(
                itemCount: state.courses.length,
                itemBuilder: (context, index) {
                  final course = state.courses[index];
                  final highScore = state.highScores[course.name];
                  final time = highScore != null
                      ? Duration(seconds: highScore.timeInSeconds)
                      : null;

                  return ListTile(
                    title: Text(course.name),
                    subtitle: Text(
                        '${(course.totalDistance / 1000).toStringAsFixed(2)} km\n'
                        '${highScore != null ? '🏆 ${highScore.userName} - ${time!.inMinutes}:${(time.inSeconds % 60).toString().padLeft(2, '0')}' : 'No high score yet'}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        context
                            .read<CourseSelectionBloc>()
                            .add(DeleteCourse(course.name));
                      },
                    ),
                    onTap: () => _onCourseSelected(context, course),
                  );
                },
              );
            }
            if (state is CoursesError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No courses found.'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['gpx'],
              withData: true,
            );

            if (result != null && result.files.single.bytes != null) {
              final fileBytes = result.files.single.bytes!;
              final fileName = result.files.single.name;
              final gpxString = String.fromCharCodes(fileBytes);

              // ignore: use_build_context_synchronously
              context
                  .read<CourseSelectionBloc>()
                  .add(AddCourse(fileName, gpxString));
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}