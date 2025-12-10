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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

Future<void> _loadData() async {
  try {
    await checklistRepository.load();
  } catch (e, st) {
    // Vai aparecer no console do Flutter (Debug Console)
    // pra você ver o erro real vindo do Supabase
    // ignore: avoid_print
    print('Erro ao carregar checklist: $e');
    // ignore: avoid_print
    print(st);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar checklist. Verifique o console.'),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}

  void _openDialog(ChecklistItem item) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // recomendado pelo professor
      builder: (_) => ChecklistDialog(item: item),
    );
    setState(() {}); // atualizar lista depois de editar/remover
  }

  void _createItem() async {
    final controller = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Criar item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Descrição"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () async {
              await checklistRepository.create(
                controller.text,
                descController.text,
              );
              if (context.mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Criar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  if (_loading) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Checklist"),
    ),
    body: const Center(
      child: CircularProgressIndicator(),
    ),
  );
}

    final items = checklistRepository.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checklist"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createItem,
        child: const Icon(Icons.add),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                "Nenhum item criado ainda.\nToque no botão + para adicionar.",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
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
