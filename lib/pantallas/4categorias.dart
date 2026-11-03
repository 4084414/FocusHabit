import 'package:flutter/material.dart';

class PantallaCategorias extends StatelessWidget {
  const PantallaCategorias({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Ergonomics', 'icon': Icons.chair_alt, 'count': 5},
    {'name': 'Eye Care', 'icon': Icons.visibility, 'count': 3},
    {'name': 'Hydration', 'icon': Icons.water_drop, 'count': 2},
    {'name': 'Focus', 'icon': Icons.psychology, 'count': 4},
    {'name': 'Fitness', 'icon': Icons.fitness_center, 'count': 6},
    {'name': 'Sleep', 'icon': Icons.bedtime, 'count': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: Icon(category['icon']),
              title: Text(
                category['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${category['count']} hábitos activos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
