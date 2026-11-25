namespace Transportadora.Domain;

/// <summary>
/// Única definição do status da entrega (base 0).
/// Os valores são gravados como INT no banco e usados pelas views/trigger do script_banco.sql
/// e pelo app mobile: 0 = Pendente, 1 = Em trânsito, 2 = Concluída, 3 = Ocorrência.
/// </summary>
public enum StatusEntrega
{
    Pendente = 0,
    EmTransito = 1,
    Concluida = 2,
    Ocorrencia = 3
}
