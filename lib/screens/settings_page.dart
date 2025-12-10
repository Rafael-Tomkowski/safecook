import 'package:flutter/material.dart';
import '../main.dart'; // importa o appTheme e prefsService

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _revogarConsentimento(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Revogar consentimento'),
        content: const Text(
            'Tem certeza que deseja revogar o consentimento? Você será redirecionado para o fluxo legal novamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Revogar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await prefsService.clearLegalData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consentimento revogado.')),
        );

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/policy',
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          // 🔥 MODO ESCURO
          SwitchListTile(
            title: const Text('Modo escuro'),
            subtitle: const Text('Aplicar tema escuro em todo o app'),
            value: appTheme.isDark,
            onChanged: (value) {
              appTheme.setDarkMode(value);
            },
          ),

          const Divider(),

          // 🔥 Revogação de consentimento (já existia)
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Revogar consentimento'),
            subtitle: const Text('Você terá que aceitar as políticas novamente'),
            onTap: () => _revogarConsentimento(context),
          ),
        ],
      ),
    );
  }
}
