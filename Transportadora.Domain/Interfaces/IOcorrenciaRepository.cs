using Transportadora.Domain;

namespace Transportadora.Domain.Interfaces;

public interface IOcorrenciaRepository
{
    Task<List<OcorrenciaEntrega>> ObterPorEntregaAsync(int entregaId);

    Task<List<OcorrenciaEntrega>> ObterPorEntregasAsync(IEnumerable<int> entregaIds);

    Task AdicionarAsync(OcorrenciaEntrega ocorrencia);
}
