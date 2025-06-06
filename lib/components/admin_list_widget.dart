import 'package:flutter/material.dart';
import 'package:internflow/models/UserModel.dart';

class AdminListWidget extends StatelessWidget {
  final List<UserModel> admins;

  const AdminListWidget({super.key, required this.admins});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admins:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (admins.isEmpty)
          const Text('No admins found.')
        else
          ...admins.map((admin) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Colors.blue.shade50,
                child: ListTile(
                  title: Text(admin.name ?? ''),
                  subtitle: Text(admin.email ?? ''),
                  trailing: const Icon(Icons.shield),
                ),
              )),
      ],
    );
  }
}
