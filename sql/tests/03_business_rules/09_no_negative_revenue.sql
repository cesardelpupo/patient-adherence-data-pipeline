-- ================================================================
-- Arquivo: 09_no_negative_revenue.sql
-- Categoria: Business Rules
-- Descrição: Garante que nenhum valor de receita seja negativo.
-- ================================================================

-- TEST: Detectar registros com valores de receita negativos.
-- EXPECTED: 0

WITH negative_values AS(
    SELECT COUNT(*) AS qty
    FROM fct_appointments
    WHERE revenue_realized < 0
       OR revenue_lost < 0
)
SELECT qty
FROM negative_values;