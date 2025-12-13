import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/checklist_item.dart';

class ChecklistLocalDaoSharedPrefs {
  String _itemsKey(String userId) => 'checklist_items_$userId';
  String _lastSyncKey(String userId) => 'checklist_last_sync_$userId';

  Future<List<ChecklistItem>> listAll(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_itemsKey(userId));
    if (jsonString == null) return [];

    final List decoded = json.decode(jsonString);
    return decoded
        .map((e) => ChecklistItem.fromLocalMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertAll(String userId, List<ChecklistItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_itemsKey(userId), encoded);
  }

  Future<void> clear(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_itemsKey(userId));
    await prefs.remove(_lastSyncKey(userId));
  }

  Future<DateTime?> getLastSync(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastSyncKey(userId));
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> setLastSync(String userId, DateTime dt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey(userId), dt.toIso8601String());
  }
}

final checklistDao = ChecklistLocalDaoSharedPrefs();
