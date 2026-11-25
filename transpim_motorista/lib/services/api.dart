import '../models/entrega.dart';

class ApiException implements Exception {
  ApiException(this.mensagem, [this.status]);
  final String mensagem;
  final int? status;
  @override
  String toString() => mensagem;
}

/// Falha de rede: o app guarda a operação na fila e reenvia depois.
class SemConexaoException extends ApiException {
  SemConexaoException() : super('Sem conexão com o servidor.');
}

/// Contrato único usado pelo app. Há duas implementações:
/// [HttpApi] (API real) e [MockApi] (dados simulados).
abstract class EntregasApi {
  void definirToken(String? token);

  /// [email] e [senha] do usuário (perfil motorista).
  Future<String> login(String email, String senha);
  Future<List<Entrega>> minhasEntregas();

  /// Só aceita: emTransito (iniciar rota), concluida e ocorrencia (não realizada).
  /// [opId] identifica a operação (cabeçalho Idempotency-Key).
  Future<void> atualizarStatus(int entregaId, StatusEntrega novo, String opId);
  Future<void> registrarOcorrencia(int entregaId, String descricao, String opId);
}
