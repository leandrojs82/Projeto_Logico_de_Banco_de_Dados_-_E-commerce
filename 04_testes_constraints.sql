-- Testes de integridade: cada comando abaixo DEVE falhar com ERROR
SET search_path TO ecommerce;
\echo '--- T1: cliente PF tentando entrar também em PJ (deve falhar)'
INSERT INTO cliente_pj (id_cliente, cnpj, razao_social) VALUES (1,'99999999999999','Dupla');
\echo '--- T2: PJ inserido em tabela PF (deve falhar)'
INSERT INTO cliente_pf (id_cliente, cpf) VALUES (5,'55555555555');
\echo '--- T3: pedido usando forma de pagamento de outro cliente (deve falhar)'
INSERT INTO pedido (id_cliente, id_forma_pagamento) VALUES (2, 1);
\echo '--- T4: tipo_cliente inválido (deve falhar)'
INSERT INTO cliente (nome,email,tipo_cliente) VALUES ('X','x@x.com','XX');
\echo '--- T5: status de entrega inválido (deve falhar)'
UPDATE entrega SET status_entrega='PERDIDO' WHERE id_pedido=1;
