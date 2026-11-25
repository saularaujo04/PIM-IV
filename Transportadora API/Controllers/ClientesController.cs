<<<<<<< HEAD
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
=======
﻿using Microsoft.AspNetCore.Mvc;
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
using Transportadora.Application.DTOs;
using Transportadora.Application.Services;

namespace Transportadora.API.Controllers;

<<<<<<< HEAD
[Authorize(Roles = "admin,operador")]
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
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

<<<<<<< HEAD
    [Authorize(Roles = "admin")]
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    [HttpPost]
    public async Task<IActionResult> Adicionar(CriarClienteDto dto)
    {
        await _service.AdicionarAsync(dto);
        return Ok(new { Mensagem = "Cliente registado com sucesso!" });
    }
}