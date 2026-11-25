using Transportadora.Application.DTOs;
using Transportadora.Application.Services;
using Transportadora.Domain;

namespace Transportadora.Tests;

public class EntregaServiceTests
{
    private readonly FakeEntregaRepository _entregas = new();
    private readonly FakeOcorrenciaRepository _ocorrencias = new();
    private readonly EntregaService _service;

    public EntregaServiceTests()
    {
        _service = new EntregaService(_entregas, _ocorrencias);
    }

    private async Task<int> CriarEntregaAsync(int motoristaId = 1)
    {
        var criada = await _service.AdicionarAsync(new CriarEntregaDto
        {
            ClienteId = 1,
            MotoristaId = motoristaId,
            VeiculoId = 1,
            EnderecoOrigem = "  Galpão  ",
            EnderecoDestino = "Av. Paulista, 1500"
        });
        return criada.Id;
    }

    [Fact]
    public async Task Adicionar_GravaOrigemEDestino_ESemEspacosNasPontas()
    {
        var id = await CriarEntregaAsync();

        var entrega = await _entregas.ObterPorIdAsync(id);

        Assert.NotNull(entrega);
        Assert.Equal("Galpão", entrega!.EnderecoOrigem);
        Assert.Equal("Av. Paulista, 1500", entrega.EnderecoDestino);
        Assert.Equal(StatusEntrega.Pendente, entrega.Status);
    }

    [Fact]
    public async Task ObterDoMotorista_DevolveSoAsEntregasDele()
    {
        await CriarEntregaAsync(motoristaId: 1);
        await CriarEntregaAsync(motoristaId: 1);
        await CriarEntregaAsync(motoristaId: 2);

        var doMotorista1 = await _service.ObterDoMotoristaAsync(1);
        var doMotorista3 = await _service.ObterDoMotoristaAsync(3);

        Assert.Equal(2, doMotorista1.Count);
        Assert.Empty(doMotorista3);
    }

    [Fact]
    public async Task Fluxo_IniciarEConcluir_AtualizaOStatusNoDto()
    {
        var id = await CriarEntregaAsync();

        await _service.IniciarRotaAsync(id);
        Assert.Equal((int)StatusEntrega.EmTransito, (await _service.ObterPorIdAsync(id))!.Status);

        await _service.ConcluirEntregaAsync(id);
        var dto = (await _service.ObterPorIdAsync(id))!;
        Assert.Equal((int)StatusEntrega.Concluida, dto.Status);
        Assert.Equal("Concluída", dto.StatusDescricao);
    }

    [Fact]
    public async Task RegistrarOcorrencia_SalvaADescricaoEMudaOStatus()
    {
        var id = await CriarEntregaAsync();
        await _service.IniciarRotaAsync(id);

        await _service.RegistrarOcorrenciaAsync(id, new CriarOcorrenciaDto { Descricao = " Destinatário ausente " });

        var dto = (await _service.ObterDoMotoristaAsync(1)).Single();
        Assert.Equal((int)StatusEntrega.Ocorrencia, dto.Status);
        Assert.Single(dto.Ocorrencias);
        Assert.Equal("Destinatário ausente", dto.Ocorrencias[0].Descricao);
    }

    [Fact]
    public async Task Concluir_EntregaPendente_LancaInvalidOperation()
    {
        var id = await CriarEntregaAsync();

        await Assert.ThrowsAsync<InvalidOperationException>(() => _service.ConcluirEntregaAsync(id));
    }

    [Fact]
    public async Task EntregaInexistente_LancaKeyNotFound()
    {
        await Assert.ThrowsAsync<KeyNotFoundException>(() => _service.IniciarRotaAsync(999));
    }

    [Fact]
    public async Task Motorista_NaoMexeNaEntregaDeOutro_Lanca()
    {
        var id = await CriarEntregaAsync(motoristaId: 1);

        await Assert.ThrowsAsync<UnauthorizedAccessException>(
            () => _service.IniciarRotaAsync(id, motoristaId: 2));
        await Assert.ThrowsAsync<UnauthorizedAccessException>(
            () => _service.RegistrarOcorrenciaAsync(id, new CriarOcorrenciaDto { Descricao = "x" }, motoristaId: -1));
    }

    [Fact]
    public async Task Motorista_PodeMexerNaPropriaEntrega()
    {
        var id = await CriarEntregaAsync(motoristaId: 1);

        await _service.IniciarRotaAsync(id, motoristaId: 1);

        Assert.Equal((int)StatusEntrega.EmTransito, (await _service.ObterPorIdAsync(id))!.Status);
    }
}
