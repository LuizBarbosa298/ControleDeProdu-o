DROP DATABASE IF EXISTS techmarica;
CREATE DATABASE techmarica;

CREATE TABLE Funcionarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    area VARCHAR(50) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    dt_contratacao DATE NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE Maquinas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL UNIQUE,
    tipo VARCHAR(50) NOT NULL
);

CREATE TABLE Produtos (
    codigo VARCHAR(10) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    resp_id INT NOT NULL,
    custo DECIMAL(10, 2) NOT NULL CHECK (custo > 0),
    dt_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (resp_id) REFERENCES Funcionarios(id)
);

CREATE TABLE Ordens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    prod_codigo VARCHAR(10) NOT NULL,
    dt_inicio DATE NOT NULL,
    dt_fim DATE,
    maq_id INT NOT NULL,
    autor_id INT NOT NULL,
    status ENUM('EM PRODUÇÃO', 'FINALIZADA', 'CANCELADA') NOT NULL DEFAULT 'EM PRODUÇÃO',
    
    FOREIGN KEY (prod_codigo) REFERENCES Produtos(codigo),
    FOREIGN KEY (maq_id) REFERENCES Maquinas(id),
    FOREIGN KEY (autor_id) REFERENCES Funcionarios(id),
    
    CHECK (dt_fim IS NULL OR dt_fim >= dt_inicio)
);


INSERT INTO Funcionarios (nome, area, ativo, dt_contratacao) VALUES
('Ana Silva', 'Engenharia', TRUE, '2020-08-10'),
('Bruno Santos', 'Produção', TRUE, '2022-01-20'),
('Carlos Oliveira', 'Manutenção', TRUE, '2023-05-15'),
('Diana Pereira', 'Qualidade', FALSE, '2021-11-01'),
('Eduardo Costa', 'Engenharia', TRUE, '2019-03-25'),
('Fernanda Lima', 'Supervisão', TRUE, '2024-02-14');

INSERT INTO Maquinas (nome, tipo) VALUES
('CNC-01', 'Montagem de Placas'),
('SMD-A', 'Inserção de Componentes'),
('Teste-Final', 'Inspeção Automatizada');

INSERT INTO Produtos (codigo, nome, resp_id, custo, dt_cadastro) VALUES
('SEN-001', 'Sensor Inteligente de Temperatura', 1, 45.50, '2022-01-15'),
('PLT-A02', 'Placa de Circuito Universal V2', 5, 120.00, '2023-03-20'),
('MOD-3K', 'Módulo de Comunicação WiFi', 1, 88.90, '2024-05-01'),
('SEN-005', 'Sensor de Proximidade Compacto', 5, 25.00, '2023-11-10'),
('KIT-DEV', 'Kit de Desenvolvimento IoT', 1, 350.00, '2024-01-25');

INSERT INTO Ordens (prod_codigo, dt_inicio, maq_id, autor_id) VALUES
('PLT-A02', '2024-10-01', 2, 2),
('SEN-001', '2024-10-03', 1, 6),
('MOD-3K', '2024-10-04', 3, 2),
('SEN-005', '2024-09-20', 1, 6);


SELECT
    OP.id AS 'ID Ordem',
    P.nome AS 'Produto',
    M.nome AS 'Máquina',
    F.nome AS 'Autorizador',
    OP.dt_inicio AS 'Início',
    OP.dt_fim AS 'Conclusão',
    OP.status AS 'Status'
FROM Ordens OP
INNER JOIN Produtos P ON OP.prod_codigo = P.codigo
INNER JOIN Maquinas M ON OP.maq_id = M.id
INNER JOIN Funcionarios F ON OP.autor_id = F.id
ORDER BY OP.id;

SELECT id, nome, area, dt_contratacao
FROM Funcionarios
WHERE ativo = FALSE;

SELECT
    F.nome AS 'Responsável Técnico',
    COUNT(P.codigo) AS 'Total de Produtos'
FROM Produtos P
INNER JOIN Funcionarios F ON P.resp_id = F.id
GROUP BY F.nome
ORDER BY 'Total de Produtos' DESC;

SELECT codigo, nome
FROM Produtos
WHERE nome LIKE 'S%';

SELECT
    nome AS 'Produto',
    dt_cadastro AS 'Data de Registro',
    TRUNCATE(DATEDIFF(CURRENT_DATE, dt_cadastro) / 365.25, 1) AS 'Idade (Anos)'
FROM Produtos
ORDER BY dt_cadastro DESC;


CREATE VIEW V_ProducaoConsolidada AS
SELECT
    OP.id AS 'ID_Ordem',
    P.nome AS 'Produto',
    M.nome AS 'Maquina',
    OP.dt_inicio AS 'Data_Inicio',
    OP.status AS 'Status',
    F_Auto.nome AS 'Autorizador',
    F_Resp.nome AS 'Resp_Tecnico',
    P.custo AS 'Custo_Estimado'
FROM Ordens OP
INNER JOIN Produtos P ON OP.prod_codigo = P.codigo
INNER JOIN Maquinas M ON OP.maq_id = M.id
INNER JOIN Funcionarios F_Auto ON OP.autor_id = F_Auto.id
INNER JOIN Funcionarios F_Resp ON P.resp_id = F_Resp.id
WHERE OP.status = 'EM PRODUÇÃO' OR OP.status = 'FINALIZADA'
ORDER BY OP.dt_inicio DESC;


DELIMITER //

CREATE PROCEDURE P_RegistrarNovaOrdem (
    IN p_prod_codigo VARCHAR(10),
    IN p_autor_id INT,
    IN p_maq_id INT
)
BEGIN
    INSERT INTO Ordens (prod_codigo, dt_inicio, maq_id, autor_id, status)
    VALUES (p_prod_codigo, CURRENT_DATE(), p_maq_id, p_autor_id, 'EM PRODUÇÃO');

    SELECT CONCAT('Nova Ordem (ID: ', LAST_INSERT_ID(), ') registrada.') AS Feedback_Sistema;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER T_AtualizarStatus
BEFORE UPDATE ON Ordens
FOR EACH ROW
BEGIN
    IF NEW.dt_fim IS NOT NULL AND OLD.dt_fim IS NULL THEN
        SET NEW.status = 'FINALIZADA';
    END IF;
END //

DELIMITER ;