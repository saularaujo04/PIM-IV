import '../models/entrega.dart';
import 'api.dart';

/// Dados simulados para desenvolver o app sem a API (flutter run --dart-define=USE_MOCK=true).
/// Login de teste: qualquer e-mail com a senha "123".
class MockApi implements EntregasApi {
  /// Quando verdadeiro, todas as chamadas falham como se não houvesse sinal.
  bool offline = false;

  final List<Entrega> _entregas = [
    Entrega(
      id: 1, codigoRastreio: 'TRK-A1B2C3', clienteNome: 'Mercado Bom Preço',
      veiculoPlaca: 'ABC-1A23',
      origem: 'Galpão TransPIM - São Paulo/SP', destino: 'Av. Brasil, 1200 - Campinas/SP',
      status: StatusEntrega.pendente, dataCriacao: DateTime.now(),
    ),
    Entrega(
      id: 2, codigoRastreio: 'TRK-D4E5F6', clienteNome: 'Farmácia Central',
      veiculoPlaca: 'ABC-1A23',
      origem: 'Galpão TransPIM - São Paulo/SP', destino: 'Rua das Flores, 85 - Santo André/SP',
      status: StatusEntrega.emTransito, dataCriacao: DateTime.now(),
    ),
    Entrega(
      id: 3, codigoRastreio: 'TRK-G7H8I9', clienteNome: 'Loja Casa & Cia',
      veiculoPlaca: 'XYZ-9B87',
      origem: 'Galpão TransPIM - São Paulo/SP', destino: 'Av. Paulista, 900 - São Paulo/SP',
      status: StatusEntrega.pendente, dataCriacao: DateTime.now(),
    ),
  ];

  Future<void> _atraso() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (offline) throw SemConexaoException();
  }

  @override
  void definirToken(String? token) {}

  @override
  Future<String> login(String email, String senha) async {
    await _atraso();
    if (email.trim().isEmpty || senha != '123') {
      throw ApiException('E-mail ou senha inválidos.', 401);
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
  Future<void> registrarOcorrencia(int entregaId, String descricao, String opId) async {
    await _atraso();
    final e = _achar(entregaId);
    if (e.status.finalizada) {
      throw ApiException('Não é possível registrar ocorrência em uma entrega concluída.', 409);
    }
    e.ocorrencias.add(Ocorrencia(descricao: descricao, dataHora: DateTime.now()));
    e.status = StatusEntrega.ocorrencia;
  }
}
