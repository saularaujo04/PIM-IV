using Microsoft.EntityFrameworkCore;
using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Infrastructure.Repositories;

public class ClienteRepository : IClienteRepository
{
    private readonly TransportadoraDbContext _context;

    public ClienteRepository(TransportadoraDbContext context)
    {
        _context = context;
    }

    public async Task<List<Cliente>> ObterTodosAsync()
    {
        return await _context.Clientes.ToListAsync();
    }

    public async Task<Cliente?> ObterPorIdAsync(int id)
    {
        return await _context.Clientes.FindAsync(id);
    }

    public async Task AdicionarAsync(Cliente cliente)
    {
        await _context.Clientes.AddAsync(cliente);
        await _context.SaveChangesAsync();
    }

    public async Task AtualizarAsync(Cliente cliente)
    {
        _context.Clientes.Update(cliente);
        await _context.SaveChangesAsync();
    }

    public async Task RemoverAsync(int id)
    {
        var cliente = await ObterPorIdAsync(id);
        if (cliente != null)
        {
            _context.Clientes.Remove(cliente);
            await _context.SaveChangesAsync();
        }
    }
}