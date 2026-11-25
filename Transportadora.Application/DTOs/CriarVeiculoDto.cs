using System.ComponentModel.DataAnnotations;

namespace Transportadora.Application.DTOs;

public class CriarVeiculoDto
{
    [Required(ErrorMessage = "A placa é obrigatória.")]
    [StringLength(10)]
<<<<<<< HEAD
    [RegularExpression(@"^[A-Za-z]{3}-?[0-9][A-Za-z0-9][0-9]{2}$", ErrorMessage = "Placa inválida (use ABC-1234 ou ABC1D23).")]
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    public string Placa { get; set; } = string.Empty;

    [Required(ErrorMessage = "O modelo é obrigatório.")]
    [StringLength(100)]
    public string Modelo { get; set; } = string.Empty;

    [Range(0.01, 1000000, ErrorMessage = "Informe uma capacidade válida.")]
    public decimal CapacidadeKg { get; set; }

    [Required(ErrorMessage = "O tipo do veículo é obrigatório.")]
    [StringLength(50)]
    public string Tipo { get; set; } = string.Empty;
}
