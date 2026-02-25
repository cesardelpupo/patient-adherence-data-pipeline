-- ================================================================
-- Arquivo: 12_fact_mart_financial_consistency.sql
-- Categoria: Layer Consistency
-- Descrição: Garante que o total de receita na fato seja igual 
--            ao total de receita nas marts.
-- ================================================================

-- TEST: Verificar se o total de receita na tabela fato é igual ao total de receita nas marts.
-- EXPECTED: 0

WITH fact_total AS(
    SELECT SUM(revenue_realized) AS value_fact
    FROM fct_appointments
),
mart_total AS(
    SELECT SUM(total_revenue_realized) AS value_mart
    FROM mart_monthly_performance
)
SELECT 
    f.value_fact - m.value_mart
FROM fact_total as f
CROSS JOIN mart_total as m;