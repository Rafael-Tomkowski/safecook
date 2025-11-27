import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../main.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  final ScrollController _scrollController = ScrollController();
  bool _canMarkRead = false;
  bool _markedRead = false;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Quando chegar bem perto do final, libera o botão
    if (!_canMarkRead &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 20) {
      setState(() {
        _canMarkRead = true;
      });
    }
  }

  String get _policyText => '''
Política de Privacidade e Termos de Uso – SafeCook (versão 1)

O SafeCook foi desenvolvido como um aplicativo educacional para auxiliar estudantes
e iniciantes na cozinha a adotarem práticas mais seguras durante o preparo de alimentos.
Nosso foco é apresentar checklists, lembretes e orientações gerais, sem substituir o
bom senso, a atenção e o acompanhamento de pessoas mais experientes quando necessário.

1. Coleta e Armazenamento de Dados

O SafeCook não coleta dados pessoais sensíveis, como CPF, endereço, dados bancários
ou informações de saúde. As únicas informações armazenadas são preferências de uso,
como flags de aceite de políticas e configurações locais, que permanecem apenas no
seu dispositivo e podem ser apagadas a qualquer momento através da opção de
revogação de consentimento nas configurações.

2. Uso das Informações

As informações salvas localmente são utilizadas exclusivamente para:
- lembrar se você já concluiu o onboarding;
- registrar se você já leu e aceitou esta política;
- personalizar algumas mensagens de primeiros passos dentro do app.

Nenhum desses dados é enviado para servidores externos ou compartilhado com terceiros.

3. Segurança na Cozinha

O SafeCook oferece checklists e passos sugeridos para atividades comuns na cozinha,
como preparo de arroz, manipulação de utensílios e noções básicas de segurança.
No entanto, o app não consegue monitorar o ambiente real, a condição dos equipamentos
ou a sua atenção no momento do uso. Por isso, você deve sempre:

- manter crianças e animais afastados do fogão;
- evitar deixar panos, plásticos ou materiais inflamáveis próximos a chamas;
- usar luvas térmicas e utensílios adequados para lidar com superfícies quentes;
- verificar cabos de aparelhos elétricos e não utilizá-los danificados;
- nunca deixar panelas no fogo sem supervisão.

4. Limitação de Responsabilidade

O uso do SafeCook é de responsabilidade do usuário. O aplicativo é apenas um apoio
educacional e de organização. Situações como queimaduras, incêndios, danos a
equipamentos ou qualquer outro incidente decorrente de uso inadequado de fogão,
forno, óleo quente, facas ou qualquer instrumento de cozinha não podem ser
atribuídas ao aplicativo.

5. Atualizações da Política

Esta política pode ser atualizada para refletir melhorias no aplicativo ou mudanças
de requisitos legais. Quando uma nova versão for publicada, o app poderá solicitar
que você leia e aceite novamente os termos antes de continuar a usar todas
as funcionalidades.

6. Revogação de Consentimento

Caso você deseje revogar o aceite desta política, poderá fazê-lo pelo menu de
Configurações do aplicativo. Ao revogar, o registro local do aceite é apagado e
você poderá ser direcionado novamente ao fluxo de leitura e consentimento ao
reabrir ou continuar usando o app.

7. Contato e Dúvidas

Este projeto é acadêmico e voltado para estudo de desenvolvimento mobile.
Em caso de dúvidas sobre o funcionamento, recomenda-se contatar o responsável
pelo projeto ou o professor da disciplina.

(role até o fim para habilitar "Marcar como lido")
''';

  Future<void> _markAsRead() async {
    setState(() {
      _markedRead = true;
    });
    await prefsService.setPrivacyReadV1(true);
    await prefsService.setTermsReadV1(true);
  }

  Future<void> _acceptAndContinue() async {
    if (!_markedRead || !_accepted) return;
    await prefsService.setPoliciesAccepted('v1');
    await prefsService.setOnboardingCompleted(true);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _markedRead && _accepted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Políticas e Consentimento'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _canMarkRead ? 1.0 : null,
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Text(
                _policyText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton(
                  onPressed: _canMarkRead && !_markedRead ? _markAsRead : null,
                  child: const Text('Marcar como lido'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _accepted,
                      onChanged: _markedRead
                          ? (val) {
                              setState(() {
                                _accepted = val ?? false;
                              });
                            }
                          : null,
                    ),
                    const Expanded(
                      child: Text(
                        'Eu li e concordo com a Política de Privacidade e os Termos de Uso.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: canConfirm ? _acceptAndContinue : null,
                    child: const Text('Concordar e continuar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
