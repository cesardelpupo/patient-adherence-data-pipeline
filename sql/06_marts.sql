-- ================================================================
-- Arquivo: marts.sql
-- Criado por: [Cesar Del Pupo]
-- Última Atualização: 2026-02-23
-- Descrição: Views analíticas para responder perguntas de negócio
-- sobnre transição de modelo de pagamento (performance mensal e 
-- comportamento do paciente) e impacto financeiro.
-- ================================================================

-- ================================================================
-- MART 1: Desempenho Mensal e Financeiro (O "Painel do Dono")
-- Grão: 1 linha por Ano / Mês / Tipo de Pagamento
-- Objetivo: Visualizar como a transição de modelo de pagamento em 
-- 2023 isolou o financeiro da clínica das faltas dos pacientes.
-- ================================================================

CREATE VIEW mart_monthly_performance AS
SELECT
	dd.month_num,
	dd.year_num,
	dpm.payment_type,
	
	-- Métricas operacionais:
	COUNT(*)		 				            AS total_scheduled, 
	SUM(fa.attended_flag) 			            AS total_attended,	
	SUM(fa.missed_flag ) 			            AS total_missed,
	
	-- Métricas Financeiras
	SUM(fa.revenue_realized) 		            AS total_revenue_realized,
	SUM(fa.revenue_lost) 			            AS total_revenue_lost,
	SUM(fa.revenue_realized)
	+ SUM(fa.revenue_lost)				        AS total_revenue_expected,
	
	-- KPI: Taxa de não comparecimento da sessão agendada (%):
	ROUND(
		CAST(SUM(fa.missed_flag) AS REAL) 
        / NULLIF(COUNT(fa.appointment_key),0)*100,2)   AS no_show_rate
FROM fct_appointments AS fa
JOIN dim_date AS dd ON fa.date_key = dd.date_key
JOIN dim_payment_model AS dpm ON fa.payment_model_key = dpm.payment_model_key 
GROUP BY
	dd.month_num,
	dd.year_num, 
	dpm.payment_type;

-- ================================================================
-- MART 2: Comportamento Anual por Paciente (O "Raio-X")
-- Grão: 1 linha por Paciente / Ano / Tipo de Pagamento
-- Objetivo: Identificar o aumento ou queda de comprometimento
-- dos pacientes ao longo da transição de modelo.
-- ================================================================

CREATE VIEW mart_patient_behavior AS
SELECT
	dp.patient_id,
	dd.year_num,
	dpm.payment_type,
	
	--Histórico de sessões do paciente
	COUNT(*) 					                AS total_sessions_scheduled,
	SUM(fa.attended_flag) 		                AS total_sessions_attended,
	SUM(fa.missed_flag) 		                AS total_sessions_missed,
	
	-- KPI: Taxa de faltas (%)
	ROUND(
		CAST(SUM(fa.missed_flag) AS REAL) 
        / NULLIF(COUNT(fa.appointment_key),0)*100,2)   AS patient_no_show_rate,
	
	-- Life time value (LTV) de cada paciente por ano
	SUM(fa.revenue_realized) 	                AS total_paid_by_patient
FROM fct_appointments AS fa
JOIN dim_date AS dd ON fa.date_key = dd.date_key
JOIN dim_payment_model AS dpm ON fa.payment_model_key = dpm.payment_model_key
JOIN dim_patient AS dp ON fa.patient_key = dp.patient_key
GROUP BY
	dp.patient_id,
	dd.year_num,
	dpm.payment_type;