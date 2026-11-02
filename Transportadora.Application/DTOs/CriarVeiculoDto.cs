namespace Transportadora.Application.DTOs;

public class CriarVeiculoDto
{
    public string Placa { get; set; } = string.Empty;
    public string Modelo { get; set; } = string.Empty;
    public decimal CapacidadeKg { get; set; }
    public string Tipo { get; set; } = string.Empty;
}