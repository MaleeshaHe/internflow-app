import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';

class WorkOverviewChart extends StatelessWidget {
  final List<DocumentSnapshot> workUpdates;

  const WorkOverviewChart({super.key, required this.workUpdates});

  @override
  Widget build(BuildContext context) {
    int coding = 0, plan = 0, debug = 0, test = 0, leave = 0;

    for (var doc in workUpdates) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['coding'] == true) coding++;
      if (data['plan'] == true) plan++;
      if (data['debugging'] == true) debug++;
      if (data['testing'] == true) test++;
      if (data['onLeave'] == true) leave++;
    }

    final dataMap = {
      "Coding": coding.toDouble(),
      "Planning": plan.toDouble(),
      "Debugging": debug.toDouble(),
      "Testing": test.toDouble(),
      "On Leave": leave.toDouble(),
    };

    return PieChart(
      dataMap: dataMap,
      chartType: ChartType.disc,
      chartRadius: MediaQuery.of(context).size.width / 2.2,
      legendOptions: const LegendOptions(showLegends: true),
      chartValuesOptions:
          const ChartValuesOptions(showChartValuesInPercentage: true),
    );
  }
}
