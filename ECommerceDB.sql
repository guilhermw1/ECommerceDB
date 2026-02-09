DROP DATABASE IF EXISTS ECommerceDB;
CREATE DATABASE ECommerceDB;
USE ECommerceDB;
CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo_cliente ENUM('PF', 'PJ') NOT NULL,
    cpf_cnpj VARCHAR(20),
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    CONSTRAINT chk_cliente_tipo CHECK (
        (tipo_cliente = 'PF' AND cpf_cnpj IS NOT NULL) OR
        (tipo_cliente = 'PJ' AND cpf_cnpj IS NOT NULL)
    )
);
CREATE TABLE Vendedor (
    id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE Fornecedor (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);
CREATE TABLE Produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    id_fornecedor INT,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id_fornecedor)
);
CREATE TABLE Pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_vendedor INT,
    data_pedido DATE NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES Vendedor(id_vendedor)
);
CREATE TABLE ItemPedido (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);
CREATE TABLE Pagamento (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    tipo_pagamento ENUM('Cartao', 'Boleto', 'Pix') NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido)
);
CREATE TABLE Entrega (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    status ENUM('Preparando', 'Enviado', 'Entregue', 'Cancelado') NOT NULL,
    codigo_rastreio VARCHAR(50),
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido)
);
-- Clientes
INSERT INTO Cliente (nome, tipo_cliente, cpf_cnpj, email, telefone) VALUES
('João Silva', 'PF', '123.456.789-00', 'joao@email.com', '11999999999'),
('Empresa XYZ', 'PJ', '12.345.678/0001-99', 'contato@xyz.com', '1133333333');

-- Vendedores
INSERT INTO Vendedor (nome, email) VALUES
('Carlos Souza', 'carlos@email.com'),
('Maria Lima', 'maria@email.com');

-- Fornecedores
INSERT INTO Fornecedor (nome, email) VALUES
('Fornecedor A', 'fornA@email.com'),
('Fornecedor B', 'fornB@email.com');

-- Produtos
INSERT INTO Produto (nome_produto, preco, estoque, id_fornecedor) VALUES
('Produto 1', 50.00, 100, 1),
('Produto 2', 120.00, 50, 2);

-- Pedidos
INSERT INTO Pedido (id_cliente, id_vendedor, data_pedido) VALUES
(1, 1, '2026-02-08'),
(2, 2, '2026-02-07');

-- Itens do pedido
INSERT INTO ItemPedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 2, 50.00),
(1, 2, 1, 120.00),
(2, 2, 3, 120.00);

-- Pagamentos
INSERT INTO Pagamento (id_pedido, tipo_pagamento, valor) VALUES
(1, 'Cartao', 220.00),
(2, 'Pix', 360.00);

-- Entregas
INSERT INTO Entrega (id_pedido, status, codigo_rastreio) VALUES
(1, 'Enviado', 'R123456789BR'),
(2, 'Preparando', NULL);
SELECT c.nome, COUNT(p.id_pedido) AS total_pedidos
FROM Cliente c
LEFT JOIN Pedido p ON c.id_cliente = p.id_cliente
GROUP BY c.nome
ORDER BY total_pedidos DESC;
SELECT f.nome AS fornecedor, p.nome_produto, p.estoque
FROM Produto p
JOIN Fornecedor f ON p.id_fornecedor = f.id_fornecedor
ORDER BY f.nome, p.nome_produto;
SELECT p.id_pedido, c.nome AS cliente, SUM(i.quantidade * i.preco_unitario) AS valor_total
FROM Pedido p
JOIN Cliente c ON p.id_cliente = c.id_cliente
JOIN ItemPedido i ON p.id_pedido = i.id_pedido
GROUP BY p.id_pedido, c.nome
HAVING valor_total > 200
ORDER BY valor_total DESC;
SELECT status, COUNT(*) AS total
FROM Entrega
GROUP BY status;
