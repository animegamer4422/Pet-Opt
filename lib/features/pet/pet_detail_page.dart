import 'package:flutter/material.dart';

class PetDetailPage extends StatelessWidget {
  final String? petId;
  const PetDetailPage({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pet ID: ${petId ?? "unknown"}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Text('This is where we’ll show pet photos, description, age, location, and contact info.'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Adoption request flow later')),
                  );
                },
                child: const Text('I want to adopt'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
