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

    public async Task AdicionarAsync(Entrega entrega)
    {
        await _repository.AdicionarAsync(entrega);
    }

    public async Task AdicionarAsync(CriarEntregaDto dto)
    {
        var entrega = new Entrega(
            dto.CodigoRastreio,
            dto.ClienteId,
            dto.MotoristaId,
            dto.EnderecoOrigem,
            dto.EnderecoDestino);

        await _repository.AdicionarAsync(entrega);
    }

    public async Task AtualizarAsync(Entrega entrega)
    {
        await _repository.AtualizarAsync(entrega);
    }

    public async Task RemoverAsync(int id)
    {
        await _repository.RemoverAsync(id);
    }

    public async Task IniciarRotaAsync(int id)
    {
        var entrega = await _repository.ObterPorIdAsync(id);

        if (entrega is null)
            throw new Exception("Entrega não encontrada.");

        entrega.IniciarRota();

        await _repository.AtualizarAsync(entrega);
    }
    public async Task ConcluirEntregaAsync(int id)
    {
        var entrega = await _repository.ObterPorIdAsync(id);

        if (entrega is null)
            throw new Exception("Entrega não encontrada.");

        entrega.ConcluirEntrega();

        await _repository.AtualizarAsync(entrega);
    }
}