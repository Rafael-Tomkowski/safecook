import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:safecook/services/avatar_service.dart';

class ProfileAppBarButton extends StatefulWidget {
  final VoidCallback onPressed;

  const ProfileAppBarButton({super.key, required this.onPressed});

  @override
  State<ProfileAppBarButton> createState() => _ProfileAppBarButtonState();
}

class _ProfileAppBarButtonState extends State<ProfileAppBarButton> {
  @override
  void initState() {
    super.initState();
    // garante que o avatar seja carregado do cache ao entrar na Home
    avatarService.loadAvatarBytes();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: avatarService.avatarNotifier,
      builder: (context, bytes, _) {
        final Widget icon = (bytes != null)
            ? CircleAvatar(
                radius: 14,
                backgroundImage: MemoryImage(bytes),
              )
            : const Icon(Icons.account_circle);

        return Semantics(
          button: true,
          label: 'Abrir configurações da conta',
          child: Tooltip(
            message: 'Conta / Configurações',
            child: IconButton(
              onPressed: widget.onPressed,
              icon: icon,
            ),
          ),
        );
      },
    );
  }
}
