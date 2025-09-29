import 'package:equatable/equatable.dart';

class RideState extends Equatable {
  final double distance; // meters
  final double speed; // m/s
  final int power; // watts
  final Duration elapsedTime;
  final double currentGrade;

  const RideState({
    required this.distance,
    required this.speed,
    required this.power,
    required this.elapsedTime,
    required this.currentGrade,
  });

  factory RideState.initial() => const RideState(
        distance: 0,
        speed: 0,
        power: 0,
        elapsedTime: Duration.zero,
        currentGrade: 0,
      );

  @override
  List<Object?> get props => [distance, speed, power, elapsedTime, currentGrade];
}