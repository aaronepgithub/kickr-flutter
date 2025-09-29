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

    final coursesJson = courses.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_coursesKey, coursesJson);
  }

  Future<List<Course>> getCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = prefs.getStringList(_coursesKey) ?? [];
    return coursesJson
        .map((json) => Course.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> deleteCourse(String courseName) async {
    final prefs = await SharedPreferences.getInstance();
    final courses = await getCourses();
    courses.removeWhere((c) => c.name == courseName);

    final coursesJson = courses.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_coursesKey, coursesJson);
  }
}

// Add JSON serialization to the Course and CoursePoint models
extension on Course {
  Map<String, dynamic> toJson() => {
        'name': name,
        'points': points.map((p) => p.toJson()).toList(),
        'totalDistance': totalDistance,
      };

  static Course fromJson(Map<String, dynamic> json) => Course(
        name: json['name'],
        points: (json['points'] as List)
            .map((p) => CoursePoint.fromJson(p))
            .toList(),
        totalDistance: json['totalDistance'],
      );
}

extension on CoursePoint {
  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'elevation': elevation,
        'distance': distance,
      };

  static CoursePoint fromJson(Map<String, dynamic> json) => CoursePoint(
        lat: json['lat'],
        lon: json['lon'],
        elevation: json['elevation'],
        distance: json['distance'],
      );
}