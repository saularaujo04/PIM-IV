using Transportadora.Domain;

namespace Transportadora.Domain.Interfaces;

public interface IOcorrenciaRepository
{
    Task<List<OcorrenciaEntrega>> ObterPorEntregaAsync(int entregaId);

    Task AdicionarAsync(OcorrenciaEntrega ocorrencia);
}