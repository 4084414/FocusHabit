import 'package:flutter/material.dart';

/// Pantalla encargada de mostrar el listado de categorías disponibles,
/// junto con su icono representativo y la cantidad de hábitos asociados.
class PantallaCategorias extends StatelessWidget {
  const PantallaCategorias({super.key});

  // Lista estática que contiene los datos de cada categoría traducidos al español
  final List<Map<String, dynamic>> _categorias = const [
    {'nombre': 'Ergonomía', 'icono': Icons.chair_alt, 'cantidad': 5},
    {'nombre': 'Salud visual', 'icono': Icons.visibility, 'cantidad': 3},
    {'nombre': 'Hidratación', 'icono': Icons.water_drop, 'cantidad': 2},
    {'nombre': 'Enfoque', 'icono': Icons.psychology, 'cantidad': 4},
    {'nombre': 'Ejercicio', 'icono': Icons.fitness_center, 'cantidad': 6},
    {'nombre': 'Sueño', 'icono': Icons.bedtime, 'cantidad': 1},
  ];

  @override
  Widget build(BuildContext context) {
    final esquemaColores = Theme.of(context).colorScheme;
    final temaTexto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      // ListView.builder para renderizar eficientemente la lista de categorías
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _categorias.length,
        itemBuilder: (context, indice) {
          final categoria = _categorias[indice];

          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              // Icono representativo de la categoría utilizando el color primario del tema
              leading: Icon(
                categoria['icono'] as IconData,
                color: esquemaColores.primary,
              ),
              // Nombre de la categoría en español
              title: Text(
                categoria['nombre'] as String,
                style: temaTexto.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Subtítulo que indica cuántos hábitos activos pertenecen a esta categoría
              subtitle: Text(
                '${categoria['cantidad']} hábitos activos',
                style: temaTexto.bodyMedium?.copyWith(
                  color: esquemaColores.onSurfaceVariant,
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
