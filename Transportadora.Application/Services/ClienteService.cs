using Transportadora.Application.DTOs;
using Transportadora.Domain;
using Transportadora.Domain.Interfaces;

namespace Transportadora.Application.Services;

public class ClienteService
{
    private readonly IClienteRepository _repository;

    public ClienteService(IClienteRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<Cliente>> ObterTodosAsync()
    {
        return await _repository.ObterTodosAsync();
    }

    public async Task<Cliente?> ObterPorIdAsync(int id)
    {
        return await _repository.ObterPorIdAsync(id);
    }

    public async Task AdicionarAsync(CriarClienteDto dto)
    {
        // Ordem do construtor: razão social, CNPJ/CPF, telefone, e-mail.
        var cliente = new Cliente(
            dto.Nome.Trim(),
            dto.Documento.Trim(),
            dto.Telefone.Trim(),
            dto.Email.Trim());

        await _repository.AdicionarAsync(cliente);
    }

    public async Task AtualizarAsync(Cliente cliente)
    {
        await _repository.AtualizarAsync(cliente);
    }

    public async Task RemoverAsync(int id)
    {
        await _repository.RemoverAsync(id);
    }
}
