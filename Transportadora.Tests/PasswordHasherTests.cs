using Transportadora.Application.Security;

namespace Transportadora.Tests;

public class PasswordHasherTests
{
    [Fact]
    public void SenhaCorreta_EhAceita()
    {
        var hash = PasswordHasher.Gerar("MinhaSenha#2026");

        Assert.True(PasswordHasher.Verificar("MinhaSenha#2026", hash));
    }

    [Fact]
    public void SenhaErrada_EhRejeitada()
    {
        var hash = PasswordHasher.Gerar("MinhaSenha#2026");

        Assert.False(PasswordHasher.Verificar("outra-senha", hash));
    }

    [Fact]
    public void MesmaSenha_GeraHashesDiferentes_PorCausaDoSalt()
    {
        var a = PasswordHasher.Gerar("123");
        var b = PasswordHasher.Gerar("123");

        Assert.NotEqual(a, b);
    }

    [Fact]
    public void HashNaoContemASenhaEmTextoPuro()
    {
        var hash = PasswordHasher.Gerar("SenhaSecreta99");

        Assert.DoesNotContain("SenhaSecreta99", hash);
        Assert.StartsWith("PBKDF2-SHA256$", hash);
    }

    [Theory]
    [InlineData("")]
    [InlineData("123")]
    [InlineData("PBKDF2-SHA256$abc$xx$yy")]
    [InlineData("OUTRO$600000$AAAA$BBBB")]
    [InlineData("PBKDF2-SHA256$600000$@@@$###")]
    public void FormatoInvalidoOuTextoPuro_NuncaAutentica(string armazenado)
    {
        Assert.False(PasswordHasher.Verificar("123", armazenado));
    }
}
