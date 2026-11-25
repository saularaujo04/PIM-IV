namespace Transportadora.Domain;

public class OcorrenciaEntrega
{
    public int Id { get; private set; }

    public int EntregaId { get; private set; }

    public string Descricao { get; private set; } = string.Empty;

    public DateTime DataOcorrencia { get; private set; }

    protected OcorrenciaEntrega()
    {
    }

    public OcorrenciaEntrega(
        int entregaId,
        string descricao)
    {
        EntregaId = entregaId;
        Descricao = descricao;
        DataOcorrencia = DateTime.Now;
    }
}
