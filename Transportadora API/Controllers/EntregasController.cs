using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Transportadora.Application.DTOs;
using Transportadora.Application.Services;

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

    /// <summary>Todas as entregas (painel web).</summary>
<<<<<<< HEAD
    [Authorize(Roles = "admin,operador")]
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    [HttpGet]
    [ProducesResponseType(typeof(List<EntregaDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterTodas()
    {
        return Ok(await _service.ObterTodasAsync());
    }

    /// <summary>Entregas do motorista logado (app mobile).</summary>
    [HttpGet("minhas")]
    [ProducesResponseType(typeof(List<EntregaDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterMinhas()
    {
        // Usuário sem vínculo com um motorista não tem entregas.
        if (!int.TryParse(User.FindFirst("motoristaId")?.Value, out var motoristaId))
            return Ok(new List<EntregaDto>());

        return Ok(await _service.ObterDoMotoristaAsync(motoristaId));
    }

<<<<<<< HEAD
    [Authorize(Roles = "admin,operador")]
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(EntregaDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObterPorId(int id)
    {
        var entrega = await _service.ObterPorIdAsync(id);

        if (entrega is null)
            return NotFound(new { Mensagem = "Entrega não encontrada." });

        return Ok(entrega);
    }

<<<<<<< HEAD
    [Authorize(Roles = "admin,operador")]
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    [HttpPost]
    [ProducesResponseType(typeof(EntregaCriadaDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar([FromBody] CriarEntregaDto dto)
    {
        try
        {
            var criada = await _service.AdicionarAsync(dto);
            return Ok(new
            {
                Mensagem = "Entrega cadastrada com sucesso.",
                criada.Id,
                criada.CodigoRastreio
            });
        }
        catch (Exception ex)
        {
            // Normalmente chave estrangeira inválida (cliente, motorista ou veículo inexistente).
            return BadRequest(new { Mensagem = ex.GetBaseException().Message });
        }
    }

    [HttpPost("{id:int}/iniciar-rota")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public Task<IActionResult> IniciarRota(int id) =>
<<<<<<< HEAD
        Executar(() => _service.IniciarRotaAsync(id, MotoristaRestrito()), "Rota iniciada com sucesso.");
=======
        Executar(() => _service.IniciarRotaAsync(id), "Rota iniciada com sucesso.");
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d

    [HttpPost("{id:int}/concluir")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public Task<IActionResult> ConcluirEntrega(int id) =>
<<<<<<< HEAD
        Executar(() => _service.ConcluirEntregaAsync(id, MotoristaRestrito()), "Entrega concluída com sucesso.");
=======
        Executar(() => _service.ConcluirEntregaAsync(id), "Entrega concluída com sucesso.");
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d

    [HttpPost("{id:int}/nao-realizada")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public Task<IActionResult> MarcarNaoRealizada(int id) =>
        Executar(
            () => _service.RegistrarOcorrenciaAsync(id, new CriarOcorrenciaDto
            {
                Descricao = "Entrega não realizada pelo motorista."
<<<<<<< HEAD
            }, MotoristaRestrito()),
=======
            }),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
            "Entrega marcada como não realizada.");

    [HttpPost("{id:int}/ocorrencia")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public Task<IActionResult> RegistrarOcorrencia(int id, [FromBody] CriarOcorrenciaDto dto) =>
<<<<<<< HEAD
        Executar(() => _service.RegistrarOcorrenciaAsync(id, dto, MotoristaRestrito()), "Ocorrência registrada com sucesso.");

    [Authorize(Roles = "admin,operador")]
=======
        Executar(() => _service.RegistrarOcorrenciaAsync(id, dto), "Ocorrência registrada com sucesso.");

>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    [HttpGet("{id:int}/ocorrencias")]
    [ProducesResponseType(typeof(List<OcorrenciaDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterOcorrencias(int id)
    {
        return Ok(await _service.ObterOcorrenciasAsync(id));
    }

    /// <summary>
    /// Executa um comando de domínio traduzindo as exceções em códigos HTTP:
    /// não encontrada = 404; regra de negócio violada (ex.: status inválido) = 409.
    /// </summary>
    private async Task<IActionResult> Executar(Func<Task> acao, string mensagemSucesso)
    {
        try
        {
            await acao();
            return Ok(new { Mensagem = mensagemSucesso });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { Mensagem = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { Mensagem = ex.Message });
        }
<<<<<<< HEAD
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { Mensagem = ex.Message });
        }
    }

    /// <summary>
    /// Motorista só pode mexer nas próprias entregas: devolve o id dele (ou -1 se não houver vínculo,
    /// valor que nunca coincide com uma entrega). Admin e operador não têm restrição (null).
    /// </summary>
    private int? MotoristaRestrito()
    {
        if (!User.IsInRole("motorista"))
            return null;

        return int.TryParse(User.FindFirst("motoristaId")?.Value, out var id) ? id : -1;
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    }
}
