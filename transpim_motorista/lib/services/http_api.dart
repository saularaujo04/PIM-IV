import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/entrega.dart';
import 'api.dart';

/// Cliente da API REST do projeto Transportadora API.
///
/// Rotas usadas:
///   POST /api/auth/login                    { email, senha } -> { token, usuario }
///   GET  /api/entregas/minhas               -> [EntregaDto]
///   POST /api/entregas/{id}/iniciar-rota
///   POST /api/entregas/{id}/concluir
///   POST /api/entregas/{id}/nao-realizada
///   POST /api/entregas/{id}/ocorrencia      { descricao }
class HttpApi implements EntregasApi {
  HttpApi(this.baseUrl);

  final String baseUrl;
  String? _token;
  final http.Client _client = http.Client();
  static const _timeout = Duration(seconds: 10);

  @override
  void definirToken(String? token) => _token = token;

  Map<String, String> _headers([String? opId]) => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
        if (opId != null) 'Idempotency-Key': opId,
      };

  Uri _uri(String caminho) => Uri.parse('$baseUrl$caminho');

  Future<http.Response> _executar(Future<http.Response> Function() chamada) async {
    try {
      final r = await chamada().timeout(_timeout);
      if (r.statusCode >= 200 && r.statusCode < 300) return r;
      throw ApiException(_mensagemDe(r), r.statusCode);
    } on TimeoutException {
      throw SemConexaoException();
    } on SocketException {
      throw SemConexaoException();
    } on http.ClientException {
      throw SemConexaoException();
    }
  }

  String _mensagemDe(http.Response r) {
    try {
      final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      final m = j['mensagem'] ?? j['detail'] ?? j['title'];
      if (m is String && m.isNotEmpty) return m;
    } catch (_) {}
    if (r.statusCode == 401) return 'Sessão expirada ou credenciais inválidas.';
    if (r.statusCode == 403) return 'Você não tem permissão para esta ação.';
    return 'Erro ${r.statusCode} ao falar com o servidor.';
  }

  @override
  Future<String> login(String email, String senha) async {
    final r = await _executar(() => _client.post(_uri('/api/auth/login'),
        headers: _headers(),
        body: jsonEncode({'email': email, 'senha': senha})));
    final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    return j['token'] as String;
  }

  @override
  Future<List<Entrega>> minhasEntregas() async {
    final r = await _executar(
        () => _client.get(_uri('/api/entregas/minhas'), headers: _headers()));
    final lista = jsonDecode(utf8.decode(r.bodyBytes)) as List;
    return lista.map((e) => Entrega.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> atualizarStatus(int entregaId, StatusEntrega novo, String opId) async {
    final acao = switch (novo) {
      StatusEntrega.emTransito => 'iniciar-rota',
      StatusEntrega.concluida => 'concluir',
      StatusEntrega.ocorrencia => 'nao-realizada',
      StatusEntrega.pendente =>
        throw ApiException('Mudança de status não permitida.', 409),
    };
    await _executar(() => _client.post(_uri('/api/entregas/$entregaId/$acao'),
        headers: _headers(opId)));
  }

  @override
  Future<void> registrarOcorrencia(int entregaId, String descricao, String opId) async {
    await _executar(() => _client.post(
        _uri('/api/entregas/$entregaId/ocorrencia'),
        headers: _headers(opId),
        body: jsonEncode({'descricao': descricao})));
  }
}
