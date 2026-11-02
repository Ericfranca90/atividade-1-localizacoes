import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/cache_mapa.dart';
import '../widgets/mapa_localizacoes.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final _repositorio = RepositorioLocalizacoes();
  final _controlador = MapController();

  List<Localizacao> _localizacoes = [];
  MapCachingProvider? _cache;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final cache = await CacheMapa.preparar();
      final registros = await _repositorio.listarUltimas();
      if (!mounted) return;
      setState(() {
        _cache = cache;
        _localizacoes = registros;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível carregar o mapa.');
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _enquadrarPontos() {
    if (_localizacoes.isEmpty) return;

    final pontos = _localizacoes
        .map((item) => LatLng(item.latitude, item.longitude))
        .toList();

    if (pontos.length == 1) {
      _controlador.move(pontos.first, 16);
      return;
    }

    _controlador.fitCamera(
      CameraFit.coordinates(
        coordinates: pontos,
        padding: const EdgeInsets.all(40),
        maxZoom: 16,
      ),
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de localizações'),
        actions: [
          IconButton(
            onPressed: _carregando ? null : _carregar,
            tooltip: 'Atualizar registros',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _construirConteudo(),
      floatingActionButton:
          !_carregando && _erro == null && _localizacoes.isNotEmpty
          ? FloatingActionButton(
              onPressed: _enquadrarPontos,
              tooltip: 'Enquadrar todos os pontos',
              child: const Icon(Icons.center_focus_strong),
            )
          : null,
    );
  }

  Widget _construirConteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _carregar,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_localizacoes.isEmpty || _cache == null) {
      return const Center(child: Text('Nenhuma localização registrada.'));
    }

    return MapaLocalizacoes(
      localizacoes: _localizacoes,
      controlador: _controlador,
      cache: _cache!,
      aoCarregar: _enquadrarPontos,
    );
  }
}
