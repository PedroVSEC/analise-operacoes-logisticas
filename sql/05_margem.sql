-- =====================================================================
-- Margem e descontos
-- Projeto: Análise de Operações Logísticas — Nortex (dados simulados)
--
-- Margem bruta global e por família de produto, e análise da política
-- de descontos praticada por cliente.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Pergunta 14
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

SELECT sum(lv. quantidade* lv. preco_unitario*(1- lv. desconto_pct))  - sum(lv. quantidade* p. custo_unitario) as margem
from linhas_validas lv
join produtos p on p. id_produto=lv. id_produto


-- ---------------------------------------------------------------------
-- Pergunta 15
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
ORDER BY valor DESC),

por_familia AS (
    SELECT p.familia,
           SUM(lv.quantidade * lv.preco_unitario * (1 - lv.desconto_pct)) AS receita,
           SUM(lv.quantidade * p.custo_unitario) AS custo
    FROM   linhas_validas lv
    JOIN   produtos p ON p.id_produto = lv.id_produto
    JOIN   encomendas_validas e ON e.id_encomenda = lv.id_encomenda
    GROUP BY p.familia
)
SELECT familia,
       ROUND(100.0 * (receita - custo) / receita, 1) AS margem_pct,
       ROUND(100.0 * (SUM(receita) OVER () - SUM(custo) OVER ()) / SUM(receita) OVER (), 1) AS margem_global
FROM   por_familia
ORDER BY margem_pct;


-- ---------------------------------------------------------------------
-- Pergunta 16
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
ORDER BY valor DESC),

por_familia AS (
    SELECT p.familia,
           SUM(lv.quantidade * lv.preco_unitario * (1 - lv.desconto_pct)) AS receita,
           SUM(lv.quantidade * p.custo_unitario) AS custo,
  SUM(lv.quantidade * lv.preco_unitario) AS receitasemdesc
    FROM   linhas_validas lv
    JOIN   produtos p ON p.id_produto = lv.id_produto
    JOIN   encomendas_validas e ON e.id_encomenda = lv.id_encomenda
    
)
SELECT familia,

       ROUND(100.0 * (receita - custo) / receita, 1) AS margem_pct,
       ROUND(100.0 * (SUM(receita) OVER () - SUM(custo) OVER ()) / SUM(receita) OVER (), 1) AS margem_global,
       ROUND(100.0 * (receitasemdesc - custo) / receitasemdesc, 1) AS margem_pctsemdesc,
       ROUND(100.0 * (SUM(receitasemdesc) OVER () - SUM(custo) OVER ()) / SUM(receitasemdesc) OVER (), 1) AS margem_globalsemdesc,
       round(receita-receitasemdesc,2) as total_desc
FROM   por_familia
ORDER BY margem_pct;


-- ---------------------------------------------------------------------
-- Pergunta 17
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
ORDER BY valor DESC),

por_cliente AS (
    SELECT c. nome,
           SUM(lv.quantidade * lv.preco_unitario * (1 - lv.desconto_pct)) AS receita,
           SUM(lv.quantidade * p.custo_unitario) AS custo,
  SUM(lv.quantidade * lv.preco_unitario) AS receitasemdesc,
  count (e. id_encomenda) as nencomendas, sum(lv. quantidade) as quantidades_encomendadas
    FROM   linhas_validas lv
    JOIN   produtos p ON p.id_produto = lv.id_produto
    JOIN   encomendas_validas e ON e.id_encomenda = lv.id_encomenda
  join clientes c on c.id_cliente = e. id_cliente
  group by c. nome
    
)
SELECT nome,

       ROUND(100.0 * (receita - custo) / receita, 1) AS margem_pct,
       ROUND(100.0 * (SUM(receita) OVER () - SUM(custo) OVER ()) / SUM(receita) OVER (), 1) AS margem_global,
       ROUND(100.0 * (receitasemdesc - custo) / receitasemdesc, 1) AS margem_pctsemdesc,
       ROUND(100.0 * (SUM(receitasemdesc) OVER () - SUM(custo) OVER ()) / SUM(receitasemdesc) OVER (), 1) AS margem_globalsemdesc,
       round(receita-receitasemdesc,2) as total_desc,
-- NOTA: nencomendas, quantidades_encomendadas
       
FROM   por_cliente
ORDER BY total_desc asc;
-- NOTA: Nao parece haver relacao entre os descontos e quantidades encomendadas e n encomendas
