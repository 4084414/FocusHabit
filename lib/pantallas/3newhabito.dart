import 'package:flutter/material.dart';

class PantallaNuevoHabito extends StatefulWidget {
  const PantallaNuevoHabito({super.key});

  @override
  State<PantallaNuevoHabito> createState() => _PantallaNuevoHabitoState();
}

class _PantallaNuevoHabitoState extends State<PantallaNuevoHabito> {
  final _controller = TextEditingController();
  String _selectedCategory = 'Ergonomics';
  int _dailyTarget = 1;

  final List<String> _categories = [
    'Ergonomics',
    'Eye Care',
    'Hydration',
    'Focus',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Hábito'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context),
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
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.save),
                label: const Text('Guardar Hábito'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
