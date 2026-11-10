import 'package:flutter/material.dart';
import 'package:focushabit/data/database_helper.dart';
import 'package:focushabit/data/habitos_controller.dart';

/// Pantalla encargada de mostrar el listado de categorías guardadas en SQLite,
/// junto con su icono representativo y la cantidad de hábitos asociados.
class PantallaCategorias extends StatelessWidget {
  const PantallaCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    final esquemaColores = Theme.of(context).colorScheme;
    final temaTexto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      // Lee las categorías con su número de hábitos (LEFT JOIN + COUNT).
      body: FutureBuilder<List<Map<String, Object?>>>(
        future: DatabaseHelper.instance.categoriasConConteo(),
        builder: (context, instantanea) {
          if (instantanea.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final categorias = instantanea.data ?? const [];
          if (categorias.isEmpty) {
            return const Center(child: Text('No hay categorías todavía'));
          }

          // ListView.builder para renderizar eficientemente la lista de categorías
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: categorias.length,
            itemBuilder: (context, indice) {
              final categoria = categorias[indice];
              final nombre = categoria['nombre'] as String;
              final cantidad = categoria['cantidad'] as int;

              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  // Icono representativo de la categoría con el color primario del tema
                  leading: Icon(
                    HabitosController.obtenerIconoPorCategoria(nombre),
                    color: esquemaColores.primary,
                  ),
                  // Nombre de la categoría
                  title: Text(
                    nombre,
                    style: temaTexto.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Subtítulo con el número de hábitos de esta categoría
                  subtitle: Text(
                    cantidad == 1 ? '1 hábito' : '$cantidad hábitos',
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
          );
        },
      ),
    );
  }
}
