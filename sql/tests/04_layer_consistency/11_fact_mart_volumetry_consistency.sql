-- ================================================================
-- Arquivo: 11_fact_mart_volumetry_consistency.sql
-- Categoria: Layer Consistency
-- Descrição: Garante que o total agendado na fato seja igual 
--            ao total agendado nas marts.
-- ================================================================

-- TEST: Verificar se o total agendado na tabela fato é igual ao total agendado nas marts.
-- EXPECTED: 0

WITH fact_count AS(
    SELECT COUNT(*) AS total_fct
    FROM fct_appointments
),
mart_count AS(
    SELECT SUM(total_scheduled) AS total_marts
    FROM mart_monthly_performance
)
SELECT
    f.total_fct - m.total_marts
FROM fact_count AS f
CROSS JOIN mart_count as m; 