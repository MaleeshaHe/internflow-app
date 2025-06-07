import 'package:flutter/material.dart';
import 'package:internflow/screens/home/work_update_screen.dart';

class InternActionButton extends StatelessWidget {
  const InternActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('Submit Daily Work Update'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WorkUpdateScreen(
              userId: '',
            ),
          ),
        );
      },
    );
  }
}
