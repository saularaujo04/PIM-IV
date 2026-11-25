using Microsoft.EntityFrameworkCore;
using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Infrastructure.Repositories;

public class OcorrenciaRepository : IOcorrenciaRepository
{
    private readonly TransportadoraDbContext _context;

    public OcorrenciaRepository(
        TransportadoraDbContext context)
    {
        _context = context;
    }

    public async Task<List<OcorrenciaEntrega>> ObterPorEntregaAsync(int entregaId)
    {
        return await _context.Ocorrencias
            .AsNoTracking()
            .Where(o => o.EntregaId == entregaId)
            .OrderBy(o => o.DataOcorrencia)
            .ToListAsync();
    }

    public async Task<List<OcorrenciaEntrega>> ObterPorEntregasAsync(IEnumerable<int> entregaIds)
    {
        var ids = entregaIds.ToList();

        return await _context.Ocorrencias
            .AsNoTracking()
            .Where(o => ids.Contains(o.EntregaId))
            .OrderBy(o => o.DataOcorrencia)
            .ToListAsync();
    }

    public async Task AdicionarAsync(OcorrenciaEntrega ocorrencia)
    {
        await _context.Ocorrencias.AddAsync(ocorrencia);

        await _context.SaveChangesAsync();
    }
}
