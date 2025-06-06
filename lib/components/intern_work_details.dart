import 'package:flutter/material.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/models/WorkUpdateModel.dart';

class InternWorkDetails extends StatelessWidget {
  final UserModel intern;
  final List<WorkUpdate> workUpdates;

  const InternWorkDetails({
    super.key,
    required this.intern,
    required this.workUpdates,
  });

  Map<String, int> _getActivityCounts() {
    return {
      'Plan': workUpdates.where((u) => u.plan).length,
      'Coding': workUpdates.where((u) => u.coding).length,
      'Debugging': workUpdates.where((u) => u.debugging).length,
      'Testing': workUpdates.where((u) => u.testing).length,
      'Waiting': workUpdates.where((u) => u.waiting).length,
      'On Leave': workUpdates.where((u) => u.onLeave).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final activityCounts = _getActivityCounts();
    final totalActivities = activityCounts.values.reduce((a, b) => a + b);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${intern.name}\'s Work Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Basic Stats
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatCard('Total Updates', workUpdates.length),
                _buildStatCard('Total Activities', totalActivities),
                _buildStatCard('Productivity', 
                    '${(totalActivities / (workUpdates.length * 3) * 100)}%'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Activity Breakdown Table
            const Text('Activity Breakdown:', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            DataTable(
              columns: const [
                DataColumn(label: Text('Activity')),
                DataColumn(label: Text('Count'), numeric: true),
                DataColumn(label: Text('Percentage'), numeric: true),
              ],
              rows: activityCounts.entries.map((e) {
                return DataRow(cells: [
                  DataCell(Text(e.key)),
                  DataCell(Text(e.value.toString())),
                  DataCell(Text('${((e.value/totalActivities)*100).toStringAsFixed(1)}%')),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            Text('$value', style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
          ],
        ),
      ),
    );
  }
}