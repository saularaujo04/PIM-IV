import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/entrega.dart';
import 'api.dart';

/// Operação feita sem conexão, aguardando envio.
class Operacao {
  Operacao({
    required this.opId,
    required this.tipo,
    required this.entregaId,
    this.status,
    this.descricao,
  });

  final String opId;
  final String tipo; // 'status' ou 'ocorrencia'
  final int entregaId;
  final int? status;
  final String? descricao;

  Map<String, dynamic> toJson() => {
        'opId': opId,
        'tipo': tipo,
        'entregaId': entregaId,
        'status': status,
        'descricao': descricao,
      };

  factory Operacao.fromJson(Map<String, dynamic> j) => Operacao(
        opId: j['opId'] as String,
        tipo: j['tipo'] as String,
        entregaId: j['entregaId'] as int,
        status: j['status'] as int?,
        descricao: j['descricao'] as String?,
      );
}

/// Fila persistente de operações pendentes. É reenviada em ordem quando
/// a conexão volta. O servidor prevalece em caso de conflito: operações
/// rejeitadas pelo servidor (erro 4xx, ex.: transição inválida) são descartadas.
/// Erros temporários (5xx, 401, 408, 429) NÃO descartam: a fila para e tenta de novo depois.
class SyncQueue {
  static const _chave = 'fila_pendente';
  List<Operacao> pendentes = [];

  Future<void> carregar() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_chave);
    if (raw == null) {
      pendentes = [];
      return;
    }
    pendentes = (jsonDecode(raw) as List)
        .map((e) => Operacao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _gravar() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_chave, jsonEncode(pendentes.map((o) => o.toJson()).toList()));
  }

  Future<void> adicionar(Operacao o) async {
    pendentes.add(o);
    await _gravar();
  }

  Future<void> limpar() async {
    pendentes = [];
    await _gravar();
  }

  Future<void> _enviar(EntregasApi api, Operacao o) {
    if (o.tipo == 'status') {
      return api.atualizarStatus(o.entregaId, StatusEntrega.deCodigo(o.status!), o.opId);
    }
    return api.registrarOcorrencia(o.entregaId, o.descricao ?? '', o.opId);
  }

  /// Retorna quantas operações foram enviadas com sucesso.
  Future<int> processar(EntregasApi api) async {
    var enviados = 0;
    while (pendentes.isNotEmpty) {
      final o = pendentes.first;
      try {
        await _enviar(api, o);
        enviados++;
      } on SemConexaoException {
        break; // ainda sem sinal: tenta de novo depois
      } on ApiException catch (e) {
        final st = e.status;
        final temporario = st == null || st >= 500 || st == 401 || st == 408 || st == 429;
        if (temporario) break; // mantém a operação na fila
        // 4xx definitivo (ex.: conflito de status): descarta e segue.
      }
      pendentes.removeAt(0);
    }
    await _gravar();
    return enviados;
  }
}
