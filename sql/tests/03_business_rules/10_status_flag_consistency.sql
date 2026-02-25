-- ================================================================
-- Arquivo: 10_status_flag_consistency.sql
-- Categoria: Business Rules
-- Descrição: Garante que os status de agendamento estejam 
--            consistentes (attended_flag + missed_flag = 1).
-- ================================================================

-- TEST: Detectar registros com valores inconsistentes de status.

-- EXPECTED: 0

WITH invalid_status AS(
    SELECT COUNT(*) AS qty_status
    FROM fct_appointments
    WHERE attended_flag + missed_flag != 1
)
SELECT qty_status
FROM invalid_status;
