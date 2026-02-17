-- ================================================================
-- dim_payment_model: Dimensão modelo de pagamento
-- Descreve os modelos de cobrança disponíveis.
-- ================================================================

DROP TABLE IF EXISTS dim_payment_model;

CREATE TABLE IF NOT EXISTS dim_payment_model(
	payment_model_id	INTEGER		PRIMARY KEY,
	payment_type		TEXT		NOT NULL UNIQUE,
	value				REAL		NOT NULL,
	is_fixed_revenue	INTEGER		NOT NULL DEFAULT 0,
	implemented_year	INTEGER		NOT NULL,
	description			TEXT		NOT NULL
);

-- ================================================================
-- INSERT: dim_payment_model
-- ================================================================

INSERT INTO dim_payment_model (
	payment_model_id, payment_type, value,
	is_fixed_revenue, implemented_year, description
)
VALUES 
	(1, 'PerSession', 50.0, 0, 2022, 
	'Cobrança por sessão realizada. Receita variável conforme presença.');

INSERT INTO dim_payment_model (
	payment_model_id, payment_type, value,
	is_fixed_revenue, implemented_year, description
)
VALUES 
	(2, 'MonthlyPackage', 200.0, 1, 2023,
	'Pacote mensal fixo. Receita garantida independente de faltas.');