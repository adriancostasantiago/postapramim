import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:posta_pra_mim/core/router/app_routes.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/core/utils/currency_formatter.dart';
import 'package:posta_pra_mim/domain/entities/novo_pedido.dart';

/// Tela de pagamento via Pix — exibida após a criação bem-sucedida
/// do pedido quando a forma selecionada é Pix.
class PagamentoPixPage extends StatefulWidget {
  const PagamentoPixPage({required this.pagamento, super.key});

  final PagamentoPix pagamento;

  @override
  State<PagamentoPixPage> createState() => _PagamentoPixPageState();
}

class _PagamentoPixPageState extends State<PagamentoPixPage> {
  late Timer _timer;
  late Duration _restante;

  @override
  void initState() {
    super.initState();
    _restante = widget.pagamento.expiracao.difference(DateTime.now());
    if (_restante.isNegative) _restante = Duration.zero;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _restante = widget.pagamento.expiracao.difference(DateTime.now());
        if (_restante.isNegative) {
          _restante = Duration.zero;
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final m = _restante.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _restante.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _copiarCodigo() {
    Clipboard.setData(
      ClipboardData(text: widget.pagamento.codigoCopiaCola),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código Pix copiado!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmarPagamento() {
    context.go(AppRoutes.managerDashboard);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pedido ${widget.pagamento.codigoPedido} aguardando '
          'confirmação do pagamento.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pix = widget.pagamento;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.go(AppRoutes.managerDashboard),
          tooltip: 'Voltar ao início',
        ),
        title: const Text(
          'Pagamento via Pix',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.notifications_none_outlined,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            // Valor e descrição
            const Text(
              'Valor Total',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(pix.valor),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined,
                    size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    pix.descricaoEnvio,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Escaneie o QR Code',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Abra o app do seu banco para pagar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // QR Code stub — CustomPaint sem dependência de SDK
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(
                        painter: _QrCodeStubPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Timer
                  if (_restante > Duration.zero)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 16, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text(
                          'Expira em $_timerLabel',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'QR Code expirado.',
                      style: TextStyle(color: AppColors.error),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Copia e Cola
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ou use o Pix Copia e Cola',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          pix.codigoCopiaCola,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _copiarCodigo,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.copy,
                              size: 16, color: AppColors.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Instruções
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      const Text(
                        'Instruções',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final instrucao in const [
                    'O pagamento é processado instantaneamente.',
                    'Após concluir, você receberá a confirmação por e-mail.',
                    'Mantenha esta tela aberta até a confirmação.',
                  ]) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            instrucao,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _confirmarPagamento,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Já realizei o pagamento',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

/// QR Code desenhado com `CustomPainter` — padrão de stub visual já
/// usado em `LocalizacaoPreview` e `MapaPreviewStub`. Para exibir
/// um QR real: use `qr_flutter` e passe [PagamentoPix.codigoCopiaCola]
/// ao `QrImageView`.
class _QrCodeStubPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final cell = size.width / 21;
    final dark = Paint()..color = const Color(0xFF191C21);

    // Finder patterns (cantos)
    void drawFinder(double ox, double oy) {
      canvas.drawRect(Rect.fromLTWH(ox, oy, cell * 7, cell * 7), dark);
      canvas.drawRect(
          Rect.fromLTWH(ox + cell, oy + cell, cell * 5, cell * 5), bg);
      canvas.drawRect(
          Rect.fromLTWH(ox + cell * 2, oy + cell * 2, cell * 3, cell * 3),
          dark);
    }

    drawFinder(0, 0);
    drawFinder(size.width - cell * 7, 0);
    drawFinder(0, size.height - cell * 7);

    // Dados simulados (padrão xadrez na área de dados)
    final rand = (size.width * 31).toInt();
    for (var row = 8; row < 21; row++) {
      for (var col = 8; col < 21; col++) {
        if ((row + col + rand) % 3 != 0) continue;
        canvas.drawRect(
          Rect.fromLTWH(col * cell, row * cell, cell, cell),
          dark,
        );
      }
    }

    // Borda pontilhada amarela
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = AppColors.primaryYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _QrCodeStubPainter old) => false;
}
