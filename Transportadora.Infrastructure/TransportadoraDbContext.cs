<<<<<<< HEAD
using Microsoft.EntityFrameworkCore;
=======
﻿using Microsoft.EntityFrameworkCore;
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
using Transportadora.Domain;
using Transportadora.Domain.Entidades;

namespace Transportadora.Infrastructure;

public class TransportadoraDbContext : DbContext
{
<<<<<<< HEAD
    // PBKDF2-SHA256 (600.000 iterações) da senha de teste "123".
    internal const string SenhaHashAdmin = "PBKDF2-SHA256$600000$V2ani/IMfHg6c078lCxC+w==$rrrw/sLxdCTSWSJwavcLgSAA9i8K7FIuQ+svCeTpaJY=";
    internal const string SenhaHashOperador = "PBKDF2-SHA256$600000$DLAhrlhRX4CNM9WTTQ5gCg==$h3Qc0Obo14/tu3nSocyQTPd50uWgQSXa+V273rEMyAM=";
    internal const string SenhaHashMotorista = "PBKDF2-SHA256$600000$D1caVovv8ObA90Vul/W1Uw==$Qvjcj88e5GeHCwiEuYybrtdxfhR5k/uBc+vVt0zS+HA=";

=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
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
    public DbSet<Usuario> Usuarios { get; set; }

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

<<<<<<< HEAD
        // A tabela tem o trigger de auditoria trg_AuditStatusEntrega (criado por migration).
        // O EF Core 7+ precisa saber disso para não usar OUTPUT direto nos UPDATEs
        // (o SQL Server rejeita OUTPUT sem INTO em tabelas com trigger).
        modelBuilder.Entity<Entrega>()
            .ToTable(tb => tb.HasTrigger("trg_AuditStatusEntrega"));

=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
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

        // =======================
<<<<<<< HEAD
        // Carga Inicial: Usuários (senha de teste "123", guardada como hash PBKDF2)
        // Troque as senhas depois do primeiro acesso: POST /api/auth/alterar-senha.
        // Os hashes são constantes de propósito: HasData precisa de valores fixos.
        // =======================
        modelBuilder.Entity<Usuario>().HasData(
            new Usuario { Id = 1, Nome = "Administrador", Email = "admin@pim.com", Senha = SenhaHashAdmin, Perfil = "admin" },
            new Usuario { Id = 2, Nome = "Operador Logístico", Email = "log@pim.com", Senha = SenhaHashOperador, Perfil = "operador" },
            new Usuario { Id = 3, Nome = "Motorista Principal", Email = "mot@pim.com", Senha = SenhaHashMotorista, Perfil = "motorista" }
=======
        // Carga Inicial: Usuários
        // =======================
        modelBuilder.Entity<Usuario>().HasData(
            new Usuario { Id = 1, Nome = "Administrador", Email = "admin@pim.com", Senha = "123", Perfil = "admin" },
            new Usuario { Id = 2, Nome = "Operador Logístico", Email = "log@pim.com", Senha = "123", Perfil = "operador" },
            new Usuario { Id = 3, Nome = "Motorista Principal", Email = "mot@pim.com", Senha = "123", Perfil = "motorista" }
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
        );
    }
}