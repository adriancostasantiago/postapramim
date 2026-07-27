import 'dart:async';

import 'package:flutter/material.dart';
import 'package:postapramim/app/theme/app_colors.dart';

/// Cartão branco que substitui o antigo SplashActionCard (com botões de
/// "Começar agora" / "Fazer login"). Aqui a splash não pede nenhuma ação
/// do usuário: apenas mostra um loading com mensagens rotativas enquanto
/// o [AuthControllerNotifier] decide a rota de destino.
class SplashLoadingCard extends StatefulWidget {
  const SplashLoadingCard({super.key});

  @override
  State<SplashLoadingCard> createState() => _SplashLoadingCardState();
}

class _SplashLoadingCardState extends State<SplashLoadingCard> {
  static const _mensagens = [
    'Preparando tudo para você...',
    'Organizando sua experiência...',
    'Verificando sua sessão...',
    'Conectando aos nossos serviços...',
    'Carregando suas informações...',
    'Conferindo tudo com segurança...',
    'Localizando os pontos de coleta...',
    'Quase tudo pronto...',
    'Deixando tudo pronto para você postar...',
    'Conectando você à nossa rede de entregas...',
    'Só mais alguns segundos...',
    'Estamos quase lá...',
    'Tudo pronto para enviar com rapidez!',
  ];

  int _indice = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() => _indice = (_indice + 1) % _mensagens.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(AppColors.darkFundo),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _mensagens[_indice],
            key: ValueKey(_indice),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.darkFundo.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
