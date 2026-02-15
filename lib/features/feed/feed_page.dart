import 'package:flutter/material.dart';
import '../../app/routes.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pets = [
      ('1', 'Bella', 'Dog • 2 yrs'),
      ('2', 'Milo', 'Cat • 1 yr'),
      ('3', 'Coco', 'Dog • 6 mo'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('PetOpt'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, Routes.createPost),
            icon: const Icon(Icons.add),
            tooltip: 'Create post',
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: pets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final (id, name, subtitle) = pets[i];
          return Card(
            child: ListTile(
              title: Text(name),
              subtitle: Text(subtitle),
              leading: const CircleAvatar(child: Icon(Icons.pets)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(
                context,
                Routes.petDetail,
                arguments: id,
              ),
            ),
          );
        },
      ),
    );
  }
}
