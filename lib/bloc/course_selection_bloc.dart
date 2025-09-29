import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kickr_flutter/bloc/course_selection_event.dart';
import 'package:kickr_flutter/bloc/course_selection_state.dart';
import 'package:kickr_flutter/gpx/course_repository.dart';
import 'package:kickr_flutter/gpx/gpx_parser.dart';
import 'package:kickr_flutter/highscore/high_score_repository.dart';

class CourseSelectionBloc
    extends Bloc<CourseSelectionEvent, CourseSelectionState> {
  final CourseRepository _courseRepository;
  final HighScoreRepository _highScoreRepository;

  CourseSelectionBloc(this._courseRepository, this._highScoreRepository)
      : super(CourseSelectionInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<AddCourse>(_onAddCourse);
    on<DeleteCourse>(_onDeleteCourse);
  }

  Future<void> _onLoadCourses(
      LoadCourses event, Emitter<CourseSelectionState> emit) async {
    emit(CoursesLoading());
    try {
      final courses = await _courseRepository.getCourses();
      final highScores = await _highScoreRepository.getAllHighScores();
      emit(CoursesLoaded(courses, highScores));
    } catch (e) {
      emit(CoursesError("Failed to load courses: $e"));
    }
  }

  Future<void> _onAddCourse(
      AddCourse event, Emitter<CourseSelectionState> emit) async {
    try {
      final course = GpxParser.parse(event.gpxString, fileName: event.fileName);
      await _courseRepository.saveCourse(course);
      add(LoadCourses()); // Reload courses to show the new one
    } catch (e) {
      emit(CoursesError("Failed to add course: $e"));
    }
  }

  Future<void> _onDeleteCourse(
      DeleteCourse event, Emitter<CourseSelectionState> emit) async {
    try {
      await _courseRepository.deleteCourse(event.courseName);
      add(LoadCourses()); // Reload courses to reflect the deletion
    } catch (e) {
      emit(CoursesError("Failed to delete course: $e"));
    }
  }
}