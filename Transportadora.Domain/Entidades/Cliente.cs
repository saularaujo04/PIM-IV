namespace Transportadora.Domain;

public class Cliente : EntidadeBase
{
    public string RazaoSocial { get; private set; } = string.Empty;
    public string Cnpj { get; private set; } = string.Empty;
    public string Telefone { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;

    protected Cliente() { } // Para o Entity Framework

    public Cliente(string razaoSocial, string cnpj, string telefone, string email)
    {
        RazaoSocial = razaoSocial;
        Cnpj = cnpj;
        Telefone = telefone;
        Email = email;
    }
}