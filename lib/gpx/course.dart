import 'package:equatable/equatable.dart';

class Course extends Equatable {
  final String name;
  final List<CoursePoint> points;
  final double totalDistance;

  const Course({
    required this.name,
    required this.points,
    required this.totalDistance,
  });

  @override
  List<Object?> get props => [name, points, totalDistance];

  // Serialization
  Map<String, dynamic> toJson() => {
        'name': name,
        'points': points.map((p) => p.toJson()).toList(),
        'totalDistance': totalDistance,
      };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        name: json['name'],
        points: (json['points'] as List)
            .map((p) => CoursePoint.fromJson(p))
            .toList(),
        totalDistance: json['totalDistance'],
      );
}

class CoursePoint extends Equatable {
  final double lat;
  final double lon;
  final double elevation;
  final double distance; // Distance from the start of the course in meters

  const CoursePoint({
    required this.lat,
    required this.lon,
    required this.elevation,
    required this.distance,
  });

  @override
  List<Object?> get props => [lat, lon, elevation, distance];

  // Serialization
  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'elevation': elevation,
        'distance': distance,
      };

  factory CoursePoint.fromJson(Map<String, dynamic> json) => CoursePoint(
        lat: json['lat'],
        lon: json['lon'],
        elevation: json['elevation'],
        distance: json['distance'],
      );
}