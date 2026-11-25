using Transportadora.Application.DTOs;
using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Application.Services;

public class VeiculoService
{
    private readonly IVeiculoRepository _repository;

    public VeiculoService(IVeiculoRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<Veiculo>> ObterTodosAsync()
    {
        return await _repository.ObterTodosAsync();
    }

    public async Task AdicionarAsync(CriarVeiculoDto dto)
    {
        var veiculo = new Veiculo(
            dto.Placa,
            dto.Modelo,
            dto.CapacidadeKg,
            dto.Tipo);

        await _repository.AdicionarAsync(veiculo);
    }
}