using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Transportadora.API.Services;
using Transportadora.Infrastructure;

namespace Transportadora.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly TransportadoraDbContext _context;
    private readonly TokenService _tokenService;

    public AuthController(TransportadoraDbContext context, TokenService tokenService)
    {
        _context = context;
        _tokenService = tokenService;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var usuario = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Email == request.Email && u.Senha == request.Senha);

        if (usuario == null)
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
                usuario.Perfil
            }
        });
    }
}

public record LoginRequest(string Email, string Senha);