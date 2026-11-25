using System.ComponentModel.DataAnnotations;

namespace Transportadora.Application.DTOs;

public class CriarOcorrenciaDto
{
    [Required(ErrorMessage = "A descrição da ocorrência é obrigatória.")]
    [StringLength(500)]
    public string Descricao { get; set; } = string.Empty;
}
