using Microsoft.AspNetCore.Mvc;
using Transportadora.Application.DTOs;
using Transportadora.Application.Services;
using Transportadora.Domain;

namespace Transportadora.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class EntregasController : ControllerBase
{
    private readonly EntregaService _service;

    public EntregasController(EntregaService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> ObterTodas()
    {
        var entregas = await _service.ObterTodasAsync();

        return Ok(entregas);
    }

    [HttpPost]
    public async Task<IActionResult> Criar(
        [FromBody] CriarEntregaDto dto)
    {
        await _service.AdicionarAsync(dto);

        return Ok(new
        {
            Mensagem = "Entrega cadastrada com sucesso."
        });
    }
}