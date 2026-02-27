-- ================================================================
-- Arquivo: 08_package_overbilling.sql
-- Categoria: Business Rules
-- Descrição: Garante que nenhum paciente pagou mais de uma vez
--              pelo mesmo pacote de sessões.
-- ================================================================

-- TEST: Detectar pacientes que pagaram mais de uma vez pelo mesmo pacote de sessões.
-- EXPECTED: 0

WITH monthly_billing AS(
    SELECT
        fa.patient_key,
        dd.year_num,
        dd.month_num,
        dp.sessions_per_week,
        SUM(fa.revenue_realized) AS total_billing,
        MAX(dpm.price)           AS package_price
    FROM fct_appointments AS fa
    JOIN dim_payment_model AS dpm ON fa.payment_model_id = dpm.payment_model_id
    JOIN dim_date AS dd ON fa.date_id = dd.date_id
    JOIN dim_patient AS dp ON fa.patient_key = dp.patient_key
    WHERE dpm.payment_type = 'MonthlyPackage'
    GROUP BY fa.patient_key, dd.year_num, dd.month_num
),
conflicts AS(
    SELECT COUNT(*) AS total
    FROM monthly_billing
    WHERE total_billing > (package_price * sessions_per_week)
       OR total_billing IS NULL
       OR package_price IS NULL
)
SELECT total
FROM conflicts;