import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kickr_flutter/bloc/ride_bloc.dart';
import 'package:kickr_flutter/bloc/ride_event.dart';
import 'package:kickr_flutter/bloc/ride_state.dart';
import 'package:kickr_flutter/bluetooth/ftms_service.dart';
import 'package:kickr_flutter/gpx/course.dart';
import 'package:kickr_flutter/highscore/high_score_repository.dart';
import 'package:kickr_flutter/ui/widgets/elevation_profile_chart.dart';
import 'package:kickr_flutter/ui/widgets/ride_stats_widget.dart';

class RideScreen extends StatelessWidget {
  final Course course;
  final bool isSimulated;

  const RideScreen({
    super.key,
    required this.course,
    this.isSimulated = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RideBloc(
        context.read<FtmsService>(),
        context.read<HighScoreRepository>(),
      )..add(StartRide(
          course: course,
          userWeight: 75.0, // TODO: Get from user input
          isSimulated: isSimulated,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: Text(course.name),
        ),
        body: BlocConsumer<RideBloc, RideState>(
          listener: (context, state) {
            if (state is RideFinished) {
              _showRideFinishedDialog(context, state);
            }
          },
          builder: (context, state) {
            if (state is RideInProgress) {
              return Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevationProfileChart(
                      course: course,
                      userRideState: state.userRideState,
                      pacerRideState: state.simulatedRideState,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: RideStatsWidget(rideState: state.userRideState),
                  ),
                ],
              );
            }
            if (state is RideError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _showRideFinishedDialog(BuildContext context, RideFinished state) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (dialogContext) {
        final rideBloc = context.read<RideBloc>();
        return AlertDialog(
          title: Text(state.isNewHighScore ? 'New High Score!' : 'Ride Finished!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Your time: ${state.finalTime.inMinutes}:${(state.finalTime.inSeconds % 60).toString().padLeft(2, '0')}'),
              if (state.isNewHighScore) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your name',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ],
          ),
          actions: [
            if (state.isNewHighScore)
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    rideBloc.add(
                      SaveHighScore(
                        courseName: course.name,
                        userName: nameController.text,
                        time: state.finalTime,
                      ),
                    );
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop(); // Go back to course selection
                  }
                },
                child: const Text('Save'),
              )
            else
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop(); // Go back to course selection
                },
                child: const Text('OK'),
              ),
          ],
        );
      },
    );
  }
}