import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/checklist/presentation/pages/checklist_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/settings');
  }

  void _openChecklist(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChecklistListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // Se não estiver logado, manda pro login
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeCook'),
        actions: [
          IconButton(
            tooltip: user.email ?? 'Conta',
            icon: const Icon(Icons.account_circle),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.kitchen, size: 48),
                  SizedBox(height: 8),
                  Text('SafeCook', style: TextStyle(fontSize: 20)),
                  Text('Segurança na cozinha'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Checklist'),
              onTap: () {
                Navigator.of(context).pop();
                _openChecklist(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.of(context).pop();
                _openSettings(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.rice_bowl, size: 48, color: Color(0xFFEF4444)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Primeiros passos: Arroz sem erro',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text('Comece praticando um preparo simples com um checklist organizado.'),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => _openChecklist(context),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Abrir checklist'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_moon, size: 40, color: Color(0xFF374151)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Dicas rápidas de segurança',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('• Não deixe panelas no fogo sem supervisão.'),
                          SizedBox(height: 4),
                          Text('• Use luva térmica ao lidar com superfícies quentes.'),
                          SizedBox(height: 4),
                          Text('• Mantenha panos e plásticos longe da chama.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
