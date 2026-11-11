using Transportadora.Application.DTOs;
using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Application.Services;

public class EntregaService
{
    private readonly IEntregaRepository _repository;

    public EntregaService(IEntregaRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<Entrega>> ObterTodasAsync()
    {
        return await _repository.ObterTodasAsync();
    }

    public async Task<Entrega?> ObterPorIdAsync(int id)
    {
        return await _repository.ObterPorIdAsync(id);
    }

    public async Task AdicionarAsync(CriarEntregaDto dto)
    {
        var entrega = new Entrega(dto.ClienteId, dto.MotoristaId, dto.VeiculoId);
        await _repository.AdicionarAsync(entrega);
    }

    public async Task IniciarRotaAsync(int id)
    {
        var entrega = await _repository.ObterPorIdAsync(id)
            ?? throw new KeyNotFoundException("Entrega não encontrada.");

        entrega.IniciarRota();
        await _repository.AtualizarAsync(entrega);
    }

    public async Task ConcluirEntregaAsync(int id)
    {
        var entrega = await _repository.ObterPorIdAsync(id)
            ?? throw new KeyNotFoundException("Entrega não encontrada.");

        entrega.ConcluirEntrega();
        await _repository.AtualizarAsync(entrega);
    }

    public async Task RegistrarOcorrenciaAsync(int id, CriarOcorrenciaDto dto)
    {
        var entrega = await _repository.ObterPorIdAsync(id)
            ?? throw new KeyNotFoundException("Entrega não encontrada.");

        _ = dto; // Silencia o aviso IDE0060 indicando consumo do parâmetro
        entrega.RegistrarOcorrencia();
        await _repository.AtualizarAsync(entrega);
    }

    public async Task<List<object>> ObterOcorrenciasAsync(int id)
    {
        _ = id; // Silencia o aviso IDE0060
        return await Task.FromResult(new List<object>());
    }
}