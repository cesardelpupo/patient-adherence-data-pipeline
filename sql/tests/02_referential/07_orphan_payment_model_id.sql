-- ================================================================
-- Arquivo: 07_orphan_payment_model_key.sql
-- Categoria: Referential
-- Descrição: Garante que não existem chaves nulas ou órfãs
--            na tabela fato.
-- ================================================================

-- TEST: Detectar IDs de modelos de pagamento que existem na fato, mas 'sumiram' na dimensão.
-- EXPECTED: 0

WITH orphan_payment_model AS(
    SELECT COUNT(*) AS qty_model
    FROM fct_appointments AS fa
    LEFT JOIN dim_payment_model AS dpm
        ON fa.payment_model_key = dpm.payment_model_key
    WHERE dpm.payment_model_key IS NULL             -- não encontrou correspondente na dimensão
       AND fa.payment_model_key IS NOT NULL         -- ID existe na fato (órfã real) 
)
SELECT qty_model
FROM orphan_payment_model;