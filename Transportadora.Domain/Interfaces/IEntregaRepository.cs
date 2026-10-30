using Transportadora.Domain;

namespace Transportadora.Domain.Interfaces;

public interface IEntregaRepository
{
    Task<List<Entrega>> ObterTodasAsync();

    Task<Entrega?> ObterPorIdAsync(int id);

    Task AdicionarAsync(Entrega entrega);

    Task AtualizarAsync(Entrega entrega);

    Task RemoverAsync(int id);
}