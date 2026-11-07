import 'package:flutter/material.dart';

/// Pantalla modal encargada de permitir al usuario crear un nuevo hábito
/// o editar uno existente (incluyendo título, categoría, objetivo diario y estado).
class PantallaNuevoHabito extends StatefulWidget {
  /// Si se pasa este parámetro, la pantalla opera en modo edición.
  /// Si es nulo, opera en modo creación.
  final Map<String, String>? habitoAEditar;

  const PantallaNuevoHabito({super.key, this.habitoAEditar});

  @override
  State<PantallaNuevoHabito> createState() => _PantallaNuevoHabitoState();
}

class _PantallaNuevoHabitoState extends State<PantallaNuevoHabito> {
  late final TextEditingController _controller;
  late String _selectedCategory;
  late int _dailyTarget;
  bool _isCompleted = false;

  // Lista predeterminada de categorías disponibles para los hábitos
  final List<String> _categories = [
    'Ergonomía',
    'Salud visual',
    'Hidratación',
    'Enfoque',
    'Ejercicio',
    'Sueño',
  ];

  // Getter auxiliar para determinar rápidamente si estamos editando un hábito existente
  bool get _esEdicion => widget.habitoAEditar != null;

  @override
  void initState() {
    super.initState();
    final habito = widget.habitoAEditar;

    // Inicializa el controlador del campo de texto con el título actual (si edita) o vacío (si crea)
    _controller = TextEditingController(text: habito?['title'] ?? '');

    // Configura la categoría seleccionada inicialmente
    final cat = habito?['category'];
    if (cat != null && cat.isNotEmpty) {
      // Si la categoría del hábito no está en la lista predeterminada, la añade para evitar errores
      if (!_categories.contains(cat)) {
        _categories.add(cat);
      }
      _selectedCategory = cat;
    } else {
      _selectedCategory = 'Ergonomics'; // Categoría por defecto
    }

    // Extrae de forma segura el valor numérico del objetivo diario a partir del texto guardado
    final targetStr = habito?['target'] ?? '';
    final match = RegExp(r'\d+').firstMatch(targetStr);
    _dailyTarget = match != null ? (int.tryParse(match.group(0)!) ?? 1) : 1;

    // Configura el estado inicial de completado
    _isCompleted = habito?['completed'] == 'true';
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Libera el controlador de texto al cerrar la pantalla
    super.dispose();
  }

  /// Valida el campo de texto y devuelve un mapa con los datos del hábito actualizado o nuevo a la pantalla anterior.
  void _guardarHabito() {
    if (_controller.text.trim().isEmpty)
      return; // Evita guardar hábitos sin título

    final nuevoHabito = {
      'title': _controller.text.trim(),
      'target': _dailyTarget == 1
          ? '1 vez al día'
          : '$_dailyTarget veces al día',
      'category': _selectedCategory,
      'completed': _isCompleted ? 'true' : 'false',
    };

    Navigator.pop(
      context,
      nuevoHabito,
    ); // Cierra la pantalla retornando el mapa resultante
  }

  /// Muestra un diálogo de confirmación antes de eliminar el hábito desde la misma pantalla de edición.
  Future<void> _confirmarBorrado() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar hábito'),
        content: Text(
          '¿Seguro que deseas eliminar "${widget.habitoAEditar?['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    // Si el usuario confirma, retorna una acción de borrado a la pantalla anterior
    if (confirmar == true && mounted) {
      Navigator.pop(context, const {'action': 'delete'});
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Hábito' : 'Nuevo Hábito'),
        actions: [
          // Botón de papelera en la barra superior si se encuentra en modo edición
          if (_esEdicion)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: 'Borrar hábito',
              onPressed: _confirmarBorrado,
            ),
          // Botón de confirmación (check) para guardar
          IconButton(icon: const Icon(Icons.check), onPressed: _guardarHabito),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Campo de texto para ingresar o modificar el nombre del hábito
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Selector desplegable (Dropdown) para escoger la categoría
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),

            // 3. Controlador numérico simple con botones (+ / -) para definir el objetivo diario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Objetivo diario:', style: textTheme.bodyLarge),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _dailyTarget > 1
                          ? () => setState(() => _dailyTarget--)
                          : null, // Deshabilita el botón si el objetivo es 1
                    ),
                    Text(
                      '$_dailyTarget',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _dailyTarget++),
                    ),
                  ],
                ),
              ],
            ),

            // Switch para marcar o desmarcar el estado de completado (solo visible en modo edición)
            if (_esEdicion) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hábito completado hoy'),
                subtitle: Text(_isCompleted ? 'Completado' : 'Pendiente'),
                value: _isCompleted,
                secondary: Icon(
                  _isCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: _isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onChanged: (val) => setState(() => _isCompleted = val),
              ),
            ],
            const Spacer(),

            // 4. Botón principal de guardado a ancho completo
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _guardarHabito,
                icon: const Icon(Icons.save),
                label: Text(_esEdicion ? 'Guardar Cambios' : 'Guardar Hábito'),
              ),
            ),

            // Botón secundario para borrar el hábito (solo visible en modo edición)
            if (_esEdicion) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _confirmarBorrado,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Borrar Hábito'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
