using Microsoft.EntityFrameworkCore;
using Transportadora.Domain;

namespace Transportadora.Infrastructure;

public class TransportadoraDbContext : DbContext
{
    public TransportadoraDbContext(
        DbContextOptions<TransportadoraDbContext> options)
        : base(options)
    {
    }

    // Entregas
    public DbSet<Entrega> Entregas { get; set; }

    // Ocorrências
    public DbSet<OcorrenciaEntrega> Ocorrencias { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Entrega
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

        // Ocorrência
        modelBuilder.Entity<OcorrenciaEntrega>()
            .HasKey(o => o.Id);

        modelBuilder.Entity<OcorrenciaEntrega>()
            .Property(o => o.Descricao)
            .IsRequired()
            .HasMaxLength(500);
    }
}