import 'package:flutter/material.dart';
import 'package:internflow/models/WorkUpdateModel.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';

class InternSummaryCard extends StatefulWidget {
  final List<WorkUpdate> workUpdates;

  const InternSummaryCard({super.key, required this.workUpdates});

  @override
  _InternSummaryCardState createState() => _InternSummaryCardState();
}

class _InternSummaryCardState extends State<InternSummaryCard> {
  String? _selectedDateRange = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  Map<String, double> _getStats() {
    final stats = {
      'Plan': 0.0,
      'Coding': 0.0,
      'Debugging': 0.0,
      'Testing': 0.0,
      'Waiting': 0.0,
      'On Leave': 0.0,
    };

    final filteredUpdates = _filterWorkUpdates();

    for (var update in filteredUpdates) {
      if (update.plan) stats['Plan'] = stats['Plan']! + 1;
      if (update.coding) stats['Coding'] = stats['Coding']! + 1;
      if (update.debugging) stats['Debugging'] = stats['Debugging']! + 1;
      if (update.testing) stats['Testing'] = stats['Testing']! + 1;
      if (update.waiting) stats['Waiting'] = stats['Waiting']! + 1;
      if (update.onLeave) stats['On Leave'] = stats['On Leave']! + 1;
    }

    return stats;
  }

  List<WorkUpdate> _filterWorkUpdates() {
    var filtered = widget.workUpdates;

    if (_selectedDateRange != 'All') {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      DateTime start;
      DateTime end = now;

      switch (_selectedDateRange) {
        case 'Today':
          return filtered.where((update) {
            try {
              if (update.date.isEmpty) {
                print("Skipping update with empty date: $update");
                return false;
              }
              final updateDate = DateFormat('yyyy-MM-dd').parse(update.date);
              return updateDate.day == todayDate.day &&
                  updateDate.month == todayDate.month &&
                  updateDate.year == todayDate.year;
            } catch (e) {
              print("Date parsing error: $e for update.date: ${update.date}");
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
          if (_startDate == null || _endDate == null) return filtered;
          start = _startDate!;
          end = _endDate!.add(Duration(days: 1));
          break;
        default:
          start = now; // Fallback, should not occur
      }

      if (_selectedDateRange != 'Today') {
        filtered = filtered.where((update) {
          try {
            if (update.date.isEmpty) {
              print("Skipping update with empty date: $update");
              return false;
            }
            final updateDate = DateFormat('yyyy-MM-dd').parse(update.date);
            return updateDate.isAfter(start.subtract(Duration(days: 1))) &&
                updateDate.isBefore(end);
          } catch (e) {
            print("Date parsing error: $e for update.date: ${update.date}");
            return false;
          }
        }).toList();
      }
    }

    return filtered;
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final stats = _getStats();
    final filteredUpdates = _filterWorkUpdates();
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.size == null) {
      print("MediaQuery.size is null, using default width");
      return const Center(
          child: Text('Unable to render chart due to invalid context'));
    }

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
                  'Work Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.date_range),
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
                        PopupMenuItem(value: 'All', child: Text('All')),
                        PopupMenuItem(value: 'Today', child: Text('Today')),
                        PopupMenuItem(value: '1 Week', child: Text('1 Week')),
                        PopupMenuItem(value: '1 Month', child: Text('1 Month')),
                        PopupMenuItem(value: 'Custom', child: Text('Custom')),
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
            const SizedBox(height: 12),
            Text('Total Updates: ${filteredUpdates.length}'),
            if (_selectedDateRange != 'All') ...[
              const SizedBox(height: 8),
              Text(
                _selectedDateRange == 'Custom'
                    ? 'Date Range: ${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                    : 'Date Range: $_selectedDateRange',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 20),
            PieChart(
              dataMap: stats,
              chartRadius: mediaQuery.size.width * 0.6,
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
