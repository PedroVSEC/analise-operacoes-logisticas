-- =====================================================================
-- Análise comercial
-- Projeto: Análise de Operações Logísticas — Nortex (dados simulados)
--
-- Faturação por produto, análise ABC por valor acumulado, concentração
-- de clientes e evolução mensal com variação face ao período anterior.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Pergunta 9
-- ---------------------------------------------------------------------

with linhas_validas as (select * from linhas l 
                        join produtos p on l.id_produto=p.id_produto
                        where l. quantidade>=0 and l. desconto_pct <= 1 and l. preco_unitario>0 and l. id_produto=p. id_produto), 
        datas_corrigidas AS (
    SELECT id_encomenda, id_cliente, id_centro, estado,
           data_encomenda,
           CASE WHEN data_prometida LIKE '%/%'
                THEN SUBSTR(data_prometida,7,4)||'-'||SUBSTR(data_prometida,4,2)||'-'||SUBSTR(data_prometida,1,2)
                ELSE data_prometida END AS d_prometida,
           CASE WHEN data_entrega LIKE '%/%'
                THEN SUBSTR(data_entrega,7,4)||'-'||SUBSTR(data_entrega,4,2)||'-'||SUBSTR(data_entrega,1,2)
                ELSE data_entrega END AS d_entrega,
  CASE WHEN estado = 'Entregue' AND data_entrega IS NULL THEN 'INCONSISTENTE'
     ELSE 'ok' END AS coerencia
    FROM encomendas),
    entregas_validas AS (
        SELECT * FROM datas_corrigidas
        WHERE data_encomenda <= d_prometida
      AND (d_entrega IS NULL OR data_encomenda <= d_entrega)
      AND id_cliente IN (SELECT id_cliente FROM clientes)
     )
      
      
       SELECT p. descricao, sum((lv. quantidade * lv. preco_unitario*(1-lv. desconto_pct))) as valor_faturado
       from produtos p
       join linhas_validas lv on lv. id_produto = p. id_produto
       JOIN   entregas_validas e ON e.id_encomenda = lv.id_encomenda      
       group by p. descricao
       order by valor_faturado desc 
       limit 10


-- ---------------------------------------------------------------------
-- Pergunta 10
-- ---------------------------------------------------------------------

with linhas_validas as (select * from linhas l 
                        join produtos p on l.id_produto=p.id_produto
                        where l. quantidade>=0 and l. desconto_pct <= 1 and l. preco_unitario>0 and l. id_produto=p. id_produto), 
        datas_corrigidas AS (
    SELECT id_encomenda, id_cliente, id_centro, estado,
           data_encomenda,
           CASE WHEN data_prometida LIKE '%/%'
                THEN SUBSTR(data_prometida,7,4)||'-'||SUBSTR(data_prometida,4,2)||'-'||SUBSTR(data_prometida,1,2)
                ELSE data_prometida END AS d_prometida,
           CASE WHEN data_entrega LIKE '%/%'
                THEN SUBSTR(data_entrega,7,4)||'-'||SUBSTR(data_entrega,4,2)||'-'||SUBSTR(data_entrega,1,2)
                ELSE data_entrega END AS d_entrega,
  CASE WHEN estado = 'Entregue' AND data_entrega IS NULL THEN 'INCONSISTENTE'
     ELSE 'ok' END AS coerencia
    FROM encomendas),
    encomendas_validas AS (
        SELECT * FROM datas_corrigidas
        WHERE data_encomenda <= d_prometida
      AND (d_entrega IS NULL OR data_encomenda <= d_entrega)
      AND id_cliente IN (SELECT id_cliente FROM clientes)
      )
     ,
      valor_produto as (SELECT p. descricao, sum((lv. quantidade * lv. preco_unitario*(1-lv. desconto_pct))) as valor
       from produtos p
       join linhas_validas lv on lv. id_produto = p. id_produto
       JOIN   encomendas_validas e ON e.id_encomenda = lv.id_encomenda      
       group by p. descricao
       order by valor desc ),
       
       analiseABC as (select descricao, ROUND(valor, 2) AS valor,
       ROUND(100.0 * valor / SUM(valor) OVER (), 2) AS pct,
       ROUND(100.0 * SUM(valor) OVER (ORDER BY valor DESC) / SUM(valor) OVER (), 2) AS pct_acum,
       CASE WHEN 100.0 * SUM(valor) OVER (ORDER BY valor DESC) / SUM(valor) OVER () <= 80 THEN 'A'
            WHEN 100.0 * SUM(valor) OVER (ORDER BY valor DESC) / SUM(valor) OVER () <= 95 THEN 'B'
            ELSE 'C' END AS classe
           FROM   valor_produto
ORDER BY valor DESC)

SELECT COUNT(*) AS n_classe_A
FROM   analiseABC
WHERE  pct_acum <= 80;


-- ---------------------------------------------------------------------
-- Pergunta 11
-- ---------------------------------------------------------------------

with linhas_validas as (select * from linhas l 
                        join produtos p on l.id_produto=p.id_produto
                        where l. quantidade>=0 and l. desconto_pct <= 1 and l. preco_unitario>0 and l. id_produto=p. id_produto), 
        datas_corrigidas AS (
    SELECT id_encomenda, id_cliente, id_centro, estado,
           data_encomenda,
           CASE WHEN data_prometida LIKE '%/%'
                THEN SUBSTR(data_prometida,7,4)||'-'||SUBSTR(data_prometida,4,2)||'-'||SUBSTR(data_prometida,1,2)
                ELSE data_prometida END AS d_prometida,
           CASE WHEN data_entrega LIKE '%/%'
                THEN SUBSTR(data_entrega,7,4)||'-'||SUBSTR(data_entrega,4,2)||'-'||SUBSTR(data_entrega,1,2)
                ELSE data_entrega END AS d_entrega,
  CASE WHEN estado = 'Entregue' AND data_entrega IS NULL THEN 'INCONSISTENTE'
     ELSE 'ok' END AS coerencia
    FROM encomendas),
    encomendas_validas AS (
        SELECT * FROM datas_corrigidas
        WHERE data_encomenda <= d_prometida
      AND (d_entrega IS NULL OR data_encomenda <= d_entrega)
      AND id_cliente IN (SELECT id_cliente FROM clientes)
      ) ,
      
     valor_faturado as ( select sum((lv. quantidade * lv. preco_unitario*(1-lv. desconto_pct))) as total
     from linhas_validas lv)
     
     SELECT p. familia, sum((lv. quantidade * lv. preco_unitario*(1-lv. desconto_pct))) as valor,
     100.0*sum((lv. quantidade * lv. preco_unitario*(1-lv. desconto_pct)))/ vf. total as pct
       from produtos p, valor_faturado vf
       join linhas_validas lv on lv. id_produto = p. id_produto
       JOIN   encomendas_validas e ON e.id_encomenda = lv.id_encomenda
       
       group by p. familia
       order by valor desc


-- ---------------------------------------------------------------------
-- Pergunta 12
-- ---------------------------------------------------------------------

with linhas_validas as (select * from linhas l 
                        join produtos p on l.id_produto=p.id_produto
                        where l. quantidade>=0 and l. desconto_pct <= 1 and l. preco_unitario>0 and l. id_produto=p. id_produto), 
        datas_corrigidas AS (
    SELECT id_encomenda, id_cliente, id_centro, estado,
           data_encomenda,
           CASE WHEN data_prometida LIKE '%/%'
                THEN SUBSTR(data_prometida,7,4)||'-'||SUBSTR(data_prometida,4,2)||'-'||SUBSTR(data_prometida,1,2)
                ELSE data_prometida END AS d_prometida,
           CASE WHEN data_entrega LIKE '%/%'
                THEN SUBSTR(data_entrega,7,4)||'-'||SUBSTR(data_entrega,4,2)||'-'||SUBSTR(data_entrega,1,2)
                ELSE data_entrega END AS d_entrega,
  CASE WHEN estado = 'Entregue' AND data_entrega IS NULL THEN 'INCONSISTENTE'
     ELSE 'ok' END AS coerencia
    FROM encomendas),
    encomendas_validas AS (
        SELECT * FROM datas_corrigidas
        WHERE data_encomenda <= d_prometida
      AND (d_entrega IS NULL OR data_encomenda <= d_entrega)
      AND id_cliente IN (SELECT id_cliente FROM clientes)
      ) ,
      
     valor_faturado as ( select sum((lv. quantidade * lv. preco_unitario*(1-lv. desconto_pct))) as total
     from linhas_validas lv)
     
     SELECT c. nome, sum((lv. quantidade * lv. preco_unitario*(1-lv. desconto_pct))) as valor,
     100.0*sum((lv. quantidade * lv. preco_unitario*(1-lv. desconto_pct)))/ vf. total as pct
       from clientes c, valor_faturado vf 
       join linhas_validas lv on lv. id_encomenda = e. id_encomenda
       JOIN encomendas_validas e ON e.id_cliente = c. id_cliente
       group by c. nome
       order by valor desc 
       limit 5


-- ---------------------------------------------------------------------
-- Pergunta 13
-- ---------------------------------------------------------------------

WITH linhas_validas AS (
    SELECT l.* FROM linhas l
    WHERE l.quantidade > 0 AND l.desconto_pct <= 1 AND l.preco_unitario > 0
      AND l.id_produto IN (SELECT id_produto FROM produtos)
),
datas_corrigidas AS (
    SELECT id_encomenda, id_cliente, data_encomenda,
           CASE WHEN data_prometida LIKE '%/%'
                THEN SUBSTR(data_prometida,7,4)||'-'||SUBSTR(data_prometida,4,2)||'-'||SUBSTR(data_prometida,1,2)
                ELSE data_prometida END AS d_prometida,
           CASE WHEN data_entrega LIKE '%/%'
                THEN SUBSTR(data_entrega,7,4)||'-'||SUBSTR(data_entrega,4,2)||'-'||SUBSTR(data_entrega,1,2)
                ELSE data_entrega END AS d_entrega
    FROM encomendas
),
encomendas_validas AS (
    SELECT * FROM datas_corrigidas
    WHERE data_encomenda <= d_prometida
      AND (d_entrega IS NULL OR data_encomenda <= d_entrega)
      AND id_cliente IN (SELECT id_cliente FROM clientes)
),
mensal AS (
    SELECT SUBSTR(e.data_encomenda,1,7) AS mes,
           SUM(lv.quantidade * lv.preco_unitario * (1 - lv.desconto_pct)) AS valor
    FROM   linhas_validas lv
    JOIN   encomendas_validas e ON e.id_encomenda = lv.id_encomenda
    GROUP BY mes
)
SELECT mes,
       ROUND(valor, 2) AS valor,
       ROUND(LAG(valor) OVER (ORDER BY mes), 2) AS mes_anterior,
       ROUND(100.0 * (valor - LAG(valor) OVER (ORDER BY mes)) / LAG(valor) OVER (ORDER BY mes), 1) AS var_pct
FROM   mensal
ORDER BY mes;
