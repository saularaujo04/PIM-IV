namespace Transportadora.Domain;

public class Motorista : EntidadeBase
{
    public string Nome { get; private set; } = string.Empty;
    public string Cpf { get; private set; } = string.Empty;
    public string Cnh { get; private set; } = string.Empty;
    public string CategoriaCnh { get; private set; } = string.Empty; // Ex: D, E
    public string Telefone { get; private set; } = string.Empty;

    protected Motorista() { }

    public Motorista(string nome, string cpf, string cnh, string categoriaCnh, string telefone)
    {
        Nome = nome;
        Cpf = cpf;
        Cnh = cnh;
        CategoriaCnh = categoriaCnh;
        Telefone = telefone;
    }
}
