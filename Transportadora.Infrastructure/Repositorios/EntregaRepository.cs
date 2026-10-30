using Microsoft.EntityFrameworkCore;
using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Infrastructure.Repositories;

public class EntregaRepository : IEntregaRepository
{
    private readonly TransportadoraDbContext _context;

    public EntregaRepository(
        TransportadoraDbContext context)
    {
        _context = context;
    }

    public async Task<List<Entrega>> ObterTodasAsync()
    {
        return await _context.Entregas.ToListAsync();
    }

    public async Task<Entrega?> ObterPorIdAsync(int id)
    {
        return await _context.Entregas
            .FirstOrDefaultAsync(e => e.Id == id);
    }

    public async Task AdicionarAsync(Entrega entrega)
    {
        await _context.Entregas.AddAsync(entrega);

        await _context.SaveChangesAsync();
    }

    public async Task AtualizarAsync(Entrega entrega)
    {
        _context.Entregas.Update(entrega);

        await _context.SaveChangesAsync();
    }

    public async Task RemoverAsync(int id)
    {
        var entrega = await ObterPorIdAsync(id);

        if (entrega is not null)
        {
            _context.Entregas.Remove(entrega);

            await _context.SaveChangesAsync();
        }
    }
}