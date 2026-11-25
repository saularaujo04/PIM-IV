using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
<<<<<<< HEAD
=======
using Transportadora.Domain;
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
using Transportadora.Domain.Entidades;

namespace Transportadora.API.Services;

public class TokenService
{
    private readonly IConfiguration _configuration;

    public TokenService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public string GerarToken(Usuario usuario)
    {
<<<<<<< HEAD
        var key = Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!);

        // Nomes curtos de claim (sub, name, email, role): o Program.cs desliga o
        // mapeamento automático (MapInboundClaims = false) e lê exatamente esses nomes.
        var claims = new List<Claim>
        {
            new Claim("sub", usuario.Id.ToString()),
            new Claim("name", usuario.Nome),
            new Claim("email", usuario.Email),
            new Claim("role", usuario.Perfil)
=======
        var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]!);

        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, usuario.Id.ToString()),
            new Claim(ClaimTypes.Name, usuario.Nome),
            new Claim(ClaimTypes.Email, usuario.Email),
            new Claim(ClaimTypes.Role, usuario.Perfil)
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
        };

        // Permite que /api/entregas/minhas saiba qual motorista está logado.
        if (usuario.MotoristaId.HasValue)
            claims.Add(new Claim("motoristaId", usuario.MotoristaId.Value.ToString()));

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.AddHours(8),
            Issuer = _configuration["Jwt:Issuer"],
            Audience = _configuration["Jwt:Audience"],
            SigningCredentials = new SigningCredentials(
                new SymmetricSecurityKey(key),
<<<<<<< HEAD
                SecurityAlgorithms.HmacSha256)
=======
                SecurityAlgorithms.HmacSha256Signature)
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
