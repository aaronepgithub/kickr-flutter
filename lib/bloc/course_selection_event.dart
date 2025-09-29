import 'package:equatable/equatable.dart';

abstract class CourseSelectionEvent extends Equatable {
  const CourseSelectionEvent();

  @override
  List<Object> get props => [];
}

class LoadCourses extends CourseSelectionEvent {}

class AddCourse extends CourseSelectionEvent {
  final String fileName;
  final String gpxString;

  const AddCourse(this.fileName, this.gpxString);

  @override
  List<Object> get props => [fileName, gpxString];
}

class DeleteCourse extends CourseSelectionEvent {
  final String courseName;

  const DeleteCourse(this.courseName);

  @override
  List<Object> get props => [courseName];
}