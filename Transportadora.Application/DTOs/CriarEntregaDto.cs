namespace Transportadora.Application.DTOs;

public class CriarEntregaDto
{
    public string CodigoRastreio { get; set; } = string.Empty;

    public int ClienteId { get; set; }

    public int MotoristaId { get; set; }

    public int VeiculoId { get; set; } // Propriedade adicionada

    public string EnderecoOrigem { get; set; } = string.Empty;

    public string EnderecoDestino { get; set; } = string.Empty;
}