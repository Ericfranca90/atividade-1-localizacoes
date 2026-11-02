import '../../models/localizacao.dart';
import '../database/banco_localizacoes.dart';

class RepositorioLocalizacoes {
  RepositorioLocalizacoes({BancoLocalizacoes? banco})
    : _banco = banco ?? BancoLocalizacoes.instancia;

  final BancoLocalizacoes _banco;

  Future<int> inserir(Localizacao localizacao) async {
    final banco = await _banco.obterBanco();
    return banco.insert('localizacoes', localizacao.toMap());
  }

  Future<List<Localizacao>> listarUltimas({int limite = 100}) async {
    final banco = await _banco.obterBanco();
    final registros = await banco.query(
      'localizacoes',
      orderBy: 'instante DESC, id DESC',
      limit: limite,
    );

    return registros.map(Localizacao.fromMap).toList();
  }

  Future<int> limparHistorico() async {
    final banco = await _banco.obterBanco();
    return banco.delete('localizacoes');
  }
}
