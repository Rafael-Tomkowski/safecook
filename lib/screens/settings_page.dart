import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _revokeConsent(BuildContext context) async {
    await prefsService.clearConsent();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consentimento revogado.')),
    );

    // volta ao fluxo (vai pedir onboarding/policy novamente)
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    return AnimatedBuilder(
      animation: appTheme, // 🔥 agora o switch atualiza sem travar
      builder: (context, _) {
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
                onChanged: (value) => appTheme.setDarkMode(value),
              ),
              const Divider(),

              if (user != null)
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: Text(user.email ?? 'Usuário logado'),
                  subtitle: const Text('Sessão ativa no Supabase'),
                ),

              if (user == null)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Login / Conta'),
                  subtitle: const Text('Entrar ou criar uma conta no SafeCook'),
                  onTap: () => Navigator.of(context).pushNamed('/login'),
                ),

              if (user != null)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sair'),
                  subtitle: const Text('Encerrar sessão e voltar ao login'),
                  onTap: () async {
                    await supabase.auth.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
                  },
                ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.gpp_bad),
                title: const Text('Revogar consentimento'),
                subtitle: const Text('Apaga o aceite local e reinicia o fluxo de políticas'),
                onTap: () => _revokeConsent(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
