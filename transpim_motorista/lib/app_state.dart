import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'models/entrega.dart';
import 'services/api.dart';
import 'services/auth_service.dart';
import 'services/http_api.dart';
import 'services/mock_api.dart';
import 'services/sync_queue.dart';

/// Estado global do app (login, entregas, fila offline).
/// Mantido simples (singleton) para facilitar o entendimento no PIM.
final AppState app = AppState();

class AppState extends ChangeNotifier {
  final EntregasApi api =
      AppConfig.useMock ? MockApi() : HttpApi(AppConfig.baseUrl);
  final AuthService _auth = AuthService();
  final SyncQueue _fila = SyncQueue();

  List<Entrega> entregas = [];
  bool carregando = false;
  bool logado = false;
  bool lendoDoCache = false;
  String? erro;
  Timer? _timer;

  static const _chaveCache = 'cache_entregas';

  int get pendentes => _fila.pendentes.length;
  bool get ehMock => api is MockApi;
  bool get simulandoOffline => api is MockApi && (api as MockApi).offline;

  void alternarOffline() {
    if (api is MockApi) {
      final m = api as MockApi;
      m.offline = !m.offline;
      notifyListeners();
    }
  }

  Future<void> iniciar() async {
    await _fila.carregar();
    final token = await _auth.lerToken();
    if (token != null) {
      api.definirToken(token);
      logado = true;
      await _lerCache();
      _iniciarTimer();
      unawaited(sincronizar());
    }
    notifyListeners();
  }

  Future<void> login(String email, String senha) async {
    erro = null;
    carregando = true;
    notifyListeners();
    try {
      final token = await api.login(email, senha);
      await _auth.salvar(token);
      api.definirToken(token);
      logado = true;
      _iniciarTimer();
      carregando = false;
      await sincronizar();
    } on ApiException catch (e) {
      erro = e.mensagem;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _timer?.cancel();
    await _auth.limpar();
    await _fila.limpar();
    final p = await SharedPreferences.getInstance();
    await p.remove(_chaveCache);
    api.definirToken(null);
    entregas = [];
    logado = false;
    erro = null;
    notifyListeners();
  }

  void _iniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 2), (_) => sincronizar());
  }

  /// Envia a fila pendente (se houver) e recarrega as entregas do servidor.
  Future<void> sincronizar() async {
    if (!logado) return;
    await _fila.processar(api);
    await carregar();
  }

  Future<void> carregar() async {
    carregando = true;
    notifyListeners();
    try {
      entregas = await api.minhasEntregas();
      lendoDoCache = false;
      erro = null;
      await _gravarCache();
    } on SemConexaoException {
      await _lerCache();
      lendoDoCache = true;
    } on ApiException catch (e) {
      erro = e.mensagem;
      if (e.status == 401) {
        carregando = false;
        await logout();
        return;
      }
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> _gravarCache() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_chaveCache, jsonEncode(entregas.map((e) => e.toJson()).toList()));
  }

  Future<void> _lerCache() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_chaveCache);
    if (raw == null) return;
    entregas = (jsonDecode(raw) as List)
        .map((e) => Entrega.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _novoOpId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 31)}';

  Entrega? _achar(int id) {
    for (final e in entregas) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Atualiza o status. Devolve uma mensagem para o usuário ou null.
  Future<String?> atualizarStatus(Entrega e, StatusEntrega novo) async {
    final anterior = e.status;
    if (!anterior.podeIrPara(novo)) return 'Mudança de status não permitida.';
    final opId = _novoOpId();
    e.status = novo; // atualização otimista na tela
    await _gravarCache();
    notifyListeners();
    try {
      await api.atualizarStatus(e.id, novo, opId);
      unawaited(carregar()); // traz do servidor o estado oficial (ex.: ocorrência criada)
      return null;
    } on SemConexaoException {
      await _fila.adicionar(Operacao(
          opId: opId, tipo: 'status', entregaId: e.id, status: novo.codigo));
      notifyListeners();
      return 'Sem conexão: a alteração será enviada quando o sinal voltar.';
    } on ApiException catch (ex) {
      e.status = anterior; // servidor recusou: desfaz
      await _gravarCache();
      notifyListeners();
      return ex.mensagem;
    }
  }

  /// O backend grava só o texto; o tipo escolhido vira prefixo da descrição.
  /// Registrar uma ocorrência também coloca a entrega no status "ocorrência".
  Future<String?> registrarOcorrencia(
      Entrega e, TipoOcorrencia tipo, String descricao) async {
    final opId = _novoOpId();
    final texto = '${tipo.rotulo}: $descricao';
    final statusAnterior = e.status;
    final oc = Ocorrencia(descricao: texto, dataHora: DateTime.now());
    e.ocorrencias.add(oc);
    e.status = StatusEntrega.ocorrencia; // atualização otimista
    await _gravarCache();
    notifyListeners();
    try {
      await api.registrarOcorrencia(e.id, texto, opId);
      unawaited(carregar());
      return null;
    } on SemConexaoException {
      await _fila.adicionar(Operacao(
          opId: opId, tipo: 'ocorrencia', entregaId: e.id, descricao: texto));
      notifyListeners();
      return 'Sem conexão: a ocorrência será enviada quando o sinal voltar.';
    } on ApiException catch (ex) {
      final atual = _achar(e.id);
      atual?.ocorrencias.remove(oc);
      atual?.status = statusAnterior;
      await _gravarCache();
      notifyListeners();
      return ex.mensagem;
    }
  }
}
