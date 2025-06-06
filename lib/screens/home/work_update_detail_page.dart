import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:internflow/models/WorkUpdateModel.dart';

class WorkUpdateDetailPage extends StatefulWidget {
  final String userId;

  const WorkUpdateDetailPage({super.key, required this.userId});

  @override
  State<WorkUpdateDetailPage> createState() => _WorkUpdateDetailPageState();
}

class _WorkUpdateDetailPageState extends State<WorkUpdateDetailPage> {
  List<WorkUpdate> _updates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkUpdates();
  }

  Future<void> _fetchWorkUpdates() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('work_updates')
          .where('userId', isEqualTo: widget.userId)
          .get();

      final updates =
          snapshot.docs.map((doc) => WorkUpdate.fromJson(doc.data())).toList();

      updates.sort((a, b) => b.date.compareTo(a.date)); // Newest first

      setState(() {
        _updates = updates;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching work updates: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget buildActivityIcon(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueAccent),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Work Logs")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _updates.isEmpty
              ? const Center(child: Text("No updates found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _updates.length,
                  itemBuilder: (context, index) {
                    final update = _updates[index];
                    final date = update.date;
                    final submittedAt = DateFormat.yMMMd().add_jm().format(
                        DateTime.tryParse(update.submittedAt) ??
                            DateTime.now());

                    final activities = <Widget>[
                      if (update.plan) buildActivityIcon("Plan", Icons.event),
                      if (update.coding)
                        buildActivityIcon("Coding", Icons.code),
                      if (update.debugging)
                        buildActivityIcon("Debugging", Icons.bug_report),
                      if (update.testing)
                        buildActivityIcon("Testing", Icons.science),
                      if (update.waiting)
                        buildActivityIcon("Waiting", Icons.hourglass_empty),
                      if (update.onLeave)
                        buildActivityIcon("On Leave", Icons.beach_access),
                    ];

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📅 $date",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: activities,
                            ),
                            if (update.description.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text("📝 ${update.description}",
                                  style: const TextStyle(fontSize: 14)),
                            ],
                            const SizedBox(height: 12),
                            Text("⏱ Submitted at: $submittedAt",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
