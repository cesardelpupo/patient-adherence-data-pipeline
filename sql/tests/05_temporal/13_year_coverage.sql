-- ================================================================
-- Arquivo: 13_year_coverage.sql
-- Categoria: Temporal
-- Descrição: Garante que os anos 2022 e 2023 estejam presentes
--            na tabela fato.
-- ================================================================

-- TEST: Verificar se os anos 2022 e 2023 estão presentes na tabela fato.
-- EXPECTED: 0

WITH expected_years AS(
    SELECT 2022 AS year_num
    UNION ALL
    SELECT 2023
),
present_years AS(
    SELECT DISTINCT dd.year_num
    FROM fct_appointments AS fa
    JOIN dim_date AS dd ON fa.date_key = dd.date_key
),
missing_years AS(
    SELECT COUNT(*) AS missing_qty
    FROM expected_years AS ey
    LEFT JOIN present_years AS py ON ey.year_num = py.year_num
    WHERE py.year_num IS NULL
)
SELECT missing_qty
FROM missing_years;