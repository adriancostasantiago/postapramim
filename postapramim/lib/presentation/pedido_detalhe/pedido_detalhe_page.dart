import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/domain/entities/pedido_detalhe.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';
import 'package:posta_pra_mim/domain/usecases/pedido_usecases.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/widgets/manager_bottom_nav.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/carga_info_card.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/despacho_status_stepper.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/destinatario_card.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/documento_list_item.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/financeiro_card.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/localizacao_preview.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/pedido_detalhe_app_bar.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/status_info_banner.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/urgencia_banner.dart';
import 'package:posta_pra_mim/presentation/shared/state/pedido_detalhe_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/pedido_detalhe_state.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/remetente_card.dart';

/// Tela de detalhes de um pedido — aberta ao tocar em um `PedidoCard`
/// na lista do dashboard. Não chama rede/IO diretamente: delega ao
/// `PedidoDetalheController`, instanciado localmente para esta página
/// (escopo por `pedidoId`, diferente dos controllers globais
/// registrados em `AppProviders`).
class PedidoDetalhePage extends StatelessWidget {
  const PedidoDetalhePage({required this.pedidoId, super.key});

  final String pedidoId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PedidoDetalheController>(
      create: (ctx) => PedidoDetalheController(
        getPedidoDetalheUseCase: ctx.read<GetPedidoDetalheUseCase>(),
      )..load(pedidoId),
      child: const _PedidoDetalheView(),
    );
  }
}

class _PedidoDetalheView extends StatefulWidget {
  const _PedidoDetalheView();

  @override
  State<_PedidoDetalheView> createState() => _PedidoDetalheViewState();
}

class _PedidoDetalheViewState extends State<_PedidoDetalheView> {
  // "Histórico" como aba inicial — chegada via lista de pedidos
  // recentes do dashboard.
  int _bottomNavIndex = 1;

  void _showPlaceholderSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PedidoDetalheController>().state;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PedidoDetalheAppBar(
        codigo: switch (state) {
          PedidoDetalheLoaded(:final detalhe) => detalhe.pedido.codigo,
          _ => '...',
        },
        isUrgente: switch (state) {
          PedidoDetalheLoaded(:final detalhe) =>
            detalhe.pedido.prioridade == PedidoPrioridade.urgente,
          _ => false,
        },
        onMoreOptions: () => _showPlaceholderSnackBar('Mais opções em breve.'),
      ),
      body: SafeArea(
        top: false,
        child: switch (state) {
          PedidoDetalheInitial() ||
          PedidoDetalheLoading() =>
            const _LoadingView(),
          PedidoDetalheError(:final failure) => _ErrorView(
              message: failure.message,
              onRetry: () => context.read<PedidoDetalheController>().retry(),
            ),
          PedidoDetalheLoaded(:final detalhe) =>
            _DetalheContent(detalhe: detalhe),
        },
      ),
      bottomNavigationBar: ManagerBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          _showPlaceholderSnackBar('Navegação em breve.');
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetalheContent extends StatelessWidget {
  const _DetalheContent({required this.detalhe});

  final PedidoDetalhe detalhe;

  void _showPlaceholderSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final pedido = detalhe.pedido;
    final localizacao = detalhe.localizacaoAtual;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text(
          'STATUS DO DESPACHO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        DespachoStatusStepper(status: pedido.status),
        const SizedBox(height: 16),
        StatusInfoBanner(message: detalhe.mensagemStatus),
        const SizedBox(height: 24),
        RemetenteCard(remetente: detalhe.remetente),
        const SizedBox(height: 24),
        DestinatarioCard(destinatario: detalhe.destinatario),
        const SizedBox(height: 20),
        CargaInfoCard(carga: detalhe.carga),
        if (pedido.prioridade == PedidoPrioridade.urgente) ...[
          const SizedBox(height: 12),
          const UrgenciaBanner(),
        ],
        const SizedBox(height: 20),
        FinanceiroCard(
          formaPagamento: pedido.formaPagamento,
          valor: pedido.valor,
          dataPagamento: detalhe.dataPagamento,
        ),
        if (detalhe.documentos.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'DOCUMENTAÇÃO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          for (final documento in detalhe.documentos)
            DocumentoListItem(
              documento: documento,
              onDownload: () => _showPlaceholderSnackBar(
                context,
                'Download de "${documento.titulo}" em breve.',
              ),
            ),
        ],
        if (localizacao != null) ...[
          const SizedBox(height: 4),
          LocalizacaoPreview(localizacao: localizacao),
        ],
      ],
    );
  }
}
