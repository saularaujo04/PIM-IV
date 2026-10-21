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

    public async Task AtualizarAsync(Entrega entrega)
    {
        await _repository.AtualizarAsync(entrega);
    }

    public async Task RemoverAsync(int id)
    {
        await _repository.RemoverAsync(id);
    }
}