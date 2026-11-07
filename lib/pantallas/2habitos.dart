import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '3newhabito.dart';
import '4categorias.dart';
import '8descanso.dart';

class PantallaHabitos extends StatefulWidget {
  const PantallaHabitos({super.key});

  @override
  State<PantallaHabitos> createState() => _PantallaHabitosState();
}

class _PantallaHabitosState extends State<PantallaHabitos> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  // Lista mutable de hábitos
  final List<Map<String, String>> _habits = [
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

  bool _abriendoNuevoHabito = false;

  // Esperar el nuevo hábito devuelto desde 3newhabito.dart
  Future<void> _abrirNuevoHabito(BuildContext context) async {
    if (_abriendoNuevoHabito) return;
    _abriendoNuevoHabito = true;
    try {
      final nuevoHabito = await Navigator.push<Map<String, String>>(
        context,
        MaterialPageRoute(builder: (context) => const PantallaNuevoHabito()),
      );
      if (nuevoHabito != null && mounted) {
        setState(() {
          _habits.add(nuevoHabito);
        });
      }
    } finally {
      _abriendoNuevoHabito = false;
      if (mounted) {
        _focusNode.requestFocus();
      }
    }
  }

  // Editar un hábito existente en 3newhabito.dart
  Future<void> _editarHabito(BuildContext context, int index) async {
    final habitoActual = _habits[index];
    final resultado = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaNuevoHabito(habitoAEditar: habitoActual),
      ),
    );
    if (resultado != null && mounted) {
      if (resultado['action'] == 'delete') {
        _eliminarHabito(index, habitoActual);
      } else {
        setState(() {
          _habits[index] = resultado;
        });
      }
    }
  }

  void _eliminarHabito(int index, Map<String, String> habitEliminado) {
    setState(() {
      _habits.removeAt(index);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        persist: false,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        content: Text('Hábito "${habitEliminado['title']}" eliminado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            setState(() {
              _habits.insert(index, habitEliminado);
            });
          },
        ),
      ),
    );
  }

  Future<void> _confirmarBorrado(BuildContext context, int index) async {
    final habit = _habits[index];
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar hábito'),
        content: Text('¿Seguro que deseas eliminar "${habit['title']}"?'),
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
      _eliminarHabito(index, habit);
    }
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

    if (!_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyN): () {
          _abrirNuevoHabito(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyN, shift: true): () {
          _abrirNuevoHabito(context);
        },
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyN &&
              !HardwareKeyboard.instance.isControlPressed &&
              !HardwareKeyboard.instance.isAltPressed &&
              !HardwareKeyboard.instance.isMetaPressed) {
            _abrirNuevoHabito(context);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _focusNode.requestFocus(),
          child: Scaffold(
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
                  tooltip: 'Añadir hábito (Tecla N)',
                  onPressed: () => _abrirNuevoHabito(context),
                ),
              ],
            ),
      body: _habits.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes hábitos activos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 120,
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: colorScheme.primary,
                          ),
                          tooltip: 'Editar hábito',
                          onPressed: () => _editarHabito(context, index),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: colorScheme.error,
                          ),
                          tooltip: 'Borrar hábito',
                          onPressed: () => _confirmarBorrado(context, index),
                        ),
                      ],
                    ),
                    onTap: () => _editarHabito(context, index),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_add_habit',
            tooltip: 'Añadir hábito (Tecla N)',
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
          ),
        ),
      ),
    );
  }
}
