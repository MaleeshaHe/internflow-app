import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';

class WorkOverviewChart extends StatefulWidget {
  final List<DocumentSnapshot> workUpdates;

  const WorkOverviewChart({super.key, required this.workUpdates});

  @override
  State<WorkOverviewChart> createState() => _WorkOverviewChartState();
}

class _WorkOverviewChartState extends State<WorkOverviewChart> {
  String _selectedDateRange = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  List<DocumentSnapshot> get _filteredWorkUpdates {
    if (_selectedDateRange == 'All') return widget.workUpdates;

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    DateTime start;
    DateTime end = now;

    switch (_selectedDateRange) {
      case 'Today':
        return widget.workUpdates.where((doc) {
          try {
            final date = DateFormat('yyyy-MM-dd').parse((doc['date'] ?? ''));
            return date.year == todayDate.year &&
                date.month == todayDate.month &&
                date.day == todayDate.day;
          } catch (_) {
            return false;
          }
        }).toList();
      case '1 Week':
        start = now.subtract(Duration(days: 6));
        break;
      case '1 Month':
        start = now.subtract(Duration(days: 30));
        break;
      case 'Custom':
        if (_startDate == null || _endDate == null) return widget.workUpdates;
        start = _startDate!;
        end = _endDate!.add(Duration(days: 1));
        break;
      default:
        return widget.workUpdates;
    }

    return widget.workUpdates.where((doc) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse((doc['date'] ?? ''));
        return date.isAfter(start.subtract(Duration(days: 1))) &&
            date.isBefore(end);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedDateRange = 'Custom';
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedDateRange = 'All';
      _startDate = null;
      _endDate = null;
    });
  }

  Map<String, double> _getStats() {
    int coding = 0, plan = 0, debug = 0, test = 0, leave = 0;

    for (var doc in _filteredWorkUpdates) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['coding'] == true) coding++;
      if (data['plan'] == true) plan++;
      if (data['debugging'] == true) debug++;
      if (data['testing'] == true) test++;
      if (data['onLeave'] == true) leave++;
    }

    return {
      "Coding": coding.toDouble(),
      "Planning": plan.toDouble(),
      "Debugging": debug.toDouble(),
      "Testing": test.toDouble(),
      "On Leave": leave.toDouble(),
    };
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Work Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_alt),
                      tooltip: 'Filter by Date Range',
                      onSelected: (value) {
                        setState(() {
                          _selectedDateRange = value;
                          if (value == 'Custom') {
                            _selectCustomDateRange(context);
                          } else {
                            _startDate = null;
                            _endDate = null;
                          }
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'All', child: Text('All')),
                        const PopupMenuItem(
                            value: 'Today', child: Text('Today')),
                        const PopupMenuItem(
                            value: '1 Week', child: Text('1 Week')),
                        const PopupMenuItem(
                            value: '1 Month', child: Text('1 Month')),
                        const PopupMenuItem(
                            value: 'Custom', child: Text('Custom')),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _resetFilters,
                      tooltip: 'Reset Filters',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Total Updates: ${_filteredWorkUpdates.length}'),
            if (_selectedDateRange != 'All') ...[
              const SizedBox(height: 4),
              Text(
                _selectedDateRange == 'Custom' &&
                        _startDate != null &&
                        _endDate != null
                    ? 'Date Range: ${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                    : 'Date Range: $_selectedDateRange',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 20),
            PieChart(
              dataMap: stats,
              chartRadius: MediaQuery.of(context).size.width * 0.6,
              legendOptions: const LegendOptions(showLegends: true),
              chartValuesOptions:
                  const ChartValuesOptions(showChartValuesInPercentage: true),
              chartType: ChartType.disc,
              animationDuration: const Duration(milliseconds: 800),
            ),
          ],
        ),
      ),
    );
  }
}
