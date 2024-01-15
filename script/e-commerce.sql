-- COSMETICO QUE ATENDE O BRASIL TODO

CREATE DATABASE ecommerce_cosmetico_egipcio;

USE ecommerce_cosmetico_egipcio;

CREATE TABLE login (
  id_login INT PRIMARY KEY AUTO_INCREMENT,
  nome_usuario VARCHAR(100) UNIQUE NOT NULL,
  email TEXT NOT NULL,
  senha_hash VARCHAR(255) NOT NULL
);

-- PESSOAS
CREATE TABLE pessoas (
	id_pessoa INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    CEP VARCHAR(11),
    tipo_logradouro VARCHAR(50),
    logradouro VARCHAR(255),
    num VARCHAR(10),
    complemento VARCHAR(255),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado CHAR(2),
    id_login INT,
	FOREIGN KEY (id_login) REFERENCES login(id_login)
    ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_nome_pessoa (nome)
);

-- TELEFONES DAS PESSOAS
CREATE TABLE telefones_pessoas (
    id_telefone_pessoa INT PRIMARY KEY AUTO_INCREMENT,
    tipo_contato VARCHAR(50) NOT NULL,
    numero VARCHAR(20),
    id_pessoa INT,
	FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- FORNECEDORES
CREATE TABLE fornecedores (
    id_fornecedor INT PRIMARY KEY AUTO_INCREMENT,
    CNPJ CHAR(15) UNIQUE NOT NULL,
    id_pessoa INT,
    FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_CNPJ_fORNECEDOR (CNPJ)
);

-- CLIENTES
CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    CPF CHAR(11) UNIQUE NOT NULL,
    id_pessoa INT,
    FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_CPF_cliente (CPF)
);

-- FUNCIONÁRIOS
CREATE TABLE funcionarios (
    id_funcionario INT PRIMARY KEY AUTO_INCREMENT,
    CPF CHAR(11) UNIQUE NOT NULL,
    cargo VARCHAR(100) NOT NULL,
    salario DECIMAL(10, 2) NOT NULL,
    id_pessoa INT,
    FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE,
	INDEX idx_CPF_funcionario (CPF)
);

-- MARCAS
CREATE TABLE marcas (
    id_marca INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) UNIQUE NOT NULL,
    INDEX idx_nome_marca (nome)
);

-- CATEGORIAS
CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) UNIQUE NOT NULL,
    INDEX idx_nome_categoria (nome)
);

-- PRODUTOS
CREATE TABLE produtos (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) UNIQUE NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    estoque INT NOT NULL,
    id_fornecedor INT,
    id_marca INT,
    id_categoria INT,
    CHECK (estoque >= 0),
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id_fornecedor)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_marca) REFERENCES marcas(id_marca)
    ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_nome_produto (nome)
);

-- VENDAS
CREATE TABLE vendas (
    id_venda INT PRIMARY KEY AUTO_INCREMENT,
    data_venda DATE NOT NULL,
    status_venda ENUM('Em processamento', 'Enviado', 'Entregue') NOT NULL,
    id_cliente INT,
    id_funcionario INT,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
    ON DELETE CASCADE ON UPDATE CASCADE,
	INDEX idx_cliente (id_cliente),
	INDEX idx_funcionario (id_funcionario)
);

-- ITENS DA VENDA
CREATE TABLE itens_venda (
    id_item_venda INT PRIMARY KEY AUTO_INCREMENT,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    id_venda INT,
    id_produto INT,
    CHECK (quantidade > 0),
    FOREIGN KEY (id_venda) REFERENCES vendas(id_venda)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
    ON DELETE CASCADE ON UPDATE CASCADE,
	INDEX idx_venda (id_venda),
	INDEX idx_produto_venda (id_produto)
);

-- PEDIDOS NO FORNECEDOR
CREATE TABLE pedidos_fornecedor (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    data_pedido DATE NOT NULL,
    status_pedido ENUM('Em processamento', 'Enviado', 'Entregue') NOT NULL,
    id_fornecedor INT,
    id_funcionario INT,
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id_fornecedor)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
    ON DELETE CASCADE ON UPDATE CASCADE,
	INDEX idx_fornecedor_pedido (id_fornecedor),
	INDEX idx_funcionario_pedido (id_funcionario)
);

-- ITENS DO PEDIDO
CREATE TABLE itens_pedido (
    id_item_pedido INT PRIMARY KEY AUTO_INCREMENT,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    id_pedido INT,
    id_produto INT,
	CHECK (quantidade > 0),
    FOREIGN KEY (id_pedido) REFERENCES pedidos_fornecedor(id_pedido)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
    ON DELETE CASCADE ON UPDATE CASCADE,
	INDEX idx_pedido (id_pedido),
	INDEX idx_produto_pedido (id_produto)
);