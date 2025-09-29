import 'package:equatable/equatable.dart';
import 'package:kickr_flutter/gpx/course.dart';

abstract class RideEvent extends Equatable {
  const RideEvent();

  @override
  List<Object> get props => [];
}

class StartRide extends RideEvent {
  final Course course;
  final double userWeight; // in kg
  final bool isSimulated;

  const StartRide({
    required this.course,
    required this.userWeight,
    this.isSimulated = false,
  });

  @override
  List<Object> get props => [course, userWeight, isSimulated];
}

class UpdatePower extends RideEvent {
  final int power;

  const UpdatePower(this.power);

  @override
  List<Object> get props => [power];
}

class StopRide extends RideEvent {}

class SaveHighScore extends RideEvent {
  final String courseName;
  final String userName;
  final Duration time;

  const SaveHighScore({
    required this.courseName,
    required this.userName,
    required this.time,
  });

  @override
  List<Object> get props => [courseName, userName, time];
}