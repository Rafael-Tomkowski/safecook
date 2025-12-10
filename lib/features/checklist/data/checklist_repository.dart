import 'package:supabase_flutter/supabase_flutter.dart';
import '../../checklist/domain/checklist_item.dart';

class ChecklistRepository {
  final _client = Supabase.instance.client;
  final List<ChecklistItem> _items = [];

  // Carrega todos os itens do Supabase
  Future<void> load() async {
    final response = await _client.from('checklist_items').select('*');

    // Se quiser ver o que está vindo:
    // print('Resposta load(): $response');

    _items
      ..clear()
      ..addAll(
        (response as List)
            .map((row) => ChecklistItem.fromMap(row as Map<String, dynamic>)),
      );
  }

  List<ChecklistItem> getAll() => List.unmodifiable(_items);

  // Cria um item novo
  Future<void> create(String title, String description) async {
    final inserted = await _client
        .from('checklist_items')
        .insert({
          'title': title,
          'description': description,
        })
        .select()
        .single();

    final item =
        ChecklistItem.fromMap(inserted as Map<String, dynamic>);
    _items.add(item);
  }

  // Atualiza item
  Future<void> update(String id, String title, String description) async {
    final updated = await _client
        .from('checklist_items')
        .update({
          'title': title,
          'description': description,
        })
        .eq('id', id)
        .select()
        .maybeSingle();

    if (updated != null) {
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        _items[idx] =
            ChecklistItem.fromMap(updated as Map<String, dynamic>);
      }
    }
  }

  // Remove item
  Future<void> delete(String id) async {
    await _client.from('checklist_items').delete().eq('id', id);
    _items.removeWhere((e) => e.id == id);
  }

  Future<void> clear() async {
    await _client.from('checklist_items').delete();
    _items.clear();
  }
}

final checklistRepository = ChecklistRepository();
