import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/presentation/solicitacoes/providers/solicitacoes_providers.dart';
import 'package:postapramim/presentation/solicitacoes/status_solicitacao_ui.dart';

/// Mostra no mapa as solicitações em coleta/em trânsito, uma marcação por
/// endereço (geocodificado via `geocoding`).
class MapaRotaPage extends ConsumerStatefulWidget {
  const MapaRotaPage({super.key});

  @override
  ConsumerState<MapaRotaPage> createState() => _MapaRotaPageState();
}

class _MapaRotaPageState extends ConsumerState<MapaRotaPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _marcadores = {};
  bool _carregandoMarcadores = false;

  final Geocoding geocoding = Geocoding();
  static const _posicaoInicial = CameraPosition(
    target: LatLng(-12.9481, -39.0958), // Santo Antônio de Jesus, BA (fallback)
    zoom: 13,
  );

  Future<void> _atualizarMarcadores(List<SolicitacaoEntity> lista) async {
    final emAberto = lista.where(
      (s) =>
          s.status.grupoExibicao == GrupoStatusExibicao.coleta ||
          s.status.grupoExibicao == GrupoStatusExibicao.emtransito,
    );

    setState(() => _carregandoMarcadores = true);
    final novos = <Marker>{};
    for (final s in emAberto) {
      final endereco = s.enderecoResumo;
      if (endereco == null) continue;
      try {
        final locais = await geocoding.locationFromAddress(endereco);
        if (locais.isEmpty) continue;
        final local = locais.first;
        novos.add(
          Marker(
            markerId: MarkerId(s.id),
            position: LatLng(local.latitude, local.longitude),
            infoWindow: InfoWindow(
              title: s.codigoDevolucao ?? s.id.substring(0, 8).toUpperCase(),
              snippet: '${s.nomeExibicao} • ${s.status.label}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              s.status.grupoExibicao == GrupoStatusExibicao.emtransito
                  ? BitmapDescriptor.hueAzure
                  : BitmapDescriptor.hueOrange,
            ),
          ),
        );
      } catch (_) {
        // Endereço não geocodificável — ignora.
      }
    }
    if (!mounted) return;
    setState(() {
      _marcadores
        ..clear()
        ..addAll(novos);
      _carregandoMarcadores = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(todasSolicitacoesRealtimeProvider);

    ref.listen(todasSolicitacoesRealtimeProvider, (prev, next) {
      next.whenData(_atualizarMarcadores);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Rota do dia')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _posicaoInicial,
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _marcadores,
          ),
          if (_carregandoMarcadores)
            const Positioned(
              top: 12,
              right: 12,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: async.when(
                  loading: () => const Row(
                    children: [
                      Icon(Icons.navigation_outlined),
                      SizedBox(width: 12),
                      Expanded(child: Text('Carregando solicitações...')),
                    ],
                  ),
                  error: (e, _) => const Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.erro),
                      SizedBox(width: 12),
                      Expanded(child: Text('Erro ao carregar as solicitações')),
                    ],
                  ),
                  data: (lista) {
                    final abertas = lista
                        .where(
                          (s) =>
                              s.status.grupoExibicao ==
                                  GrupoStatusExibicao.coleta ||
                              s.status.grupoExibicao ==
                                  GrupoStatusExibicao.emtransito,
                        )
                        .length;
                    return Row(
                      children: [
                        const Icon(Icons.navigation_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            abertas == 0
                                ? 'Nenhuma coleta em aberto no momento'
                                : '$abertas coleta(s) em aberto na região',
                            style: AppTextStyles.corpo,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
