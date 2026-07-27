import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/presentation/auth/widgets/opcao_card.dart';

/// Primeira tela que um usuário não autenticado vê (após a Splash).
/// Segue exatamente o Design System aprovado: topo amarelo com a proposta
/// de valor + ilustração, e um "sheet" branco arredondado com as duas
/// formas de continuar — sem cadastro (fluxo avulso) ou com conta
/// (login/cadastro, para acompanhar histórico).
class BoasVindasPage extends StatelessWidget {
  const BoasVindasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.amarelo,
      body: SafeArea(
        child: Stack(
          children: [
            // Fundo amarelo
            Container(color: AppColors.amarelo),

            // Topo (logo + texto + caminhão)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * .42,
              child: const _TopoBoasVindas(),
            ),

            // Card branco
            Positioned(
              left: 0,
              right: 0,
              top: size.height * .37,
              bottom: 0,
              child: const _MenuBoasVindas(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuBoasVindas extends StatelessWidget {
  const _MenuBoasVindas();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      decoration: const BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Como deseja continuar?',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitulo.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            // const SizedBox(height: 4),
            Text(
              'Escolha a opção que melhor se adapta a você.',
              textAlign: TextAlign.center,
              style: AppTextStyles.corpo.copyWith(
                fontSize: 14,
                color: AppColors.cinzaTexto,
              ),
            ),

            const SizedBox(height: 10),

            OpcaoCard(
              icone: 'assets/icons/icone_solicitar_sem_cadastro.png',
              corFundoIcone: AppColors.amarelo.withValues(alpha: .25),
              titulo: 'Solicitar sem cadastro',
              subtitulo: 'Ideal para uma única devolução.',
              botaoLabel: 'Nova Solicitação',
              botaoPreenchido: true,
              onPressed: () => context.push(RoutePaths.solicitarSemCadastro),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.cinzaBorda)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('ou', style: AppTextStyles.legenda),
                ),
                const Expanded(child: Divider(color: AppColors.cinzaBorda)),
              ],
            ),

            const SizedBox(height: 10),

            OpcaoCard(
              icone: 'assets/icons/icone_entrar_criar_conta.png',
              corFundoIcone: AppColors.azulInstitucional.withValues(alpha: .12),
              titulo: 'Entrar ou criar conta',
              subtitulo: 'Acompanhe suas devoluções e histórico.',
              botaoLabel: 'Entrar / Cadastrar',
              botaoPreenchido: false,
              onPressed: () => context.push(RoutePaths.login),
            ),

            const SizedBox(height: 10),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 18,
                    color: AppColors.cinzaTexto,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Dúvidas? ',
                    style: AppTextStyles.corpo.copyWith(
                      color: AppColors.cinzaTexto,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Abrir WhatsApp ou suporte
                    },
                    child: Text(
                      'Fale com a gente',
                      style: AppTextStyles.corpo.copyWith(
                        color: AppColors.azulInstitucional,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopoBoasVindas extends StatelessWidget {
  const _TopoBoasVindas();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.amarelo),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // IMAGEM DE FUNDO
          Positioned(
            top: 0,
            bottom: 40,
            right: -30,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/ilustracao_boas_vindas.png',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          // Gradiente opcional para melhorar a leitura do texto
          // Container(
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.centerLeft,
          //       end: Alignment.centerRight,
          //       colors: [
          //         AppColors.amarelo,
          //         AppColors.amarelo.withOpacity(.95),
          //         Colors.transparent,
          //       ],
          //       stops: const [0.0, .45, 1],
          //     ),
          //   ),
          // ),

          // Conteúdo
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 40, right: 24),
            child: SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo.png', height: 58),

                  const SizedBox(height: 20),

                  Text(
                    'Devolva sua\nencomenda sem\nsair de casa.',
                    style: AppTextStyles.titulo.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: 220,
                    child: Text(
                      'Informe seu código de devolução e nós cuidamos da postagem para você.',
                      style: AppTextStyles.corpo.copyWith(
                        fontSize: 14,
                        color: AppColors.cinzaTexto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
