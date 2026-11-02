using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Transportadora.Infrastructure;
using Transportadora.Domain.Entidades;

namespace Transportadora.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly TransportadoraDbContext _context;

    public AuthController(TransportadoraDbContext context)
    {
        _context = context;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var usuario = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Email.ToLower() == dto.Email.ToLower() && u.Senha == dto.Senha);

        if (usuario == null)
        {
            return Unauthorized(new { mensagem = "E-mail ou senha inválidos." });
        }

        return Ok(new { usuario.Id, usuario.Nome, usuario.Email, usuario.Perfil });
    }
}

public record LoginDto(string Email, string Senha);