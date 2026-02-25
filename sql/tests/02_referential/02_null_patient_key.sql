-- ================================================================
-- Arquivo: 02_null_patient_key.sql
-- Categoria: Referential
-- Descrição: Garante que não existem chaves nulas ou órfãs
--            na tabela fato.
-- ================================================================

-- TEST: Chave órfã: patient_key nulo na fct_appointments
-- EXPECTED: 0

WITH null_keys AS(
    SELECT COUNT(*) AS qty_patient
    FROM fct_appointments 
    WHERE patient_key IS NULL
)
SELECT qty_patient
FROM null_keys;