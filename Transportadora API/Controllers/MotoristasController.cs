using Microsoft.AspNetCore.Mvc;
using Transportadora.Application.DTOs;
using Transportadora.Application.Services;

namespace Transportadora.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MotoristasController : ControllerBase
{
    private readonly MotoristaService _service;

    public MotoristasController(MotoristaService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> ObterTodos()
    {
        var motoristas = await _service.ObterTodosAsync();
        return Ok(motoristas);
    }

    [HttpPost]
    public async Task<IActionResult> Adicionar(CriarMotoristaDto dto)
    {
        await _service.AdicionarAsync(dto);
        return Ok(new { Mensagem = "Motorista cadastrado com sucesso!" });
    }
}