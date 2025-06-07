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

  List<WorkUpdate> get _filteredUpdates {
    return _updates.where((update) {
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
    DateTimeRange? tempRange = _selectedRange;
    Set<String> tempActivities = Set.from(_selectedActivities);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Filter Work Updates",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      tempRange == null
                          ? 'Select Date Range'
                          : '${DateFormat.yMMMd().format(tempRange!.start)} - ${DateFormat.yMMMd().format(tempRange!.end)}',
                    ),
                    onPressed: () async {
                      final now = DateTime.now();
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(now.year - 1),
                        lastDate: now,
                        initialDateRange: tempRange,
                      );
                      if (range != null) {
                        setStateDialog(() {
                          tempRange = range;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Activity Types:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _activityChip(
                          'Plan', 'plan', tempActivities, setStateDialog),
                      _activityChip(
                          'Coding', 'coding', tempActivities, setStateDialog),
                      _activityChip('Debugging', 'debugging', tempActivities,
                          setStateDialog),
                      _activityChip(
                          'Testing', 'testing', tempActivities, setStateDialog),
                      _activityChip(
                          'Waiting', 'waiting', tempActivities, setStateDialog),
                      _activityChip('On Leave', 'onLeave', tempActivities,
                          setStateDialog),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedRange = null;
                            _selectedActivities.clear();
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Clear Filters"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedRange = tempRange;
                            _selectedActivities = tempActivities;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _activityChip(String label, String key, Set<String> selectedSet,
      void Function(void Function()) setStateDialog) {
    final isSelected = selectedSet.contains(key);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setStateDialog(() {
          if (selected) {
            selectedSet.add(key);
          } else {
            selectedSet.remove(key);
          }
        });
      },
      selectedColor: Colors.blueAccent.withOpacity(0.2),
      checkmarkColor: Colors.blueAccent,
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
                            Text("📅 $submittedAt",
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
                            Text(
                              "⏱ Submitted at: ${DateFormat.jm().format(DateTime.tryParse(update.submittedAt) ?? DateTime.now())}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
