-- ================================================================
-- Arquivo: dim_patient.sql
-- Criado por: [Cesar Del Pupo]
-- Última Atualização: 2026-02-22
-- Descrição: Perfil de cada paciente.
-- ================================================================

CREATE TABLE dim_patient(
	patient_key				INTEGER PRIMARY KEY AUTOINCREMENT, 	-- SK para estabilidade nos JOIN e BI performance
	patient_id				TEXT NOT NULL UNIQUE,
	first_appointment		TEXT NOT NULL,						-- Data do primeiro registro de atendimento do período analisado
	last_appointment		TEXT NOT NULL,						-- Data do atendimento mais recente do período analisado
	active_years			TEXT,								-- Anos distintos em atendimento no período analisado
	current_payment_model	TEXT,								-- Mais recente modelo de pagamento baseado no último atendimento
	patient_status			TEXT NOT NULL						-- Classificação temporal: Novo, retido, perdido e fatore_externos (P004)
);

INSERT INTO dim_patient(
	patient_id, first_appointment, last_appointment,
	active_years, current_payment_model, patient_status
)
WITH patient_base AS(
	SELECT
		-- métricas base por paciente
		patient_id,
		MIN(appointment_date) AS first_appointment,
		MAX(appointment_date) AS last_appointment,
		
		-- quais anos cada paciente esteve ativo
		GROUP_CONCAT(DISTINCT dd.year_num) AS active_years,
		MAX(CASE WHEN dd.year_num = 2022 THEN 1 ELSE 0 END) AS in_2022,
		MAX(CASE WHEN dd.year_num = 2023 THEN 1 ELSE 0 END) AS in_2023
	FROM staging_appointments AS stg
	JOIN dim_date AS dd ON stg.date_id = dd.date_id
	GROUP BY patient_id
),
-- seleciona o tipo de pagamento atual de cada paciente.
patient_model AS(
	SELECT
		patient_id,
		payment_type,
		/*
		numera atendimentos por paciente do mais recente para o mais antigo.
        rn = 1 representa o último atendimento.
		*/
        ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY appointment_date DESC, appointment_id DESC) AS rn
	FROM staging_appointments
)
SELECT
	pb.patient_id,
	pb.first_appointment,
	pb.last_appointment,
	pb.active_years,
	pm.payment_type AS current_payment_model,
/*
Regra de status do paciente:

Retained
- Pacientes ativos em 2022 em 2023.

Churned
- Pacientes ativos em 2022 mas inativos a partir de 2023.

New
- Paciente ativos somente a partir de 2023.

External_Factor
- Caso classificado manualmente (P004) para teste de sensibilidade analítica
- Usado para avaliar o comportamento da taxa de abstenção, excluindo casos atípicos.

Unknown
- Outros cenários não cobertos pelas regras acima definidas.
*/
	CASE
		WHEN pb.patient_id = 'P004' THEN 'External_Factor'
		WHEN pb.in_2022 = 1 AND pb.in_2023 = 1 THEN 'Retained'
		WHEN pb.in_2022 = 1 AND pb.in_2023 = 0 THEN 'Churned'
		WHEN pb.in_2022 = 0 AND pb.in_2023 = 1 THEN 'New'
		ELSE 'Unknown'
	END AS patient_status
FROM patient_base AS pb 
JOIN patient_model AS pm ON pb.patient_id = pm.patient_id
WHERE pm.rn = 1;

-- ================================================================
-- INDEXES: Índices para performance no SQL
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_patient_status   ON dim_patient(patient_status);