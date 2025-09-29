import 'dart:math';

import 'package:gpx/gpx.dart';
import 'package:kickr_flutter/gpx/course.dart';

class GpxParser {
  static Course parse(String gpxString, {required String fileName}) {
    final gpx = GpxReader().fromString(gpxString);
    final courseName = gpx.metadata?.name ?? fileName;
    final points = <CoursePoint>[];
    double totalDistance = 0;

    Wpt? lastPoint;

    for (var track in gpx.trks) {
      for (var segment in track.trksegs) {
        for (var point in segment.trkpts) {
          if (lastPoint != null) {
            totalDistance += _distance(
              lastPoint.lat ?? 0,
              lastPoint.lon ?? 0,
              point.lat ?? 0,
              point.lon ?? 0,
            );
          }
          points.add(
            CoursePoint(
              lat: point.lat ?? 0,
              lon: point.lon ?? 0,
              elevation: point.ele ?? 0,
              distance: totalDistance,
            ),
          );
          lastPoint = point;
        }
      }
    }

    return Course(
      name: courseName,
      points: points,
      totalDistance: totalDistance,
    );
  }

  static double _distance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // 2 * R; R = 6371 km
  }
}