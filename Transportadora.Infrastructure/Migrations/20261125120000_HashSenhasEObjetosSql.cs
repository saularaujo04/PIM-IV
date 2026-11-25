using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Transportadora.Infrastructure;

#nullable disable

namespace Transportadora.Infrastructure.Migrations
{
    /// <summary>
    /// 1) Troca as senhas de teste (texto puro "123") por hash PBKDF2.
    /// 2) Cria as views, a tabela de auditoria, o trigger e a stored procedure
    ///    (antes isso ficava só no script_banco.sql, que não rodava no deploy).
    /// Os comandos SQL são idempotentes (CREATE OR ALTER / IF NOT EXISTS).
    /// Escrita à mão; se preferir regenerar o Designer, apague este arquivo e rode:
    ///   dotnet ef migrations add HashSenhasEObjetosSql
    /// e depois recoloque os comandos de Sql() abaixo.
    /// </summary>
    [DbContext(typeof(TransportadoraDbContext))]
    [Migration("20261125120000_HashSenhasEObjetosSql")]
    public partial class HashSenhasEObjetosSql : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // ---- senhas com hash ----
            migrationBuilder.UpdateData(table: "Usuarios", keyColumn: "Id", keyValue: 1,
                column: "Senha", value: "PBKDF2-SHA256$600000$V2ani/IMfHg6c078lCxC+w==$rrrw/sLxdCTSWSJwavcLgSAA9i8K7FIuQ+svCeTpaJY=");
            migrationBuilder.UpdateData(table: "Usuarios", keyColumn: "Id", keyValue: 2,
                column: "Senha", value: "PBKDF2-SHA256$600000$DLAhrlhRX4CNM9WTTQ5gCg==$h3Qc0Obo14/tu3nSocyQTPd50uWgQSXa+V273rEMyAM=");
            migrationBuilder.UpdateData(table: "Usuarios", keyColumn: "Id", keyValue: 3,
                column: "Senha", value: "PBKDF2-SHA256$600000$D1caVovv8ObA90Vul/W1Uw==$Qvjcj88e5GeHCwiEuYybrtdxfhR5k/uBc+vVt0zS+HA=");

            // ---- views ----
            migrationBuilder.Sql("""
                CREATE OR ALTER VIEW vw_RelatorioEntregasDetalhadas AS
                SELECT
                    e.Id AS EntregaId,
                    e.CodigoRastreio,
                    c.RazaoSocial AS ClienteNome,
                    m.Nome AS MotoristaNome,
                    v.Placa AS VeiculoPlaca,
                    v.Modelo AS VeiculoModelo,
                    e.EnderecoOrigem,
                    e.EnderecoDestino,
                    CASE e.Status
                        WHEN 0 THEN 'Pendente'
                        WHEN 1 THEN 'Em Trânsito'
                        WHEN 2 THEN 'Concluída'
                        WHEN 3 THEN 'Ocorrência'
                        ELSE 'Desconhecido'
                    END AS StatusDescricao,
                    e.DataCriacao
                FROM Entregas e
                INNER JOIN Clientes c ON e.ClienteId = c.Id
                INNER JOIN Motoristas m ON e.MotoristaId = m.Id
                INNER JOIN Veiculos v ON e.VeiculoId = v.Id
                """);

            migrationBuilder.Sql("""
                CREATE OR ALTER VIEW vw_DashboardOperacional AS
                SELECT
                    COUNT(e.Id) AS TotalEntregas,
                    ISNULL(SUM(CASE WHEN e.Status = 0 THEN 1 ELSE 0 END), 0) AS QtdPendentes,
                    ISNULL(SUM(CASE WHEN e.Status = 1 THEN 1 ELSE 0 END), 0) AS QtdEmTransito,
                    ISNULL(SUM(CASE WHEN e.Status = 2 THEN 1 ELSE 0 END), 0) AS QtdConcluidas,
                    ISNULL(SUM(CASE WHEN e.Status = 3 THEN 1 ELSE 0 END), 0) AS QtdOcorrencias
                FROM Entregas e
                """);

            // ---- tabela de auditoria ----
            migrationBuilder.Sql("""
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LogHistoricoEntregas')
                BEGIN
                    CREATE TABLE LogHistoricoEntregas (
                        Id INT IDENTITY(1,1) PRIMARY KEY,
                        EntregaId INT NOT NULL,
                        StatusAnterior INT,
                        StatusNovo INT,
                        DataAlteracao DATETIME DEFAULT GETDATE(),
                        UsuarioSistema VARCHAR(100) DEFAULT SYSTEM_USER
                    );
                END
                """);

            // ---- trigger de auditoria ----
            migrationBuilder.Sql("""
                CREATE OR ALTER TRIGGER trg_AuditStatusEntrega
                ON Entregas
                AFTER UPDATE
                AS
                BEGIN
                    SET NOCOUNT ON;

                    IF UPDATE(Status)
                    BEGIN
                        INSERT INTO LogHistoricoEntregas (EntregaId, StatusAnterior, StatusNovo)
                        SELECT d.Id, d.Status, i.Status
                        FROM deleted d
                        INNER JOIN inserted i ON d.Id = i.Id
                        WHERE d.Status <> i.Status;
                    END
                END
                """);

            // ---- stored procedure ----
            migrationBuilder.Sql("""
                CREATE OR ALTER PROCEDURE sp_RegistrarNovaEntrega
                    @ClienteId INT,
                    @MotoristaId INT,
                    @VeiculoId INT,
                    @EnderecoOrigem VARCHAR(200),
                    @EnderecoDestino VARCHAR(200),
                    @NovoId INT OUTPUT
                AS
                BEGIN
                    SET NOCOUNT ON;

                    BEGIN TRANSACTION;

                    BEGIN TRY
                        IF NOT EXISTS (SELECT 1 FROM Clientes WHERE Id = @ClienteId)
                            RAISERROR('Cliente informado não existe na base.', 16, 1);

                        IF NOT EXISTS (SELECT 1 FROM Motoristas WHERE Id = @MotoristaId)
                            RAISERROR('Motorista informado não existe na base.', 16, 1);

                        IF NOT EXISTS (SELECT 1 FROM Veiculos WHERE Id = @VeiculoId)
                            RAISERROR('Veículo informado não existe na base.', 16, 1);

                        DECLARE @CodigoRastreio VARCHAR(30) = 'TRK-' + UPPER(SUBSTRING(CONVERT(VARCHAR(36), NEWID()), 1, 6));

                        INSERT INTO Entregas (CodigoRastreio, ClienteId, MotoristaId, VeiculoId, EnderecoOrigem, EnderecoDestino, Status, DataCriacao)
                        VALUES (@CodigoRastreio, @ClienteId, @MotoristaId, @VeiculoId, @EnderecoOrigem, @EnderecoDestino, 0, GETDATE());

                        SET @NovoId = SCOPE_IDENTITY();

                        COMMIT TRANSACTION;
                    END TRY
                    BEGIN CATCH
                        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
                        RAISERROR(@ErrorMessage, 16, 1);
                    END CATCH
                END
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP PROCEDURE IF EXISTS sp_RegistrarNovaEntrega");
            migrationBuilder.Sql("DROP TRIGGER IF EXISTS trg_AuditStatusEntrega");
            migrationBuilder.Sql("DROP VIEW IF EXISTS vw_DashboardOperacional");
            migrationBuilder.Sql("DROP VIEW IF EXISTS vw_RelatorioEntregasDetalhadas");
            // A tabela LogHistoricoEntregas é mantida de propósito (histórico de auditoria).

            migrationBuilder.UpdateData(table: "Usuarios", keyColumn: "Id", keyValue: 1, column: "Senha", value: "123");
            migrationBuilder.UpdateData(table: "Usuarios", keyColumn: "Id", keyValue: 2, column: "Senha", value: "123");
            migrationBuilder.UpdateData(table: "Usuarios", keyColumn: "Id", keyValue: 3, column: "Senha", value: "123");
        }
    }
}
