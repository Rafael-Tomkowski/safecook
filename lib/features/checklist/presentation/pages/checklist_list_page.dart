import 'package:flutter/material.dart';
import '../../data/checklist_repository.dart';
import '../../domain/checklist_item.dart';
import '../widgets/checklist_dialog.dart';

class ChecklistListPage extends StatefulWidget {
  const ChecklistListPage({super.key});

  @override
  State<ChecklistListPage> createState() => _ChecklistListPageState();
}

class _ChecklistListPageState extends State<ChecklistListPage> {
  void _openDialog(ChecklistItem item) async {
    await showDialog(
      context: context,
      builder: (_) => ChecklistDialog(item: item),
    );
    setState(() {}); // refresh
  }

  void _createItem() async {
    final controller = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Criar item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, decoration: const InputDecoration(labelText: "Título")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Descrição")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          FilledButton(
            onPressed: () {
              checklistRepository.create(controller.text, descController.text);
              Navigator.pop(context);
            },
            child: const Text("Criar"),
          )
        ],
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = checklistRepository.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checklist"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createItem,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return ListTile(
            title: Text(item.title),
            subtitle: Text(item.description),
            onTap: () => _openDialog(item),
          );
        },
      ),
    );
  }
}
