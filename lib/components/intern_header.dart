import 'package:flutter/material.dart';
import 'package:internflow/models/UserModel.dart';

class InternHeader extends StatelessWidget {
  final UserModel user;

  const InternHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name ?? '',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.email, size: 16),
              const SizedBox(width: 6),
              Text(user.email ?? '')
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.badge, size: 16),
              const SizedBox(width: 6),
              Text(user.role ?? '')
            ]),
          ],
        ),
      ),
    );
  }
}
