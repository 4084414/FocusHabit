import 'package:flutter/material.dart';

/// Pantalla encargada de mostrar el listado de categorías disponibles,
/// junto con su icono representativo y la cantidad de hábitos asociados.
class PantallaCategorias extends StatelessWidget {
  const PantallaCategorias({super.key});

  // Lista estática que contiene los datos de cada categoría traducidos al español
  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Ergonomía', 'icon': Icons.chair_alt, 'count': 5},
    {'name': 'Salud visual', 'icon': Icons.visibility, 'count': 3},
    {'name': 'Hidratación', 'icon': Icons.water_drop, 'count': 2},
    {'name': 'Enfoque', 'icon': Icons.psychology, 'count': 4},
    {'name': 'Ejercicio', 'icon': Icons.fitness_center, 'count': 6},
    {'name': 'Sueño', 'icon': Icons.bedtime, 'count': 1},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      // ListView.builder para renderizar eficientemente la lista de categorías
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              // Icono representativo de la categoría utilizando el color primario del tema
              leading: Icon(
                category['icon'] as IconData,
                color: colorScheme.primary,
              ),
              // Nombre de la categoría en español
              title: Text(
                category['name'] as String,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Subtítulo que indica cuántos hábitos activos pertenecen a esta categoría
              subtitle: Text(
                '${category['count']} hábitos activos',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              // Icono indicador de navegación hacia la derecha
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Aquí puedes agregar la navegación hacia una vista filtrada por categoría si lo deseas
              },
            ),
          );
        },
      ),
    );
  }
}
