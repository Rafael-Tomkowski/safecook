import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/checklist_item.dart';

class ChecklistLocalDaoSharedPrefs {
  static const String storageKey = 'checklist_items';

  Future<List<ChecklistItem>> listAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(storageKey);

    if (jsonString == null) {
      return [];
    }

    final List decoded = json.decode(jsonString);
    return decoded.map((e) => ChecklistItem.fromMap(e)).toList();
  }

  Future<void> upsertAll(List<ChecklistItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        json.encode(items.map((e) => e.toMap()).toList());
    await prefs.setString(storageKey, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}

final checklistDao = ChecklistLocalDaoSharedPrefs();
