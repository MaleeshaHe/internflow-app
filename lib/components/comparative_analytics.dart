import 'package:flutter/material.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/models/WorkUpdateModel.dart';

class ComparativeAnalytics extends StatelessWidget {
  final List<UserModel> interns;
  final List<WorkUpdate> workUpdates;

  const ComparativeAnalytics({
    super.key,
    required this.interns,
    required this.workUpdates,
  });

  Map<String, Map<String, int>> _getComparativeData() {
    final Map<String, Map<String, int>> data = {};

    for (var intern in interns) {
      final internUpdates = workUpdates.where((u) => u.userId == intern.uid);
      data[intern.name ?? 'Unknown'] = {
        'Plan': internUpdates.where((u) => u.plan).length,
        'Coding': internUpdates.where((u) => u.coding).length,
        'Debugging': internUpdates.where((u) => u.debugging).length,
        'Testing': internUpdates.where((u) => u.testing).length,
        'Total': internUpdates.length,
      };
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final comparativeData = _getComparativeData();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparative Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Data Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Intern')),
                  DataColumn(label: Text('Plan'), numeric: true),
                  DataColumn(label: Text('Coding'), numeric: true),
                  DataColumn(label: Text('Debug'), numeric: true),
                  DataColumn(label: Text('Test'), numeric: true),
                  DataColumn(label: Text('Total'), numeric: true),
                ],
                rows: comparativeData.entries.map((entry) {
                  return DataRow(cells: [
                    DataCell(Text(entry.key)),
                    DataCell(Text('${entry.value['Plan']}')),
                    DataCell(Text('${entry.value['Coding']}')),
                    DataCell(Text('${entry.value['Debugging']}')),
                    DataCell(Text('${entry.value['Testing']}')),
                    DataCell(Text('${entry.value['Total']}')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
