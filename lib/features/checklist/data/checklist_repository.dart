import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/checklist_item.dart';
import 'checklist_local_dao.dart';

class ChecklistRepository {
  final _client = Supabase.instance.client;
  final _uuid = const Uuid();

  final List<ChecklistItem> _items = [];
  bool _syncing = false;

  String _requireUserId() {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');
    return user.id;
  }

  List<ChecklistItem> getAllVisible() {
    // não mostra itens deletados
    final visible = _items.where((e) => !e.isDeleted).toList();
    return List.unmodifiable(visible);
  }

  /// Carrega local primeiro (offline) e tenta sincronizar (se online).
  Future<void> load() async {
    final userId = _requireUserId();

    // 1) Local first
    final local = await checklistDao.listAll(userId);
    _items
      ..clear()
      ..addAll(local);

    // 2) Sync best-effort (não explode o app se falhar)
    try {
      await sync();
    } catch (_) {
      // offline/erro de rede: fica com local mesmo
    }
  }

  /// Sincronização 2 vias:
  /// A) PUSH alterações locais (dirty) -> Supabase
  /// B) PULL alterações do Supabase desde lastSync -> local
  Future<void> sync() async {
    if (_syncing) return;
    _syncing = true;

    final userId = _requireUserId();

    try {
      // A) PUSH dirty
      final dirtyItems = _items.where((e) => e.isDirty).toList();

      for (final item in dirtyItems) {
        // upsert garante que se existir, atualiza; se não, cria
        final row = {
          'id': item.id,
          'user_id': userId,
          'title': item.title,
          'description': item.description,
          'is_deleted': item.isDeleted,
        };

        final remote = await _client
            .from('checklist_items')
            .upsert(row)
            .select('*')
            .single();

        final remoteItem =
            ChecklistItem.fromRemoteMap(remote as Map<String, dynamic>);

        // aplica de volta no local (agora “limpo”)
        final idx = _items.indexWhere((e) => e.id == item.id);
        if (idx >= 0) {
          _items[idx] = ChecklistItem(
            id: remoteItem.id,
            userId: remoteItem.userId,
            title: remoteItem.title,
            description: remoteItem.description,
            isDeleted: remoteItem.isDeleted,
            updatedAt: remoteItem.updatedAt,
            isDirty: false,
            localUpdatedAt: DateTime.now(),
          );
        }
      }

      // salva local após push
      await checklistDao.upsertAll(userId, _items);

      // B) PULL desde lastSync
      final lastSync = await checklistDao.getLastSync(userId);

      dynamic query = _client
          .from('checklist_items')
          .select('*')
          .eq('user_id', userId);

      if (lastSync != null) {
        query = query.gt('updated_at', lastSync.toIso8601String());
      }

      final response = await query;

      final List<Map<String, dynamic>> rows =
          (response as List).cast<Map<String, dynamic>>();

      DateTime? maxRemoteUpdatedAt;

      for (final row in rows) {
        final remoteItem = ChecklistItem.fromRemoteMap(row);

        if (maxRemoteUpdatedAt == null ||
            remoteItem.updatedAt.isAfter(maxRemoteUpdatedAt)) {
          maxRemoteUpdatedAt = remoteItem.updatedAt;
        }

        final idx = _items.indexWhere((e) => e.id == remoteItem.id);

        if (idx == -1) {
          // não existe local -> adiciona
          _items.add(remoteItem);
          continue;
        }

        final localItem = _items[idx];

        // Se local está dirty, assumimos “push-first” como vencedor.
        // (conflito: outro dispositivo editou e você também editou offline)
        // Estratégia simples: manter local (porque já foi pushado antes do pull).
        // Aqui, localItem já estaria limpo se conseguiu push. Se ainda está dirty,
        // significa que push falhou e estamos offline -> não sobrescrever.
        if (localItem.isDirty) continue;

        // Se remoto é mais novo, aplica
        if (remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
          _items[idx] = remoteItem;
        }
      }

      // Atualiza lastSync (usa o maior updated_at recebido; se nada veio, mantém)
      if (maxRemoteUpdatedAt != null) {
        await checklistDao.setLastSync(userId, maxRemoteUpdatedAt);
      } else if (lastSync == null) {
        // primeira sync sem retorno: marca agora pra não puxar tudo sempre
        await checklistDao.setLastSync(userId, DateTime.now());
      }

      // salva local após pull
      await checklistDao.upsertAll(userId, _items);
    } finally {
      _syncing = false;
    }
  }

  Future<void> create(String title, String description) async {
    final userId = _requireUserId();

    final now = DateTime.now();
    final item = ChecklistItem(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      description: description,
      isDeleted: false,
      updatedAt: now,
      isDirty: true,
      localUpdatedAt: now,
    );

    _items.add(item);
    await checklistDao.upsertAll(userId, _items);

    // tenta sincronizar (se offline, fica dirty e sincroniza depois)
    try {
      await sync();
    } catch (_) {}
  }

  Future<void> update(String id, String title, String description) async {
    final userId = _requireUserId();
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return;

    final now = DateTime.now();

    final current = _items[idx];
    _items[idx] = ChecklistItem(
      id: current.id,
      userId: current.userId,
      title: title,
      description: description,
      isDeleted: current.isDeleted,
      updatedAt: now,
      isDirty: true,
      localUpdatedAt: now,
    );

    await checklistDao.upsertAll(userId, _items);

    try {
      await sync();
    } catch (_) {}
  }

  /// Delete offline-safe: marca tombstone e sincroniza depois
  Future<void> delete(String id) async {
    final userId = _requireUserId();
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return;

    final now = DateTime.now();
    final current = _items[idx];

    _items[idx] = ChecklistItem(
      id: current.id,
      userId: current.userId,
      title: current.title,
      description: current.description,
      isDeleted: true,
      updatedAt: now,
      isDirty: true,
      localUpdatedAt: now,
    );

    await checklistDao.upsertAll(userId, _items);

    try {
      await sync();
    } catch (_) {}
  }

  Future<void> clearAllForUser() async {
    final userId = _requireUserId();

    // marca tudo como deleted + dirty para sincronizar corretamente
    final now = DateTime.now();
    for (var i = 0; i < _items.length; i++) {
      final it = _items[i];
      _items[i] = ChecklistItem(
        id: it.id,
        userId: it.userId,
        title: it.title,
        description: it.description,
        isDeleted: true,
        updatedAt: now,
        isDirty: true,
        localUpdatedAt: now,
      );
    }

    await checklistDao.upsertAll(userId, _items);

    try {
      await sync();
    } catch (_) {}
  }
}

final checklistRepository = ChecklistRepository();
