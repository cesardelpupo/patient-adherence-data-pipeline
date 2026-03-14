-- ================================================================
-- Arquivo: dim_payment_model.sql
-- Criado por: [Cesar Del Pupo]
-- Última Atualização: 2026-02-19
-- Descrição: Dimensão de modelos de pagamento da clínica.
-- ================================================================

CREATE TABLE dim_payment_model(
	payment_model_key	INTEGER		PRIMARY KEY,			-- 1 = PerSession | 2 = MonthlyPackage
	payment_type		TEXT		NOT NULL UNIQUE,		-- Nome do modelo (único): PerSession, MonthlyPackage
	price				REAL		NOT NULL,				-- Valor financeiro do modelo: R$ 50 (PerSession), R$ 200 (MonthlyPackage)
	is_fixed_revenue	INTEGER		NOT NULL DEFAULT 0,		-- 0 = receita variável | 1 = receita fixa
	implemented_year	INTEGER		NOT NULL,				-- Ano que o modelo entrou em vigor
	description			TEXT		NOT NULL				-- Descrição do modelo
);

-- ================================================================
-- INSERT: dim_payment_model
-- ================================================================

INSERT INTO dim_payment_model (
	payment_model_key, payment_type, price, is_fixed_revenue,
	implemented_year, description
)
VALUES 
	(1, 'PerSession', 50.0, 0, 2022, 'Cobrança por sessão realizada. Receita variável conforme presença.'),
	(2, 'MonthlyPackage', 200.0, 1, 2023, 'Pacote mensal fixo. Receita garantida independente de faltas.');