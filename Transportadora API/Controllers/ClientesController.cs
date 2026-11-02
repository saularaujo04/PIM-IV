using Microsoft.AspNetCore.Mvc;
using Transportadora.Application.DTOs;
using Transportadora.Application.Services;

namespace Transportadora.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ClientesController : ControllerBase
{
    private readonly ClienteService _service;

    public ClientesController(ClienteService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> ObterTodos()
    {
        var clientes = await _service.ObterTodosAsync();
        return Ok(clientes);
    }

    [HttpPost]
    public async Task<IActionResult> Adicionar(CriarClienteDto dto)
    {
        await _service.AdicionarAsync(dto);
        return Ok(new { Mensagem = "Cliente registado com sucesso!" });
    }
}