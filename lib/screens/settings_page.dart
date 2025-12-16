import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // appTheme e prefsService

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final loggedIn = user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo escuro'),
            subtitle: const Text('Aplicar tema escuro em todo o app'),
            value: appTheme.isDark,
            onChanged: (value) {
              appTheme.setDarkMode(value);
            },
          ),
          const Divider(),

          if (loggedIn)
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: Text(user!.email ?? 'Usuário logado'),
              subtitle: const Text('Sessão ativa no Supabase'),
            ),

          if (!loggedIn)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Login / Conta'),
              subtitle: const Text('Entrar ou criar uma conta no SafeCook'),
              onTap: () {
                Navigator.of(context).pushNamed('/login');
              },
            ),

          if (loggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              subtitle: const Text('Encerrar sessão e voltar ao login'),
              onTap: () async {
                await supabase.auth.signOut();

                // opcional: manter flag local por compatibilidade
                try {
                  await prefsService.setLoggedIn(false);
                } catch (_) {}

                if (!context.mounted) return;

                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}
