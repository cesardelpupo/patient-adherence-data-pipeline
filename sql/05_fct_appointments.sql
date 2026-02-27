-- ================================================================
-- Arquivo: fct_appointments.sql
-- Criado por: [Cesar Del Pupo]
-- Última Atualização: 2026-02-27
-- Descrição: Tabela fato, com a granularidade por atendimentos
-- 1 linha = 1 atendimento
-- ================================================================

CREATE TABLE fct_appointments(
	-- chave primária técnica
    fact_key            INTEGER     PRIMARY KEY AUTOINCREMENT,
    
    -- chave de origem
    appointment_id      TEXT        NOT NULL UNIQUE,
    
    -- chaves estrangeiras
    date_id             INTEGER     NOT NULL,
    patient_key         INTEGER     NOT NULL,
    payment_model_id    INTEGER     NOT NULL,
    
    -- flagas
    attended_flag       INTEGER     NOT NULL CHECK (attended_flag IN (0, 1)),
    missed_flag         INTEGER     NOT NULL CHECK (missed_flag IN (0, 1)),
    
    -- métricas financeiras
    session_value       REAL        NOT NULL DEFAULT 0.0,                   
    revenue_realized    REAL        NOT NULL DEFAULT 0.0,
    revenue_lost        REAL        NOT NULL DEFAULT 0.0,

    FOREIGN KEY (date_id)           REFERENCES dim_date(date_id),
    FOREIGN KEY (patient_key)       REFERENCES dim_patient(patient_key),
    FOREIGN KEY (payment_model_id)  REFERENCES dim_payment_model(payment_model_id)
);

INSERT INTO fct_appointments(
    appointment_id, date_id, patient_key, 
    payment_model_id, attended_flag, missed_flag, 
    session_value, revenue_realized, revenue_lost 
)
WITH ranked_sessions AS (
	SELECT
		stg.appointment_id,
		stg.date_id,
		stg.patient_id,
		stg.payment_type,
		stg.attended_flag,
		stg.missed_flag,
		dd.year_num,
		dd.month_num,
		-- Função para ranquear os atendimentos de cada paciente por mês.
		ROW_NUMBER() OVER (
			PARTITION BY stg.patient_id, dd.year_num, dd.month_num
			ORDER BY stg.appointment_date ASC, stg.appointment_id ASC) AS session_rank
	FROM staging_appointments AS stg
	JOIN dim_date AS dd ON stg.date_id = dd.date_id		
)
SELECT
	rs.appointment_id,
	rs.date_id,
	dp.patient_key,
	dpm.payment_model_id,
	rs.attended_flag,
	rs.missed_flag,
/* 
Regra de atribuição de receita por sessão:

session_value
- Representa o valor contratual da sessão, independente da presença do paciente.

PerSession
- Cada sessão recebe o valor integral definido em dim_payment_model.price.

MonthlyPackage
- Apenas a primeira sessão do paciente no mês recebe o valor total do pacote.
- As demais sessões do pacote recebem valor 0 para evitar duplicação de receita.
- feat.: Adicionado a multiplicação pelo número de sessões semanais contratadas (sessions_per_week) 
para refletir o valor total do pacote mensal, considerando a frequência semanal acordada.
- Tem como objetivo garantir que o valor do pacote seja contabilizado apenas uma vez por período.
*/
	CASE 
		WHEN dpm.payment_type = 'PerSession'
		THEN dpm.price
		
		WHEN dpm.payment_type = 'MonthlyPackage' AND rs.session_rank = 1
		THEN dpm.price * dp.sessions_per_week
		
		ELSE 0.0
	END AS session_value,
/*
Regra de reconhecimento da receita realizada:

PerSession
- A receita é reconhecida somente se o paciente compareceu a sessão (attended_flag = 1)

MonthlyPackage
- A receita é reconhecida uma vez por mês para cada paciente.
- Aplicada a 1ª sessão cronológica do mês (session_rank = 1)
- O atendimento não depende de presença, visto que o pacote mensal é cobrado antecipadamente. 
- feat: Adicionado a multiplicação pelo número de sessões semanais contratadas (sessions_per_week) 
para refletir o valor total do pacote mensal, considerando a frequência semanal acordada.

Todos os outros casos retornam 0.0, para evitar dupla contagem de receita.
*/
	CASE 
		WHEN dpm.payment_type = 'PerSession' AND rs.attended_flag = 1
		THEN dpm.price
		
		WHEN dpm.payment_type = 'MonthlyPackage' AND rs.session_rank = 1
		THEN dpm.price * dp.sessions_per_week
		
		ELSE 0.0
	END AS revenue_realized,
/*
Regra de reconhecimento da receita perdida:

PerSession
- A receita é reconhecida somente se o paciente faltou a sessão (missed_flag = 1)

MonthlyPackage
- Não é aplicada ao pacote, pois o paciente sempre paga o pacote completo e retorna 0.0, 
para evitar contagem indevida de receita.
*/
	CASE 
		WHEN dpm.payment_type = 'PerSession' AND rs.missed_flag = 1
		THEN dpm.price
		
		ELSE 0.0 
	END AS revenue_lost	
FROM ranked_sessions AS rs
JOIN dim_patient AS dp ON rs.patient_id = dp.patient_id 
JOIN dim_payment_model AS dpm  ON rs.payment_type = dpm.payment_type;

-- ================================================================
-- INDEXES: Índices para performance no SQL
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_fact_date                ON fct_appointments(date_id);
CREATE INDEX IF NOT EXISTS idx_fct_patient              ON fct_appointments(patient_key);
CREATE INDEX IF NOT EXISTS idx_fct_payment_model        ON fct_appointments(payment_model_id);