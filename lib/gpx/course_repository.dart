import 'dart:convert';

import 'package:kickr_flutter/gpx/course.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseRepository {
  static const _coursesKey = 'gpx_courses';

  Future<void> saveCourse(Course course) async {
    final prefs = await SharedPreferences.getInstance();
    final courses = await getCourses();
    // Avoid duplicates by name
    courses.removeWhere((c) => c.name == course.name);
    courses.add(course);

    final courseListForJson = courses.map((c) => c.toJson()).toList();
    await prefs.setString(_coursesKey, jsonEncode(courseListForJson));
  }

  Future<List<Course>> getCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJsonString = prefs.getString(_coursesKey);

    if (coursesJsonString == null) {
      return [];
    }

    final List<dynamic> courseList = jsonDecode(coursesJsonString);
    // Defensively filter out any invalid entries before mapping
    return courseList
        .where((json) => json is Map<String, dynamic>)
        .map((json) => Course.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteCourse(String courseName) async {
    final prefs = await SharedPreferences.getInstance();
    final courses = await getCourses();
    courses.removeWhere((c) => c.name == courseName);

    final courseListForJson = courses.map((c) => c.toJson()).toList();
    await prefs.setString(_coursesKey, jsonEncode(courseListForJson));
  }
}

// The extensions on Course and CoursePoint for toJson/fromJson are in course.dart
// and do not need to be repeated here.