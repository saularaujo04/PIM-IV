using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Tests;

/// <summary>Repositório de entregas em memória (sem banco) para testar o EntregaService.</summary>
public class FakeEntregaRepository : IEntregaRepository
{
    public List<Entrega> Itens { get; } = new();
    private int _proximoId = 1;

    public Task<List<Entrega>> ObterTodasAsync() => Task.FromResult(Itens.ToList());

    public Task<List<Entrega>> ObterPorMotoristaAsync(int motoristaId) =>
        Task.FromResult(Itens.Where(e => e.MotoristaId == motoristaId).ToList());

    public Task<Entrega?> ObterPorIdAsync(int id) =>
        Task.FromResult(Itens.FirstOrDefault(e => e.Id == id));

    public Task AdicionarAsync(Entrega entrega)
    {
        // Id tem setter protegido: o banco o define de verdade; aqui simulamos por reflexão.
        typeof(EntidadeBase).GetProperty(nameof(EntidadeBase.Id))!.SetValue(entrega, _proximoId++);
        Itens.Add(entrega);
        return Task.CompletedTask;
    }

    public Task AtualizarAsync(Entrega entrega) => Task.CompletedTask;

    public Task RemoverAsync(int id)
    {
        Itens.RemoveAll(e => e.Id == id);
        return Task.CompletedTask;
    }
}

public class FakeOcorrenciaRepository : IOcorrenciaRepository
{
    public List<OcorrenciaEntrega> Itens { get; } = new();

    public Task<List<OcorrenciaEntrega>> ObterPorEntregaAsync(int entregaId) =>
        Task.FromResult(Itens.Where(o => o.EntregaId == entregaId).ToList());

    public Task<List<OcorrenciaEntrega>> ObterPorEntregasAsync(IEnumerable<int> entregaIds)
    {
        var ids = entregaIds.ToHashSet();
        return Task.FromResult(Itens.Where(o => ids.Contains(o.EntregaId)).ToList());
    }

    public Task AdicionarAsync(OcorrenciaEntrega ocorrencia)
    {
        Itens.Add(ocorrencia);
        return Task.CompletedTask;
    }
}
