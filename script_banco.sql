USE [TransportadoraDb];
GO

-- ============================================================================
-- 1. VISUALIZAÇÃO DIRETA NO BANCO DE DADOS (VIEWS)
-- ============================================================================

-- Identifica dinamicamente as colunas de nome em Clientes e Motoristas
DECLARE @ColClienteNome NVARCHAR(50) = ISNULL((SELECT TOP 1 name FROM sys.columns WHERE object_id = OBJECT_ID('Clientes') AND name IN ('RazaoSocial', 'Nome', 'NomeRazaoSocial', 'NomeFantasia')), 'Id');
DECLARE @ColMotoristaNome NVARCHAR(50) = ISNULL((SELECT TOP 1 name FROM sys.columns WHERE object_id = OBJECT_ID('Motoristas') AND name IN ('Nome', 'NomeCompleto')), 'Id');

-- Cria a View Consolidada de Entregas adaptada à sua estrutura
DECLARE @SqlViewDetalhada NVARCHAR(MAX) = N'
CREATE OR ALTER VIEW vw_RelatorioEntregasDetalhadas AS
SELECT 
    e.Id AS EntregaId,
    e.CodigoRastreio,
    c.' + QUOTENAME(@ColClienteNome) + N' AS ClienteNome,
    m.' + QUOTENAME(@ColMotoristaNome) + N' AS MotoristaNome,
    v.Placa AS VeiculoPlaca,
    v.Modelo AS VeiculoModelo,
    e.EnderecoOrigem,
    e.EnderecoDestino,
    CASE e.Status
        WHEN 0 THEN ''Pendente''
        WHEN 1 THEN ''Em Trânsito''
        WHEN 2 THEN ''Concluída''
        WHEN 3 THEN ''Ocorrência''
        ELSE ''Desconhecido''
    END AS StatusDescricao,
    e.DataCriacao
FROM Entregas e
INNER JOIN Clientes c ON e.ClienteId = c.Id
INNER JOIN Motoristas m ON e.MotoristaId = m.Id
INNER JOIN Veiculos v ON e.VeiculoId = v.Id;';

EXEC sp_executesql @SqlViewDetalhada;
GO

-- View de Resumo Operacional (Dashboard)
CREATE OR ALTER VIEW vw_DashboardOperacional AS
SELECT 
    COUNT(e.Id) AS TotalEntregas,
    SUM(CASE WHEN e.Status = 0 THEN 1 ELSE 0 END) AS QtdPendentes,
    SUM(CASE WHEN e.Status = 1 THEN 1 ELSE 0 END) AS QtdEmTransito,
    SUM(CASE WHEN e.Status = 2 THEN 1 ELSE 0 END) AS QtdConcluidas,
    SUM(CASE WHEN e.Status = 3 THEN 1 ELSE 0 END) AS QtdOcorrencias
FROM Entregas e;
GO

-- ============================================================================
-- 2. PROGRAMAÇÃO DE BD: AUDITORIA E TRIGGER DE ALTERAÇÃO DE STATUS
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
        SELECT 
            d.Id,
            d.Status,
            i.Status
        FROM deleted d
        INNER JOIN inserted i ON d.Id = i.Id
        WHERE d.Status <> i.Status;
    END
END
GO

-- ============================================================================
-- 3. STORED PROCEDURE COM TRANSAÇÃO E ROLLBACK DE SEGURANÇA
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
        PRINT 'Entrega inserida com sucesso via Stored Procedure.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================================
-- 4. ALIMENTAÇÃO DA BASE (SEEDING INTELIGENTE DE DADOS FICTÍCIOS)
-- ============================================================================

BEGIN TRANSACTION;
BEGIN TRY

    -- Popula Clientes se estiver vazio
    IF NOT EXISTS (SELECT 1 FROM Clientes)
    BEGIN
        DECLARE @ColC_Nome NVARCHAR(50) = ISNULL((SELECT TOP 1 name FROM sys.columns WHERE object_id = OBJECT_ID('Clientes') AND name IN ('RazaoSocial', 'Nome', 'NomeRazaoSocial')), 'Nome');
        DECLARE @ColC_Doc NVARCHAR(50) = ISNULL((SELECT TOP 1 name FROM sys.columns WHERE object_id = OBJECT_ID('Clientes') AND name IN ('CNPJ', 'Documento', 'CpfCnpj', 'CPF')), 'Documento');
        
        DECLARE @SqlSeedCliente NVARCHAR(MAX) = N'
        INSERT INTO Clientes (' + QUOTENAME(@ColC_Nome) + N', ' + QUOTENAME(@ColC_Doc) + N', Email, DataCriacao) VALUES
        (''Logística & Cia Ltda'', ''12.345.678/0001-90'', ''contato@logisticacia.com'', GETDATE()),
        (''Distribuidora Express S.A.'', ''98.765.432/0001-10'', ''sac@distribuidoraexpress.com'', GETDATE()),
        (''Comércio de Bebidas Sul'', ''45.678.912/0001-33'', ''compras@bebidassul.com.br'', GETDATE());';
        
        EXEC sp_executesql @SqlSeedCliente;
    END

    -- Popula Motoristas se estiver vazio
    IF NOT EXISTS (SELECT 1 FROM Motoristas)
    BEGIN
        DECLARE @ColM_Nome NVARCHAR(50) = ISNULL((SELECT TOP 1 name FROM sys.columns WHERE object_id = OBJECT_ID('Motoristas') AND name IN ('Nome', 'NomeCompleto')), 'Nome');
        
        DECLARE @SqlSeedMotorista NVARCHAR(MAX) = N'
        INSERT INTO Motoristas (' + QUOTENAME(@ColM_Nome) + N', CNH, CategoriaCNH, DataCriacao) VALUES
        (''Carlos Eduardo Silva'', ''12345678900'', ''D'', GETDATE()),
        (''Roberto Oliveira'', ''98765432100'', ''E'', GETDATE()),
        (''Fernanda Souza'', ''45678912300'', ''D'', GETDATE());';
        
        EXEC sp_executesql @SqlSeedMotorista;
    END

    -- Popula Veículos se estiver vazio
    IF NOT EXISTS (SELECT 1 FROM Veiculos)
    BEGIN
        INSERT INTO Veiculos (Placa, Modelo, CapacidadeKg, DataCriacao) VALUES
        ('ABC-1A23', 'Mercedes-Benz Accelo 1016', 6000.00, GETDATE()),
        ('XYZ-9B87', 'Volvo VM 330', 14000.00, GETDATE()),
        ('KLL-4C56', 'Scania R450', 30000.00, GETDATE());
    END

    -- Popula Entregas Iniciais se estiver vazio
    IF NOT EXISTS (SELECT 1 FROM Entregas)
    BEGIN
        DECLARE @CId INT = (SELECT TOP 1 Id FROM Clientes ORDER BY Id ASC);
        DECLARE @MId INT = (SELECT TOP 1 Id FROM Motoristas ORDER BY Id ASC);
        DECLARE @VId INT = (SELECT TOP 1 Id FROM Veiculos ORDER BY Id ASC);

        INSERT INTO Entregas (CodigoRastreio, ClienteId, MotoristaId, VeiculoId, EnderecoOrigem, EnderecoDestino, Status, DataCriacao) VALUES
        ('TRK-A1B2C3', @CId, @MId, @VId, 'Av. das Nações Unidas, 1000 - SP', 'Rua Augusta, 500 - SP', 0, GETDATE()),
        ('TRK-D4E5F6', @CId, @MId, @VId, 'Rod. dos Bandeirantes, Km 45 - Jundiaí', 'Av. Paulista, 1500 - SP', 1, GETDATE()),
        ('TRK-G7H8I9', @CId, @MId, @VId, 'Rua Galvão Bueno, 200 - SP', 'Av. Faria Lima, 3000 - SP', 2, GETDATE());
    END

    COMMIT TRANSACTION;
    PRINT 'Massa de dados inicial e estrutura criadas com sucesso.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Erro ao popular a base de dados.';
END CATCH
GO