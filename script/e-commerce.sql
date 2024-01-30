-- COSMÉTICO EGÍPCIO QUE ATENDE O BRASIL TODO

DROP DATABASE IF EXISTS ecommerce_cosmetico_egipcio;
CREATE DATABASE ecommerce_cosmetico_egipcio;

USE ecommerce_cosmetico_egipcio;

-- LOGIN
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
    FULLTEXT (nome) -- Índice FULLTEXT (ìndice de texto completo): adicionado a coluna nome na tabela pessoas
);

-- Exemplo de consulta usando índice de texto completo
-- Ajustar a consulta com a palavra que deseja consultar na coluna nome
/*
SELECT *
FROM pessoas
WHERE MATCH (nome) AGAINST ('palavra-chave');
*/

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
    CNPJ CHAR(19) UNIQUE NOT NULL,
    id_pessoa INT,
    FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_CNPJ_fORNECEDOR (CNPJ)
);

-- CLIENTES
CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    CPF CHAR(14) UNIQUE NOT NULL,
    id_pessoa INT,
    FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_CPF_cliente (CPF)
);

-- FUNCIONÁRIOS
CREATE TABLE funcionarios (
    id_funcionario INT PRIMARY KEY AUTO_INCREMENT,
    CPF CHAR(14) UNIQUE NOT NULL,
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
    INDEX idx_nome_categoria (nome) -- Índice Único: garante que esse valor seja exclusivo, onde não deve ter duplicatas.
);

-- PRODUTOS
CREATE TABLE produtos (
    id_produto INT PRIMARY KEY AUTO_INCREMENT, -- Constraint Primary Key: cada valor único e não nulo.
    nome VARCHAR(255) UNIQUE NOT NULL, -- Constraint Unique: a coluna nome é definida como única.
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL CHECK (preco >= 0), -- Constraint Check: garante que o preço seja sempre não negativo
    estoque INT NOT NULL,
    id_marca INT,
    id_categoria INT,
    CHECK (estoque >= 0), -- Constraint Check: assegura que o valor na coluna estoque seja sempre não negativo
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria) -- Constraint Foreign Key: chave estrangeira presente referenciando as tabelas categorias e marcas
    ON DELETE CASCADE ON UPDATE CASCADE, -- Constraint On Update Cascade: garante a integridade referencial
    FOREIGN KEY (id_marca) REFERENCES marcas(id_marca)
    ON DELETE CASCADE ON UPDATE CASCADE, -- Constraint On Delete Cascade: garante a integridade referencial
    INDEX idx_nome_produto (nome, id_categoria) -- Índice Composto: otimiza consulta de dados usando uma combinação específica dessas colunas.
);
/*
EXPLICAÇÃO:
Todas as tabelas foram criadas com CONSTRAINTS, mas a de Produtos foi usado como exemplo, pois é a mais completa.
*/

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

-- VENDAS (Tabela Particionada por Ano)
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
); -- PARTITION BY RANGE (EXTRACT(YEAR FROM data_venda)); -- Particionamento: indica que a tabela Vendas será particionada por ano, criando partições separadas por ano.

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

-- INSERINDO DADOS NAS TABELAS

-- LOGIN
INSERT INTO login (nome_usuario, email, senha_hash)
VALUES
('alice_in_wonderland', 'alice@email.com', SHA2('alice_password', 256)),
('bob_the_builder', 'bob@email.com', SHA2('bob_password', 256)),
('charlie_chaplin', 'charlie@email.com', SHA2('charlie_password', 256)),
('diana_the_explorer', 'diana@email.com', SHA2('diana_password', 256)),
('edgar_allan_poe', 'edgar@email.com', SHA2('edgar_password', 256)),
('frank_the_tank', 'frank@email.com', SHA2('frank_password', 256)),
('gina_the_ninja', 'gina@email.com', SHA2('gina_password', 256)),
('hank_the_hiker', 'hank@email.com', SHA2('hank_password', 256)),
('isabella_the_illusionist', 'isabella@email.com', SHA2('isabella_password', 256)),
('jackson_the_jazzman', 'jackson@email.com', SHA2('jackson_password', 256)),
('emma_the_explorer', 'emma@email.com', SHA2('emma_password', 256)),
('felix_the_fighter', 'felix@email.com', SHA2('felix_password', 256)),
('gabriela_the_gardener', 'gabriela@email.com', SHA2('gabriela_password', 256)),
('henry_the_hiker', 'henry@email.com', SHA2('henry_password', 256)),
('isabel_the_illusionist', 'isabel@email.com', SHA2('isabel_password', 256)),
('jack_the_joker', 'jack@email.com', SHA2('jack_password', 256)),
('kate_the_knight', 'kate@email.com', SHA2('kate_password', 256)),
('leo_the_librarian', 'leo@email.com', SHA2('leo_password', 256)),
('mia_the_mermaid', 'mia@email.com', SHA2('mia_password', 256)),
('nathan_the_navigator', 'nathan@email.com', SHA2('nathan_password', 256));

-- PESSOAS
INSERT INTO pessoas (nome, CEP, tipo_logradouro, logradouro, num, complemento, bairro, cidade, estado, id_login)
VALUES
('Ana Silva', '12345678', 'Rua', 'Rua da Flores', '123', 'Apto 1', 'Jardim Primavera', 'São Paulo', 'SP', 1),
('Bruno Oliveira', '23456789', 'Avenida', 'Avenida dos Sonhos', '456', 'Casa 2', 'Bairro Encantado', 'Rio de Janeiro', 'RJ', 2),
('Clara Santos', '34567890', 'Travessa', 'Travessa das Estrelas', '789', 'Cobertura', 'Bairro Celestial', 'Belo Horizonte', 'MG', 3),
('Daniel Pereira', '45678901', 'Alameda', 'Alameda das Palmeiras', '101', 'Sobrado 3', 'Bairro Tropical', 'Curitiba', 'PR', 4),
('Eva Costa', '56789012', 'Praça', 'Praça Central', '202', 'Loja 4', 'Centro Histórico', 'Porto Alegre', 'RS', 5),
('Felipe Lima', '67890123', 'Estrada', 'Estrada do Sol', '303', 'Apto 5', 'Bairro Solar', 'Salvador', 'BA', 6),
('Gabriela Oliveira', '78901234', 'Viela', 'Viela da Lua', '404', 'Casa 6', 'Bairro Lunar', 'Fortaleza', 'CE', 7),
('Henrique Almeida', '89012345', 'Largo', 'Largo das Maravilhas', '505', 'Apto 7', 'Bairro Encantador', 'Recife', 'PE', 8),
('Isabela Martins', '90123456', 'Acesso', 'Acesso dos Ventos', '606', 'Casa 8', 'Bairro Ventoso', 'Manaus', 'AM', 9),
('João Souza', '01234567', 'Calçada', 'Calçada do Rio', '707', 'Loja 9', 'Bairro Aquático', 'Belém', 'PA', 10),
('Laura Santos', '98765432', 'Passagem', 'Passagem da Serra', '808', 'Casa 10', 'Bairro Serrano', 'Florianópolis', 'SC', 11),
('Miguel Pereira', '87654321', 'Corredor', 'Corredor das Águias', '909', 'Sobrado 11', 'Bairro Águia', 'Goiânia', 'GO', 12),
('Natalia Costa', '76543210', 'Ladeira', 'Ladeira da Lua', '010', 'Apto 12', 'Bairro Lunar', 'São Luís', 'MA', 13),
('Otávio Lima', '65432109', 'Galeria', 'Galeria das Estrelas', '111', 'Cobertura 13', 'Bairro Celestial', 'Campo Grande', 'MS', 14),
('Patrícia Oliveira', '54321098', 'Passarela', 'Passarela do Sol', '212', 'Apto 14', 'Bairro Solar', 'Teresina', 'PI', 15),
('Rafael Souza', '43210987', 'Beco', 'Beco das Maravilhas', '313', 'Casa 15', 'Bairro Encantador', 'Vitória', 'ES', 16),
('Sofia Almeida', '32109876', 'Trilha', 'Trilha dos Ventos', '414', 'Apto 16', 'Bairro Ventoso', 'Palmas', 'TO', 17),
('Thiago Martins', '21098765', 'Caminho', 'Caminho do Rio', '515', 'Casa 17', 'Bairro Aquático', 'Porto Velho', 'RO', 18),
('Valentina Lima', '10987654', 'Passadiço', 'Passadiço da Serra', '616', 'Loja 18', 'Bairro Serrano', 'Aracaju', 'SE', 19),
('William Souza', '09876543', 'Alameda', 'Alameda das Águias', '717', 'Apto 19', 'Bairro Águia', 'Macapá', 'AP', 20);

-- TELEFONES DAS PESSOAS
INSERT INTO telefones_pessoas (tipo_contato, numero, id_pessoa)
VALUES
('Celular', '+55 (011) 1234-5678', 3),
('Telefone Fixo', '+55 (011) 8765-4321', 4),
('Celular', '+55 (021) 2345-6789', 5),
('Telefone Fixo', '+55 (021) 5432-1098', 6),
('Celular', '+55 (031) 3456-7890', 7),
('Telefone Fixo', '+55 (031) 2109-8765', 8),
('Celular', '+55 (041) 4567-8901', 9),
('Telefone Fixo', '+55 (041) 9876-5432', 10),
('Celular', '+55 (051) 5678-9012', 11),
('Telefone Fixo', '+55 (051) 7654-3210', 12),
('Celular', '+55 (061) 6789-0123', 13),
('Telefone Fixo', '+55 (061) 4321-0987', 14),
('Celular', '+55 (071) 7890-1234', 15),
('Telefone Fixo', '+55 (071) 3210-9876', 16),
('Celular', '+55 (081) 8901-2345', 17),
('Telefone Fixo', '+55 (081) 6543-2109', 18),
('Celular', '+55 (091) 9012-3456', 19),
('Telefone Fixo', '+55 (091) 1098-7654', 20);

-- FORNECEDORES
INSERT INTO fornecedores (CNPJ, id_pessoa)
VALUES
('24.928.191/0001-30', 1),
('23.456.789/0123-45', 2),
('34.567.890/1234-56', 3),
('45.678.901/2345-67', 4),
('56.789.012/3456-78', 5),
('67.890.123/4567-89', 6),
('78.901.234/5678-90', 7),
('89.012.345/6789-01', 8);

-- CLIENTES
INSERT INTO clientes (CPF, id_pessoa)
VALUES
('012.345.678-90', 9),
('123.456.789-01', 11),
('345.678.901-23', 12),
('456.789.012-34', 13),
('567.890.123-45', 14),
('678.901.234-56', 15),
('789.012.345-67', 16);

-- FUNCIONÁRIOS
INSERT INTO funcionarios (CPF, cargo, salario, id_pessoa)
VALUES
('234.567.890-12', 'Gerente', 5000.00, 17),
('345.678.901-23', 'Vendedor', 3500.00, 18),
('456.789.012-34', 'Atendente', 2500.00, 19),
('567.890.123-45', 'Analista de Marketing', 4000.00, 20);

-- MARCAS
INSERT INTO marcas (nome)
VALUES
('Cleópatra Cosméticos'),
('Egito Elegante'),
('Faraó Fashion'),
('Anúbis Beleza'),
('Osiris Luxo'),
('Nefertiti Estilo'),
('Sphinx Charme'),
('Rá Radiante'),
('Horus Glamour'),
('Isis Inspiração');

-- CATEGORIAS
INSERT INTO categorias (nome)
VALUES
('Cuidados com a Pele'),
('Maquiagem Egípcia'),
('Fragrâncias do Nilo'),
('Cabelos do Deserto'),
('Olhos de Cleópatra'),
('Banhos de Luxo'),
('Sacerdotisas da Beleza'),
('Essências do Egito'),
('Segredos da Esfinge'),
('Encantos do Vale do Nilo');

-- PRODUTOS
INSERT INTO produtos (nome, descricao, preco, estoque, id_marca, id_categoria)
VALUES
('Sérum da Cleópatra', 'Fórmula exclusiva para revitalização da pele inspirada nos antigos rituais egípcios.', 120.00, 50, 3, 1),
('Sombra do Deserto', 'Paleta de sombras com tonalidades inspiradas nas cores do deserto egípcio.', 65.00, 80, 1, 2),
('Loção Nefertiti', 'Hidratante com fragrância única que remete aos perfumes das rainhas egípcias.', 80.00, 30, 2, 3),
('Óleo de Ísis', 'Óleo capilar enriquecido com ingredientes exóticos para fortalecimento e brilho dos cabelos.', 45.00, 100, 4, 4),
('Delineador do Nilo', 'Delineador líquido de longa duração para realçar o olhar, inspirado na beleza do rio Nilo.', 35.00, 120, 3, 5),
('Sabonete Luxuoso de Cleópatra', 'Sabonete artesanal com ingredientes naturais para um banho luxuoso e revigorante.', 25.00, 200, 4, 6),
('Poção da Deusa Hathor', 'Essência mística para atrair a beleza e a proteção da deusa Hathor.', 150.00, 20, 5, 7),
('Máscara da Esfinge', 'Máscara facial purificante inspirada nos segredos da Esfinge.', 40.00, 80, 2, 1),
('Bálsamo de Ícaro', 'Bálsamo labial com ingredientes especiais para lábios irresistíveis.', 20.00, 150, 1, 4),
('Elixir do Vale do Oásis', 'Fragrância única que evoca os encantos do Vale do Oásis.', 90.00, 40, 3, 5),
('Sais de Banho de Nefertari', 'Sais de banho aromáticos para um momento relaxante e revigorante.', 30.00, 100, 5, 6),
('Loção Corporal de Ra', 'Loção corporal com essência solar inspirada no deus Ra.', 55.00, 60, 4, 2),
('Pó Iluminador de Anúbis', 'Iluminador em pó para destacar os pontos altos do rosto, com inspiração no deus Anúbis.', 75.00, 30, 1, 3),
('Água de Luxor', 'Água facial revitalizante inspirada nas águas do rio Luxor.', 28.00, 180, 2, 4),
('Creme de Isis', 'Creme facial noturno com propriedades regeneradoras, inspirado na deusa Isis.', 100.00, 25, 3, 5),
('Batom Encantado de Bastet', 'Batom de longa duração com cores intensas, inspirado na deusa Bastet.', 45.00, 70, 4, 1),
('Esmalte de Hathor', 'Esmalte com cores vibrantes inspiradas na deusa Hathor.', 18.00, 120, 5, 2),
('Perfume do Faraó', 'Fragrância exclusiva para homens inspirada na elegância dos faraós.', 80.00, 50, 2, 3),
('Máscara Capilar de Ísis', 'Máscara capilar nutritiva inspirada na deusa Ísis para cabelos deslumbrantes.', 60.00, 60, 1, 5),
('Sérum Noturno do Deserto', 'Sérum facial noturno para regeneração da pele, com ingredientes do deserto.', 110.00, 35, 3, 1);

-- PEDIDOS NO FORNECEDOR
INSERT INTO pedidos_fornecedor (data_pedido, status_pedido, id_fornecedor, id_funcionario)
VALUES
('2024-01-14', 'Entregue', 1, 3),
('2024-01-15', 'Em processamento', 2, 2),
('2024-01-16', 'Enviado', 3, 3),
('2024-01-17', 'Em processamento', 4, 2),
('2024-01-18', 'Entregue', 5, 3),
('2024-01-19', 'Enviado', 6, 2),
('2024-01-20', 'Entregue', 7, 3),
('2024-01-21', 'Em processamento', 8, 2),
('2024-01-22', 'Enviado', 1, 3),
('2024-01-23', 'Entregue', 2, 2),
('2024-01-24', 'Em processamento', 3, 3),
('2024-01-25', 'Enviado', 4, 2),
('2024-01-26', 'Entregue', 5, 3),
('2024-01-27', 'Em processamento', 6, 2),
('2024-01-28', 'Enviado', 7, 3),
('2024-01-29', 'Entregue', 8, 2),
('2024-01-30', 'Em processamento', 1, 3),
('2024-01-31', 'Entregue', 2, 2),
('2024-02-01', 'Enviado', 3, 3),
('2024-02-02', 'Entregue', 4, 2);

-- ITENS DO PEDIDO
INSERT INTO itens_pedido (quantidade, preco_unitario, total, id_pedido, id_produto)
VALUES
(5, 20.00, 100.00, 1, 1),
(2, 15.00, 30.00, 2, 2),
(3, 25.00, 75.00, 3, 3),
(4, 18.00, 72.00, 4, 4),
(2, 40.00, 80.00, 5, 5),
(7, 12.00, 84.00, 6, 6),
(3, 30.00, 90.00, 7, 7),
(6, 22.00, 132.00, 8, 8),
(8, 28.00, 224.00, 9, 9),
(10, 10.00, 100.00, 10, 10),
(2, 35.00, 70.00, 11, 11),
(3, 18.00, 54.00, 12, 12),
(4, 24.00, 96.00, 13, 13),
(5, 32.00, 160.00, 14, 14),
(6, 16.00, 96.00, 15, 15),
(2, 45.00, 90.00, 16, 16),
(4, 28.00, 112.00, 17, 17),
(3, 22.00, 66.00, 18, 18),
(5, 20.00, 100.00, 19, 19),
(6, 15.00, 90.00, 20, 20);

-- VENDAS
INSERT INTO vendas (data_venda, status_venda, id_cliente, id_funcionario)
VALUES
('2024-01-14', 'Enviado', 1, 2),
('2024-01-15', 'Em processamento', 2, 3),
('2024-01-16', 'Entregue', 3, 2),
('2024-01-17', 'Enviado', 4, 3),
('2024-01-18', 'Em processamento', 5, 2),
('2024-01-19', 'Entregue', 6, 3),
('2024-01-20', 'Enviado', 7, 2),
('2024-01-21', 'Em processamento', 1, 3),
('2024-01-22', 'Entregue', 2, 2),
('2024-01-23', 'Enviado', 3, 3);

-- ITENS DA VENDA
INSERT INTO itens_venda (quantidade, preco_unitario, total, id_venda, id_produto)
VALUES
(2, 50.00, 100.00, 1, 1),
(3, 30.00, 90.00, 2, 2),
(4, 25.00, 100.00, 3, 3),
(1, 40.00, 40.00, 4, 4),
(5, 20.00, 100.00, 5, 5),
(2, 15.00, 30.00, 6, 6),
(3, 35.00, 105.00, 7, 7),
(2, 28.00, 56.00, 8, 8),
(1, 60.00, 60.00, 9, 9),
(4, 45.00, 180.00, 10, 10);

-- MOSTRAR TODAS AS TABELAS

SHOW tables;

-- CONSULTAR OS DADOS DAS TABELAS

-- LOGIN
SELECT * FROM login;
-- PESSOAS
SELECT * FROM pessoas;
-- TELEFONES DAS PESSOAS
SELECT * FROM telefones_pessoas;
-- FORNECEDORES
SELECT * FROM fornecedores;
-- CLIENTES
SELECT * FROM clientes;
-- FUNCIONÁRIOS
SELECT * FROM funcionarios;
-- MARCAS
SELECT * FROM marcas;
-- CATEGORIAS
SELECT * FROM categorias;
-- PRODUTOS
SELECT * FROM produtos;
-- PEDIDOS NO FORNECEDOR
SELECT * FROM pedidos_fornecedor;
-- ITENS DO PEDIDO
SELECT * FROM itens_pedido;
-- VENDAS
SELECT * FROM vendas;
-- ITENS DA VENDA
SELECT * FROM itens_venda;

-- UPDATE

-- Atualizar o e-mail do usuário com o nome de usuário 'alice_in_wonderland':
UPDATE login
SET email = 'novo_alice@email.com'
WHERE nome_usuario = 'alice_in_wonderland';

-- Atualizar o número de telefone da pessoa com o nome 'Ana Silva':
UPDATE telefones_pessoas
SET numero = '+55 (011) 9876-5432'
WHERE id_pessoa = 1;

-- Atualizar o preço do produto com o nome 'Sérum da Cleópatra':
UPDATE produtos
SET preco = 130.00
WHERE nome = 'Sérum da Cleópatra';

-- DELETE

-- Excluir o usuário com o nome de usuário 'frank_the_tank':
DELETE FROM login
WHERE nome_usuario = 'frank_the_tank';

-- Excluir a pessoa com o nome 'Bruno Oliveira' e todos os registros de telefone relacionados:
DELETE FROM telefones_pessoas
WHERE id_pessoa = (SELECT id_pessoa FROM pessoas WHERE nome = 'Bruno Oliveira');
DELETE FROM pessoas
WHERE nome = 'Bruno Oliveira';

-- Excluir a categoria com o nome 'Maquiagem Egípcia' e todos os registros de produtos relacionados:
DELETE FROM produtos
WHERE id_categoria = (SELECT id_categoria FROM categorias WHERE nome = 'Maquiagem Egípcia');
DELETE FROM categorias
WHERE nome = 'Maquiagem Egípcia';

-- CONSULTAS

-- Listar todas as pessoas e seus telefones:
SELECT pessoas.nome, telefones_pessoas.tipo_contato, telefones_pessoas.numero
FROM pessoas
JOIN telefones_pessoas ON pessoas.id_pessoa = telefones_pessoas.id_pessoa;

-- Listar todos os fornecedores com seus dados:
SELECT fornecedores.id_fornecedor, fornecedores.CNPJ, pessoas.nome
FROM fornecedores
JOIN pessoas ON fornecedores.id_pessoa = pessoas.id_pessoa;

-- Listar todos os clientes com seus dados:
SELECT clientes.id_cliente, clientes.CPF, pessoas.nome
FROM clientes
JOIN pessoas ON clientes.id_pessoa = pessoas.id_pessoa;

-- Listar todos os funcionários com seus dados:
SELECT funcionarios.id_funcionario, funcionarios.CPF, funcionarios.cargo, funcionarios.salario, pessoas.nome
FROM funcionarios
JOIN pessoas ON funcionarios.id_pessoa = pessoas.id_pessoa;

-- Listar todos os produtos com suas categorias e marcas:
SELECT produtos.nome, produtos.descricao, produtos.preco, produtos.estoque, categorias.nome AS categoria, marcas.nome AS marca
FROM produtos
JOIN categorias ON produtos.id_categoria = categorias.id_categoria
JOIN marcas ON produtos.id_marca = marcas.id_marca;

-- Listar todos os pedidos no fornecedor com status "Entregue":
SELECT * FROM pedidos_fornecedor WHERE status_pedido = 'Entregue';

-- Listar todos os itens de pedidos com seus produtos associados:
SELECT itens_pedido.id_item_pedido, itens_pedido.quantidade, itens_pedido.preco_unitario, itens_pedido.total, produtos.nome AS produto
FROM itens_pedido
JOIN produtos ON itens_pedido.id_produto = produtos.id_produto;

-- Listar todas as vendas com status "Em processamento":
SELECT * FROM vendas WHERE status_venda = 'Em processamento';

-- Listar todos os itens de vendas com seus produtos associados:
SELECT itens_venda.id_item_venda, itens_venda.quantidade, itens_venda.preco_unitario, itens_venda.total, produtos.nome AS produto
FROM itens_venda
JOIN produtos ON itens_venda.id_produto = produtos.id_produto;

-- Mostre as marcas de produtos em ordem alfabética.
SELECT nome FROM marcas ORDER BY nome;

-- Quais são os produtos que têm um preço superior a 100 reais?
SELECT nome, preco FROM produtos WHERE preco > 100.00 ORDER BY preco DESC;

-- Quem são os clientes e seus estados?
SELECT clientes.id_cliente, clientes.CPF, pessoas.nome, pessoas.estado
FROM clientes
JOIN pessoas ON clientes.id_pessoa = pessoas.id_pessoa;

-- Quais são os pedidos no fornecedor que estão "Em processamento"?
SELECT * FROM pedidos_fornecedor WHERE status_pedido = 'Em processamento';

-- Liste todas as vendas com os nomes dos clientes.
SELECT vendas.id_venda, vendas.data_venda, clientes.id_cliente, pessoas.nome AS cliente
FROM vendas
JOIN clientes ON vendas.id_cliente = clientes.id_cliente
JOIN pessoas ON clientes.id_pessoa = pessoas.id_pessoa;

-- Mostre todos os itens de venda com detalhes de produto.
SELECT itens_venda.id_item_venda, itens_venda.quantidade, itens_venda.preco_unitario, itens_venda.total, produtos.nome AS produto
FROM itens_venda
JOIN produtos ON itens_venda.id_produto = produtos.id_produto;

-- Quais são os funcionários que têm salário superior a 3000 reais?
SELECT funcionarios.id_funcionario, funcionarios.CPF, funcionarios.salario, pessoas.nome
FROM funcionarios
JOIN pessoas ON funcionarios.id_pessoa = pessoas.id_pessoa
WHERE funcionarios.salario > 3000.00;

-- Qual é a média de estoque dos produtos por categoria?
SELECT categorias.nome AS categoria, ROUND(AVG(produtos.estoque), 0) AS media_estoque
FROM produtos
JOIN categorias ON produtos.id_categoria = categorias.id_categoria
GROUP BY categorias.nome;

-- Quais são os clientes que fizeram compras com valor total acima de 200 reais?
SELECT clientes.id_cliente, clientes.CPF, pessoas.nome AS cliente, SUM(itens_venda.total) AS total_compras
FROM clientes
JOIN vendas ON clientes.id_cliente = vendas.id_cliente
JOIN itens_venda ON vendas.id_venda = itens_venda.id_venda
JOIN pessoas ON clientes.id_pessoa = pessoas.id_pessoa
GROUP BY clientes.id_cliente
HAVING total_compras > 200.00;

-- Quantos produtos diferentes cada fornecedor fornece?
SELECT fornecedores.id_fornecedor, COUNT(DISTINCT produtos.id_produto) AS qtd_produtos
FROM fornecedores
JOIN pedidos_fornecedor ON fornecedores.id_fornecedor = pedidos_fornecedor.id_fornecedor
JOIN itens_pedido ON pedidos_fornecedor.id_pedido = itens_pedido.id_pedido
JOIN produtos ON itens_pedido.id_produto = produtos.id_produto
GROUP BY fornecedores.id_fornecedor;

-- Quais são os cinco produtos mais caros?
SELECT nome, preco FROM produtos ORDER BY preco DESC LIMIT 5;

-- Listar os clientes 5 e 6.
SELECT * FROM clientes LIMIT 2 OFFSET 4;

-- Quais são os últimos três pedidos realizados?
SELECT * FROM vendas ORDER BY data_venda DESC LIMIT 3;

-- Qual é o total de vendas realizadas até agora?
SELECT SUM(total) AS total_vendas FROM itens_venda;

-- Quantos produtos têm um estoque abaixo de 50 unidades?
SELECT COUNT(*) AS qtd_produtos_baixo_estoque FROM produtos WHERE estoque < 50;

-- Quanto é o salário total pago aos funcionários?
SELECT SUM(salario) AS salario_total FROM funcionarios;

-- Listar todos os produtos com um preço inferior a R$ 30,00:
SELECT *
FROM produtos
WHERE preco < 30.00;

-- Mostrar todos os representantes que estão localizados fora do estado de São Paulo (estado 'SP'):
SELECT CNPJ, nome, bairro, cidade, estado
FROM fornecedores
INNER JOIN pessoas
ON pessoas.id_pessoa = fornecedores.id_pessoa
WHERE estado <> 'SP';

-- Listar todos os produtos disponíveis para Cuidados com a Pele, ordenados pelo preço em ordem crescente:
SELECT produtos.nome, descricao, preco, estoque, categorias.nome
FROM produtos
INNER JOIN categorias
ON produtos.id_categoria = categorias.id_categoria
WHERE categorias.nome = 'Cuidados com a Pele'
ORDER BY preco;

-- Listar todas as vendas feitas em janeiro de 2024:
SELECT *
FROM vendas
WHERE EXTRACT(YEAR FROM data_venda) = 2024 AND EXTRACT(MONTH FROM data_venda) = 1;

-- Listar todos os fornecedores e seus telefones, mostrando apenas aqueles que têm pelo menos um telefone cadastrado:
SELECT *
FROM fornecedores
JOIN pessoas
ON fornecedores.id_pessoa = pessoas.id_pessoa
JOIN telefones_pessoas
ON telefones_pessoas.id_pessoa = pessoas.id_pessoa
WHERE numero IS NOT NULL;

-- Mostrar o produto mais caro:
SELECT *
FROM produtos
ORDER BY preco DESC
LIMIT 1;

-- Mostrar o segundo produto mais caro:
SELECT *
FROM produtos
ORDER BY preco DESC
LIMIT 1 OFFSET 1;

-- Mostre as marcas de produtos em ordem alfabética.
SELECT nome FROM marcas ORDER BY nome;

-- Quais são os produtos que têm um preço superior a 100 reais?
SELECT nome, preco FROM produtos WHERE preco > 100.00 ORDER BY preco DESC;

-- Quem são os clientes e seus estados?
SELECT clientes.id_cliente, clientes.CPF, pessoas.nome, pessoas.estado
FROM clientes
JOIN pessoas ON clientes.id_pessoa = pessoas.id_pessoa;

-- Quais são os pedidos no fornecedor que estão "Em processamento"?
SELECT * FROM pedidos_fornecedor WHERE status_pedido = 'Em processamento';

-- Liste todas as vendas com os nomes dos clientes.
SELECT vendas.id_venda, vendas.data_venda, clientes.id_cliente, pessoas.nome AS cliente
FROM vendas
JOIN clientes ON vendas.id_cliente = clientes.id_cliente
JOIN pessoas ON clientes.id_pessoa = pessoas.id_pessoa;

-- Mostre todos os itens de venda com detalhes de produto.
SELECT itens_venda.id_item_venda, itens_venda.quantidade, itens_venda.preco_unitario, itens_venda.total, produtos.nome AS produto
FROM itens_venda
JOIN produtos ON itens_venda.id_produto = produtos.id_produto;

-- Quais são os funcionários que têm salário superior a 3000 reais?
SELECT funcionarios.id_funcionario, funcionarios.CPF, funcionarios.salario, pessoas.nome
FROM funcionarios
JOIN pessoas ON funcionarios.id_pessoa = pessoas.id_pessoa
WHERE funcionarios.salario > 3000.00;

-- Qual é a média de estoque dos produtos por categoria?
SELECT categorias.nome AS categoria, ROUND(AVG(produtos.estoque), 0) AS media_estoque
FROM produtos
JOIN categorias ON produtos.id_categoria = categorias.id_categoria
GROUP BY categorias.nome;

-- Quais são os clientes que fizeram compras com valor total acima de 200 reais?
SELECT clientes.id_cliente, clientes.CPF, pessoas.nome AS cliente, SUM(itens_venda.total) AS total_compras
FROM clientes
JOIN vendas ON clientes.id_cliente = vendas.id_cliente
JOIN itens_venda ON vendas.id_venda = itens_venda.id_venda
JOIN pessoas ON clientes.id_pessoa = pessoas.id_pessoa
GROUP BY clientes.id_cliente
HAVING total_compras > 200.00;

-- Quantos produtos diferentes cada fornecedor fornece?
SELECT fornecedores.id_fornecedor, COUNT(DISTINCT produtos.id_produto) AS qtd_produtos
FROM fornecedores
JOIN pedidos_fornecedor ON fornecedores.id_fornecedor = pedidos_fornecedor.id_fornecedor
JOIN itens_pedido ON pedidos_fornecedor.id_pedido = itens_pedido.id_pedido
JOIN produtos ON itens_pedido.id_produto = produtos.id_produto
GROUP BY fornecedores.id_fornecedor;

-- Quais são os cinco produtos mais caros?
SELECT nome, preco FROM produtos ORDER BY preco DESC LIMIT 5;

-- Listar os clientes 5 e 6.
SELECT * FROM clientes LIMIT 2 OFFSET 4;

-- Quais são os últimos três pedidos realizados?
SELECT * FROM vendas ORDER BY data_venda DESC LIMIT 3;

-- Qual é o total de vendas realizadas até agora?
SELECT SUM(total) AS total_vendas FROM itens_venda;

-- Quantos produtos têm um estoque abaixo de 50 unidades?
SELECT COUNT(*) AS qtd_produtos_baixo_estoque FROM produtos WHERE estoque < 50;

-- Quanto é o salário total pago aos funcionários?
SELECT SUM(salario) AS salario_total FROM funcionarios;

-- Listar todos os produtos com um preço inferior a R$ 30,00:
SELECT *
FROM produtos
WHERE preco < 30.00;

-- Mostrar todos os representantes que estão localizados fora do estado de São Paulo (estado 'SP'):
SELECT CNPJ, nome, bairro, cidade, estado
FROM fornecedores
INNER JOIN pessoas
ON pessoas.id_pessoa = fornecedores.id_pessoa
WHERE estado <> 'SP';

-- Listar todos os produtos disponíveis para Cuidados com a Pele, ordenados pelo preço em ordem crescente:
SELECT produtos.nome, descricao, preco, estoque, categorias.nome
FROM produtos
INNER JOIN categorias
ON produtos.id_categoria = categorias.id_categoria
WHERE categorias.nome = 'Cuidados com a Pele'
ORDER BY preco;

-- Listar todas as vendas feitas em janeiro de 2024:
SELECT *
FROM vendas
WHERE EXTRACT(YEAR FROM data_venda) = 2024 AND EXTRACT(MONTH FROM data_venda) = 1;

-- Listar todos os fornecedores e seus telefones, mostrando apenas aqueles que têm pelo menos um telefone cadastrado:
SELECT *
FROM fornecedores
JOIN pessoas
ON fornecedores.id_pessoa = pessoas.id_pessoa
JOIN telefones_pessoas
ON telefones_pessoas.id_pessoa = pessoas.id_pessoa
WHERE numero IS NOT NULL;

-- Mostrar o produto mais caro:
SELECT *
FROM produtos
ORDER BY preco DESC
LIMIT 1;

-- Mostrar o segundo produto mais caro:
SELECT *
FROM produtos
ORDER BY preco DESC
LIMIT 1 OFFSET 1;

-- TOP (assumindo que seja usado no contexto do SQL Server)
-- Selecionar os top 5 produtos mais caros:
SELECT *
FROM produtos
ORDER BY preco DESC
LIMIT 5;

-- Exemplo com GROUP BY e AVG
-- Calcular o preço médio de cada produto na coluna 'preco_medio':
SELECT produto, AVG(preco) AS preco_medio
FROM produtos
GROUP BY produto;

-- Exemplo com GROUP BY e MAX
-- Encontrar o preço máximo de cada marca na coluna 'preco_maximo':
SELECT marca, MAX(preco) AS preco_maximo
FROM produtos
GROUP BY marca;

-- Exemplo com GROUP BY e MIN
-- Encontrar o estoque minimo de produtos para cada categoria:
SELECT categoria, MIN(estoque) AS estoque_minimo
FROM produtos
GROUP BY categoria;

-- Exemplo com GROUP BY e STDEV
-- Calcular o desvio padrão dos preços dos produtos para cada marca:
SELECT marca, STDEV(preco) AS desvio_padrao_precos
FROM produtos
GROUP BY marca;

-- A função FIRST não existe nativamente no MYSQL
-- Exemplo com GROUP BY e FIRST
-- Encontrar o primeiro valor da coluna 'estoque' para cada grupo de 'marca':
/*
SELECT marca, FIRST(estoque) AS primeiro_estoque
FROM produtos
GROUP BY marca;
*/
-- Para corrigir a falta dessa função, pode ser feito dessa maneira:
-- Exemplo com GROUP BY e MIN para obter o primeiro estoque
SELECT marca, MIN(estoque) AS primeiro_estoque
FROM produtos
GROUP BY marca;

-- A função MEDIAN não existe navitamente no MYSQL
-- Exemplo com GROUP BY e MEDIAN
-- Calcular a mediana para cada grupo de categoria:
/*
SELECT categoria, MEDIAN(preco) AS preco_mediano
FROM produtos
GROUP BY categoria;
*/
-- Para corrigir a falta dessa função, pode ser feito dessa maneira:
-- Exemplo de cálculo da mediana usando subconsulta
SELECT
  categoria,
  AVG(preco) AS preco_mediano
FROM (
  SELECT
    categoria,
    preco,
    ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY preco) AS row_num,
    COUNT(*) OVER (PARTITION BY categoria) AS total_rows
  FROM produtos
) AS ranked
WHERE row_num = CEIL(total_rows / 2.0) OR row_num = FLOOR(total_rows / 2.0) + 1
GROUP BY categoria;
/* 
EXPLICAÇÃO:
Foi usado uma subconsulta para atribuir número de linha ('row_num') a cada linha dentro de cada grupo de categoria,
ordenando as linhas pelo preço. Em seguida, usou a função AVG para calcular a média dos preços onde row_num é igual
a metade do número total de linhas ou a metade arredondada para cima, que é a mediana. Isso é feito para cada grupo de categoria. 
*/

-- A função MODE não existe nativamente no MYSQL
-- Exemplo com GROUP BY e MODE
-- Calcular a cor que aparece com mais frequência nos produtos:
/*
SELECT cor, MODE() WITHIN GROUP (ORDER BY quantidade) AS cor_mais_frequente
FROM produtos
GROUP BY cor;
*/
-- Para corrigir a falta dessa função, pode ser feito dessa maneira:
-- Exemplo de cálculo da moda usando subconsulta
SELECT
  cor,
  cor_mais_frequente
FROM (
  SELECT
    cor,
    quantidade,
    ROW_NUMBER() OVER (PARTITION BY cor ORDER BY quantidade DESC) AS row_num
  FROM produtos
) AS ranked
WHERE row_num = 1;
/* 
EXPLICAÇÃO:
A moda (MODE) é o valor que ocorre com mais frequência em um conjunto de dados.
Foi usado uma subconsulta para atribuir números de linha ('row_num') a cada linha dentro de cada grupo de cor,
ordenando as linhas pela quantidade em ordem decrescente. Em seguida, selecionamos apenas as linhas onde row_num é igual a 1,
identificando assim a cor mais frequente (moda) em cada grupo de cor.
*/

-- Exemplo com GROUP BY e CORR
-- Calcular a correlação entre os valores das colunas 'preco' e 'estoque' para cada grupo de categoria na tabela de produtos:
SELECT categoria, CORR(preco, estoque) AS correlacao_preco_estoque
FROM produtos
GROUP BY categoria;
/* 
EXPLICAÇÃO:
A correlação varia de -1 a 1, onde:
1 indica uma correlação positiva perfeita
-1 indica uma correlação negativa perfeita
0 indica ausência de correlação linear
*/

-- Consulta com LEFT JOIN
-- Retorna o nome dos clientes e as datas de suas vendas(se existirem):
SELECT clientes.nome, vendas.data_venda
FROM clientes
LEFT JOIN vendas ON clientes.id_cliente = vendas.id_cliente;
/* 
EXPLICAÇÃO:
Garante que todos os clientes estejam presentes na saída, mesmo que não tenham feito nenhuma compra. 
Se um cliente não tiver vendas associadas, a coluna data_venda será nula.
*/

-- Consulta com RIGHT JOIN
-- Retorna os IDs das vendas e os IDs dos produtos associados (se existirem):
SELECT vendas.id_venda, itens_venda.id_produto
FROM vendas
RIGHT JOIN itens_venda ON vendas.id_venda = itens_venda.id_venda;
/* 
EXPLICAÇÃO:
Garante que todas as linhas de itens_venda estejam presentes na saída, mesmo que não tenham uma venda correspondente. 
Se um item não estiver associado a uma venda, a coluna id_venda será nula.
*/

-- Consulta com FULL JOIN
-- Retorna os nomes dos funcionários e os IDs dos pedidos de fornecedores associados (se existirem):
SELECT funcionarios.nome, pedidos_fornecedor.id_pedido
FROM funcionarios
FULL JOIN pedidos_fornecedor ON funcionarios.id_funcionario = pedidos_fornecedor.id_funcionario;
/* 
EXPLICAÇÃO:
Garante que todas as linhas de funcionarios e pedidos_fornecedor estejam presentes na saída. 
Se um funcionário não estiver associado a um pedido ou vice-versa, as colunas relacionadas serão nulas.
*/

-- Consultas com subconsultas
-- Identificar e listar os nomes das pessoas que possuem pelo menos um número de telefone do tipo 'celular' na tabela telefone das pessoas:
SELECT nome
FROM pessoas
WHERE id_pessoa IN (SELECT id_pessoa FROM telefones_pessoas WHERE tipo_contato = 'Celular');

-- UNION - Seleção de Nomes de Clientes e Fornecedores
-- Realiza uma união dos nomes de clientes e fornecedores, removendo duplicatas:
SELECT nome FROM clientes
UNION
SELECT nome FROM fornecedores;
/* 
EXPLICAÇÃO:
Se a tabela clientes tem os nomes "Ana" e "Carlos" e a tabela fornecedores tem os nomes "Carlos" e "David", o resultado seria "Ana", "Carlos", "David".
*/

-- ALTER TABLE - Adição de Coluna "Peso" na Tabela "Produtos"
-- Adiciona uma nova coluna chamada "peso" à tabela "produtos" com o tipo de dados DECIMAL(5,2):
ALTER TABLE produtos
ADD COLUMN peso DECIMAL(5,2);
/*
EXPLICAÇÃO:
Adiciona uma coluna que armazena valores decimais com até 5 dígitos no total, sendo 2 deles após o ponto decimal.
A tabela "produtos" agora terá uma nova coluna chamada "peso".
*/

-- CREATE VIEW - Criação de uma Visão chamada "produtos_vendidos"
-- Cria uma visão chamada "produtos_vendidos" que contém os nomes dos produtos e suas quantidades vendidas, unindo as tabelas "itens_venda" e "produtos":
CREATE VIEW produtos_vendidos AS
SELECT produtos.nome, itens_venda.quantidade
FROM itens_venda
JOIN produtos ON itens_venda.id_produto = produtos.id_produto;
/*
EXPLICAÇÃO:
Facilita consultas que envolvem a quantidade de produtos vendidos sem a necessidade de escrever a junção toda vez.
Agora pode consultar a visão "produtos_vendidos" para obter informações sobre produtos vendidos.
*/

-- Otimização de Consulta: EXPLAIN
-- EXPLAIN é usado para analisar o plano de execução de uma consulta:
EXPLAIN SELECT * FROM vendas WHERE id_cliente = 1;
/*
EXPLICAÇÃO:
Este comando EXPLAIN está sendo usado para analisar a consulta que seleciona todas as colunas da tabela vendas onde o id_cliente é igual a 1.
As informações fornecidas podem incluir detalhes sobre quais índices são usados, 
se há alguma varredura de tabela, e a ordem de execução dos diferentes estágios da consulta.
*/
