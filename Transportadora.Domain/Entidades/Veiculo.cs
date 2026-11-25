namespace Transportadora.Domain;

public class Veiculo : EntidadeBase
{
    public string Placa { get; private set; } = string.Empty;
    public string Modelo { get; private set; } = string.Empty;
    public decimal CapacidadeKg { get; private set; }
    public string Tipo { get; private set; } = string.Empty; // Ex: Carreta, VUC
    protected Veiculo() { }

    public Veiculo(string placa, string modelo, decimal capacidadeKg, string tipo)
    {
        Placa = placa;
        Modelo = modelo;
        CapacidadeKg = capacidadeKg;
        Tipo = tipo;
    }
}