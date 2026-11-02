using Microsoft.EntityFrameworkCore;
using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Infrastructure.Repositories;

public class VeiculoRepository : IVeiculoRepository
{
    private readonly TransportadoraDbContext _context;

    public VeiculoRepository(TransportadoraDbContext context)
    {
        _context = context;
    }

    public async Task<List<Veiculo>> ObterTodosAsync()
    {
        return await _context.Veiculos.ToListAsync();
    }

    public async Task<Veiculo?> ObterPorIdAsync(int id)
    {
        return await _context.Veiculos.FindAsync(id);
    }

    public async Task AdicionarAsync(Veiculo veiculo)
    {
        await _context.Veiculos.AddAsync(veiculo);
        await _context.SaveChangesAsync();
    }
}