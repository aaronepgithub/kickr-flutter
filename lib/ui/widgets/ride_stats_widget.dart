import 'package:flutter/material.dart';
import 'package:kickr_flutter/simulation/ride_state.dart' as sim;

class RideStatsWidget extends StatelessWidget {
  final sim.RideState rideState;

  const RideStatsWidget({super.key, required this.rideState});

  @override
  Widget build(BuildContext context) {
    final speedKmh = rideState.speed * 3.6;
    final distanceKm = rideState.distance / 1000;
    final avgSpeedKmh = rideState.elapsedTime.inSeconds > 0
        ? (rideState.distance / rideState.elapsedTime.inSeconds) * 3.6
        : 0;
    final elapsedTime =
        '${rideState.elapsedTime.inMinutes}:${(rideState.elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}';

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 2.0,
      children: [
        _buildStatCard('Power', rideState.power.toString(), 'W'),
        _buildStatCard('Speed', speedKmh.toStringAsFixed(1), 'km/h'),
        _buildStatCard('Distance', distanceKm.toStringAsFixed(2), 'km'),
        _buildStatCard('Avg Speed', avgSpeedKmh.toStringAsFixed(1), 'km/h'),
        _buildStatCard('Time', elapsedTime, ''),
        _buildStatCard('Grade', '${(rideState.currentGrade * 100).toStringAsFixed(1)}%', ''),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String unit) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              children: [
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}