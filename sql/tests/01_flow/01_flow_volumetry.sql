-- ================================================================
-- Arquivo: 01_flow_volumetry.sql
-- Categoria: Flow
-- Descrição: Garante que nenhum registro se perdeu entre as
--            camadas do pipeline (Staging → Fato).
-- ================================================================

-- TEST: Volumetria: Staging vs Fato (diferença deve ser 0)
-- EXPECTED: 0

WITH source_count AS(
    SELECT COUNT(*) AS total
    FROM staging_appointments
),
fct_count AS(
    SELECT COUNT(*) AS total
    FROM fct_appointments
)
SELECT
    s.total - f.total
FROM source_count AS s
CROSS JOIN fct_count AS f;