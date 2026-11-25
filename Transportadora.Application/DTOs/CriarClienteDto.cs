using System.ComponentModel.DataAnnotations;
<<<<<<< HEAD
using Transportadora.Application.Validation;
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d

namespace Transportadora.Application.DTOs;

public class CriarClienteDto
{
    [Required(ErrorMessage = "O nome / razão social é obrigatório.")]
    [StringLength(200)]
    public string Nome { get; set; } = string.Empty;

    [Required(ErrorMessage = "O documento (CPF/CNPJ) é obrigatório.")]
    [StringLength(18)]
<<<<<<< HEAD
    [CpfOuCnpj]
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    public string Documento { get; set; } = string.Empty;

    [Required(ErrorMessage = "O e-mail é obrigatório.")]
    [EmailAddress(ErrorMessage = "E-mail inválido.")]
    [StringLength(200)]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "O telefone é obrigatório.")]
    [StringLength(20)]
    public string Telefone { get; set; } = string.Empty;
}
