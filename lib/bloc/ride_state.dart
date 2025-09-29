import 'package:equatable/equatable.dart';
import 'package:kickr_flutter/simulation/ride_state.dart' as sim;

abstract class RideState extends Equatable {
  const RideState();

  @override
  List<Object?> get props => [];
}

class RideInitial extends RideState {}

class RideInProgress extends RideState {
  final sim.RideState userRideState;
  final sim.RideState? simulatedRideState;

  const RideInProgress(this.userRideState, [this.simulatedRideState]);

  @override
  List<Object?> get props => [userRideState, simulatedRideState];
}

class RideFinished extends RideState {
  final Duration finalTime;
  final bool isNewHighScore;

  const RideFinished(this.finalTime, this.isNewHighScore);

  @override
  List<Object> get props => [finalTime, isNewHighScore];
}

class RideError extends RideState {
  final String message;

  const RideError(this.message);

  @override
  List<Object> get props => [message];
}