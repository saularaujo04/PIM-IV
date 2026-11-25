using System.ComponentModel.DataAnnotations;

namespace Transportadora.Application.Validation;

/// <summary>Validação dos dígitos verificadores de CPF e CNPJ (aceita com ou sem máscara).</summary>
public static class Documentos
{
    public static string SomenteDigitos(string? valor) =>
        new((valor ?? string.Empty).Where(char.IsDigit).ToArray());

    public static bool CpfValido(string? valor)
    {
        var d = SomenteDigitos(valor);
        if (d.Length != 11 || d.Distinct().Count() == 1)
            return false;

        for (var n = 9; n <= 10; n++)
        {
            var soma = 0;
            for (var i = 0; i < n; i++)
                soma += (d[i] - '0') * (n + 1 - i);

            var digito = soma * 10 % 11 % 10;
            if (d[n] - '0' != digito)
                return false;
        }

        return true;
    }

    public static bool CnpjValido(string? valor)
    {
        var d = SomenteDigitos(valor);
        if (d.Length != 14 || d.Distinct().Count() == 1)
            return false;

        int[] pesos1 = { 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };
        int[] pesos2 = { 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };

        return DigitoCnpj(d, pesos1) == d[12] - '0' && DigitoCnpj(d, pesos2) == d[13] - '0';
    }

    private static int DigitoCnpj(string d, int[] pesos)
    {
        var soma = 0;
        for (var i = 0; i < pesos.Length; i++)
            soma += (d[i] - '0') * pesos[i];

        var resto = soma % 11;
        return resto < 2 ? 0 : 11 - resto;
    }
}

/// <summary>Valida CPF. Vazio/nulo passa (use [Required] para obrigar).</summary>
[AttributeUsage(AttributeTargets.Property | AttributeTargets.Field | AttributeTargets.Parameter)]
public sealed class CpfAttribute : ValidationAttribute
{
    public CpfAttribute() : base("CPF inválido.") { }

    public override bool IsValid(object? value) =>
        value is not string s || s.Length == 0 || Documentos.CpfValido(s);
}

/// <summary>Valida CPF (11 dígitos) ou CNPJ (14 dígitos). Vazio/nulo passa.</summary>
[AttributeUsage(AttributeTargets.Property | AttributeTargets.Field | AttributeTargets.Parameter)]
public sealed class CpfOuCnpjAttribute : ValidationAttribute
{
    public CpfOuCnpjAttribute() : base("CPF ou CNPJ inválido.") { }

    public override bool IsValid(object? value)
    {
        if (value is not string s || s.Length == 0)
            return true;

        return Documentos.SomenteDigitos(s).Length switch
        {
            11 => Documentos.CpfValido(s),
            14 => Documentos.CnpjValido(s),
            _ => false
        };
    }
}
