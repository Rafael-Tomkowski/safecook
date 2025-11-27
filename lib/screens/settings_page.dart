import 'package:flutter/material.dart';
import '../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _revokeConsent(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Revogar consentimento'),
        content: const Text(
            'Isso vai limpar seu aceite e voltar ao fluxo inicial do app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Revogar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await prefsService.clearConsent();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Consentimento revogado')));
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/onboarding', (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacidade',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aqui você pode revogar o consentimento.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text('Revogar consentimento'),
              onPressed: () => _revokeConsent(context),
            )
          ],
        ),
      ),
    );
  }
}
