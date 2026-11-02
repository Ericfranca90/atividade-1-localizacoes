import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class FalhaLocalizacao implements Exception {
  const FalhaLocalizacao(this.mensagem);

  final String mensagem;
}

class ServicoLocalizacao {
  Future<LocationPermission> prepararAcesso() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw const FalhaLocalizacao(
        'Ative o serviço de localização do dispositivo.',
      );
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.deniedForever) {
      throw const FalhaLocalizacao(
        'A permissão foi bloqueada. Abra as configurações do aplicativo.',
      );
    }

    if (permissao == LocationPermission.denied) {
      throw const FalhaLocalizacao(
        'A coleta depende da permissão de localização.',
      );
    }

    return permissao;
  }

  Stream<Position> obterPosicoes() {
    final configuracao = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      intervalDuration: const Duration(seconds: 20),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: 'Coleta de localização ativa',
        notificationText: 'As posições estão sendo salvas no aparelho.',
        notificationChannelName: 'Coleta de localização',
        notificationIcon: AndroidResource(
          name: 'ic_localizacoes',
          defType: 'mipmap',
        ),
        setOngoing: true,
        color: Color(0xFF006D77),
      ),
    );

    return Geolocator.getPositionStream(locationSettings: configuracao);
  }

  Future<bool> abrirConfiguracoesPermissao() {
    return Geolocator.openAppSettings();
  }
}
