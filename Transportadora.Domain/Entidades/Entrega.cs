namespace Transportadora.Domain;

public class Entrega : EntidadeBase
{
    public string CodigoRastreio { get; private set; } = string.Empty;
    public int ClienteId { get; private set; }
    public int MotoristaId { get; private set; }
    public int VeiculoId { get; private set; }
    public string EnderecoOrigem { get; private set; } = string.Empty;
    public string EnderecoDestino { get; private set; } = string.Empty;
    public StatusEntrega Status { get; private set; }

    // Propriedades de Navegação
    public virtual Cliente? Cliente { get; private set; }
    public virtual Motorista? Motorista { get; private set; }
    public virtual Veiculo? Veiculo { get; private set; }

    protected Entrega() { }

    public Entrega(
        int clienteId,
        int motoristaId,
        int veiculoId,
        string enderecoOrigem = "A definir",
        string enderecoDestino = "A definir")
    {
        ClienteId = clienteId;
        MotoristaId = motoristaId;
        VeiculoId = veiculoId;
        EnderecoOrigem = enderecoOrigem;
        EnderecoDestino = enderecoDestino;
        CodigoRastreio = $"TRK-{Guid.NewGuid().ToString().Substring(0, 6).ToUpper()}";
        Status = StatusEntrega.Pendente;
    }

    public void IniciarRota()
    {
        if (Status != StatusEntrega.Pendente)
            throw new InvalidOperationException("Apenas entregas pendentes podem ser iniciadas.");

        Status = StatusEntrega.EmTransito;
        RegistrarAtualizacao();
    }

    public void ConcluirEntrega()
    {
        if (Status != StatusEntrega.EmTransito)
            throw new InvalidOperationException("A entrega precisa estar em trânsito para ser concluída.");

        Status = StatusEntrega.Concluida;
        RegistrarAtualizacao();
    }

    public void RegistrarOcorrencia()
    {
        if (Status == StatusEntrega.Concluida)
            throw new InvalidOperationException("Não é possível registrar ocorrência em uma entrega concluída.");

        Status = StatusEntrega.Ocorrencia;
        RegistrarAtualizacao();
    }
}