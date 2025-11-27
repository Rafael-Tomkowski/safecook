import '../../checklist/domain/checklist_item.dart';
import 'package:uuid/uuid.dart';

class ChecklistRepository {
  final List<ChecklistItem> _items = [];
  final _uuid = const Uuid();

  List<ChecklistItem> getAll() => List.unmodifiable(_items);

  ChecklistItem create(String title, String description) {
    final item = ChecklistItem(
      id: _uuid.v4(),
      title: title,
      description: description,
    );
    _items.add(item);
    return item;
  }

  void update(String id, String title, String description) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      _items[idx].title = title;
      _items[idx].description = description;
    }
  }

  void delete(String id) {
    _items.removeWhere((e) => e.id == id);
  }
}

final checklistRepository = ChecklistRepository();
