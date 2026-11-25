using System.Security.Cryptography;

namespace Transportadora.Application.Security;

/// <summary>
/// Hash de senha com PBKDF2-SHA256 (sem pacotes externos).
/// Formato guardado no banco: PBKDF2-SHA256$iterações$salt(base64)$hash(base64).
/// As iterações ficam no próprio texto, então dá para aumentá-las no futuro sem quebrar senhas antigas.
/// </summary>
public static class PasswordHasher
{
    private const string Prefixo = "PBKDF2-SHA256";
    private const int Iteracoes = 600_000;
    private const int LimiteIteracoes = 5_000_000;
    private const int TamanhoSalt = 16;
    private const int TamanhoHash = 32;

    public static string Gerar(string senha)
    {
        var salt = RandomNumberGenerator.GetBytes(TamanhoSalt);
        var hash = Rfc2898DeriveBytes.Pbkdf2(senha, salt, Iteracoes, HashAlgorithmName.SHA256, TamanhoHash);
        return $"{Prefixo}${Iteracoes}${Convert.ToBase64String(salt)}${Convert.ToBase64String(hash)}";
    }

    public static bool Verificar(string senha, string armazenado)
    {
        if (string.IsNullOrEmpty(armazenado))
            return false;

        var partes = armazenado.Split('$');
        if (partes.Length != 4 || partes[0] != Prefixo)
            return false;

        if (!int.TryParse(partes[1], out var iteracoes) || iteracoes <= 0 || iteracoes > LimiteIteracoes)
            return false;

        try
        {
            var salt = Convert.FromBase64String(partes[2]);
            var esperado = Convert.FromBase64String(partes[3]);
            if (esperado.Length == 0)
                return false;

            var calculado = Rfc2898DeriveBytes.Pbkdf2(senha, salt, iteracoes, HashAlgorithmName.SHA256, esperado.Length);
            return CryptographicOperations.FixedTimeEquals(calculado, esperado);
        }
        catch (FormatException)
        {
            return false;
        }
    }
}
