import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/localizacao.dart';

class MapaLocalizacoes extends StatelessWidget {
  const MapaLocalizacoes({
    super.key,
    required this.localizacoes,
    required this.controlador,
    required this.cache,
    required this.aoCarregar,
  });

  final List<Localizacao> localizacoes;
  final MapController controlador;
  final MapCachingProvider cache;
  final VoidCallback aoCarregar;

  @override
  Widget build(BuildContext context) {
    final primeira = localizacoes.first;

    return FlutterMap(
      mapController: controlador,
      options: MapOptions(
        initialCenter: LatLng(primeira.latitude, primeira.longitude),
        initialZoom: 15,
        onMapReady: aoCarregar,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'br.edu.fatec.atividade_localizacoes',
          tileProvider: NetworkTileProvider(cachingProvider: cache),
        ),
        MarkerLayer(
          markers: [
            for (var indice = 0; indice < localizacoes.length; indice++)
              Marker(
                point: LatLng(
                  localizacoes[indice].latitude,
                  localizacoes[indice].longitude,
                ),
                width: 40,
                height: 40,
                child: Icon(
                  Icons.location_on,
                  size: 36,
                  color: indice == 0 ? Colors.red : Colors.blue,
                ),
              ),
          ],
        ),
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
      ],
    );
  }
}
