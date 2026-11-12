import '../models/entrega.dart';
import 'api.dart';

/// Dados simulados para desenvolver o app antes de a API ficar pronta.
/// Login de teste: qualquer usuário com a senha "123".
class MockApi implements EntregasApi {
  /// Quando verdadeiro, todas as chamadas falham como se não houvesse sinal.
  bool offline = false;

  final List<Entrega> _entregas = [
    Entrega(
      id: 1, codigoRastreio: 'TP-2026-0001', clienteNome: 'Mercado Bom Preço',
      origem: 'Galpão TransPIM - São Paulo/SP', destino: 'Av. Brasil, 1200 - Campinas/SP',
      pesoKg: 480, status: StatusEntrega.alocada,
      dataPrevista: DateTime.now().add(const Duration(hours: 4)),
    ),
    Entrega(
      id: 2, codigoRastreio: 'TP-2026-0002', clienteNome: 'Farmácia Central',
      origem: 'Galpão TransPIM - São Paulo/SP', destino: 'Rua das Flores, 85 - Santo André/SP',
      pesoKg: 75.5, status: StatusEntrega.emRota,
      dataPrevista: DateTime.now().add(const Duration(hours: 2)),
    ),
    Entrega(
      id: 3, codigoRastreio: 'TP-2026-0003', clienteNome: 'Loja Casa & Cia',
      origem: 'Galpão TransPIM - São Paulo/SP', destino: 'Av. Paulista, 900 - São Paulo/SP',
      pesoKg: 210, status: StatusEntrega.alocada,
      dataPrevista: DateTime.now().add(const Duration(hours: 7)),
    ),
  ];

  Future<void> _atraso() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (offline) throw SemConexaoException();
  }

  @override
  void definirToken(String? token) {}

  @override
  Future<String> login(String usuario, String senha) async {
    await _atraso();
    if (usuario.trim().isEmpty || senha != '123') {
      throw ApiException('Usuário ou senha inválidos.', 401);
    }
    return 'token-simulado';
  }

  @override
  Future<List<Entrega>> minhasEntregas() async {
    await _atraso();
    // Devolve cópias para o app não alterar a "base" do servidor simulado.
    return _entregas.map((e) => Entrega.fromJson(e.toJson())).toList();
  }

  Entrega _achar(int id) => _entregas.firstWhere((e) => e.id == id,
      orElse: () => throw ApiException('Entrega não encontrada.', 404));

  @override
  Future<void> atualizarStatus(int entregaId, StatusEntrega novo, String opId) async {
    await _atraso();
    final e = _achar(entregaId);
    if (!e.status.podeIrPara(novo)) {
      throw ApiException('Transição de status não permitida.', 409);
    }
    e.status = novo;
  }

  @override
  Future<void> registrarOcorrencia(
      int entregaId, TipoOcorrencia tipo, String descricao, String opId) async {
    await _atraso();
    _achar(entregaId).ocorrencias.add(
        Ocorrencia(tipo: tipo, descricao: descricao, dataHora: DateTime.now()));
  }
}
