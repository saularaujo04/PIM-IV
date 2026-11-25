using Microsoft.EntityFrameworkCore;
using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Infrastructure.Repositories;

public class MotoristaRepository : IMotoristaRepository
{
    private readonly TransportadoraDbContext _context;

    public MotoristaRepository(TransportadoraDbContext context)
    {
        _context = context;
    }

    public async Task<List<Motorista>> ObterTodosAsync()
    {
        return await _context.Motoristas.ToListAsync();
    }

    public async Task<Motorista?> ObterPorIdAsync(int id)
    {
        return await _context.Motoristas.FindAsync(id);
    }

    public async Task AdicionarAsync(Motorista motorista)
    {
        await _context.Motoristas.AddAsync(motorista);
        await _context.SaveChangesAsync();
    }
}