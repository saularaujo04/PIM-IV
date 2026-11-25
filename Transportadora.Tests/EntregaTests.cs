using Transportadora.Domain;

namespace Transportadora.Tests;

/// <summary>Regras de transição de status da entidade Entrega.</summary>
public class EntregaTests
{
    private static Entrega NovaEntrega() => new(1, 1, 1, "Origem X", "Destino Y");

    [Fact]
    public void NovaEntrega_ComecaPendenteComCodigoDeRastreio()
    {
        var entrega = NovaEntrega();

        Assert.Equal(StatusEntrega.Pendente, entrega.Status);
        Assert.Matches("^TRK-[0-9A-F]{6}$", entrega.CodigoRastreio);
        Assert.Equal("Origem X", entrega.EnderecoOrigem);
        Assert.Equal("Destino Y", entrega.EnderecoDestino);
    }

    [Fact]
    public void ValoresDoEnum_SaoOsMesmosDoBancoEDoApp()
    {
        Assert.Equal(0, (int)StatusEntrega.Pendente);
        Assert.Equal(1, (int)StatusEntrega.EmTransito);
        Assert.Equal(2, (int)StatusEntrega.Concluida);
        Assert.Equal(3, (int)StatusEntrega.Ocorrencia);
    }

    [Fact]
    public void IniciarRota_DePendente_VaiParaEmTransito()
    {
        var entrega = NovaEntrega();

        entrega.IniciarRota();

        Assert.Equal(StatusEntrega.EmTransito, entrega.Status);
        Assert.NotNull(entrega.DataAtualizacao);
    }

    [Fact]
    public void IniciarRota_QuandoJaEmTransito_Lanca()
    {
        var entrega = NovaEntrega();
        entrega.IniciarRota();

        Assert.Throws<InvalidOperationException>(() => entrega.IniciarRota());
    }

    [Fact]
    public void Concluir_SemEstarEmTransito_Lanca()
    {
        var entrega = NovaEntrega();

        Assert.Throws<InvalidOperationException>(() => entrega.ConcluirEntrega());
    }

    [Fact]
    public void Concluir_DeEmTransito_VaiParaConcluida()
    {
        var entrega = NovaEntrega();
        entrega.IniciarRota();

        entrega.ConcluirEntrega();

        Assert.Equal(StatusEntrega.Concluida, entrega.Status);
    }

    [Fact]
    public void RegistrarOcorrencia_EmTransito_VaiParaOcorrencia()
    {
        var entrega = NovaEntrega();
        entrega.IniciarRota();

        entrega.RegistrarOcorrencia();

        Assert.Equal(StatusEntrega.Ocorrencia, entrega.Status);
    }

    [Fact]
    public void RegistrarOcorrencia_AposConcluida_Lanca()
    {
        var entrega = NovaEntrega();
        entrega.IniciarRota();
        entrega.ConcluirEntrega();

        Assert.Throws<InvalidOperationException>(() => entrega.RegistrarOcorrencia());
    }

    [Fact]
    public void AposOcorrencia_AEntregaPodeSerRetomadaEConcluida()
    {
        var entrega = NovaEntrega();
        entrega.IniciarRota();
        entrega.RegistrarOcorrencia();

        entrega.IniciarRota();
        entrega.ConcluirEntrega();

        Assert.Equal(StatusEntrega.Concluida, entrega.Status);
    }

    [Fact]
    public void Concluir_ComOcorrenciaAberta_Lanca()
    {
        var entrega = NovaEntrega();
        entrega.IniciarRota();
        entrega.RegistrarOcorrencia();

        Assert.Throws<InvalidOperationException>(() => entrega.ConcluirEntrega());
    }
}
