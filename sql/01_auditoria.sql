-- =====================================================================
-- Auditoria de dados
-- Projeto: Análise de Operações Logísticas — Nortex (dados simulados)
--
-- Deteção sistemática de problemas de qualidade antes de qualquer análise.
-- Uma query por tipo de problema: quantidades negativas, descontos inválidos,
-- preços a zero, registos órfãos, datas impossíveis, formatos inconsistentes
-- e duplicados. O relatório consolidado está no fim do ficheiro.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Verificação 1
-- ---------------------------------------------------------------------

SELECT id_linha, quantidade
from linhas
where quantidade<0
-- NOTA: manter e assinalar. Pode ser uma devolucao


-- ---------------------------------------------------------------------
-- Verificação 2
-- ---------------------------------------------------------------------

SELECT id_linha, desconto_pct
from linhas
where desconto_pct>1
-- NOTA: excluir. Nao ha forma de recuperar o valor correto e nao faz sentido haver um desconto maior que 1


-- ---------------------------------------------------------------------
-- Verificação 3
-- ---------------------------------------------------------------------

SELECT id_linha, preco_unitario
from linhas
where preco_unitario=0
-- NOTA: manter e assinalar. Pode ser uma oferta


-- ---------------------------------------------------------------------
-- Verificação 4
-- ---------------------------------------------------------------------

SELECT l. id_linha, l. id_produto
from linhas l 
left join produtos p on p. id_produto=l. id_produto
where p.id_produto is null
-- NOTA: nao e recuperavel, a tabela linhas so tem o id_produto. Manter no valor total faturado (a venda existiu) e excluir das analises por produto.


-- ---------------------------------------------------------------------
-- Verificação 5
-- ---------------------------------------------------------------------

SELECT id_encomenda, id_cliente
from encomendas 
where id_cliente not in (select id_cliente from clientes)
-- NOTA: mesmo tratamento do caso anterior: manter no total faturado e excluir das analises por cliente.


-- ---------------------------------------------------------------------
-- Verificação 6
-- ---------------------------------------------------------------------

SELECT id_encomenda, data_entrega, data_encomenda
from encomendas 
where data_entrega not like '%/%' and data_entrega<data_encomenda
-- NOTA: excluir, seria impossivel ou ma pratica que nao deve acontecer de todo. E melhor garantir que nao volta a contecer do q manter nos dados mesmo assinalando


-- ---------------------------------------------------------------------
-- Verificação 7
-- ---------------------------------------------------------------------

SELECT id_encomenda, data_prometida, data_encomenda
from encomendas 
where data_prometida not like '%/%' and data_prometida<data_encomenda
-- NOTA: mesma decisao da verificacao 6: excluir das analises de prazo, por ser logicamente impossivel.


-- ---------------------------------------------------------------------
-- Verificação 8
-- ---------------------------------------------------------------------

SELECT id_encomenda, data_entrega, estado
from encomendas 
where data_entrega is null and estado='Entregue'
-- NOTA: manter e assinalar. Pode ter sido apenas um lapso, o resto das informacoes da linha podem ser importantes na mesma


-- ---------------------------------------------------------------------
-- Verificação 9
-- ---------------------------------------------------------------------

SELECT id_encomenda, data_entrega
from encomendas 
where data_entrega like '%/%';
-- NOTA: corrigir, e facil


-- ---------------------------------------------------------------------
-- Verificação 10
-- ---------------------------------------------------------------------

SELECT   id_encomenda, id_produto, quantidade, preco_unitario, desconto_pct,
         COUNT(*) AS n
FROM     linhas
GROUP BY id_encomenda, id_produto, quantidade, preco_unitario, desconto_pct
HAVING   COUNT(*) > 1;

-- NOTA: Apagar a duplicada apenas


-- ---------------------------------------------------------------------
-- Verificação 19
-- ---------------------------------------------------------------------

SELECT 'Quantidade negativa' AS problema, COUNT(*) AS n
FROM linhas WHERE quantidade < 0

UNION ALL

SELECT 'Desconto inválido', COUNT(*)
FROM linhas WHERE desconto_pct > 1

UNION ALL

SELECT 'Preço zero', COUNT(*)
FROM linhas WHERE preco_unitario = 0;
