-- ============================================================================
<<<<<<< HEAD
-- script_banco.sql  (PIM IV - TMS)  —  DADOS DE EXEMPLO
--
-- A estrutura (tabelas, views, trigger de auditoria e stored procedure) agora é criada
-- pelas migrations:  dotnet ef database update ...
-- Este script só insere dados de exemplo e é reexecutável (não duplica nada).
--
-- Antes de executar: selecione o banco TransportadoraDb (lista no topo do SSMS).
--
-- Status da entrega (INT, igual ao enum StatusEntrega do C# e do app):
--   0 = Pendente | 1 = Em trânsito | 2 = Concluída | 3 = Ocorrência
-- ============================================================================

IF OBJECT_ID('dbo.Clientes') IS NULL OR OBJECT_ID('dbo.vw_DashboardOperacional') IS NULL
BEGIN
    RAISERROR('Banco sem estrutura: selecione o banco TransportadoraDb e rode "dotnet ef database update" antes deste script.', 16, 1);
    SET NOEXEC ON;  -- pula o restante do script
END
GO

=======
-- script_banco.sql  (PIM IV - TMS)
-- Rode DEPOIS de aplicar as migrations (Update-Database / dotnet ef database update).
-- Cria views, tabela de auditoria, trigger, stored procedure e dados de exemplo.
-- É reexecutável: pode rodar de novo sem duplicar nada.
--
-- Status da entrega (INT, mesmo valor do enum StatusEntrega do C# e do app):
--   0 = Pendente | 1 = Em trânsito | 2 = Concluída | 3 = Ocorrência
-- ============================================================================
USE [TransportadoraDb];   -- no Azure SQL Database remova esta linha (USE não é suportado lá)
GO

-- ============================================================================
-- 1. VIEWS
-- ============================================================================
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
INNER JOIN Veiculos v ON e.VeiculoId = v.Id;
GO

CREATE OR ALTER VIEW vw_DashboardOperacional AS
SELECT
    COUNT(e.Id) AS TotalEntregas,
    ISNULL(SUM(CASE WHEN e.Status = 0 THEN 1 ELSE 0 END), 0) AS QtdPendentes,
    ISNULL(SUM(CASE WHEN e.Status = 1 THEN 1 ELSE 0 END), 0) AS QtdEmTransito,
    ISNULL(SUM(CASE WHEN e.Status = 2 THEN 1 ELSE 0 END), 0) AS QtdConcluidas,
    ISNULL(SUM(CASE WHEN e.Status = 3 THEN 1 ELSE 0 END), 0) AS QtdOcorrencias
FROM Entregas e;
GO

-- ============================================================================
-- 2. AUDITORIA: TABELA + TRIGGER DE ALTERAÇÃO DE STATUS
-- ============================================================================
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
GO

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
GO

-- ============================================================================
-- 3. STORED PROCEDURE COM TRANSAÇÃO E ROLLBACK
-- ============================================================================
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
GO

-- ============================================================================
-- 4. DADOS DE EXEMPLO (só entram se a tabela estiver vazia)
-- ============================================================================
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
BEGIN TRANSACTION;
BEGIN TRY

    IF NOT EXISTS (SELECT 1 FROM Clientes)
    BEGIN
        INSERT INTO Clientes (RazaoSocial, Cnpj, Telefone, Email, DataCriacao) VALUES
        ('Logística & Cia Ltda',       '12.345.678/0001-90', '(11) 3000-1000',  'contato@logisticacia.com',      GETDATE()),
        ('Distribuidora Express S.A.', '98.765.432/0001-10', '(11) 3000-2000',  'sac@distribuidoraexpress.com',  GETDATE()),
        ('Comércio de Bebidas Sul',    '45.678.912/0001-33', '(11) 3000-3000',  'compras@bebidassul.com.br',     GETDATE());
    END

    IF NOT EXISTS (SELECT 1 FROM Motoristas)
    BEGIN
        INSERT INTO Motoristas (Nome, Cpf, Cnh, CategoriaCnh, Telefone, DataCriacao) VALUES
        ('Carlos Eduardo Silva', '123.456.789-00', '12345678900', 'D', '(11) 99999-0001', GETDATE()),
        ('Roberto Oliveira',     '987.654.321-00', '98765432100', 'E', '(11) 99999-0002', GETDATE()),
        ('Fernanda Souza',       '456.789.123-00', '45678912300', 'D', '(11) 99999-0003', GETDATE());
    END

    IF NOT EXISTS (SELECT 1 FROM Veiculos)
    BEGIN
        INSERT INTO Veiculos (Placa, Modelo, CapacidadeKg, Tipo, DataCriacao) VALUES
        ('ABC-1A23', 'Mercedes-Benz Accelo 1016', 6000.00,  'VUC',     GETDATE()),
        ('XYZ-9B87', 'Volvo VM 330',              14000.00, 'Truck',   GETDATE()),
        ('KLL-4C56', 'Scania R450',               30000.00, 'Carreta', GETDATE());
    END

    IF NOT EXISTS (SELECT 1 FROM Entregas)
    BEGIN
        DECLARE @CId INT = (SELECT TOP 1 Id FROM Clientes ORDER BY Id ASC);
        DECLARE @MId INT = (SELECT TOP 1 Id FROM Motoristas ORDER BY Id ASC);
        DECLARE @VId INT = (SELECT TOP 1 Id FROM Veiculos ORDER BY Id ASC);

        INSERT INTO Entregas (CodigoRastreio, ClienteId, MotoristaId, VeiculoId, EnderecoOrigem, EnderecoDestino, Status, DataCriacao) VALUES
        ('TRK-A1B2C3', @CId, @MId, @VId, 'Av. das Nações Unidas, 1000 - SP',       'Rua Augusta, 500 - SP',        0, GETDATE()),
        ('TRK-D4E5F6', @CId, @MId, @VId, 'Rod. dos Bandeirantes, Km 45 - Jundiaí',  'Av. Paulista, 1500 - SP',      1, GETDATE()),
        ('TRK-G7H8I9', @CId, @MId, @VId, 'Rua Galvão Bueno, 200 - SP',              'Av. Faria Lima, 3000 - SP',    2, GETDATE());
    END

    -- Vincula o usuário motorista de teste (mot@pim.com) ao primeiro motorista cadastrado.
    -- Sem esse vínculo, GET /api/entregas/minhas devolve lista vazia.
    UPDATE Usuarios
       SET MotoristaId = (SELECT TOP 1 Id FROM Motoristas ORDER BY Id ASC)
     WHERE Email = 'mot@pim.com' AND MotoristaId IS NULL;

    COMMIT TRANSACTION;
<<<<<<< HEAD
    PRINT 'Dados de exemplo inseridos com sucesso.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERRO ao inserir dados de exemplo: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

SET NOEXEC OFF;
GO
=======
    PRINT 'Estrutura e massa de dados inicial criadas com sucesso.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERRO ao popular a base: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
