import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/servico_localizacao.dart';
import 'tela_localizacoes.dart';
import 'tela_mapa.dart';

class TelaColeta extends StatefulWidget {
  const TelaColeta({super.key});

  @override
  State<TelaColeta> createState() => _TelaColetaState();
}

class _TelaColetaState extends State<TelaColeta> {
  final _servico = ServicoLocalizacao();
  final _repositorio = RepositorioLocalizacoes();

  StreamSubscription<Position>? _assinatura;
  Future<void> _filaGravacoes = Future.value();
  bool _iniciando = false;
  bool _parando = false;
  String _mensagem = 'A coleta está parada.';

  bool get _coletando => _assinatura != null;

  Future<void> _iniciarColeta() async {
    if (_coletando || _iniciando) {
      return;
    }

    setState(() {
      _iniciando = true;
      _mensagem = 'Verificando localização e permissão...';
    });

    try {
      final permissao = await _servico.prepararAcesso();
      final assinatura = _servico.obterPosicoes().listen(
        _salvarPosicao,
        onError: _tratarErroDoStream,
        onDone: _tratarFimDoStream,
      );

      if (!mounted) {
        await assinatura.cancel();
        return;
      }

      setState(() {
        _assinatura = assinatura;
        _mensagem = permissao == LocationPermission.always
            ? 'Coleta iniciada.'
            : 'Coleta iniciada. Para garantir a coleta ao minimizar, permita '
                  'a localização o tempo todo nas configurações.';
      });
    } on FalhaLocalizacao catch (erro) {
      if (!mounted) return;
      setState(() => _mensagem = erro.mensagem);
    } catch (_) {
      if (!mounted) return;
      setState(() => _mensagem = 'Não foi possível iniciar a coleta.');
    } finally {
      if (mounted) {
        setState(() => _iniciando = false);
      }
    }
  }

  void _salvarPosicao(Position posicao) {
    final localizacao = Localizacao(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
      precisao: posicao.accuracy,
      instante: posicao.timestamp.toUtc(),
    );

    _filaGravacoes = _filaGravacoes.then((_) async {
      try {
        await _repositorio.inserir(localizacao);
        if (!mounted) return;
        setState(() => _mensagem = 'Última posição salva com sucesso.');
      } catch (_) {
        if (!mounted) return;
        setState(() => _mensagem = 'Não foi possível salvar uma posição.');
      }
    });
  }

  void _tratarErroDoStream(Object erro) {
    if (!mounted) return;
    setState(() => _mensagem = 'Falha ao receber a localização.');
  }

  void _tratarFimDoStream() {
    if (!mounted) return;
    setState(() {
      _assinatura = null;
      _mensagem = 'A coleta foi encerrada pelo serviço de localização.';
    });
  }

  Future<void> _pararColeta() async {
    if (!_coletando || _parando) {
      return;
    }

    setState(() {
      _parando = true;
      _mensagem = 'Parando a coleta...';
    });

    try {
      await _assinatura?.cancel();
      _assinatura = null;
      await _filaGravacoes;

      if (!mounted) return;
      setState(() => _mensagem = 'Coleta parada.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _mensagem = 'Não foi possível parar a coleta.');
    } finally {
      if (mounted) {
        setState(() => _parando = false);
      }
    }
  }

  Future<void> _abrirConfiguracoes() async {
    final abriu = await _servico.abrirConfiguracoesPermissao();
    if (!mounted || abriu) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir as configurações.')),
    );
  }

  void _abrirHistorico() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TelaLocalizacoes(coletaAtiva: _coletando),
      ),
    );
  }

  void _abrirMapa() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const TelaMapa()));
  }

  @override
  void dispose() {
    _assinatura?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coleta de localização')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              _mensagem,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _coletando || _iniciando || _parando
                  ? null
                  : _iniciarColeta,
              child: Text(_iniciando ? 'Iniciando...' : 'Iniciar coleta'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _coletando && !_parando ? _pararColeta : null,
              child: Text(_parando ? 'Parando...' : 'Parar coleta'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _abrirHistorico,
              child: const Text('Consultar histórico'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _abrirMapa,
              child: const Text('Ver mapa'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _abrirConfiguracoes,
              child: const Text('Configurações de permissão'),
            ),
          ],
        ),
      ),
    );
  }
}
