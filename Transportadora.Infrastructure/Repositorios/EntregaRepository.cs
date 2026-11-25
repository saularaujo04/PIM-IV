using Microsoft.EntityFrameworkCore;
using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Infrastructure.Repositories;

public class EntregaRepository : IEntregaRepository
{
    private readonly TransportadoraDbContext _context;

    public EntregaRepository(TransportadoraDbContext context)
    {
        _context = context;
    }

    // Consultas de listagem são somente leitura: AsNoTracking evita custo de rastreamento.
    public async Task<List<Entrega>> ObterTodasAsync()
    {
        return await _context.Entregas
            .AsNoTracking()
            .Include(e => e.Cliente)
            .Include(e => e.Motorista)
            .Include(e => e.Veiculo)
            .OrderByDescending(e => e.Id)
            .ToListAsync();
    }

    public async Task<List<Entrega>> ObterPorMotoristaAsync(int motoristaId)
    {
        return await _context.Entregas
            .AsNoTracking()
            .Include(e => e.Cliente)
            .Include(e => e.Motorista)
            .Include(e => e.Veiculo)
            .Where(e => e.MotoristaId == motoristaId)
            .OrderByDescending(e => e.Id)
            .ToListAsync();
    }

    // Aqui o rastreamento fica ligado porque a entidade será alterada em seguida.
    public async Task<Entrega?> ObterPorIdAsync(int id)
    {
        return await _context.Entregas
            .Include(e => e.Cliente)
            .Include(e => e.Motorista)
            .Include(e => e.Veiculo)
            .FirstOrDefaultAsync(e => e.Id == id);
    }

    public async Task AdicionarAsync(Entrega entrega)
    {
        await _context.Entregas.AddAsync(entrega);
        await _context.SaveChangesAsync();
    }

    public async Task AtualizarAsync(Entrega entrega)
    {
        // Entidade já rastreada: SaveChanges grava só o que mudou.
        // Chamar Update() nela marcaria também Cliente/Motorista/Veículo como alterados.
        if (_context.Entry(entrega).State == EntityState.Detached)
            _context.Entregas.Update(entrega);

        await _context.SaveChangesAsync();
    }

    public async Task RemoverAsync(int id)
    {
        var entrega = await ObterPorIdAsync(id);
        if (entrega != null)
        {
            _context.Entregas.Remove(entrega);
            await _context.SaveChangesAsync();
        }
    }
}
