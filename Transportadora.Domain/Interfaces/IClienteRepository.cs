using Transportadora.Domain;

namespace Transportadora.Domain.Interfaces;

public interface IClienteRepository
{
    Task<List<Cliente>> ObterTodosAsync();
    Task<Cliente?> ObterPorIdAsync(int id);
    Task AdicionarAsync(Cliente cliente);
    Task AtualizarAsync(Cliente cliente);
    Task RemoverAsync(int id);
}