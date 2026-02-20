-- ================================================================
-- Arquivo: dim_patient.sql
-- Criado por: [Cesar Del Pupo]
-- Última Atualização: 2026-02-19
-- Descrição: Perfil de cada paciente.
-- ================================================================

DROP TABLE IF EXISTS dim_patient;

CREATE TABLE dim_patient(
	patient_key				INTEGER PRIMARY KEY AUTOINCREMENT,		
	patient_id				TEXT NOT NULL UNIQUE,
	first_appointment		TEXT NOT NULL,
	last_appointment		TEXT NOT NULL,
	active_years			TEXT,
	current_payment_model	TEXT,
	patient_status			TEXT NOT NULL
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
		GROUP_CONCAT(DISTINCT year_num) AS active_years,
		MAX(CASE WHEN year_num = 2022 THEN 1 ELSE 0 END) AS in_2022,
		MAX(CASE WHEN year_num = 2023 THEN 1 ELSE 0 END) AS in_2023
	FROM staging_appointments
	GROUP BY patient_id
),
patient_model AS(       -- seleciona o tipo de pagamento atual de cada paciente.
	SELECT
		patient_id,
		payment_type,
		-- numera atendimentos por paciente do mais recente para o mais antigo.
        -- rn = 1 representa o último atendimento.
        ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY appointment_date DESC, appointment_id DESC) AS rn
	FROM staging_appointments
)
SELECT
	pb.patient_id,
	pb.first_appointment,
	pb.last_appointment,
	pb.active_years,
	pm.payment_type AS current_payment_model,
	CASE
		WHEN pb.patient_id = 'P004' THEN 'External_Factor'
		WHEN pb.in_2022 = 1 AND pb.in_2023 = 1 THEN 'Retained'
		WHEN pb.in_2022 = 1 AND pb.in_2023 = 0 THEN 'Churned'
		WHEN pb.in_2022 = 0 AND pb.in_2023 = 1 THEN 'New'
		ELSE 'Unknown'
	END AS patient_type
FROM patient_base AS pb 
JOIN patient_model AS pm ON pb.patient_id = pm.patient_id
WHERE pm.rn = 1;

-- ================================================================
-- INDEXES: Índices para performance no SQL
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_patient_id       ON dim_patient(patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_status   ON dim_patient(patient_status);