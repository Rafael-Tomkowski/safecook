import 'package:flutter/material.dart';
import '../../domain/checklist_item.dart';
import '../../data/checklist_repository.dart';

class ChecklistEditPage extends StatefulWidget {
  final ChecklistItem item;

  const ChecklistEditPage({super.key, required this.item});

  @override
  State<ChecklistEditPage> createState() => _ChecklistEditPageState();
}

class _ChecklistEditPageState extends State<ChecklistEditPage> {
  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.item.title);
    descCtrl = TextEditingController(text: widget.item.description);
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    await checklistRepository.update(
      widget.item.id,
      titleCtrl.text.trim(),
      descCtrl.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Descrição"),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
