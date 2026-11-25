using Transportadora.Domain;

namespace Transportadora.Domain.Interfaces;

public interface IEntregaRepository
{
    Task<List<Entrega>> ObterTodasAsync();
    Task<List<Entrega>> ObterPorMotoristaAsync(int motoristaId);
    Task<Entrega?> ObterPorIdAsync(int id);
    Task AdicionarAsync(Entrega entrega);
    Task AtualizarAsync(Entrega entrega);
    Task RemoverAsync(int id);
}
