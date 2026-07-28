import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';

class AjudaPage extends StatelessWidget {
  const AjudaPage({super.key});

  static const _telefone = '+5575992873792';
  static const _email = 'contato@postapramim.com.br';

  Future<void> _ligar() async {
    final uri = Uri.parse('tel:$_telefone');
    if (!await launchUrl(uri)) throw Exception('Não foi possível ligar.');
  }

  Future<void> _whatsapp() async {
    final numero = _telefone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse(
      'https://wa.me/$numero?text=${Uri.encodeComponent('Olá! Preciso de ajuda com o app Posta Pra Mim.')}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Não foi possível abrir o WhatsApp.');
    }
  }

  Future<void> _abrirEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      query: 'subject=${Uri.encodeComponent('Ajuda - Posta Pra Mim')}',
    );
    if (!await launchUrl(uri))
      throw Exception('Não foi possível abrir o e-mail.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.preto),
        title: Text(
          'Ajuda',
          style: AppTextStyles.titulo.copyWith(color: AppColors.preto),
        ),
        backgroundColor: AppColors.branco,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Fale com a gente',
            style: AppTextStyles.subtitulo.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 4),
          Text(
            'Escolha o canal que preferir — nossa equipe responde rapidinho.',
            style: AppTextStyles.legenda,
          ),
          const SizedBox(height: 20),
          _CanalContato(
            icone: Icons.chat_outlined,
            cor: const Color(0xFF25D366),
            titulo: 'WhatsApp',
            subtitulo: _telefone,
            onTap: _whatsapp,
          ),
          const SizedBox(height: 12),
          _CanalContato(
            icone: Icons.call_outlined,
            cor: AppColors.azulInstitucional,
            titulo: 'Ligar',
            subtitulo: _telefone,
            onTap: _ligar,
          ),
          const SizedBox(height: 12),
          _CanalContato(
            icone: Icons.mail_outline,
            cor: AppColors.amareloEscuro,
            titulo: 'E-mail',
            subtitulo: _email,
            onTap: _abrirEmail,
          ),
          const SizedBox(height: 28),
          Text(
            'Perguntas frequentes',
            style: AppTextStyles.subtitulo.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const _PerguntaFrequente(
            pergunta: 'Quanto tempo leva para minha coleta ser aceita?',
            resposta:
                'Assim que você solicita, qualquer coletador da região pode aceitar. '
                'Normalmente isso acontece em poucas horas.',
          ),
          const _PerguntaFrequente(
            pergunta: 'Posso cancelar uma solicitação?',
            resposta:
                'Sim, enquanto ela não estiver concluída. Acesse os detalhes da '
                'solicitação e toque em "Cancelar solicitação".',
          ),
          const _PerguntaFrequente(
            pergunta: 'Como acompanho minha coleta?',
            resposta:
                'Na tela inicial ou em "Solicitações" você vê o status atualizado '
                'em tempo real de cada devolução.',
          ),
        ],
      ),
      // bottomNavigationBar: NavigationBar(
      //   backgroundColor: AppColors.branco,
      //   indicatorColor: AppColors.darkFundo,
      //   labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
      //     if (states.contains(WidgetState.selected)) {
      //       return AppTextStyles.legenda.copyWith(
      //         color: AppColors.darkFundo,
      //         fontWeight: FontWeight.bold,
      //       );
      //     }

      //     return AppTextStyles.legenda.copyWith(color: AppColors.darkFundo);
      //   }),
      //   selectedIndex: 2,
      //   onDestinationSelected: (i) {
      //     switch (i) {
      //       case 0:
      //         context.push(RoutePaths.coletadorDashboard);
      //         break;
      //       case 1:
      //         context.push(RoutePaths.coletadorMinhasColetas);
      //         break;
      //       // case 2:
      //       //   context.push(RoutePaths.coletadorMapaRota);
      //       //   break;
      //       // case 2:
      //       //   context.push(RoutePaths.ajuda);
      //       //   break;
      //       case 3:
      //         context.push(RoutePaths.perfil);
      //         break;
      //     }
      //   },
      //   destinations: const [
      //     NavigationDestination(
      //       icon: Icon(Icons.home_outlined, color: AppColors.cinzaTexto),
      //       label: 'Início',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.inventory_2_outlined, color: AppColors.cinzaTexto),
      //       label: 'Solicitações',
      //     ),
      //     // NavigationDestination(
      //     //   icon: Icon(Icons.map_outlined, color: AppColors.cinzaTexto),
      //     //   label: 'Rotas',
      //     // ),
      //     NavigationDestination(
      //       icon: Icon(Icons.help_outline, color: AppColors.branco),
      //       label: 'Ajuda',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.person_outline, color: AppColors.cinzaTexto),
      //       label: 'Conta',
      //     ),
      //   ],
      // ),
    );
  }
}

class _CanalContato extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _CanalContato({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cinzaBorda),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: cor.withValues(alpha: .12),
              child: Icon(icone, color: cor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitulo, style: AppTextStyles.legenda),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.cinzaTexto),
          ],
        ),
      ),
    );
  }
}

class _PerguntaFrequente extends StatelessWidget {
  final String pergunta;
  final String resposta;
  const _PerguntaFrequente({required this.pergunta, required this.resposta});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          pergunta,
          style: AppTextStyles.corpo.copyWith(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.only(bottom: 12),
        expandedAlignment: Alignment.centerLeft,
        children: [Text(resposta, style: AppTextStyles.legenda)],
      ),
    );
  }
}
