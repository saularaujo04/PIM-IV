using Microsoft.EntityFrameworkCore;
using Transportadora.Domain;

namespace Transportadora.Infrastructure;

public class TransportadoraDbContext : DbContext
{
    public TransportadoraDbContext(DbContextOptions<TransportadoraDbContext> options)
        : base(options)
    {
    }

    // Tabelas do Banco de Dados (DbSets)
    public DbSet<Entrega> Entregas { get; set; }
    public DbSet<OcorrenciaEntrega> Ocorrencias { get; set; }
    public DbSet<Cliente> Clientes { get; set; }
    public DbSet<Motorista> Motoristas { get; set; }
    public DbSet<Veiculo> Veiculos { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.UseSqlServer("Server=localhost;Database=TransportadoraDb;Trusted_Connection=True;TrustServerCertificate=True;");
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // =======================
        // Configuração: Entrega
        // =======================
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

        // Relacionamentos da Entrega (Chaves Estrangeiras)
        modelBuilder.Entity<Entrega>()
            .HasOne(e => e.Cliente)
            .WithMany()
            .HasForeignKey(e => e.ClienteId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Entrega>()
            .HasOne(e => e.Motorista)
            .WithMany()
            .HasForeignKey(e => e.MotoristaId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Entrega>()
            .HasOne(e => e.Veiculo)
            .WithMany()
            .HasForeignKey(e => e.VeiculoId)
            .OnDelete(DeleteBehavior.Restrict);

        // =======================
        // Configuração: Ocorrência
        // =======================
        modelBuilder.Entity<OcorrenciaEntrega>()
            .HasKey(o => o.Id);

        modelBuilder.Entity<OcorrenciaEntrega>()
            .Property(o => o.Descricao)
            .IsRequired()
            .HasMaxLength(500);

        // =======================
        // Configuração: Veiculo
        // =======================
        modelBuilder.Entity<Veiculo>()
            .Property(v => v.CapacidadeKg)
            .HasPrecision(10, 2);
    }
}