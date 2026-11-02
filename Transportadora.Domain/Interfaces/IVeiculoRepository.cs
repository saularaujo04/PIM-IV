using Transportadora.Domain;

namespace Transportadora.Domain.Interfaces;

public interface IVeiculoRepository
{
    Task<List<Veiculo>> ObterTodosAsync();
    Task<Veiculo?> ObterPorIdAsync(int id);
    Task AdicionarAsync(Veiculo veiculo);
}