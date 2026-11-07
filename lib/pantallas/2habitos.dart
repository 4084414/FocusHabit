import 'package:flutter/material.dart';

import '3newhabito.dart';
import '4categorias.dart';
import '8descanso.dart'; // Importación añadida

class PantallaHabitos extends StatelessWidget {
  const PantallaHabitos({super.key});

  final List<Map<String, dynamic>> _habits = const [
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
        padding: const EdgeInsets.all(16),
        itemCount: _habits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final habit = _habits[index];
          final isEyeCare = habit['category'] == 'Eye Care';

          return Card(
            child: ListTile(
              onTap: isEyeCare ? () => _abrirDescansoVisual(context) : null,
              leading: Icon(
                isEyeCare ? Icons.visibility : Icons.check_circle_outline,
                color: colorScheme.primary,
              ),
              title: Text(habit['title'] ?? ''),
              subtitle: Text('Objetivo: ${habit['target']}'),
              trailing: IconButton(
                icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                onPressed: () {
                  // Acción para editar hábito
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirNuevoHabito(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
