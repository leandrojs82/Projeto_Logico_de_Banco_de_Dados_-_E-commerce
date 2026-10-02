# Projeto Lógico de Banco de Dados — E-commerce

Projeto lógico (PostgreSQL) de um cenário de e-commerce, construído a partir do modelo conceitual/EER com os refinamentos propostos no desafio da DIO.

## Refinamentos aplicados

| Refinamento | Como foi implementado |
|---|---|
| **Cliente PJ e PF** — conta é PF *ou* PJ, nunca as duas | Especialização do EER mapeada em 3 tabelas: `cliente` (supertipo, com `tipo_cliente`), `cliente_pf` e `cliente_pj`. As tabelas filhas usam **FK composta** `(id_cliente, tipo_cliente)` com `CHECK` fixando o tipo (`'PF'`/`'PJ'`), então o mesmo cliente não consegue existir nas duas |
| **Pagamento** — mais de uma forma por cliente | Tabela `forma_pagamento` (1 cliente : N formas). O `pedido` referencia a forma via **FK composta** `(id_forma_pagamento, id_cliente)`, garantindo que o pedido só use uma forma de pagamento do próprio cliente |
| **Entrega** — status e código de rastreio | Tabela `entrega` (1 pedido : 1 entrega) com `status_entrega`, `codigo_rastreio` (único), datas de envio e previsão |

## Mapeamento EER → modelo relacional

- **Especialização (PF/PJ):** supertipo + uma tabela por subtipo, compartilhando a PK do supertipo.
- **Relacionamentos N:N:** tabelas associativas com PK composta — `produto_fornecedor`, `produto_vendedor` (vendedor terceiro), `produto_estoque` (com quantidade) e `item_pedido` (com quantidade e preço unitário no momento da compra).
- **Relacionamentos 1:N:** FK no lado "N" (`pedido.id_cliente`, `forma_pagamento.id_cliente`).
- **Relacionamento 1:1:** `entrega.id_pedido` com `UNIQUE`.

## Entidades

`cliente`, `cliente_pf`, `cliente_pj`, `forma_pagamento`, `pedido`, `item_pedido`, `entrega`, `produto`, `fornecedor`, `vendedor`, `estoque`, `produto_fornecedor`, `produto_vendedor`, `produto_estoque`.

## Constraints principais

- `PRIMARY KEY` em todas as tabelas (compostas nas associativas).
- `FOREIGN KEY` com `ON DELETE CASCADE` onde o filho não faz sentido sem o pai (PF/PJ, formas de pagamento, itens, entrega).
- `UNIQUE`: e-mail, CPF, CNPJ, código de rastreio.
- `CHECK`: tipo de cliente, tipo de pagamento, categoria, status do pedido, status da entrega, valores e quantidades positivas.

## Estrutura do repositório

```
01_schema.sql              -- criação do schema e das tabelas
02_dados.sql               -- carga de dados para testes
03_consultas.sql           -- 14 consultas com perguntas de negócio
04_testes_constraints.sql  -- comandos que DEVEM falhar (validam as regras)
```

## Como executar

```bash
createdb ecommerce_db
psql -d ecommerce_db -f 01_schema.sql
psql -d ecommerce_db -f 02_dados.sql
psql -d ecommerce_db -f 03_consultas.sql
psql -d ecommerce_db -f 04_testes_constraints.sql   # esperado: 5 mensagens de ERROR
```

Testado no PostgreSQL 16.

## Consultas e perguntas respondidas

| # | Pergunta | Cláusulas |
|---|---|---|
| 1 | Quais produtos existem e quanto custam? | SELECT |
| 2 | Quais clientes PF nasceram antes de 1990? | WHERE, JOIN |
| 3 | Qual o valor total (itens + frete) de cada pedido? | atributo derivado, GROUP BY, ORDER BY |
| 4 | **Quantos pedidos cada cliente fez?** | LEFT JOIN, GROUP BY, ORDER BY |
| 5 | Quais clientes têm mais de um pedido confirmado e quanto gastaram? | WHERE, GROUP BY, HAVING |
| 6 | Qual o documento e o nome oficial de cada cliente, PF ou PJ? | LEFT JOIN, COALESCE |
| 7 | **Algum vendedor também é fornecedor?** | JOIN por CNPJ |
| 8 | **Relação de produtos, fornecedores e estoques** | JOIN de 4 tabelas |
| 9 | **Relação de nomes dos fornecedores e nomes dos produtos** | JOIN, ORDER BY |
| 10 | Quais produtos têm menos de 50 unidades em estoque no total? | GROUP BY, HAVING |
| 11 | Status, rastreio e forma de pagamento de cada pedido | JOIN, LEFT JOIN, COALESCE |
| 12 | Quantos dias de transporte foram previstos por entrega? | atributo derivado (aritmética de datas) |
| 13 | Quais clientes têm mais de uma forma de pagamento? | GROUP BY, HAVING, STRING_AGG |
| 14 | Faturamento por categoria e tipo de cliente (pedidos confirmados) | JOIN de 4 tabelas, HAVING, ORDER BY |

## Resultado de destaque nos dados de teste

A consulta 7 mostra que **Tech Solutions Informática LTDA** e **Moda Atacado SA** atuam ao mesmo tempo como vendedor e fornecedor (mesmo CNPJ nas duas tabelas).
