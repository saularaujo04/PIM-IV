using System.ComponentModel.DataAnnotations;
<<<<<<< HEAD
using Transportadora.Application.Validation;
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d

namespace Transportadora.Application.DTOs;

public class CriarMotoristaDto
{
    [Required(ErrorMessage = "O nome é obrigatório.")]
    [StringLength(200)]
    public string Nome { get; set; } = string.Empty;

    [Required(ErrorMessage = "O CPF é obrigatório.")]
    [StringLength(14)]
<<<<<<< HEAD
    [Cpf]
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    public string Cpf { get; set; } = string.Empty;

    [Required(ErrorMessage = "A CNH é obrigatória.")]
    [StringLength(11)]
    public string Cnh { get; set; } = string.Empty;

    [Required(ErrorMessage = "A categoria da CNH é obrigatória.")]
    [StringLength(2)]
    public string CategoriaCnh { get; set; } = string.Empty;

    [Required(ErrorMessage = "O telefone é obrigatório.")]
    [StringLength(20)]
    public string Telefone { get; set; } = string.Empty;
}
