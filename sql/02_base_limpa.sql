-- =====================================================================
-- Construção da base limpa
-- Projeto: Análise de Operações Logísticas — Nortex (dados simulados)
--
-- Correção e filtragem aplicadas na leitura, sem alterar os dados de origem.
-- As CTEs definidas aqui são reutilizadas em todas as análises seguintes.
-- Inclui a comparação entre o total faturado antes e depois da limpeza.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Verificação 12
-- ---------------------------------------------------------------------

SELECT id_encomenda, data_entrega as antiga, SUBSTR(data_entrega,7,4) || '-' || SUBSTR(data_entrega,4,2) || '-' || SUBSTR(data_entrega,1,2) AS convertida
from encomendas 
where data_entrega like '%/%';


-- ---------------------------------------------------------------------
-- Verificação 13
-- ---------------------------------------------------------------------

SELECT id_encomenda, case when data_entrega like '%/%' then SUBSTR(data_entrega,7,4) || '-' || SUBSTR(data_entrega,4,2) || '-' || SUBSTR(data_entrega,1,2) else data_entrega end
from encomendas


-- ---------------------------------------------------------------------
-- Verificação 14
-- ---------------------------------------------------------------------

SELECT id_encomenda, 
case when data_entrega like '%/%' then SUBSTR(data_entrega,7,4) || '-' || SUBSTR(data_entrega,4,2) || '-' || SUBSTR(data_entrega,1,2) else data_entrega end,
sum(case when data_entrega<data_encomenda then 1 else 0 end)
from encomendas

/* NOTA
   Depois de converter as datas sobram apenas 2 registos impossiveis;
   antes da conversao apareciam 6.

   Os outros 4 eram falsos positivos: em formato DD/MM/YYYY a comparacao
   de texto e alfabetica e nao cronologica ('13/01/2025' < '2025-01-03'
   porque '1' < '2').

   Corrigir o formato antes de testar coerencias logicas e essencial,
   caso contrario um problema mascara-se noutro.
*/


-- ---------------------------------------------------------------------
-- Verificação 15
-- ---------------------------------------------------------------------

with linhas_validas as (select * from linhas l 
                        join produtos p on l.id_produto=p.id_produto
                        where l. quantidade>=0 and l. desconto_pct <= 1 and l. preco_unitario>0 and l. id_produto=p. id_produto)
                      select count(*) from linhas_validas
-- NOTA: ficaram 1303


-- ---------------------------------------------------------------------
-- Verificação 16
-- ---------------------------------------------------------------------

WITH datas_corrigidas AS (
    SELECT id_encomenda, id_cliente, id_centro, estado,
           data_encomenda,
           CASE WHEN data_prometida LIKE '%/%'
                THEN SUBSTR(data_prometida,7,4)||'-'||SUBSTR(data_prometida,4,2)||'-'||SUBSTR(data_prometida,1,2)
                ELSE data_prometida END AS d_prometida,
           CASE WHEN data_entrega LIKE '%/%'
                THEN SUBSTR(data_entrega,7,4)||'-'||SUBSTR(data_entrega,4,2)||'-'||SUBSTR(data_entrega,1,2)
                ELSE data_entrega END AS d_entrega
    FROM encomendas
)
SELECT *, CASE WHEN estado = 'Entregue' AND d_entrega IS NULL THEN 'INCONSISTENTE'
     ELSE 'ok' END AS coerencia
FROM   datas_corrigidas
WHERE  data_encomenda <= d_prometida
  AND  (d_entrega IS NULL OR data_encomenda <= d_entrega)
  AND  id_cliente IN (SELECT id_cliente FROM clientes);

-- NOTA: 416 encomendas


-- ---------------------------------------------------------------------
-- Verificação 17
-- ---------------------------------------------------------------------

WITH datas_corrigidas AS (
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
    FROM encomendas
), linhas_validas as (select * from linhas l 
                        join produtos p on l.id_produto=p.id_produto
                        where l. quantidade>0 and l. desconto_pct <= 1 and l. preco_unitario>0 and l. id_produto=p. id_produto)
                        
SELECT sum(l.quantidade*l.preco_unitario*(1-l.desconto_pct))
from linhas_validas l 
join datas_corrigidas d on d. id_encomenda = l. id_encomenda
where SUBSTR(d.data_encomenda, 1, 4) = '2025' and data_encomenda <= d_prometida
  AND  (d_entrega IS NULL OR data_encomenda <= d_entrega)
  AND  id_cliente IN (SELECT id_cliente FROM clientes);	
where d. d_entrega>'2024-12-31' and d. d_entrega<'2026-01-01' and d. coerencia= 'ok'


-- ---------------------------------------------------------------------
-- Verificação 18
-- ---------------------------------------------------------------------

-- NOTA: 7159130.87 valor limpo
-- NOTA: 7224956.47 valor sujo
