import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InternDropdown extends StatelessWidget {
  final List<DocumentSnapshot> interns;
  final String? selectedInternId;
  final Function(String selectedId, Map<String, dynamic> data) onChanged;

  const InternDropdown({
    super.key,
    required this.interns,
    required this.selectedInternId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedInternId,
          hint: const Text('Select Intern'),
          isExpanded: true,
          onChanged: (value) {
            if (value != null) {
              final selectedData = interns
                  .firstWhere((doc) => doc['uid'] == value)
                  .data() as Map<String, dynamic>;
              onChanged(value, selectedData);
            }
          },
          items: interns.map((doc) {
            return DropdownMenuItem<String>(
              value: doc['uid'],
              child: Text(doc['name']),
            );
          }).toList(),
        ),
      ),
    );
  }
}
