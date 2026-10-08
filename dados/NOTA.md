# Sobre os dados

Os dados são **simulados** e foram gerados especificamente para este exercício.

Problemas de qualidade foram introduzidos deliberadamente no dataset, de forma
a reproduzir as condições de um ficheiro de produção real:

- linhas duplicadas
- registos órfãos (referências a produtos e clientes inexistentes)
- datas em formatos inconsistentes dentro da mesma coluna
- datas logicamente impossíveis (entrega anterior à encomenda)
- quantidades negativas e preços a zero
- descontos superiores a 100%
- estado de encomenda inconsistente com os dados

O objetivo do projeto é demonstrar o **método de análise** — auditoria dos dados
antes de qualquer cálculo, decisões de limpeza documentadas, e conclusões com as
respetivas limitações declaradas. Os valores em si não representam nenhuma
empresa real.

## Como reproduzir

O ficheiro `nortex_setup.sql` contém a base de dados completa. Pode ser carregado
em qualquer motor SQLite — por exemplo em sqliteonline.com, colando o conteúdo e
executando uma vez.

## Esquema

| Tabela | Conteúdo |
|---|---|
| `fornecedores` | 12 fornecedores, país e lead time contratado |
| `produtos` | 25 referências, família, custo e preço de venda |
| `centros` | 4 centros de distribuição, cidade e nº de operadores |
| `inventario` | stock, stock de segurança e consumo mensal por produto e centro |
| `clientes` | 14 clientes, região e segmento |
| `encomendas` | 420 encomendas, datas de encomenda, promessa e entrega |
| `linhas` | 1.309 linhas de encomenda, quantidade, preço e desconto |
