using Transportadora.Domain;

namespace Transportadora.Domain.Interfaces;

public interface IMotoristaRepository
{
    Task<List<Motorista>> ObterTodosAsync();
    Task<Motorista?> ObterPorIdAsync(int id);
    Task AdicionarAsync(Motorista motorista);
}