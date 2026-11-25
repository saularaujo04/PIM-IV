using System.ComponentModel.DataAnnotations;

namespace Transportadora.Application.DTOs;

public class CriarEntregaDto
{
    [Range(1, int.MaxValue, ErrorMessage = "Selecione um cliente.")]
    public int ClienteId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Selecione um motorista.")]
    public int MotoristaId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Selecione um veículo.")]
    public int VeiculoId { get; set; }

    [Required(ErrorMessage = "O endereço de origem é obrigatório.")]
    [StringLength(200)]
    public string EnderecoOrigem { get; set; } = string.Empty;

    [Required(ErrorMessage = "O endereço de destino é obrigatório.")]
    [StringLength(200)]
    public string EnderecoDestino { get; set; } = string.Empty;
}
