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

  // Filtering state
  DateTimeRange? _selectedRange;
  Set<String> _selectedActivities = {};

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

  // Filtering logic
  List<WorkUpdate> get _filteredUpdates {
    return _updates.where((update) {
      // Date filter
      bool dateOk = true;
      if (_selectedRange != null) {
        final updateDate = DateTime.tryParse(update.date);
        if (updateDate != null) {
          dateOk = updateDate.isAfter(
                  _selectedRange!.start.subtract(const Duration(days: 1))) &&
              updateDate
                  .isBefore(_selectedRange!.end.add(const Duration(days: 1)));
        }
      }
      // Activity filter
      bool activityOk = _selectedActivities.isEmpty ||
          (_selectedActivities.contains('plan') && update.plan) ||
          (_selectedActivities.contains('coding') && update.coding) ||
          (_selectedActivities.contains('debugging') && update.debugging) ||
          (_selectedActivities.contains('testing') && update.testing) ||
          (_selectedActivities.contains('waiting') && update.waiting) ||
          (_selectedActivities.contains('onLeave') && update.onLeave);

      return dateOk && activityOk;
    }).toList();
  }

  void _showFilterDialog() async {
    DateTimeRange? pickedRange = _selectedRange;
    Set<String> pickedActivities = Set.from(_selectedActivities);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Filter Work Updates'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        pickedRange == null
                            ? 'Select Date Range'
                            : '${pickedRange?.start.toString().substring(0, 10)} - ${pickedRange?.end.toString().substring(0, 10)}',
                      ),
                      onPressed: () async {
                        final now = DateTime.now();
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(now.year - 1),
                          lastDate: now,
                          initialDateRange: pickedRange,
                        );
                        if (range != null) {
                          setStateDialog(() {
                            pickedRange = range;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Activity Types:'),
                    CheckboxListTile(
                      title: const Text('Plan'),
                      value: pickedActivities.contains('plan'),
                      onChanged: (val) {
                        setStateDialog(() {
                          val!
                              ? pickedActivities.add('plan')
                              : pickedActivities.remove('plan');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Coding'),
                      value: pickedActivities.contains('coding'),
                      onChanged: (val) {
                        setStateDialog(() {
                          val!
                              ? pickedActivities.add('coding')
                              : pickedActivities.remove('coding');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Debugging'),
                      value: pickedActivities.contains('debugging'),
                      onChanged: (val) {
                        setStateDialog(() {
                          val!
                              ? pickedActivities.add('debugging')
                              : pickedActivities.remove('debugging');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Testing'),
                      value: pickedActivities.contains('testing'),
                      onChanged: (val) {
                        setStateDialog(() {
                          val!
                              ? pickedActivities.add('testing')
                              : pickedActivities.remove('testing');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Waiting'),
                      value: pickedActivities.contains('waiting'),
                      onChanged: (val) {
                        setStateDialog(() {
                          val!
                              ? pickedActivities.add('waiting')
                              : pickedActivities.remove('waiting');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('On Leave'),
                      value: pickedActivities.contains('onLeave'),
                      onChanged: (val) {
                        setStateDialog(() {
                          val!
                              ? pickedActivities.add('onLeave')
                              : pickedActivities.remove('onLeave');
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedRange = pickedRange;
                      _selectedActivities = pickedActivities;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildActivityIcon(String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
      appBar: AppBar(
        title: const Text("Work Logs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredUpdates.isEmpty
              ? const Center(child: Text("No updates found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredUpdates.length,
                  itemBuilder: (context, index) {
                    final update = _filteredUpdates[index];
                    final date = update.date;
                    final submittedAt = DateFormat.yMMMd().add_jm().format(
                        DateTime.tryParse(update.submittedAt) ??
                            DateTime.now());

                    // Only relevant activities
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
