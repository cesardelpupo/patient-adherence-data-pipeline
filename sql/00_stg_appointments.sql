-- ================================================================
-- STAGING: estrutura base
-- ================================================================

CREATE TABLE IF NOT EXISTS staging_appointments(
    appointment_id      TEXT    PRIMARY KEY,
    date_id             INTEGER NOT NULL,
    appointment_date    TEXT    NOT NULL,
    appointment_status  TEXT    NOT NULL,
    patient_id          TEXT    NOT NULL,
    appointment_price   REAL,
    payment_type        TEXT    NOT NULL,
    attended_flag       INTEGER NOT NULL,
    missed_flag         INTEGER NOT NULL,
    is_package          INTEGER NOT NULL,
    year_num            INTEGER NOT NULL,
    month_num           INTEGER NOT NULL,
    month_name          TEXT,
    month_date          TEXT,
    weekday_num         INTEGER,
    weekday_name        TEXT
);

-- ================================================================
-- INDEXES: Índices para performance no SQL
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_stg_patient ON staging_appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_stg_date    ON staging_appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_stg_month   ON staging_appointments(month_date);
CREATE INDEX IF NOT EXISTS idx_stg_status  ON staging_appointments(appointment_status);
CREATE INDEX IF NOT EXISTS idx_stg_type    ON staging_appointments(payment_type);