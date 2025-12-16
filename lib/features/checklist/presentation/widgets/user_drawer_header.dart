import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:safecook/services/avatar_service.dart';

class UserDrawerHeader extends StatefulWidget {
  const UserDrawerHeader({super.key});

  @override
  State<UserDrawerHeader> createState() => _UserDrawerHeaderState();
}

class _UserDrawerHeaderState extends State<UserDrawerHeader> {
  Uint8List? _avatarBytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final bytes = await avatarService.loadAvatarBytes();
    if (!mounted) return;
    setState(() {
      _avatarBytes = bytes;
      _loading = false;
    });
  }

  Future<void> _pickAvatar() async {
    final bytes = await avatarService.pickCompressAndSaveAvatar();
    if (!mounted) return;
    if (bytes != null) {
      setState(() => _avatarBytes = bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto atualizada.')),
      );
    }
  }

  Future<void> _removeAvatar() async {
    await avatarService.removeAvatar();
    if (!mounted) return;
    setState(() => _avatarBytes = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto removida.')),
    );
  }

  void _openAvatarActions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher foto'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAvatar();
                },
              ),
              if (_avatarBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remover foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _removeAvatar();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final initials = AvatarService.initialsFromEmail(email);

    const double avatarSize = 72;

    final avatar = CircleAvatar(
      radius: avatarSize / 2,
      backgroundImage: _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
      child: _avatarBytes == null
          ? Text(
              initials,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            )
          : null,
    );

    // ✅ altura controlada (sem DrawerHeader)
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          height: 210, // suficiente para avatar + textos + botão sem overflow
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                button: true,
                label: 'Foto do usuário. Toque para alterar.',
                child: Tooltip(
                  message: 'Alterar foto do perfil',
                  child: InkWell(
                    onTap: _loading ? null : _openAvatarActions,
                    borderRadius: BorderRadius.circular(avatarSize),
                    child: SizedBox(
                      width: avatarSize,
                      height: avatarSize,
                      child: Center(child: avatar),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('SafeCook', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 2),
              Text(
                email.isEmpty ? 'Usuário' : email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // ✅ botão visível pra remover a foto
              if (_avatarBytes != null)
                SizedBox(
                  height: 44, // alvo bom (>= 48dp é recomendado; aqui está bem próximo, mas o ListTile abaixo também ajuda)
                  child: TextButton.icon(
                    onPressed: _removeAvatar,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remover foto'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
