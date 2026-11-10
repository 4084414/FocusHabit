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
  late final TextEditingController _controladorTexto;
  late String _categoriaSeleccionada;
  late int _objetivoDiario;
  bool _estaCompletado = false;

  // Lista predeterminada de categorías disponibles para los hábitos
  final List<String> _categorias = [
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
    _controladorTexto = TextEditingController(text: habito?['titulo'] ?? '');

    // Configura la categoría seleccionada inicialmente
    final categoria = habito?['categoria'];
    if (categoria != null && categoria.isNotEmpty) {
      // Si la categoría del hábito no está en la lista predeterminada, la añade para evitar errores
      if (!_categorias.contains(categoria)) {
        _categorias.add(categoria);
      }
      _categoriaSeleccionada = categoria;
    } else {
      _categoriaSeleccionada = 'Ergonomía'; // Categoría por defecto
    }

    // Extrae de forma segura el valor numérico del objetivo diario a partir del texto guardado
    final textoObjetivo = habito?['objetivo'] ?? '';
    final coincidencia = RegExp(r'\d+').firstMatch(textoObjetivo);
    _objetivoDiario = coincidencia != null
        ? (int.tryParse(coincidencia.group(0)!) ?? 1)
        : 1;

    // Configura el estado inicial de completado
    _estaCompletado = habito?['completado'] == 'true';
  }

  @override
  void dispose() {
    _controladorTexto
        .dispose(); // Libera el controlador de texto al cerrar la pantalla
    super.dispose();
  }

  /// Valida el campo de texto y devuelve un mapa con los datos del hábito actualizado o nuevo a la pantalla anterior.
  void _guardarHabito() {
    if (_controladorTexto.text.trim().isEmpty)
      return; // Evita guardar hábitos sin título

    final nuevoHabito = {
      'titulo': _controladorTexto.text.trim(),
      'objetivo': _objetivoDiario == 1
          ? '1 vez al día'
          : '$_objetivoDiario veces al día',
      'categoria': _categoriaSeleccionada,
      'completado': _estaCompletado ? 'true' : 'false',
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
          '¿Seguro que deseas eliminar "${widget.habitoAEditar?['titulo']}"?',
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
      Navigator.pop(context, const {'accion': 'borrar'});
    }
  }

  @override
  Widget build(BuildContext context) {
    final temaTexto = Theme.of(context).textTheme;

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
              controller: _controladorTexto,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Selector desplegable (Dropdown) para escoger la categoría
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: _categorias
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => _categoriaSeleccionada = valor);
                }
              },
            ),
            const SizedBox(height: 16),

            // 3. Controlador numérico simple con botones (+ / -) para definir el objetivo diario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Objetivo diario:', style: temaTexto.bodyLarge),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _objetivoDiario > 1
                          ? () => setState(() => _objetivoDiario--)
                          : null, // Deshabilita el botón si el objetivo es 1
                    ),
                    Text(
                      '$_objetivoDiario',
                      style: temaTexto.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _objetivoDiario++),
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
                subtitle: Text(_estaCompletado ? 'Completado' : 'Pendiente'),
                value: _estaCompletado,
                secondary: Icon(
                  _estaCompletado
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: _estaCompletado
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onChanged: (valor) => setState(() => _estaCompletado = valor),
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
