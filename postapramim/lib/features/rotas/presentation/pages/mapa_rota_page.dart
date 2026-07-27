import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Mostra a rota do dia com posição atual, próximo destino, distância e
/// tempo estimado. A lógica de otimização de rota (ordenação das paradas)
/// fica no domain da feature `rotas` (ex.: OtimizarRotaUsecase), consumindo
/// a Directions API ou lógica própria; aqui só a apresentação.
class MapaRotaPage extends StatefulWidget {
  const MapaRotaPage({super.key});

  @override
  State<MapaRotaPage> createState() => _MapaRotaPageState();
}

class _MapaRotaPageState extends State<MapaRotaPage> {
  GoogleMapController? _mapController;

  static const _posicaoInicial = CameraPosition(
    target: LatLng(-12.9481, -39.0958), // Santo Antônio de Jesus, BA (fallback)
    zoom: 13,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rota do dia')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _posicaoInicial,
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers:
                const {}, // TODO: popular com paradas da rota (coletas do dia)
            polylines: const {}, // TODO: desenhar trajeto entre as paradas
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.navigation_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Próxima parada: aguardando dados da rota'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
