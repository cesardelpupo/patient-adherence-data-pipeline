-- ================================================================
-- Arquivo: 06_orphan_date_key.sql
-- Categoria: Referential
-- Descrição: Garante que não existem chaves nulas ou órfãs
--            na tabela fato.
-- ================================================================

-- TEST: Detectar IDs de datas que existem na fato, mas 'sumiram' na dimensão.
-- EXPECTED: 0

WITH orphan_date AS(
    SELECT COUNT(*) AS qty_date
    FROM fct_appointments AS fa
    LEFT JOIN dim_date AS dd
        ON fa.date_key = dd.date_key
    WHERE dd.date_key IS NULL             -- não encontrou correspondente na dimensão
      AND fa.date_key IS NOT NULL         -- ID existe na fato (órfã real) 
)
SELECT qty_date
FROM orphan_date;