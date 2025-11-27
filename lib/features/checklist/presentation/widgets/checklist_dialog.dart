import 'package:flutter/material.dart';
import '../../domain/checklist_item.dart';
import '../../data/checklist_repository.dart';
import '../pages/checklist_edit_page.dart';

class ChecklistDialog extends StatelessWidget {
  final ChecklistItem item;

  const ChecklistDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(item.title),
      content: Text(item.description),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Fechar"),
        ),
        TextButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChecklistEditPage(item: item),
              ),
            );
            Navigator.pop(context);
          },
          child: const Text("Editar"),
        ),
        FilledButton(
          onPressed: () {
            checklistRepository.delete(item.id);
            Navigator.pop(context);
          },
          child: const Text("Remover"),
        ),
      ],
    );
  }
}
