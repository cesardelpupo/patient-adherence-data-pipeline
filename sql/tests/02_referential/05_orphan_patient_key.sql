-- ================================================================
-- Arquivo: 05_orphan_patient_key.sql
-- Categoria: Referential
-- Descrição: Garante que não existem chaves nulas ou órfãs
--            na tabela fato.
-- ================================================================

-- TEST: Detectar IDs de pacientes que existem na fato, mas 'sumiram' na dimensão.
-- EXPECTED: 0

WITH orphan_patient AS(
    SELECT COUNT(*) AS qty_patient
    FROM fct_appointments AS fa
    LEFT JOIN dim_patient AS dp
        ON fa.patient_key = dp.patient_key
    WHERE dp.patient_key IS NULL             -- não encontrou correspondente na dimensão
      AND fa.patient_key IS NOT NULL         -- ID existe na fato (órfã real) 
)
SELECT qty_patient
FROM orphan_patient;