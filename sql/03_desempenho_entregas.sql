-- =====================================================================
-- Desempenho de entregas
-- Projeto: Análise de Operações Logísticas — Nortex (dados simulados)
--
-- Taxa de cumprimento de prazo (OTD) global, por centro de distribuição,
-- por mês e por perfil de cliente. Inclui o atraso médio, distinguindo
-- o desvio de todas as entregas do desvio apenas das atrasadas.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Pergunta 3
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
        WHERE coerencia = 'ok' AND d_entrega IS NOT NULL
          AND d_entrega >= data_encomenda AND d_prometida >= data_encomenda
          AND id_cliente IN (SELECT id_cliente FROM clientes)
      )
    select round(100.0*sum(case WHEN d_prometida>= d_entrega then 1 else 0 end)/COUNT(d_entrega),2) as tx_global  
    from entregas_validas


-- ---------------------------------------------------------------------
-- Pergunta 4
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
        WHERE coerencia = 'ok' AND d_entrega IS NOT NULL
          AND d_entrega >= data_encomenda AND d_prometida >= data_encomenda
          AND id_cliente IN (SELECT id_cliente FROM clientes)
      )
      
      
      
    select c. nome, round(100.0*sum(case WHEN d_prometida>= d_entrega then 1 else 0 end)/COUNT(d_entrega),2) as tx_globalOTD  
    from entregas_validas ev
   join centros c on c. id_centro=ev. id_centro
    group by c. id_centro
    
O centro com mais problemas de atrasos e o de lisboa com apenas 14.89% das encomendas a chegarem a tempo. Ainda assim, todos os outros centros apresentam taxas de atrasos muito elevadas sendo o centro norte o unico com uma taxa de atrasos menor que 50% (ainda assim elevada na casa dos 35%)


-- ---------------------------------------------------------------------
-- Pergunta 5
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
        WHERE coerencia = 'ok' AND d_entrega IS NOT NULL
          AND d_entrega >= data_encomenda AND d_prometida >= data_encomenda
          AND id_cliente IN (SELECT id_cliente FROM clientes)
      )
      
      
      
    select c. nome, round(sum(case WHEN d_prometida< d_entrega then julianday(d_entrega)-julianday(d_prometida) else 0 end)/sum(case when d_prometida< d_entrega then 1 else 0 end),2) as atrasomedioatrasadas,
    round(avg(julianday(d_entrega)- julianday(d_prometida)),2) as atrasomediototal
                         
                                                                           
    from entregas_validas ev
   join centros c on c. id_centro=ev. id_centro
    group by c. id_centro


-- ---------------------------------------------------------------------
-- Pergunta 6
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
        WHERE coerencia = 'ok' AND d_entrega IS NOT NULL
          AND d_entrega >= data_encomenda AND d_prometida >= data_encomenda
          AND id_cliente IN (SELECT id_cliente FROM clientes)
      )
      
      
      
  select  round(100.0*sum(case WHEN d_prometida>= d_entrega then 1 else 0 end)/COUNT(d_entrega),2) as tx_cumprimento, substr(data_encomenda,1,7) as mes
                         
                                                                    
    from entregas_validas ev
    group by mes
    order by mes


-- ---------------------------------------------------------------------
-- Pergunta 7
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
        WHERE coerencia = 'ok' AND d_entrega IS NOT NULL
          AND d_entrega >= data_encomenda AND d_prometida >= data_encomenda
          AND id_cliente IN (SELECT id_cliente FROM clientes)
      )
      
      
      
    select c. nome, round(100.0*sum(case WHEN d_prometida>= d_entrega then 1 else 0 end)/COUNT(d_entrega),2) as tx_globalOTD, c. n_operadores  
    from entregas_validas ev
   join centros c on c. id_centro=ev. id_centro
    group by c. id_centro
    

-- NOTA: nao ha uma correlacao direta. O centro de lisboa e o que emprega mais trabalhadores e tem o pior desempenho de entrega enquanto o centro norte e o Segundo centro com mais trabalhadores e é o que apresenta melhor desempenho. Se compararmos o centro sul com o centro centro percebemos que apesar do centro centro ter 22 trabalhadores e o centro sul ter 15 os seus desempenhos sao semelhantes


-- ---------------------------------------------------------------------
-- Pergunta 8
-- ---------------------------------------------------------------------

-- NOTA: nao copiei as CTEs neste exercicio mas estao no sql
    select c. regiao, round(100.0*sum(case WHEN d_prometida>= d_entrega then 1 else 0 end)/COUNT(d_entrega),2) as tx_globalOTD
    from entregas_validas ev
   join clientes c on c. id_cliente=ev. id_cliente
    group by c. regiao

-- NOTA: por regiao percebe se que a taxa de cumprimento e maior quando o cliente e da regiao norte com 54%. As restantes regioes tem uma taxa de cerca de 38.5%

select  c.segmento, round(100.0*sum(case WHEN d_prometida>= d_entrega then 1 else 0 end)/COUNT(d_entrega),2) as tx_globalOTD
    from entregas_validas ev
   join clientes c on c. id_cliente=ev. id_cliente
    group by c. segment

-- NOTA: por segmento percebe se que o mais preocupante e o dos servicos com apenas 33%. Os restantes estao entre os 40 e 50%
