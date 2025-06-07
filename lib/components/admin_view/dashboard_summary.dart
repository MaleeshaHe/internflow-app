import 'package:flutter/material.dart';
import 'package:internflow/screens/home/intern_list_page.dart';

class DashboardSummary extends StatelessWidget {
  final int totalInterns;
  final int internsWithUpdates;
  final int internsWithoutUpdates;

  const DashboardSummary({
    super.key,
    required this.totalInterns,
    required this.internsWithUpdates,
    required this.internsWithoutUpdates, required Null Function() onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget _buildStatCard(String title, String value, Color color) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 110,
          height: 90,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  )),
              const SizedBox(height: 4),
              Text(title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: color,
                  )),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            SizedBox(width: 8),
            Text(
              "Intern Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard("Total Interns", "$totalInterns", Colors.deepPurple),
            _buildStatCard("With Updates", "$internsWithUpdates", Colors.green),
            _buildStatCard("No Updates", "$internsWithoutUpdates", Colors.red),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InternListPage()),
              );
            },
            icon:
                const Icon(Icons.people_outline, size: 20, color: Colors.white),
            label:
                const Text("View All Interns", style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
