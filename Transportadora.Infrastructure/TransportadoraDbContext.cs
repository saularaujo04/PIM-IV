using Microsoft.EntityFrameworkCore;
using Transportadora.Domain;

namespace Transportadora.Infrastructure;

public class TransportadoraDbContext : DbContext
{
    // Construtor que recebe as opções de conexão da API
    public TransportadoraDbContext(DbContextOptions<TransportadoraDbContext> options) : base(options)
    {
    }

    // Mapeia a entidade Entrega para a tabela "Entregas" no banco de dados
    public DbSet<Entrega> Entregas { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configurações e restrições da tabela Entregas
        modelBuilder.Entity<Entrega>()
            .HasKey(e => e.Id);

        modelBuilder.Entity<Entrega>()
            .Property(e => e.CodigoRastreio)
            .IsRequired()
            .HasMaxLength(30);

        modelBuilder.Entity<Entrega>()
            .Property(e => e.EnderecoOrigem)
            .IsRequired()
            .HasMaxLength(200);

        modelBuilder.Entity<Entrega>()
            .Property(e => e.EnderecoDestino)
            .IsRequired()
            .HasMaxLength(200);
    }
}