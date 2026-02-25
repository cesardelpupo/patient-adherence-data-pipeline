-- ================================================================
-- Arquivo: 14_payment_model_by_year.sql
-- Categoria: Temporal
-- Descrição: Garante que cada ano tenha exclusivamente o modelo 
--            de pagamento correto.
-- ================================================================

-- TEST: Garante que cada ano tenha exclusivamente o modelo de pagamento correto.
-- EXPECTED: 0

WITH wrong_model AS(
    SELECT COUNT(*) AS qty_wrong
    FROM fct_appointments AS fa
    JOIN dim_date AS dd ON fa.date_id = dd.date_id
    JOIN dim_payment_model AS dpm ON fa.payment_model_id = dpm.payment_model_id
    WHERE (dd.year_num = 2022 AND dpm.payment_type <> 'PerSession')
       OR (dd.year_num = 2023 AND dpm.payment_type <> 'MonthlyPackage')
),
result AS(
    SELECT qty_wrong
    FROM wrong_model
)
SELECT qty_wrong
FROM result;