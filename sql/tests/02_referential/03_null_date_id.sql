-- ================================================================
-- Arquivo: 03_null_date_key.sql
-- Categoria: Referential
-- Descrição: Garante que não existem chaves nulas ou órfãs
--            na tabela fato.
-- ================================================================

-- TEST: Chave órfã: date_key nulo na fct_appointments
-- EXPECTED: 0

WITH null_keys AS(
    SELECT COUNT(*) AS qty_date
    FROM fct_appointments
    WHERE date_key IS NULL
)
SELECT qty_date
FROM null_keys;