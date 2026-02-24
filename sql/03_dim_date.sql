-- ================================================================
-- Arquivo: dim_date.sql
-- Criado por: [Cesar Del Pupo]
-- Última Atualização: 2026-02-17
-- Descrição: Dimensão calendário, com todas as datas do período
-- analisado (2022-2023).
-- ================================================================

DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date(
	date_id				INTEGER		PRIMARY KEY,
	full_date			TEXT		NOT NULL UNIQUE,
	year_num			INTEGER		NOT NULL,
	semester_num		INTEGER 	NOT NULL,
	quarter_num			INTEGER 	NOT NULL,
	month_num			INTEGER 	NOT NULL,
	month_name			TEXT		NOT NULL,
	month_date			TEXT		NOT NULL,
	day_num				INTEGER		NOT NULL,
	day_of_year			INTEGER 	NOT NULL,
	week_of_year		INTEGER 	NOT NULL,
	weekday_num			INTEGER 	NOT NULL,
	weekday_name		TEXT		NOT NULL,
	is_business_day		INTEGER	NOT NULL DEFAULT 0
);

INSERT INTO dim_date(
	date_id, full_date, year_num, semester_num, quarter_num,
	month_num, month_name, month_date, day_num, day_of_year,
	week_of_year, weekday_num, weekday_name, is_business_day
)
WITH RECURSIVE dates(date) AS(
	VALUES('2022-01-01')
	UNION ALL
	SELECT date(date, '+1 day')
	FROM dates
	WHERE JULIANDAY(date) < JULIANDAY('2023-12-31')
),
date_parts AS(
	SELECT
		date,
		CAST(STRFTIME('%Y%m%d', date)       AS INTEGER) 	AS date_id,
		CAST(STRFTIME('%Y', date)           AS INTEGER) 	AS year_num,
		CAST(STRFTIME('%m', date)           AS INTEGER)		AS month_num,
		CAST(STRFTIME('%d', date)           AS INTEGER)		AS day_num,
		CASE CAST(STRFTIME('%w', date)      AS INTEGER)
            WHEN 0 THEN 7
            ELSE CAST(STRFTIME('%w', date)  AS INTEGER)
        END                                                 AS weekday_num,
		CAST(STRFTIME('%j', date)           AS INTEGER)		AS day_of_year,
		CAST(STRFTIME('%W', date)           AS INTEGER)		AS week_of_year
	FROM dates
)
SELECT
	date_id,
	date AS full_date,
	year_num,
	CASE  
		WHEN month_num <= 6 THEN 1
		ELSE 2
	END AS semester_num,
	CASE
		WHEN month_num <= 3 THEN 1
		WHEN month_num <= 6 THEN 2
		WHEN month_num <= 9 THEN 3
		ELSE 4
	END AS quarter_num,
	month_num,
	CASE month_num
		WHEN 1 THEN 'January'
		WHEN 2 THEN 'February'
		WHEN 3 THEN 'March'
		WHEN 4 THEN 'April'
		WHEN 5 THEN 'May'
		WHEN 6 THEN 'June'
		WHEN 7 THEN 'July'
		WHEN 8 THEN 'August'
		WHEN 9 THEN 'September'
		WHEN 10 THEN 'October'
		WHEN 11 THEN 'November'
		WHEN 12 THEN 'December'
	END AS month_name,
	STRFTIME('%Y-%m-01', date) AS month_date,
	day_num,
	day_of_year,
	week_of_year,
	weekday_num,
	CASE weekday_num
		WHEN 1 THEN 'Monday'
		WHEN 2 THEN 'Tuesday'
		WHEN 3 THEN 'Wednesday'
		WHEN 4 THEN 'Thursday'
		WHEN 5 THEN 'Friday'
		WHEN 6 THEN 'Saturday'
		WHEN 7 THEN 'Sunday'
	END AS weekday_name,
	CASE 
		WHEN weekday_num BETWEEN 1 AND 5 THEN 1
		ELSE 0
	END AS is_business_day
FROM date_parts;

-- ================================================================
-- INDEXES: Índices para performance no SQL
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_date_year_month ON dim_date(year_num, month_num);
CREATE INDEX IF NOT EXISTS idx_date_business   ON dim_date(is_business_day);
