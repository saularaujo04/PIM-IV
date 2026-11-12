/// Códigos alinhados ao script SQL proposto no Apêndice A do PIM.
/// ATENÇÃO: conferir com os enumeradores reais do projeto Domain.
enum StatusEntrega {
  solicitada(1, 'Solicitada'),
  alocada(2, 'Alocada'),
  emRota(3, 'Em rota'),
  entregue(4, 'Entregue'),
  naoRealizada(5, 'Não realizada'),
  cancelada(6, 'Cancelada');

  const StatusEntrega(this.codigo, this.rotulo);
  final int codigo;
  final String rotulo;

  static StatusEntrega deCodigo(int c) => StatusEntrega.values
      .firstWhere((s) => s.codigo == c, orElse: () => StatusEntrega.solicitada);

  bool get finalizada =>
      this == StatusEntrega.entregue ||
      this == StatusEntrega.naoRealizada ||
      this == StatusEntrega.cancelada;

  /// O status só avança no ciclo de vida, nunca retrocede.
  bool podeIrPara(StatusEntrega novo) {
    switch (this) {
      case StatusEntrega.alocada:
        return novo == StatusEntrega.emRota;
      case StatusEntrega.emRota:
        return novo == StatusEntrega.entregue ||
            novo == StatusEntrega.naoRealizada;
      default:
        return false;
    }
  }
}

enum TipoOcorrencia {
  ausenteDestinatario(1, 'Destinatário ausente'),
  avaria(2, 'Avaria na carga'),
  atraso(3, 'Atraso'),
  enderecoNaoEncontrado(4, 'Endereço não encontrado'),
  recusada(5, 'Recusada pelo destinatário'),
  outro(9, 'Outro');

  const TipoOcorrencia(this.codigo, this.rotulo);
  final int codigo;
  final String rotulo;

  static TipoOcorrencia deCodigo(int c) => TipoOcorrencia.values
      .firstWhere((t) => t.codigo == c, orElse: () => TipoOcorrencia.outro);
}

class Ocorrencia {
  Ocorrencia({required this.tipo, required this.descricao, required this.dataHora});

  final TipoOcorrencia tipo;
  final String descricao;
  final DateTime dataHora;

  factory Ocorrencia.fromJson(Map<String, dynamic> j) => Ocorrencia(
        tipo: TipoOcorrencia.deCodigo(j['tipo'] as int),
        descricao: (j['descricao'] ?? '') as String,
        dataHora: DateTime.parse(j['dataHora'] as String),
      );

  Map<String, dynamic> toJson() => {
        'tipo': tipo.codigo,
        'descricao': descricao,
        'dataHora': dataHora.toIso8601String(),
      };
}

class Entrega {
  Entrega({
    required this.id,
    required this.codigoRastreio,
    required this.clienteNome,
    required this.origem,
    required this.destino,
    required this.pesoKg,
    required this.status,
    this.dataPrevista,
    List<Ocorrencia>? ocorrencias,
  }) : ocorrencias = ocorrencias ?? [];

  final int id;
  final String codigoRastreio;
  final String clienteNome;
  final String origem;
  final String destino;
  final double pesoKg;
  StatusEntrega status;
  final DateTime? dataPrevista;
  final List<Ocorrencia> ocorrencias;

  factory Entrega.fromJson(Map<String, dynamic> j) => Entrega(
        id: j['id'] as int,
        codigoRastreio: (j['codigoRastreio'] ?? '') as String,
        clienteNome: (j['clienteNome'] ?? '') as String,
        origem: (j['origem'] ?? '') as String,
        destino: (j['destino'] ?? '') as String,
        pesoKg: ((j['pesoKg'] ?? 0) as num).toDouble(),
        status: StatusEntrega.deCodigo(j['status'] as int),
        dataPrevista: j['dataPrevista'] == null
            ? null
            : DateTime.parse(j['dataPrevista'] as String),
        ocorrencias: ((j['ocorrencias'] ?? []) as List)
            .map((o) => Ocorrencia.fromJson(o as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'codigoRastreio': codigoRastreio,
        'clienteNome': clienteNome,
        'origem': origem,
        'destino': destino,
        'pesoKg': pesoKg,
        'status': status.codigo,
        'dataPrevista': dataPrevista?.toIso8601String(),
        'ocorrencias': ocorrencias.map((o) => o.toJson()).toList(),
      };
}
