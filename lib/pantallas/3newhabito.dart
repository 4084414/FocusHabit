import 'package:flutter/material.dart';

class PantallaNuevoHabito extends StatefulWidget {
  final Map<String, String>? habitoAEditar;

  const PantallaNuevoHabito({super.key, this.habitoAEditar});

  @override
  State<PantallaNuevoHabito> createState() => _PantallaNuevoHabitoState();
}

class _PantallaNuevoHabitoState extends State<PantallaNuevoHabito> {
  late final TextEditingController _controller;
  late String _selectedCategory;
  late int _dailyTarget;

  final List<String> _categories = [
    'Ergonomics',
    'Eye Care',
    'Hydration',
    'Focus',
  ];

  bool get _esEdicion => widget.habitoAEditar != null;

  @override
  void initState() {
    super.initState();
    final habito = widget.habitoAEditar;
    _controller = TextEditingController(text: habito?['title'] ?? '');

    final cat = habito?['category'];
    if (cat != null && cat.isNotEmpty) {
      if (!_categories.contains(cat)) {
        _categories.add(cat);
      }
      _selectedCategory = cat;
    } else {
      _selectedCategory = 'Ergonomics';
    }

    final targetStr = habito?['target'] ?? '';
    final match = RegExp(r'\d+').firstMatch(targetStr);
    _dailyTarget = match != null ? (int.tryParse(match.group(0)!) ?? 1) : 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Método auxiliar para guardar y devolver el mapa del hábito
  void _guardarHabito() {
    if (_controller.text.trim().isEmpty) return;
    final nuevoHabito = {
      'title': _controller.text.trim(),
      'target': _dailyTarget == 1
          ? '1 vez al día'
          : '$_dailyTarget veces al día',
      'category': _selectedCategory,
    };
    Navigator.pop(context, nuevoHabito);
  }

  // Confirmar y solicitar el borrado del hábito
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
          if (_esEdicion)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: 'Borrar hábito',
              onPressed: _confirmarBorrado,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _guardarHabito,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Nombre del hábito
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Categoría
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

            // 3. Objetivo diario simple (+ / -)
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
                          : null,
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
            const Spacer(),

            // 4. Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _guardarHabito,
                icon: const Icon(Icons.save),
                label: Text(_esEdicion ? 'Guardar Cambios' : 'Guardar Hábito'),
              ),
            ),
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
