import 'package:flutter/material.dart';
import 'package:internflow/models/WorkUpdateModel.dart';
import 'package:pie_chart/pie_chart.dart';

class InternSummaryCard extends StatelessWidget {
  final List<WorkUpdate> workUpdates;

  const InternSummaryCard({super.key, required this.workUpdates});

  Map<String, double> _getStats() {
    final stats = {
      'Plan': 0,
      'Coding': 0,
      'Debugging': 0,
      'Testing': 0,
      'Waiting': 0,
      'On Leave': 0,
    };

    for (var update in workUpdates) {
      if (update.plan) stats['Plan'] = stats['Plan']! + 1;
      if (update.coding) stats['Coding'] = stats['Coding']! + 1;
      if (update.debugging) stats['Debugging'] = stats['Debugging']! + 1;
      if (update.testing) stats['Testing'] = stats['Testing']! + 1;
      if (update.waiting) stats['Waiting'] = stats['Waiting']! + 1;
      if (update.onLeave) stats['On Leave'] = stats['On Leave']! + 1;
    }

    return stats.map((key, value) => MapEntry(key, value.toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getStats();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Work Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Total Updates: ${workUpdates.length}'),
            const SizedBox(height: 20),
            PieChart(
              dataMap: stats,
              chartRadius: MediaQuery.of(context).size.width * 0.6,
              legendOptions: const LegendOptions(
                showLegends: true,
                legendPosition: LegendPosition.right,
              ),
              chartValuesOptions: const ChartValuesOptions(
                showChartValuesInPercentage: true,
              ),
              chartType: ChartType.disc,
              animationDuration: const Duration(milliseconds: 800),
            ),
          ],
        ),
      ),
    );
  }
}
