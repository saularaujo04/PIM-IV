using Transportadora.Application.DTOs;
using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Application.Services;

public class MotoristaService
{
    private readonly IMotoristaRepository _repository;

    public MotoristaService(IMotoristaRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<Motorista>> ObterTodosAsync()
    {
        return await _repository.ObterTodosAsync();
    }

    public async Task AdicionarAsync(CriarMotoristaDto dto)
    {
        var motorista = new Motorista(
            dto.Nome,
            dto.Cpf,
            dto.Cnh,
            dto.Telefone);

        await _repository.AdicionarAsync(motorista);
    }
}