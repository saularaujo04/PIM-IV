using Microsoft.AspNetCore.Mvc;
using Transportadora.Application.DTOs;
using Transportadora.Application.Services;

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

    [HttpGet("{id}")]
    public async Task<IActionResult> ObterPorId(int id)
    {
        var entrega = await _service.ObterPorIdAsync(id);

        if (entrega is null)
            return NotFound();

        return Ok(entrega);
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

    [HttpPost("{id}/iniciar-rota")]
    public async Task<IActionResult> IniciarRota(int id)
    {
        try
        {
            await _service.IniciarRotaAsync(id);

            return Ok(new
            {
                Mensagem = "Rota iniciada com sucesso."
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                Mensagem = ex.Message
            });
        }
    }

    [HttpPost("{id}/concluir")]
    public async Task<IActionResult> ConcluirEntrega(int id)
    {
        try
        {
            await _service.ConcluirEntregaAsync(id);

            return Ok(new
            {
                Mensagem = "Entrega concluída com sucesso."
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                Mensagem = ex.Message
            });
        }
    }
}