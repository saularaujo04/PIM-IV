<<<<<<< HEAD
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Transportadora.API.Services;
using Transportadora.Application.Security;
=======
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Transportadora.API.Services;
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
using Transportadora.Infrastructure;

namespace Transportadora.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
<<<<<<< HEAD
    // Usado quando o e-mail não existe, para o tempo de resposta não revelar quais e-mails são válidos.
    private static readonly string HashFalso = PasswordHasher.Gerar("senha-inexistente");

=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    private readonly TransportadoraDbContext _context;
    private readonly TokenService _tokenService;

    public AuthController(TransportadoraDbContext context, TokenService tokenService)
    {
        _context = context;
        _tokenService = tokenService;
    }

    [HttpPost("login")]
<<<<<<< HEAD
    [EnableRateLimiting("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var email = (request.Email ?? string.Empty).Trim();
        var usuario = await _context.Usuarios.FirstOrDefaultAsync(u => u.Email == email);

        var senhaCorreta = PasswordHasher.Verificar(request.Senha ?? string.Empty, usuario?.Senha ?? HashFalso);

        if (usuario == null || !senhaCorreta)
=======
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var usuario = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Email == request.Email && u.Senha == request.Senha);

        if (usuario == null)
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
            return Unauthorized(new { mensagem = "E-mail ou senha inválidos." });

        var token = _tokenService.GerarToken(usuario);

        return Ok(new
        {
            token,
            usuario = new
            {
                usuario.Id,
                usuario.Nome,
                usuario.Email,
                usuario.Perfil,
                usuario.MotoristaId
            }
        });
    }
<<<<<<< HEAD

    /// <summary>Troca a senha do próprio usuário logado.</summary>
    [Authorize]
    [HttpPost("alterar-senha")]
    public async Task<IActionResult> AlterarSenha([FromBody] AlterarSenhaRequest request)
    {
        if (!int.TryParse(User.FindFirst("sub")?.Value, out var id))
            return Unauthorized();

        var usuario = await _context.Usuarios.FindAsync(id);

        if (usuario == null || !PasswordHasher.Verificar(request.SenhaAtual, usuario.Senha))
            return BadRequest(new { mensagem = "Senha atual incorreta." });

        if (request.SenhaAtual == request.NovaSenha)
            return BadRequest(new { mensagem = "A nova senha precisa ser diferente da atual." });

        usuario.Senha = PasswordHasher.Gerar(request.NovaSenha);
        await _context.SaveChangesAsync();

        return Ok(new { mensagem = "Senha alterada com sucesso." });
    }
}

public record LoginRequest(string Email, string Senha);

public class AlterarSenhaRequest
{
    [Required(ErrorMessage = "Informe a senha atual.")]
    public string SenhaAtual { get; set; } = string.Empty;

    [Required(ErrorMessage = "Informe a nova senha.")]
    [MinLength(8, ErrorMessage = "A nova senha precisa ter pelo menos 8 caracteres.")]
    [MaxLength(100)]
    public string NovaSenha { get; set; } = string.Empty;
}
=======
}

public record LoginRequest(string Email, string Senha);
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
