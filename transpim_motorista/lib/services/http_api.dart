import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/entrega.dart';
import 'api.dart';

/// Cliente da API REST (endpoints previstos na Tabela 6 do PIM).
/// ATENÇÃO: nomes de campos e a rota /api/entregas/minhas devem ser
/// alinhados com os controllers do projeto Transportadora.API.
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
    if (r.statusCode == 401) return 'Sessão expirada ou credenciais inválidas.';
    if (r.statusCode == 403) return 'Você não tem permissão para esta ação.';
    try {
      final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      final m = j['mensagem'] ?? j['detail'] ?? j['title'];
      if (m is String && m.isNotEmpty) return m;
    } catch (_) {}
    return 'Erro ${r.statusCode} ao falar com o servidor.';
  }

  @override
  Future<String> login(String usuario, String senha) async {
    final r = await _executar(() => _client.post(_uri('/api/auth/login'),
        headers: _headers(),
        body: jsonEncode({'usuario': usuario, 'senha': senha})));
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
    await _executar(() => _client.patch(_uri('/api/entregas/$entregaId/status'),
        headers: _headers(opId), body: jsonEncode({'status': novo.codigo})));
  }

  @override
  Future<void> registrarOcorrencia(
      int entregaId, TipoOcorrencia tipo, String descricao, String opId) async {
    await _executar(() => _client.post(
        _uri('/api/entregas/$entregaId/ocorrencias'),
        headers: _headers(opId),
        body: jsonEncode({'tipo': tipo.codigo, 'descricao': descricao})));
  }
}
