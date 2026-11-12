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
  Future<String> login(String usuario, String senha);
  Future<List<Entrega>> minhasEntregas();

  /// [opId] identifica a operação; o servidor deve ignorar reenvios duplicados.
  Future<void> atualizarStatus(int entregaId, StatusEntrega novo, String opId);
  Future<void> registrarOcorrencia(
      int entregaId, TipoOcorrencia tipo, String descricao, String opId);
}
