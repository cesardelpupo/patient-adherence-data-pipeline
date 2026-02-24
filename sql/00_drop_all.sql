-- ================================================================
-- Arquivo: drop_all.sql
-- Criado por: [Cesar Del Pupo]
-- Última Atualização: 2026-02-23
-- Descrição: Remove todas as tabelas e views existentes.
-- ================================================================

-- remover as views
DROP VIEW IF EXISTS mart_patient_behavior;
DROP VIEW IF EXISTS mart_monthly_performance;

-- remover a tabela filha (fato)
DROP TABLE IF EXISTS fct_appointments;

-- remover dimensões
DROP TABLE IF EXISTS dim_payment_model;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_patient;   