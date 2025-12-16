import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../main.dart'; // prefsService

class AvatarService {
  static const String _keyAvatarBase64 = 'user_avatar_b64_v1';

  final ImagePicker _picker = ImagePicker();

  /// Notificador global: quando mudar, o AppBar e Drawer atualizam.
  final ValueNotifier<Uint8List?> avatarNotifier = ValueNotifier<Uint8List?>(null);

  Future<Uint8List?> loadAvatarBytes() async {
    // se já está em memória, reaproveita
    if (avatarNotifier.value != null) return avatarNotifier.value;

    final b64 = prefsService.getString(_keyAvatarBase64);
    if (b64 == null || b64.isEmpty) {
      avatarNotifier.value = null;
      return null;
    }

    try {
      final bytes = base64Decode(b64);
      avatarNotifier.value = bytes;
      return bytes;
    } catch (_) {
      avatarNotifier.value = null;
      return null;
    }
  }

  Future<void> removeAvatar() async {
    await prefsService.remove(_keyAvatarBase64);
    avatarNotifier.value = null;
  }

  /// Seleciona imagem, sanitiza (remove EXIF por re-encode) e comprime.
  Future<Uint8List?> pickCompressAndSaveAvatar() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final sanitized = _sanitizeAndCompress(bytes);

    final b64 = base64Encode(sanitized);
    await prefsService.setString(_keyAvatarBase64, b64);

    // 🔥 atualiza listeners
    avatarNotifier.value = sanitized;
    return sanitized;
  }

  static String initialsFromEmail(String? email) {
    final e = (email ?? '').trim();
    if (e.isEmpty) return 'U';

    final beforeAt = e.split('@').first;
    final cleaned = beforeAt.replaceAll(RegExp(r'[^a-zA-Z0-9\. _-]'), '');

    final parts = cleaned
        .split(RegExp(r'[\. _-]+'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      final first = cleaned.isNotEmpty ? cleaned[0] : 'U';
      return first.toUpperCase();
    }

    final first = parts[0][0].toUpperCase();
    final second = parts.length > 1 ? parts[1][0].toUpperCase() : '';
    final initials = (first + second).trim();
    return initials.isEmpty ? 'U' : initials;
  }

  Uint8List _sanitizeAndCompress(Uint8List input) {
    try {
      final decoded = img.decodeImage(input);
      if (decoded == null) return input;

      final resized = _resizeMax(decoded, 512);

      // Re-encode remove metadados (EXIF/GPS)
      final jpg = img.encodeJpg(resized, quality: 80);
      return Uint8List.fromList(jpg);
    } catch (_) {
      return input;
    }
  }

  img.Image _resizeMax(img.Image src, int maxSide) {
    final w = src.width;
    final h = src.height;

    if (w <= maxSide && h <= maxSide) return src;

    if (w >= h) {
      final newW = maxSide;
      final newH = (h * (maxSide / w)).round();
      return img.copyResize(src, width: newW, height: newH);
    } else {
      final newH = maxSide;
      final newW = (w * (maxSide / h)).round();
      return img.copyResize(src, width: newW, height: newW);
    }
  }
}

final avatarService = AvatarService();
