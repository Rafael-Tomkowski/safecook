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
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      await checklistRepository.load();
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao carregar checklist: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao carregar.')),
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

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    try {
      await checklistRepository.sync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sincronizado.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sem internet ou erro ao sincronizar.')),
        );
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
      if (mounted) setState(() {});
    }
  }

  Future<void> _openDialog(ChecklistItem item) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChecklistDialog(item: item),
    );
    if (mounted) setState(() {});
  }

  Future<void> _createItem() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Criar item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: descCtrl,
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
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (title.isEmpty) return;

              await checklistRepository.create(title, desc);

              if (context.mounted) Navigator.pop(context);
              if (mounted) setState(() {});
            },
            child: const Text("Criar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = checklistRepository.getAllVisible();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checklist"),
        actions: [
          IconButton(
            tooltip: 'Sincronizar agora',
            onPressed: _syncing ? null : _syncNow,
            icon: _syncing
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createItem,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Nenhum item criado ainda.\nToque no botão + para adicionar.",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _syncing ? null : _syncNow,
                        icon: const Icon(Icons.sync),
                        label: const Text('Tentar sincronizar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _syncNow();
                  },
                  child: ListView.builder(
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
                ),
    );
  }
}
