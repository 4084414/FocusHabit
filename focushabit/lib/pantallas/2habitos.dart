import 'package:flutter/material.dart';

class PantallaHabitos extends StatelessWidget {
  const PantallaHabitos({super.key});

  final List<Map<String, String>> _habits = const [
    {
      'title': 'Postura recta en silla',
      'target': '1 min cada hora',
      'category': 'Ergonomics',
    },
    {
      'title': 'Regla 20-20-20',
      'target': '20 seg cada 20 min',
      'category': 'Eye Care',
    },
    {
      'title': 'Ajustar altura de monitor',
      'target': '1 vez al día',
      'category': 'Ergonomics',
    },
    {
      'title': 'Parpadear conscientemente',
      'target': '5 min al día',
      'category': 'Eye Care',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Hábitos')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _habits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final habit = _habits[index];

          return Card(
            child: ListTile(
              title: Text(habit['title'] ?? ''),
              subtitle: Text('Objetivo: ${habit['target']}'),
              trailing: IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: colorScheme.primary, // Usa el color del tema
                ),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
