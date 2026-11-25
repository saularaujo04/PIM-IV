/// Status da entrega: mesmos códigos do enum StatusEntrega do backend (C#) e do SQL.
///   0 = Pendente | 1 = Em trânsito | 2 = Concluída | 3 = Ocorrência
enum StatusEntrega {
  pendente(0, 'Pendente'),
  emTransito(1, 'Em trânsito'),
  concluida(2, 'Concluída'),
  ocorrencia(3, 'Com ocorrência');

  const StatusEntrega(this.codigo, this.rotulo);
  final int codigo;
  final String rotulo;

  static StatusEntrega deCodigo(int c) => StatusEntrega.values
      .firstWhere((s) => s.codigo == c, orElse: () => StatusEntrega.pendente);

  bool get finalizada => this == StatusEntrega.concluida;

  /// Regras iguais às do backend (Entrega.IniciarRota / ConcluirEntrega / RegistrarOcorrencia).
  bool podeIrPara(StatusEntrega novo) {
    return switch (this) {
      StatusEntrega.pendente || StatusEntrega.ocorrencia =>
        novo == StatusEntrega.emTransito,
      StatusEntrega.emTransito =>
        novo == StatusEntrega.concluida || novo == StatusEntrega.ocorrencia,
      StatusEntrega.concluida => false,
    };
  }
}

/// Tipos usados só na tela de ocorrência. A API guarda apenas o texto,
/// então o tipo vira prefixo da descrição ("Avaria na carga: caixa molhada").
enum TipoOcorrencia {
  ausenteDestinatario('Destinatário ausente'),
  avaria('Avaria na carga'),
  atraso('Atraso'),
  enderecoNaoEncontrado('Endereço não encontrado'),
  recusada('Recusada pelo destinatário'),
  outro('Outro');

  const TipoOcorrencia(this.rotulo);
  final String rotulo;
}

class Ocorrencia {
  Ocorrencia({required this.descricao, required this.dataHora});

  final String descricao;
  final DateTime dataHora;

  // Mesmas chaves da API (OcorrenciaDto), também usadas no cache local.
  factory Ocorrencia.fromJson(Map<String, dynamic> j) => Ocorrencia(
        descricao: (j['descricao'] ?? '') as String,
        dataHora: DateTime.parse(j['dataOcorrencia'] as String),
      );

  Map<String, dynamic> toJson() => {
        'descricao': descricao,
        'dataOcorrencia': dataHora.toIso8601String(),
      };
}

class Entrega {
  Entrega({
    required this.id,
    required this.codigoRastreio,
    required this.clienteNome,
    required this.veiculoPlaca,
    required this.origem,
    required this.destino,
    required this.status,
    this.dataCriacao,
    List<Ocorrencia>? ocorrencias,
  }) : ocorrencias = ocorrencias ?? [];

  final int id;
  final String codigoRastreio;
  final String clienteNome;
  final String veiculoPlaca;
  final String origem;
  final String destino;
  StatusEntrega status;
  final DateTime? dataCriacao;
  final List<Ocorrencia> ocorrencias;

  // Chaves iguais ao EntregaDto da API (GET /api/entregas/minhas).
  factory Entrega.fromJson(Map<String, dynamic> j) => Entrega(
        id: j['id'] as int,
        codigoRastreio: (j['codigoRastreio'] ?? '') as String,
        clienteNome: (j['clienteNome'] ?? '') as String,
        veiculoPlaca: (j['veiculoPlaca'] ?? '') as String,
        origem: (j['enderecoOrigem'] ?? '') as String,
        destino: (j['enderecoDestino'] ?? '') as String,
        status: StatusEntrega.deCodigo(j['status'] as int),
        dataCriacao: j['dataCriacao'] == null
            ? null
            : DateTime.parse(j['dataCriacao'] as String),
        ocorrencias: ((j['ocorrencias'] ?? []) as List)
            .map((o) => Ocorrencia.fromJson(o as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'codigoRastreio': codigoRastreio,
        'clienteNome': clienteNome,
        'veiculoPlaca': veiculoPlaca,
        'enderecoOrigem': origem,
        'enderecoDestino': destino,
        'status': status.codigo,
        'dataCriacao': dataCriacao?.toIso8601String(),
        'ocorrencias': ocorrencias.map((o) => o.toJson()).toList(),
      };
}
