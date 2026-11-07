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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              leading: Icon(
                category['icon'] as IconData,
                color: colorScheme.primary, // Usa el verde #2E7D6B del tema
              ),
              title: Text(
                category['name'] as String,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${category['count']} hábitos activos',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
