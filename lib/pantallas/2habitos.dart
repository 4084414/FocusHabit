import 'package:flutter/material.dart';

import '3newhabito.dart';
import '4categorias.dart';
import '8descanso.dart';

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

  void _abrirNuevoHabito(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaNuevoHabito()),
    );
  }

  void _abrirCategorias(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaCategorias()),
    );
  }

  void _abrirDescansoVisual(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaDescansoVisual()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hábitos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categorías',
            onPressed: () => _abrirCategorias(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Añadir hábito',
            onPressed: () => _abrirNuevoHabito(context),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 120, // Espacio para no tapar los elementos con los FABs
        ),
        itemCount: _habits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final habit = _habits[index];

          return Card(
            child: ListTile(
              leading: Icon(
                Icons.check_circle_outline,
                color: colorScheme.primary,
              ),
              title: Text(habit['title'] ?? ''),
              subtitle: Text('Objetivo: ${habit['target']}'),
              trailing: IconButton(
                icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
      // Columna de botones flotantes (FAB de Añadir arriba, FAB de Descanso abajo)
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_add_habit',
            onPressed: () => _abrirNuevoHabito(context),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'fab_eye_rest',
            onPressed: () => _abrirDescansoVisual(context),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Descanso Visual'),
          ),
        ],
      ),
    );
  }
}
