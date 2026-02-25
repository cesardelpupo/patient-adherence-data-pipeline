-- ================================================================
-- Arquivo: 04_null_payment_model_id.sql
-- Categoria: Referential
-- Descrição: Garante que não existem chaves nulas ou órfãs
--            na tabela fato.
-- ================================================================

-- TEST: Chave órfã: payment_model_id nulo na fct_appointments
-- EXPECTED: 0

WITH null_key AS(
    SELECT COUNT(*) AS qty_payment
    FROM fct_appointments
    WHERE payment_model_id IS NULL
)
SELECT qty_payment
FROM null_key;