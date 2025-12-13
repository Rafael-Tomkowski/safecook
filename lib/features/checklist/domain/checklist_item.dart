class ChecklistItem {
  final String id;
  final String userId;

  String title;
  String description;

  /// Tombstone para deletar offline e sincronizar depois
  bool isDeleted;

  /// Último updated_at conhecido do servidor (ou local quando ainda não sincronizou)
  DateTime updatedAt;

  /// Se true, significa “tem mudança local pendente de enviar pro Supabase”
  bool isDirty;

  /// Marca quando foi alterado localmente (útil para debug/decisão)
  DateTime localUpdatedAt;

  ChecklistItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.isDeleted,
    required this.updatedAt,
    required this.isDirty,
    required this.localUpdatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'is_deleted': isDeleted,
      'updated_at': updatedAt.toIso8601String(),
      'is_dirty': isDirty,
      'local_updated_at': localUpdatedAt.toIso8601String(),
    };
  }

  /// Map vindo do Supabase (sem is_dirty/local_updated_at)
  factory ChecklistItem.fromRemoteMap(Map<String, dynamic> map) {
    final updatedAtStr = (map['updated_at'] ?? '').toString();
    final updatedAt = DateTime.tryParse(updatedAtStr) ?? DateTime.now();

    return ChecklistItem(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      isDeleted: (map['is_deleted'] ?? false) as bool,
      updatedAt: updatedAt,
      isDirty: false,
      localUpdatedAt: DateTime.now(),
    );
  }

  /// Map vindo do cache local (SharedPreferences)
  factory ChecklistItem.fromLocalMap(Map<String, dynamic> map) {
    final updatedAtStr = (map['updated_at'] ?? '').toString();
    final localUpdatedAtStr = (map['local_updated_at'] ?? '').toString();

    return ChecklistItem(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      isDeleted: (map['is_deleted'] ?? false) as bool,
      updatedAt: DateTime.tryParse(updatedAtStr) ?? DateTime.now(),
      isDirty: (map['is_dirty'] ?? false) as bool,
      localUpdatedAt: DateTime.tryParse(localUpdatedAtStr) ?? DateTime.now(),
    );
  }
}
