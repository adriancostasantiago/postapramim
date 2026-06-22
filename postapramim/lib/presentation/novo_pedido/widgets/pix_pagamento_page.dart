import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/core/utils/currency_formatter.dart';

/// Tela de confirmação do pagamento via Pix.
/// Exibida como uma "sub-página" após o usuário tocar em
/// "Finalizar Pedido" no passo de Revisão com Pix selecionado.
class PixPagamentoPage extends StatefulWidget {
  const PixPagamentoPage({
    required this.codigoPedido,
    required this.valor,
    required this.onConfirmar,
    super.key,
  });

  final String codigoPedido;
  final double valor;
  final VoidCallback onConfirmar;

  @override
  State<PixPagamentoPage> createState() => _PixPagamentoPageState();
}

class _PixPagamentoPageState extends State<PixPagamentoPage> {
  static const _pixCopiaCola =
      '00020101021226840014br.gov.bcb.pix01368d0f9...';

  void _copiarCodigo() {
    Clipboard.setData(const ClipboardData(text: _pixCopiaCola));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código Pix copiado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Voltar',
        ),
        title: const Text(
          'Pagamento via Pix',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_outlined,
                  color: AppColors.onSurface),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Valor Total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor Total',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(widget.valor),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined,
                            size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          'Envio #${widget.codigoPedido} · Centro de SP',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // QR Code
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Escaneie o QR Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Abra o app do seu banco para pagar',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: const _QrCodePlaceholder(),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time,
                              size: 14, color: AppColors.error),
                          const SizedBox(width: 6),
                          const Text(
                            'Expira em 28:57',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pix Copia e Cola
              const Text(
                'Ou use o Pix Copia e Cola',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Text(
                          _pixCopiaCola,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _copiarCodigo,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.copy,
                            size: 18, color: AppColors.onPrimary),
                      ),
                    ),
                  ],
                ),
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
                    const SizedBox(height: 8),
                    _BulletItem('O pagamento é processado instantaneamente.'),
                    _BulletItem(
                        'Após concluir, você receberá a confirmação por e-mail.'),
                    _BulletItem(
                        'Mantenha esta tela aberta até a confirmação.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onConfirmar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle_outline, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Já realizei o pagamento',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 12, color: AppColors.primary)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder do QR Code desenhado em CustomPaint.
class _QrCodePlaceholder extends StatelessWidget {
  const _QrCodePlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _QrPainter());
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.onSurface
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 21;

    // Representação simplificada de um QR code (padrão de finder)
    void drawCell(int col, int row) {
      canvas.drawRect(
        Rect.fromLTWH(col * cellSize + 8, row * cellSize + 8,
            cellSize - 1, cellSize - 1),
        paint,
      );
    }

    // Finder pattern top-left
    for (var r = 0; r < 7; r++) {
      for (var c = 0; c < 7; c++) {
        final edge = r == 0 || r == 6 || c == 0 || c == 6;
        final inner = r >= 2 && r <= 4 && c >= 2 && c <= 4;
        if (edge || inner) drawCell(c, r);
      }
    }

    // Finder pattern top-right
    for (var r = 0; r < 7; r++) {
      for (var c = 14; c < 21; c++) {
        final col = c - 14;
        final edge = r == 0 || r == 6 || col == 0 || col == 6;
        final inner = r >= 2 && r <= 4 && col >= 2 && col <= 4;
        if (edge || inner) drawCell(c, r);
      }
    }

    // Finder pattern bottom-left
    for (var r = 14; r < 21; r++) {
      for (var c = 0; c < 7; c++) {
        final row = r - 14;
        final edge = row == 0 || row == 6 || c == 0 || c == 6;
        final inner = row >= 2 && row <= 4 && c >= 2 && c <= 4;
        if (edge || inner) drawCell(c, r);
      }
    }

    // Dados aleatórios simulados no centro
    final dataCells = [
      [9, 9], [11, 9], [13, 9], [10, 10], [12, 10],
      [9, 11], [10, 11], [12, 11], [13, 11], [11, 12],
      [9, 13], [11, 13], [13, 13], [10, 14], [12, 14],
    ];
    for (final cell in dataCells) {
      drawCell(cell[0], cell[1]);
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) => false;
}
