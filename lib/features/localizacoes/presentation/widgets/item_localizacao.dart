import 'package:flutter/material.dart';

import '../../models/localizacao.dart';

class ItemLocalizacao extends StatelessWidget {
  const ItemLocalizacao({super.key, required this.localizacao});

  final Localizacao localizacao;

  String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');

  String _formatarData(DateTime instante) {
    final data = instante.toLocal();
    return '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}/${data.year} '
        '${_doisDigitos(data.hour)}:${_doisDigitos(data.minute)}:'
        '${_doisDigitos(data.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(_formatarData(localizacao.instante)),
        subtitle: Text(
          'Latitude: ${localizacao.latitude.toStringAsFixed(6)}\n'
          'Longitude: ${localizacao.longitude.toStringAsFixed(6)}\n'
          'Precisão: ${localizacao.precisao.toStringAsFixed(1)} m',
        ),
      ),
    );
  }
}
