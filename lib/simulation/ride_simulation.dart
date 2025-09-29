import 'dart:async';
import 'dart:math';

import 'package:kickr_flutter/gpx/course.dart';
import 'package:kickr_flutter/simulation/ride_state.dart';

class RideSimulation {
  final Course course;
  final double riderWeightKg; // Rider's weight in kg
  final double bikeWeightKg = 9.0; // Assumed bike weight

  // Physics constants
  final double _gravity = 9.81; // m/s^2
  final double _rollingResistanceCoeff = 0.005; // Crr
  final double _airDensity = 1.225; // rho in kg/m^3
  final double _dragCoefficient = 0.5; // Cd
  final double _frontalArea = 0.4; // A in m^2
  double get _dragArea => _dragCoefficient * _frontalArea; // CdA

  late final double _totalMass; // kg

  Stream<int> powerStream; // Input power from the trainer or simulator
  StreamController<RideState> _rideStateController = StreamController<RideState>.broadcast();
  Stream<RideState> get rideStateStream => _rideStateController.stream;

  Timer? _simulationTimer;
  RideState _currentState = RideState.initial();
  int _currentPower = 0;

  RideSimulation({
    required this.course,
    required this.riderWeightKg,
    required this.powerStream,
  }) {
    _totalMass = riderWeightKg + bikeWeightKg;
    powerStream.listen((power) {
      _currentPower = power;
    });
  }

  void start() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void stop() {
    _simulationTimer?.cancel();
  }

  void _tick(Timer timer) {
    final grade = _getGradeAtDistance(_currentState.distance);
    final forces = _calculateResistiveForces(_currentState.speed, grade);
    final newSpeed = _calculateNewSpeed(forces, _currentPower, _currentState.speed);
    final distanceMoved = newSpeed * 1.0; // distance = speed * time (1s)

    _currentState = RideState(
      distance: _currentState.distance + distanceMoved,
      speed: newSpeed,
      power: _currentPower,
      elapsedTime: _currentState.elapsedTime + const Duration(seconds: 1),
      currentGrade: grade,
    );

    _rideStateController.add(_currentState);

    if (_currentState.distance >= course.totalDistance) {
      stop();
    }
  }

  double _getGradeAtDistance(double distance) {
    if (course.points.length < 2) return 0.0;

    final currentPointIndex = course.points.indexWhere((p) => p.distance >= distance);
    if (currentPointIndex <= 0) return 0.0;

    final p1 = course.points[currentPointIndex - 1];
    final p2 = course.points[currentPointIndex];

    final elevationChange = p2.elevation - p1.elevation;
    final distanceChange = p2.distance - p1.distance;

    if (distanceChange == 0) return 0.0;
    return elevationChange / distanceChange;
  }

  double _calculateResistiveForces(double speed, double grade) {
    // Force of gravity
    final gravityForce = _totalMass * _gravity * sin(atan(grade));
    // Rolling resistance force
    final rollingForce = _totalMass * _gravity * cos(atan(grade)) * _rollingResistanceCoeff;
    // Aerodynamic drag force
    final dragForce = 0.5 * _airDensity * _dragArea * pow(speed, 2);

    return gravityForce + rollingForce + dragForce;
  }

  double _calculateNewSpeed(double resistiveForce, int power, double lastSpeed) {
    // Using an iterative approach to find speed from power
    // Power = Force * Velocity
    double newSpeed = lastSpeed;
    for (int i = 0; i < 5; i++) { // 5 iterations is enough for convergence
      double totalForce = resistiveForce;
      if (newSpeed > 0.1) {
        totalForce = power / newSpeed;
      }
      final netForce = totalForce - resistiveForce;
      final acceleration = netForce / _totalMass;
      newSpeed = lastSpeed + acceleration * 1.0; // dt = 1s
      if (newSpeed < 0) newSpeed = 0;
    }
    return newSpeed;
  }

  void dispose() {
    stop();
    _rideStateController.close();
  }
}