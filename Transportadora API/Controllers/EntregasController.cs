using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Transportadora.Application.DTOs;
using Transportadora.Application.Services;
using Transportadora.Domain;

namespace Transportadora.API.Controllers;

[Authorize]
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
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterTodas()
    {
        var entregas = await _service.ObterTodasAsync();
        return Ok(entregas);
    }

    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObterPorId(int id)
    {
        var entrega = await _service.ObterPorIdAsync(id);

        if (entrega is null)
            return NotFound(new { Mensagem = "Entrega não encontrada." });

        return Ok(entrega);
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar([FromBody] CriarEntregaDto dto)
    {
        try
        {
            await _service.AdicionarAsync(dto);
            return Ok(new { Mensagem = "Entrega cadastrada com sucesso." });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Mensagem = ex.Message });
        }
    }

    [HttpPost("{id}/iniciar-rota")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> IniciarRota(int id)
    {
        try
        {
            await _service.IniciarRotaAsync(id);
            return Ok(new { Mensagem = "Rota iniciada com sucesso." });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Mensagem = ex.Message });
        }
    }

    [HttpPost("{id}/concluir")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ConcluirEntrega(int id)
    {
        try
        {
            await _service.ConcluirEntregaAsync(id);
            return Ok(new { Mensagem = "Entrega concluída com sucesso." });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Mensagem = ex.Message });
        }
    }

    [HttpPost("{id}/ocorrencia")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RegistrarOcorrencia(int id, [FromBody] CriarOcorrenciaDto dto)
    {
        try
        {
            await _service.RegistrarOcorrenciaAsync(id, dto);
            return Ok(new { Mensagem = "Ocorrência registrada com sucesso." });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Mensagem = ex.Message });
        }
    }

    [HttpGet("{id}/ocorrencias")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterOcorrencias(int id)
    {
        var ocorrencias = await _service.ObterOcorrenciasAsync(id);
        return Ok(ocorrencias);
    }
}