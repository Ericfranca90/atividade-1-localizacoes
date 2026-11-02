import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BancoLocalizacoes {
  BancoLocalizacoes._();

  static final BancoLocalizacoes instancia = BancoLocalizacoes._();

  Database? _banco;
  Future<Database>? _abertura;

  Future<Database> obterBanco() async {
    final bancoAtual = _banco;
    if (bancoAtual != null && bancoAtual.isOpen) {
      return bancoAtual;
    }

    try {
      _abertura ??= _abrirBanco();
      final bancoAberto = await _abertura!;
      _banco = bancoAberto;
      _abertura = null;
      return bancoAberto;
    } catch (_) {
      _abertura = null;
      rethrow;
    }
  }

  Future<Database> _abrirBanco() async {
    final pasta = await getDatabasesPath();
    final caminho = p.join(pasta, 'localizacoes.db');

    return openDatabase(
      caminho,
      version: 1,
      onCreate: (banco, versao) async {
        await banco.execute('''
          CREATE TABLE localizacoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            precisao REAL NOT NULL,
            instante TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
