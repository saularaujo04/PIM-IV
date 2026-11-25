using Transportadora.Application.DTOs;
using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Application.Services;

public class EntregaService
{
    private readonly IEntregaRepository _repository;
    private readonly IOcorrenciaRepository _ocorrencias;

    public EntregaService(IEntregaRepository repository, IOcorrenciaRepository ocorrencias)
    {
        _repository = repository;
        _ocorrencias = ocorrencias;
    }

    // ---------------------------------------------------------------- consultas

    public async Task<List<EntregaDto>> ObterTodasAsync()
    {
        var entregas = await _repository.ObterTodasAsync();
        return entregas.Select(e => EntregaParaDto(e, Enumerable.Empty<OcorrenciaEntrega>())).ToList();
    }

    public async Task<List<EntregaDto>> ObterDoMotoristaAsync(int motoristaId)
    {
        var entregas = await _repository.ObterPorMotoristaAsync(motoristaId);
        if (entregas.Count == 0)
            return new List<EntregaDto>();

        var ocorrencias = await _ocorrencias.ObterPorEntregasAsync(entregas.Select(e => e.Id));
        var porEntrega = ocorrencias.ToLookup(o => o.EntregaId);

        return entregas.Select(e => EntregaParaDto(e, porEntrega[e.Id])).ToList();
    }

    public async Task<EntregaDto?> ObterPorIdAsync(int id)
    {
        var entrega = await _repository.ObterPorIdAsync(id);
        if (entrega is null)
            return null;

        var ocorrencias = await _ocorrencias.ObterPorEntregaAsync(id);
        return EntregaParaDto(entrega, ocorrencias);
    }

    public async Task<List<OcorrenciaDto>> ObterOcorrenciasAsync(int id)
    {
        var ocorrencias = await _ocorrencias.ObterPorEntregaAsync(id);
        return ocorrencias.Select(OcorrenciaParaDto).ToList();
    }

    // ----------------------------------------------------------------- comandos

    public async Task<EntregaCriadaDto> AdicionarAsync(CriarEntregaDto dto)
    {
        var entrega = new Entrega(
            dto.ClienteId,
            dto.MotoristaId,
            dto.VeiculoId,
            dto.EnderecoOrigem.Trim(),
            dto.EnderecoDestino.Trim());

        await _repository.AdicionarAsync(entrega);
        return new EntregaCriadaDto(entrega.Id, entrega.CodigoRastreio);
    }

<<<<<<< HEAD
    public async Task IniciarRotaAsync(int id, int? motoristaId = null)
    {
        var entrega = await ObterParaAlterarAsync(id, motoristaId);
=======
    public async Task IniciarRotaAsync(int id)
    {
        var entrega = await ObterParaAlterarAsync(id);
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d

        entrega.IniciarRota();
        await _repository.AtualizarAsync(entrega);
    }

<<<<<<< HEAD
    public async Task ConcluirEntregaAsync(int id, int? motoristaId = null)
    {
        var entrega = await ObterParaAlterarAsync(id, motoristaId);
=======
    public async Task ConcluirEntregaAsync(int id)
    {
        var entrega = await ObterParaAlterarAsync(id);
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d

        entrega.ConcluirEntrega();
        await _repository.AtualizarAsync(entrega);
    }

<<<<<<< HEAD
    public async Task RegistrarOcorrenciaAsync(int id, CriarOcorrenciaDto dto, int? motoristaId = null)
    {
        var entrega = await ObterParaAlterarAsync(id, motoristaId);
=======
    public async Task RegistrarOcorrenciaAsync(int id, CriarOcorrenciaDto dto)
    {
        var entrega = await ObterParaAlterarAsync(id);
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d

        entrega.RegistrarOcorrencia();

        // Repositórios compartilham o mesmo DbContext (escopo da requisição):
        // um único SaveChanges grava a mudança de status e a ocorrência na mesma transação.
        await _ocorrencias.AdicionarAsync(new OcorrenciaEntrega(id, dto.Descricao.Trim()));
    }

    // ------------------------------------------------------------------ helpers

<<<<<<< HEAD
    /// <param name="motoristaId">
    /// Quando informado (usuário com perfil motorista), a entrega precisa pertencer a ele;
    /// senão lança UnauthorizedAccessException (HTTP 403 na API).
    /// </param>
    private async Task<Entrega> ObterParaAlterarAsync(int id, int? motoristaId)
    {
        var entrega = await _repository.ObterPorIdAsync(id)
            ?? throw new KeyNotFoundException("Entrega não encontrada.");

        if (motoristaId.HasValue && entrega.MotoristaId != motoristaId.Value)
            throw new UnauthorizedAccessException("Esta entrega pertence a outro motorista.");

        return entrega;
=======
    private async Task<Entrega> ObterParaAlterarAsync(int id)
    {
        return await _repository.ObterPorIdAsync(id)
            ?? throw new KeyNotFoundException("Entrega não encontrada.");
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    }

    private static OcorrenciaDto OcorrenciaParaDto(OcorrenciaEntrega o) => new()
    {
        Descricao = o.Descricao,
        DataOcorrencia = o.DataOcorrencia
    };

    private static EntregaDto EntregaParaDto(Entrega e, IEnumerable<OcorrenciaEntrega> ocorrencias) => new()
    {
        Id = e.Id,
        CodigoRastreio = e.CodigoRastreio,
        ClienteNome = e.Cliente?.RazaoSocial ?? string.Empty,
        MotoristaNome = e.Motorista?.Nome ?? string.Empty,
        VeiculoPlaca = e.Veiculo?.Placa ?? string.Empty,
        EnderecoOrigem = e.EnderecoOrigem,
        EnderecoDestino = e.EnderecoDestino,
        Status = (int)e.Status,
        StatusDescricao = e.Status switch
        {
            StatusEntrega.Pendente => "Pendente",
            StatusEntrega.EmTransito => "Em trânsito",
            StatusEntrega.Concluida => "Concluída",
            StatusEntrega.Ocorrencia => "Ocorrência",
            _ => "Desconhecido"
        },
        DataCriacao = e.DataCriacao,
        Ocorrencias = ocorrencias.Select(OcorrenciaParaDto).ToList()
    };
}
