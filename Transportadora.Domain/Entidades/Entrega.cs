namespace Transportadora.Domain;

public class Entrega : EntidadeBase
{
    public string CodigoRastreio { get; private set; } = string.Empty;
    public int ClienteId { get; private set; }
    public int MotoristaId { get; private set; }
    public int VeiculoId { get; private set; } // Adicionado
    public string EnderecoOrigem { get; private set; } = string.Empty;
    public string EnderecoDestino { get; private set; } = string.Empty;
    public StatusEntrega Status { get; private set; }

    // Propriedades de Navegação (Para o Entity Framework gerenciar os relacionamentos)
    public virtual Cliente? Cliente { get; private set; }
    public virtual Motorista? Motorista { get; private set; }
    public virtual Veiculo? Veiculo { get; private set; }

    protected Entrega() { }

    public Entrega(
        string codigoRastreio,
        int clienteId,
        int motoristaId,
        int veiculoId, // Adicionado
        string enderecoOrigem,
        string enderecoDestino)
    {
        CodigoRastreio = codigoRastreio;
        ClienteId = clienteId;
        MotoristaId = motoristaId;
        VeiculoId = veiculoId;
        EnderecoOrigem = enderecoOrigem;
        EnderecoDestino = enderecoDestino;
        Status = StatusEntrega.Pendente;
    }

    public void IniciarRota()
    {
        if (Status != StatusEntrega.Pendente)
            throw new InvalidOperationException(
                "Apenas entregas pendentes podem ser iniciadas.");

        Status = StatusEntrega.EmTransito;

        RegistrarAtualizacao();
    }

    public void ConcluirEntrega()
    {
        if (Status != StatusEntrega.EmTransito)
            throw new InvalidOperationException(
                "A entrega precisa estar em trânsito para ser concluída.");

        Status = StatusEntrega.Concluida;

        RegistrarAtualizacao();
    }

    public void RegistrarOcorrencia()
    {
        if (Status == StatusEntrega.Concluida)
            throw new InvalidOperationException(
                "Não é possível registrar ocorrência em uma entrega concluída.");

        Status = StatusEntrega.Ocorrencia;

        RegistrarAtualizacao();
    }
}