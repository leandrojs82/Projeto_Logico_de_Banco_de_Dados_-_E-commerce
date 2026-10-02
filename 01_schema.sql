-- =====================================================================
-- Projeto Lógico de Banco de Dados - E-commerce
-- SGBD: PostgreSQL
-- =====================================================================

DROP SCHEMA IF EXISTS ecommerce CASCADE;
CREATE SCHEMA ecommerce;
SET search_path TO ecommerce;

-- ---------------------------------------------------------------------
-- CLIENTE (supertipo) + especializações PF / PJ (EER -> tabelas)
-- Regra: uma conta é PF ou PJ, nunca as duas.
-- Implementação: a tabela cliente guarda o tipo; as tabelas filhas
-- referenciam (id_cliente, tipo) com FK composta e CHECK fixando o tipo,
-- impedindo que o mesmo cliente exista em PF e PJ ao mesmo tempo.
-- ---------------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente     SERIAL PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    email          VARCHAR(120) NOT NULL UNIQUE,
    telefone       VARCHAR(20),
    tipo_cliente   CHAR(2)      NOT NULL CHECK (tipo_cliente IN ('PF', 'PJ')),
    data_cadastro  DATE         NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT uq_cliente_tipo UNIQUE (id_cliente, tipo_cliente)
);

CREATE TABLE cliente_pf (
    id_cliente       INT PRIMARY KEY,
    tipo_cliente     CHAR(2)  NOT NULL DEFAULT 'PF' CHECK (tipo_cliente = 'PF'),
    cpf              CHAR(11) NOT NULL UNIQUE,
    data_nascimento  DATE,
    CONSTRAINT fk_pf_cliente FOREIGN KEY (id_cliente, tipo_cliente)
        REFERENCES cliente (id_cliente, tipo_cliente) ON DELETE CASCADE
);

CREATE TABLE cliente_pj (
    id_cliente      INT PRIMARY KEY,
    tipo_cliente    CHAR(2)  NOT NULL DEFAULT 'PJ' CHECK (tipo_cliente = 'PJ'),
    cnpj            CHAR(14) NOT NULL UNIQUE,
    razao_social    VARCHAR(120) NOT NULL,
    CONSTRAINT fk_pj_cliente FOREIGN KEY (id_cliente, tipo_cliente)
        REFERENCES cliente (id_cliente, tipo_cliente) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- FORMA DE PAGAMENTO: um cliente pode ter várias formas cadastradas
-- ---------------------------------------------------------------------
CREATE TABLE forma_pagamento (
    id_forma_pagamento  SERIAL PRIMARY KEY,
    id_cliente          INT NOT NULL REFERENCES cliente (id_cliente) ON DELETE CASCADE,
    tipo_pagamento      VARCHAR(20) NOT NULL
        CHECK (tipo_pagamento IN ('CARTAO_CREDITO', 'CARTAO_DEBITO', 'PIX', 'BOLETO')),
    descricao           VARCHAR(80),          -- ex.: "Visa final 4417"
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_forma_pagamento_cliente UNIQUE (id_forma_pagamento, id_cliente)
);

-- ---------------------------------------------------------------------
-- PRODUTO, FORNECEDOR, VENDEDOR TERCEIRO, ESTOQUE
-- ---------------------------------------------------------------------
CREATE TABLE produto (
    id_produto   SERIAL PRIMARY KEY,
    nome         VARCHAR(100) NOT NULL,
    categoria    VARCHAR(30)  NOT NULL
        CHECK (categoria IN ('ELETRONICO', 'VESTUARIO', 'BRINQUEDO', 'ALIMENTO', 'MOVEIS', 'LIVRO')),
    descricao    VARCHAR(255),
    valor        NUMERIC(10,2) NOT NULL CHECK (valor > 0)
);

CREATE TABLE fornecedor (
    id_fornecedor  SERIAL PRIMARY KEY,
    razao_social   VARCHAR(120) NOT NULL,
    cnpj           CHAR(14)     NOT NULL UNIQUE
);

CREATE TABLE vendedor (
    id_vendedor    SERIAL PRIMARY KEY,
    razao_social   VARCHAR(120) NOT NULL,
    nome_fantasia  VARCHAR(100),
    cnpj           CHAR(14)     NOT NULL UNIQUE,
    localizacao    VARCHAR(60)
);

CREATE TABLE estoque (
    id_estoque   SERIAL PRIMARY KEY,
    localizacao  VARCHAR(60) NOT NULL
);

-- Relacionamentos N:N
CREATE TABLE produto_fornecedor (
    id_produto     INT NOT NULL REFERENCES produto (id_produto),
    id_fornecedor  INT NOT NULL REFERENCES fornecedor (id_fornecedor),
    PRIMARY KEY (id_produto, id_fornecedor)
);

CREATE TABLE produto_vendedor (
    id_vendedor  INT NOT NULL REFERENCES vendedor (id_vendedor),
    id_produto   INT NOT NULL REFERENCES produto (id_produto),
    quantidade   INT NOT NULL DEFAULT 1 CHECK (quantidade >= 0),
    PRIMARY KEY (id_vendedor, id_produto)
);

CREATE TABLE produto_estoque (
    id_produto  INT NOT NULL REFERENCES produto (id_produto),
    id_estoque  INT NOT NULL REFERENCES estoque (id_estoque),
    quantidade  INT NOT NULL DEFAULT 0 CHECK (quantidade >= 0),
    PRIMARY KEY (id_produto, id_estoque)
);

-- ---------------------------------------------------------------------
-- PEDIDO e ITEM_PEDIDO
-- A FK composta garante que a forma de pagamento usada no pedido
-- pertence ao próprio cliente que fez o pedido.
-- ---------------------------------------------------------------------
CREATE TABLE pedido (
    id_pedido           SERIAL PRIMARY KEY,
    id_cliente          INT NOT NULL REFERENCES cliente (id_cliente),
    id_forma_pagamento  INT NOT NULL,
    status_pedido       VARCHAR(20) NOT NULL DEFAULT 'EM_PROCESSAMENTO'
        CHECK (status_pedido IN ('CANCELADO', 'CONFIRMADO', 'EM_PROCESSAMENTO')),
    descricao           VARCHAR(255),
    frete               NUMERIC(8,2) NOT NULL DEFAULT 0 CHECK (frete >= 0),
    data_pedido         DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_pedido_pagamento FOREIGN KEY (id_forma_pagamento, id_cliente)
        REFERENCES forma_pagamento (id_forma_pagamento, id_cliente)
);

CREATE TABLE item_pedido (
    id_pedido       INT NOT NULL REFERENCES pedido (id_pedido) ON DELETE CASCADE,
    id_produto      INT NOT NULL REFERENCES produto (id_produto),
    quantidade      INT NOT NULL CHECK (quantidade > 0),
    preco_unitario  NUMERIC(10,2) NOT NULL CHECK (preco_unitario > 0),
    PRIMARY KEY (id_pedido, id_produto)
);

-- ---------------------------------------------------------------------
-- ENTREGA: status e código de rastreio (1 pedido -> 1 entrega)
-- ---------------------------------------------------------------------
CREATE TABLE entrega (
    id_entrega        SERIAL PRIMARY KEY,
    id_pedido         INT NOT NULL UNIQUE REFERENCES pedido (id_pedido) ON DELETE CASCADE,
    status_entrega    VARCHAR(20) NOT NULL DEFAULT 'PREPARANDO'
        CHECK (status_entrega IN ('PREPARANDO', 'ENVIADO', 'EM_TRANSITO', 'ENTREGUE', 'DEVOLVIDO')),
    codigo_rastreio   VARCHAR(20) UNIQUE,
    data_envio        DATE,
    previsao_entrega  DATE
);

CREATE INDEX idx_pedido_cliente ON pedido (id_cliente);
CREATE INDEX idx_item_produto   ON item_pedido (id_produto);
