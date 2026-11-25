namespace Transportadora.Application.DTOs;

/// <summary>Contrato de leitura de uma entrega (usado pelo painel web e pelo app mobile).</summary>
public class EntregaDto
{
    public int Id { get; set; }
    public string CodigoRastreio { get; set; } = string.Empty;
    public string ClienteNome { get; set; } = string.Empty;
    public string MotoristaNome { get; set; } = string.Empty;
    public string VeiculoPlaca { get; set; } = string.Empty;
    public string EnderecoOrigem { get; set; } = string.Empty;
    public string EnderecoDestino { get; set; } = string.Empty;

    /// <summary>0 = Pendente, 1 = Em trânsito, 2 = Concluída, 3 = Ocorrência.</summary>
    public int Status { get; set; }
    public string StatusDescricao { get; set; } = string.Empty;
    public DateTime DataCriacao { get; set; }
    public List<OcorrenciaDto> Ocorrencias { get; set; } = new();
}

public class OcorrenciaDto
{
    public string Descricao { get; set; } = string.Empty;
    public DateTime DataOcorrencia { get; set; }
}

public record EntregaCriadaDto(int Id, string CodigoRastreio);
