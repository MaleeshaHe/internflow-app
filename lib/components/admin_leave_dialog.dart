import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminLeaveDialog extends StatelessWidget {
  final DateTime date;
  final List<String> names;

  const AdminLeaveDialog({
    super.key,
    required this.date,
    required this.names,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFf5f5f5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Interns on Leave - ${DateFormat('MMM dd, yyyy').format(date)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 0),

            // Content
            Expanded(
              child: names.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No interns on leave this day.',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: names.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Text(
                          names[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
            ),

            const Divider(height: 0),

            // Actions
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: TextButton.icon(
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
