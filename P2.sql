DROP DATABASE IF EXISTS TechMarica;
CREATE DATABASE TechMarica;
USE TechMarica;

-- Tabela Funcionarios
CREATE TABLE Funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    area_atuacao VARCHAR(50) NOT NULL,
    ativo TINYINT(1) DEFAULT 1
);

-- Tabela Maquinas
CREATE TABLE Maquinas (
    id_maquina INT AUTO_INCREMENT PRIMARY KEY,
    nome_maquina VARCHAR(100) NOT NULL,
    tipo VARCHAR(50)
);

-- Tabela Produtos
CREATE TABLE Produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    codigo_interno VARCHAR(20) UNIQUE NOT NULL,
    nome_comercial VARCHAR(100) NOT NULL,
    responsavel_tecnico VARCHAR(100) NOT NULL,
    custo_estimado DECIMAL(10, 2) NOT NULL,
    data_criacao DATE DEFAULT (CURRENT_DATE)
);

-- Tabela OrdensProducao
CREATE TABLE OrdensProducao (
    id_ordem INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    id_funcionario INT NOT NULL,
    id_maquina INT NOT NULL,
    data_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_conclusao DATETIME NULL,
    status VARCHAR(20) DEFAULT 'AGUARDANDO',
    FOREIGN KEY (id_produto) REFERENCES Produtos(id_produto),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionarios(id_funcionario),
    FOREIGN KEY (id_maquina) REFERENCES Maquinas(id_maquina)
);

-- Inserção de Funcionários
INSERT INTO Funcionarios (nome, area_atuacao, ativo) VALUES 
('Carlos Silva', 'Montagem', 1),
('Ana Beatriz', 'Qualidade', 1),
('Roberto Dias', 'Engenharia', 0),
('Fernanda Lima', 'Supervisão', 1),
('Lucas Mendes', 'Logística', 1);

-- Inserção de Máquinas
INSERT INTO Maquinas (nome_maquina, tipo) VALUES 
('Soldadora Wave 3000', 'Soldagem'),
('Montadora SMT-X', 'Montagem Superficial'),
('Bancada de Teste Final', 'Qualidade');

-- Inserção de Produtos
INSERT INTO Produtos (codigo_interno, nome_comercial, responsavel_tecnico, custo_estimado, data_criacao) VALUES 
('SENSOR-01', 'Sensor de Proximidade', 'Eng. Roberto', 45.50, '2020-01-15'),
('MOD-WIFI', 'Módulo Wi-Fi IoT', 'Eng. Roberto', 120.00, '2021-05-20'),
('PCB-MAIN', 'Placa Principal V2', 'Eng. Amanda', 250.00, '2019-11-10'),
('BAT-LITH', 'Bateria Lítio', 'Eng. Amanda', 80.00, '2023-02-01'),
('DISP-OLED', 'Display OLED 1.3', 'Eng. Roberto', 60.00, '2022-08-15');

-- Inserção de Ordens de Produção
INSERT INTO OrdensProducao (id_produto, id_funcionario, id_maquina, data_inicio, status) VALUES 
(1, 1, 1, '2023-10-01 08:00:00', 'FINALIZADA'),
(2, 4, 2, NOW(), 'EM PRODUÇÃO'),
(3, 1, 1, NOW(), 'EM PRODUÇÃO'),
(4, 2, 3, '2023-10-05 10:30:00', 'PAUSADA');

-- View de Relatório
CREATE OR REPLACE VIEW vw_RelatorioProducao AS
SELECT 
    OP.id_ordem,
    P.nome_comercial,
    P.custo_estimado,
    F.nome AS autorizador,
    OP.status
FROM OrdensProducao OP
JOIN Produtos P ON OP.id_produto = P.id_produto
JOIN Funcionarios F ON OP.id_funcionario = F.id_funcionario;

-- Procedure para Nova Ordem
DELIMITER $$
CREATE PROCEDURE sp_NovaOrdemProducao(IN p_id_prod INT, IN p_id_func INT, IN p_id_maq INT)
BEGIN
    INSERT INTO OrdensProducao (id_produto, id_funcionario, id_maquina, data_inicio, status)
    VALUES (p_id_prod, p_id_func, p_id_maq, NOW(), 'EM PRODUÇÃO');
    SELECT 'Ordem registrada com sucesso!' AS Mensagem;
END $$
DELIMITER ;

-- Trigger para Atualização de Status
DELIMITER $$
CREATE TRIGGER trg_FinalizaOrdem
BEFORE UPDATE ON OrdensProducao
FOR EACH ROW
BEGIN
    IF NEW.data_conclusao IS NOT NULL AND OLD.data_conclusao IS NULL THEN
        SET NEW.status = 'FINALIZADA';
    END IF;
END $$
DELIMITER ;

-- Consultas solicitadas
SELECT OP.id_ordem, P.nome_comercial, M.nome_maquina, F.nome, OP.data_inicio, OP.status
FROM OrdensProducao OP
INNER JOIN Produtos P ON OP.id_produto = P.id_produto
INNER JOIN Maquinas M ON OP.id_maquina = M.id_maquina
INNER JOIN Funcionarios F ON OP.id_funcionario = F.id_funcionario;

SELECT * FROM Funcionarios WHERE ativo = 0;

SELECT responsavel_tecnico, COUNT(*) AS qtd_produtos FROM Produtos GROUP BY responsavel_tecnico;

SELECT * FROM Produtos WHERE nome_comercial LIKE 'S%';

SELECT nome_comercial, TIMESTAMPDIFF(YEAR, data_criacao, CURDATE()) AS idade_anos FROM Produtos;

-- Uso dos objetos criados
SELECT * FROM vw_RelatorioProducao;

CALL sp_NovaOrdemProducao(5, 4, 3);

UPDATE OrdensProducao SET data_conclusao = NOW() WHERE id_ordem = 2;

SELECT * FROM OrdensProducao WHERE id_ordem = 2;