-- =====================================================================
-- Consultas SQL - E-commerce
-- =====================================================================
SET search_path TO ecommerce;

-- ---------------------------------------------------------------------
-- 1) SELECT simples: lista de produtos cadastrados
-- Pergunta: Quais produtos existem e quanto custam?
-- ---------------------------------------------------------------------
SELECT id_produto, nome, categoria, valor
FROM produto;

-- ---------------------------------------------------------------------
-- 2) WHERE: clientes pessoa física nascidos antes de 1990
-- Pergunta: Quais clientes PF nasceram antes de 1990?
-- ---------------------------------------------------------------------
SELECT c.nome, pf.cpf, pf.data_nascimento
FROM cliente c
JOIN cliente_pf pf ON pf.id_cliente = c.id_cliente
WHERE pf.data_nascimento < '1990-01-01';

-- ---------------------------------------------------------------------
-- 3) Atributo derivado + ORDER BY: valor total de cada pedido
-- Pergunta: Qual o valor total (itens + frete) de cada pedido?
-- ---------------------------------------------------------------------
SELECT p.id_pedido,
       c.nome AS cliente,
       SUM(i.quantidade * i.preco_unitario)          AS total_itens,
       p.frete,
       SUM(i.quantidade * i.preco_unitario) + p.frete AS total_pedido
FROM pedido p
JOIN cliente c     ON c.id_cliente = p.id_cliente
JOIN item_pedido i ON i.id_pedido  = p.id_pedido
GROUP BY p.id_pedido, c.nome, p.frete
ORDER BY total_pedido DESC;

-- ---------------------------------------------------------------------
-- 4) GROUP BY + ORDER BY: quantidade de pedidos por cliente
-- Pergunta: Quantos pedidos foram feitos por cada cliente?
-- (LEFT JOIN mantém clientes sem pedidos)
-- ---------------------------------------------------------------------
SELECT c.id_cliente,
       c.nome,
       c.tipo_cliente,
       COUNT(p.id_pedido) AS qtd_pedidos
FROM cliente c
LEFT JOIN pedido p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome, c.tipo_cliente
ORDER BY qtd_pedidos DESC, c.nome;

-- ---------------------------------------------------------------------
-- 5) HAVING: clientes com mais de um pedido confirmado
-- Pergunta: Quais clientes têm mais de um pedido confirmado e quanto gastaram?
-- ---------------------------------------------------------------------
SELECT c.nome,
       COUNT(DISTINCT p.id_pedido)               AS pedidos_confirmados,
       SUM(i.quantidade * i.preco_unitario)      AS total_gasto
FROM cliente c
JOIN pedido p      ON p.id_cliente = c.id_cliente
JOIN item_pedido i ON i.id_pedido  = p.id_pedido
WHERE p.status_pedido = 'CONFIRMADO'
GROUP BY c.nome
HAVING COUNT(DISTINCT p.id_pedido) > 1
ORDER BY total_gasto DESC;

-- ---------------------------------------------------------------------
-- 6) Junção + COALESCE: identificação PF/PJ em uma única visão
-- Pergunta: Qual o documento e o nome oficial de cada cliente, seja PF ou PJ?
-- ---------------------------------------------------------------------
SELECT c.id_cliente,
       c.tipo_cliente,
       COALESCE(pf.cpf, pj.cnpj)       AS documento,
       COALESCE(pj.razao_social, c.nome) AS nome_oficial
FROM cliente c
LEFT JOIN cliente_pf pf ON pf.id_cliente = c.id_cliente
LEFT JOIN cliente_pj pj ON pj.id_cliente = c.id_cliente
ORDER BY c.tipo_cliente, c.nome;

-- ---------------------------------------------------------------------
-- 7) Junção: algum vendedor também é fornecedor?
-- Pergunta: Existem vendedores que também são fornecedores (mesmo CNPJ)?
-- ---------------------------------------------------------------------
SELECT v.id_vendedor,
       v.razao_social AS vendedor,
       f.id_fornecedor,
       f.razao_social AS fornecedor,
       v.cnpj
FROM vendedor v
JOIN fornecedor f ON f.cnpj = v.cnpj;

-- ---------------------------------------------------------------------
-- 8) Junção: produtos, fornecedores e estoque
-- Pergunta: Qual a relação de produtos, fornecedores e estoque disponível?
-- ---------------------------------------------------------------------
SELECT p.nome                  AS produto,
       f.razao_social          AS fornecedor,
       e.localizacao           AS local_estoque,
       pe.quantidade           AS qtd_em_estoque
FROM produto p
JOIN produto_fornecedor pf ON pf.id_produto = p.id_produto
JOIN fornecedor f          ON f.id_fornecedor = pf.id_fornecedor
JOIN produto_estoque pe    ON pe.id_produto = p.id_produto
JOIN estoque e             ON e.id_estoque = pe.id_estoque
ORDER BY p.nome, e.localizacao;

-- ---------------------------------------------------------------------
-- 9) Junção: nomes dos fornecedores e nomes dos produtos
-- Pergunta: Quais produtos cada fornecedor fornece?
-- ---------------------------------------------------------------------
SELECT f.razao_social AS fornecedor,
       p.nome         AS produto
FROM fornecedor f
JOIN produto_fornecedor pf ON pf.id_fornecedor = f.id_fornecedor
JOIN produto p             ON p.id_produto = pf.id_produto
ORDER BY f.razao_social, p.nome;

-- ---------------------------------------------------------------------
-- 10) GROUP BY + HAVING: estoque total por produto
-- Pergunta: Quais produtos têm menos de 50 unidades somadas em todos os estoques?
-- ---------------------------------------------------------------------
SELECT p.nome,
       SUM(pe.quantidade) AS estoque_total
FROM produto p
JOIN produto_estoque pe ON pe.id_produto = p.id_produto
GROUP BY p.nome
HAVING SUM(pe.quantidade) < 50
ORDER BY estoque_total;

-- ---------------------------------------------------------------------
-- 11) Junção de pedido, entrega e pagamento
-- Pergunta: Qual o status e o código de rastreio de cada pedido, e a forma de pagamento usada?
-- ---------------------------------------------------------------------
SELECT p.id_pedido,
       c.nome            AS cliente,
       fp.tipo_pagamento,
       p.status_pedido,
       e.status_entrega,
       COALESCE(e.codigo_rastreio, 'Sem código ainda') AS codigo_rastreio
FROM pedido p
JOIN cliente c          ON c.id_cliente = p.id_cliente
JOIN forma_pagamento fp ON fp.id_forma_pagamento = p.id_forma_pagamento
LEFT JOIN entrega e     ON e.id_pedido = p.id_pedido
ORDER BY p.id_pedido;

-- ---------------------------------------------------------------------
-- 12) Atributo derivado: atraso na entrega
-- Pergunta: Quantos dias de transporte foram previstos para cada entrega já enviada?
-- ---------------------------------------------------------------------
SELECT e.id_pedido,
       e.status_entrega,
       e.data_envio,
       e.previsao_entrega,
       (e.previsao_entrega - e.data_envio) AS dias_previstos_transporte
FROM entrega e
WHERE e.data_envio IS NOT NULL
ORDER BY dias_previstos_transporte DESC;

-- ---------------------------------------------------------------------
-- 13) Clientes com mais de uma forma de pagamento (HAVING)
-- Pergunta: Quais clientes cadastraram mais de uma forma de pagamento?
-- ---------------------------------------------------------------------
SELECT c.nome,
       COUNT(fp.id_forma_pagamento)           AS qtd_formas,
       STRING_AGG(fp.tipo_pagamento, ', ')    AS formas
FROM cliente c
JOIN forma_pagamento fp ON fp.id_cliente = c.id_cliente
GROUP BY c.nome
HAVING COUNT(fp.id_forma_pagamento) > 1
ORDER BY qtd_formas DESC, c.nome;

-- ---------------------------------------------------------------------
-- 14) Faturamento por categoria e tipo de cliente
-- Pergunta: Quanto cada categoria de produto faturou em pedidos confirmados, por PF e PJ?
-- ---------------------------------------------------------------------
SELECT pr.categoria,
       c.tipo_cliente,
       SUM(i.quantidade * i.preco_unitario) AS faturamento
FROM item_pedido i
JOIN pedido p   ON p.id_pedido  = i.id_pedido
JOIN produto pr ON pr.id_produto = i.id_produto
JOIN cliente c  ON c.id_cliente  = p.id_cliente
WHERE p.status_pedido = 'CONFIRMADO'
GROUP BY pr.categoria, c.tipo_cliente
HAVING SUM(i.quantidade * i.preco_unitario) > 100
ORDER BY faturamento DESC;
