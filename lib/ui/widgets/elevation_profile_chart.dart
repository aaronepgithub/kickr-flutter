import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kickr_flutter/gpx/course.dart';
import 'package:kickr_flutter/simulation/ride_state.dart' as sim;

class ElevationProfileChart extends StatelessWidget {
  final Course course;
  final sim.RideState userRideState;
  final sim.RideState? pacerRideState;

  const ElevationProfileChart({
    super.key,
    required this.course,
    required this.userRideState,
    this.pacerRideState,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: course.totalDistance / 5, // Show 5 labels
                getTitlesWidget: (value, meta) {
                  return Text('${(value / 1000).toStringAsFixed(1)}km');
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: course.points
                  .map((p) => FlSpot(p.distance, p.elevation))
                  .toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
            ),
          ],
          extraLinesData: ExtraLinesData(
            verticalLines: [
              if (userRideState.distance > 0)
                VerticalLine(
                  x: userRideState.distance,
                  color: Colors.red,
                  strokeWidth: 2,
                  label: VerticalLineLabel(
                    show: true,
                    labelResolver: (_) => 'You',
                    alignment: Alignment.topRight,
                  ),
                ),
              if (pacerRideState != null && pacerRideState!.distance > 0)
                VerticalLine(
                  x: pacerRideState!.distance,
                  color: Colors.green,
                  strokeWidth: 2,
                  label: VerticalLineLabel(
                    show: true,
                    labelResolver: (_) => 'Pacer',
                    alignment: Alignment.topLeft,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}