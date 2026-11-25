namespace Transportadora.Domain;

public abstract class EntidadeBase
{
    public int Id { get; protected set; }
    public DateTime DataCriacao { get; private set; } = DateTime.Now;
    public DateTime? DataAtualizacao { get; private set; }

    protected void RegistrarAtualizacao()
    {
        DataAtualizacao = DateTime.Now;
    }
}
