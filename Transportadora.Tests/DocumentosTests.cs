using Transportadora.Application.Validation;

namespace Transportadora.Tests;

public class DocumentosTests
{
    [Theory]
    [InlineData("529.982.247-25")]
    [InlineData("52998224725")]
    [InlineData("168.995.350-09")]
    [InlineData("453.178.287-91")]
    public void Cpf_Valido(string cpf) => Assert.True(Documentos.CpfValido(cpf));

    [Theory]
    [InlineData("123.456.789-00")]
    [InlineData("111.111.111-11")]
    [InlineData("529.982.247-26")]
    [InlineData("123")]
    [InlineData("")]
    [InlineData(null)]
    public void Cpf_Invalido(string? cpf) => Assert.False(Documentos.CpfValido(cpf));

    [Theory]
    [InlineData("11.222.333/0001-81")]
    [InlineData("11222333000181")]
    [InlineData("11.444.777/0001-61")]
    public void Cnpj_Valido(string cnpj) => Assert.True(Documentos.CnpjValido(cnpj));

    [Theory]
    [InlineData("12.345.678/0001-90")]
    [InlineData("00.000.000/0000-00")]
    [InlineData("11.222.333/0001-82")]
    [InlineData("")]
    [InlineData(null)]
    public void Cnpj_Invalido(string? cnpj) => Assert.False(Documentos.CnpjValido(cnpj));

    [Fact]
    public void AtributoCpfOuCnpj_AceitaOsDoisTiposERejeitaOutrosTamanhos()
    {
        var atributo = new CpfOuCnpjAttribute();

        Assert.True(atributo.IsValid("529.982.247-25"));
        Assert.True(atributo.IsValid("11.222.333/0001-81"));
        Assert.False(atributo.IsValid("12345"));
        Assert.False(atributo.IsValid("123.456.789-00"));
        Assert.True(atributo.IsValid(""));   // obrigatoriedade é papel do [Required]
    }

    [Fact]
    public void AtributoCpf_RejeitaCnpj()
    {
        Assert.False(new CpfAttribute().IsValid("11.222.333/0001-81"));
        Assert.True(new CpfAttribute().IsValid("529.982.247-25"));
    }
}
