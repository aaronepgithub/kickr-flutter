import 'package:equatable/equatable.dart';
import 'package:kickr_flutter/gpx/course.dart';
import 'package:kickr_flutter/highscore/high_score.dart';

abstract class CourseSelectionState extends Equatable {
  const CourseSelectionState();

  @override
  List<Object> get props => [];
}

class CourseSelectionInitial extends CourseSelectionState {}

class CoursesLoading extends CourseSelectionState {}

class CoursesLoaded extends CourseSelectionState {
  final List<Course> courses;
  final Map<String, HighScore> highScores;

  const CoursesLoaded(this.courses, this.highScores);

  @override
  List<Object> get props => [courses, highScores];
}

class CoursesError extends CourseSelectionState {
  final String message;

  const CoursesError(this.message);

  @override
  List<Object> get props => [message];
}