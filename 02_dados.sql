-- =====================================================================
-- Carga de dados para testes
-- =====================================================================
SET search_path TO ecommerce;

-- Clientes (4 PF + 3 PJ)
INSERT INTO cliente (nome, email, telefone, tipo_cliente, data_cadastro) VALUES
('Ana Souza',          'ana.souza@email.com',      '31991110001', 'PF', '2025-01-10'),
('Bruno Lima',         'bruno.lima@email.com',     '31991110002', 'PF', '2025-02-15'),
('Carla Mendes',       'carla.mendes@email.com',   '31991110003', 'PF', '2025-03-20'),
('Diego Rocha',        'diego.rocha@email.com',    '31991110004', 'PF', '2025-04-05'),
('Tech Solutions',     'contato@techsol.com.br',   '3133330001',  'PJ', '2025-01-25'),
('Mercado Bom Preço',  'compras@bompreco.com.br',  '3133330002',  'PJ', '2025-05-12'),
('Escritório Alfa',    'adm@escritorioalfa.com',   '3133330003',  'PJ', '2025-06-30');

INSERT INTO cliente_pf (id_cliente, cpf, data_nascimento) VALUES
(1, '11111111111', '1990-05-14'),
(2, '22222222222', '1985-11-02'),
(3, '33333333333', '1998-07-21'),
(4, '44444444444', '1979-01-30');

INSERT INTO cliente_pj (id_cliente, cnpj, razao_social) VALUES
(5, '10000000000191', 'Tech Solutions Informática LTDA'),
(6, '20000000000192', 'Mercado Bom Preço Comércio LTDA'),
(7, '30000000000193', 'Escritório Alfa Contabilidade S/S');

-- Formas de pagamento (clientes com mais de uma forma cadastrada)
INSERT INTO forma_pagamento (id_cliente, tipo_pagamento, descricao) VALUES
(1, 'CARTAO_CREDITO', 'Visa final 1111'),   -- 1
(1, 'PIX',            'Chave e-mail'),       -- 2
(2, 'BOLETO',         'Boleto bancário'),    -- 3
(3, 'CARTAO_DEBITO',  'Master final 3333'),  -- 4
(3, 'PIX',            'Chave celular'),      -- 5
(4, 'CARTAO_CREDITO', 'Elo final 4444'),     -- 6
(5, 'BOLETO',         'Boleto faturado'),    -- 7
(5, 'CARTAO_CREDITO', 'Corporativo 5555'),   -- 8
(6, 'PIX',            'Chave CNPJ'),         -- 9
(7, 'BOLETO',         'Boleto 30 dias');     -- 10

-- Produtos
INSERT INTO produto (nome, categoria, descricao, valor) VALUES
('Smartphone X10',      'ELETRONICO', 'Smartphone 128GB',          1899.90), -- 1
('Notebook Pro 14',     'ELETRONICO', 'Notebook 16GB RAM',         4599.00), -- 2
('Camiseta Básica',     'VESTUARIO',  'Camiseta algodão',            49.90), -- 3
('Jaqueta Jeans',       'VESTUARIO',  'Jaqueta unissex',            219.90), -- 4
('Quebra-cabeça 1000p', 'BRINQUEDO',  'Paisagem 1000 peças',         79.90), -- 5
('Cafeteira Elétrica',  'ELETRONICO', 'Cafeteira 30 xícaras',       189.90), -- 6
('Mesa de Escritório',  'MOVEIS',     'Mesa 1,20m',                 649.00), -- 7
('Livro SQL Essencial', 'LIVRO',      'Guia prático de SQL',         89.90), -- 8
('Chocolate Premium',   'ALIMENTO',   'Barra 70% cacau',             19.90); -- 9

-- Fornecedores
INSERT INTO fornecedor (razao_social, cnpj) VALUES
('Almeida e Filhos LTDA',  '40000000000101'), -- 1
('Eletro Distribuidora',   '40000000000102'), -- 2
('Moda Atacado SA',        '40000000000103'), -- 3
('Tech Solutions Informática LTDA', '10000000000191'); -- 4 (mesmo CNPJ de um vendedor)

-- Vendedores terceiros
INSERT INTO vendedor (razao_social, nome_fantasia, cnpj, localizacao) VALUES
('Tech Solutions Informática LTDA', 'Tech Solutions', '10000000000191', 'Belo Horizonte'), -- 1
('Casa & Estilo LTDA',              'Casa & Estilo',  '50000000000201', 'São Paulo'),       -- 2
('Moda Atacado SA',                 'Moda Atacado',   '40000000000103', 'Contagem');        -- 3

-- Estoques
INSERT INTO estoque (localizacao) VALUES
('Belo Horizonte'), ('São Paulo'), ('Rio de Janeiro');

-- Produto x Fornecedor
INSERT INTO produto_fornecedor (id_produto, id_fornecedor) VALUES
(1,2),(2,2),(2,4),(3,3),(4,3),(5,1),(6,2),(7,1),(8,1),(9,1);

-- Produto x Vendedor
INSERT INTO produto_vendedor (id_vendedor, id_produto, quantidade) VALUES
(1,1,30),(1,2,15),(2,6,40),(2,7,10),(3,3,200),(3,4,80);

-- Produto x Estoque
INSERT INTO produto_estoque (id_produto, id_estoque, quantidade) VALUES
(1,1,25),(1,2,10),(2,1,8),(3,2,150),(4,2,60),(5,3,45),
(6,1,30),(7,3,12),(8,1,100),(9,2,500);

-- Pedidos (id_forma_pagamento precisa pertencer ao cliente do pedido)
INSERT INTO pedido (id_cliente, id_forma_pagamento, status_pedido, descricao, frete, data_pedido) VALUES
(1, 1, 'CONFIRMADO',       'Compra de eletrônicos',   25.00, '2025-07-01'), -- 1
(1, 2, 'CONFIRMADO',       'Roupas',                  15.00, '2025-07-20'), -- 2
(2, 3, 'CANCELADO',        'Pedido cancelado',        10.00, '2025-07-22'), -- 3
(3, 4, 'CONFIRMADO',       'Presentes',               12.00, '2025-08-02'), -- 4
(3, 5, 'EM_PROCESSAMENTO', 'Livro e brinquedo',        0.00, '2025-08-15'), -- 5
(4, 6, 'CONFIRMADO',       'Cafeteira',               18.00, '2025-08-18'), -- 6
(5, 7, 'CONFIRMADO',       'Notebooks para equipe',   80.00, '2025-09-01'), -- 7
(5, 8, 'CONFIRMADO',       'Smartphones corporativos',60.00, '2025-09-10'), -- 8
(6, 9, 'EM_PROCESSAMENTO', 'Chocolates para revenda', 30.00, '2025-09-12'), -- 9
(7, 10,'CONFIRMADO',       'Mobiliário de escritório',90.00, '2025-09-20'); -- 10

-- Itens dos pedidos
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1,1,1,1899.90),(1,8,1,89.90),
(2,3,3,49.90),(2,4,1,219.90),
(3,5,2,79.90),
(4,5,1,79.90),(4,9,5,19.90),
(5,8,2,89.90),(5,5,1,79.90),
(6,6,1,189.90),
(7,2,5,4599.00),
(8,1,10,1799.90),
(9,9,200,15.90),
(10,7,4,649.00),(10,8,2,89.90);

-- Entregas (pedido cancelado e em processamento não têm entrega enviada)
INSERT INTO entrega (id_pedido, status_entrega, codigo_rastreio, data_envio, previsao_entrega) VALUES
(1,  'ENTREGUE',    'BR100000001XX', '2025-07-02', '2025-07-08'),
(2,  'ENTREGUE',    'BR100000002XX', '2025-07-21', '2025-07-26'),
(4,  'EM_TRANSITO', 'BR100000004XX', '2025-08-03', '2025-08-10'),
(5,  'PREPARANDO',  NULL,            NULL,         '2025-08-25'),
(6,  'ENVIADO',     'BR100000006XX', '2025-08-19', '2025-08-24'),
(7,  'ENTREGUE',    'BR100000007XX', '2025-09-02', '2025-09-09'),
(8,  'DEVOLVIDO',   'BR100000008XX', '2025-09-11', '2025-09-17'),
(9,  'PREPARANDO',  NULL,            NULL,         '2025-09-22'),
(10, 'EM_TRANSITO', 'BR100000010XX', '2025-09-21', '2025-09-28');
