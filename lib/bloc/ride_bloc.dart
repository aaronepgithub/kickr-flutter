import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kickr_flutter/bloc/ride_event.dart';
import 'package:kickr_flutter/bloc/ride_state.dart';
import 'package:kickr_flutter/bluetooth/ftms_service.dart';
import 'package:kickr_flutter/gpx/course.dart';
import 'package:kickr_flutter/highscore/high_score_repository.dart';
import 'package:kickr_flutter/simulation/ride_simulation.dart';
import 'package:kickr_flutter/simulation/ride_state.dart' as sim;

class RideBloc extends Bloc<RideEvent, RideState> {
  final FtmsService _ftmsService;
  final HighScoreRepository _highScoreRepository;

  RideSimulation? _userSimulation;
  RideSimulation? _pacerSimulation;

  StreamSubscription? _userSub;
  StreamSubscription? _pacerSub;
  StreamSubscription? _powerSub;

  sim.RideState? _lastUserSate;
  sim.RideState? _lastPacerState;

  RideBloc(this._ftmsService, this._highScoreRepository) : super(RideInitial()) {
    on<StartRide>(_onStartRide);
    on<StopRide>(_onStopRide);
    on<SaveHighScore>(_onSaveHighScore);
  }

  void _onSaveHighScore(SaveHighScore event, Emitter<RideState> emit) {
    final highScore = HighScore(
      courseName: event.courseName,
      userName: event.userName,
      timeInSeconds: event.time.inSeconds,
    );
    _highScoreRepository.saveHighScore(highScore);
  }

  void _onStartRide(StartRide event, Emitter<RideState> emit) {
    _cleanup(); // Clean up any previous ride

    final userPowerController = StreamController<int>();
    _userSimulation = RideSimulation(
      course: event.course,
      riderWeightKg: event.userWeight,
      powerStream: userPowerController.stream,
    );

    if (event.isSimulated) {
      // Use a simulated power source for the user
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (isClosed) {
          timer.cancel();
          return;
        }
        userPowerController.add(200); // Simulated user power
      });
    } else {
      // Use the real power data from the FTMS service
      _powerSub = _ftmsService.powerStream.listen(userPowerController.add);
    }

    // Always include the pacer
    final pacerPowerController = StreamController<int>();
    _pacerSimulation = RideSimulation(
      course: event.course,
      riderWeightKg: 75, // 165 lbs
      powerStream: pacerPowerController.stream,
    );
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      pacerPowerController.add(200); // Pacer power
    });

    _userSub = _userSimulation!.rideStateStream.listen((userState) async {
      _lastUserSate = userState;
      _emitInProgressState(emit);

      // For real rides, send the current grade to the trainer
      if (!event.isSimulated) {
        _ftmsService.setSimulationParameters(userState.currentGrade);
      }

      await _checkCompletion(event.course, userState, emit);
    });

    _pacerSub = _pacerSimulation!.rideStateStream.listen((pacerState) {
      _lastPacerState = pacerState;
      _emitInProgressState(emit);
    });

    _userSimulation!.start();
    _pacerSimulation!.start();
  }

  void _onStopRide(StopRide event, Emitter<RideState> emit) {
    _cleanup();
    emit(RideInitial());
  }

  void _emitInProgressState(Emitter<RideState> emit) {
    if (_lastUserSate != null) {
      emit(RideInProgress(_lastUserSate!, _lastPacerState));
    }
  }

  Future<void> _checkCompletion(
      Course course, sim.RideState userState, Emitter<RideState> emit) async {
    // Prevent re-entering after completion state is emitted
    if (userState.distance >= course.totalDistance && state is! RideFinished) {
      final existingHighScore =
          await _highScoreRepository.getHighScore(course.name);
      final newTime = userState.elapsedTime;
      bool isNewHighScore = false;

      if (existingHighScore == null ||
          newTime.inSeconds < existingHighScore.timeInSeconds) {
        isNewHighScore = true;
      }

      emit(RideFinished(newTime, isNewHighScore));
      _cleanup();
    }
  }

  void _cleanup() {
    _userSub?.cancel();
    _pacerSub?.cancel();
    _powerSub?.cancel();
    _userSimulation?.dispose();
    _pacerSimulation?.dispose();
    _lastUserSate = null;
    _lastPacerState = null;
  }

  @override
  Future<void> close() {
    _cleanup();
    return super.close();
  }
}