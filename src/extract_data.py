# src/extract_data.py

import pandas as pd
from pathlib import Path
import logging

logger = logging.getLogger(__name__)

# ================================================================
# CONFIG 
# ================================================================

RAW_PATH = Path('data/raw/appointments_raw.csv')

# Colunas esperadas
EXPECTED_COLUMNS = {
    'appointment_id',
    'appointment_date',
    'appointment_status',
    'patient_id',
    'price',
    'payment_type',
    'sessions_per_week'
}

# Status válidos
VALID_STATUS = {'Attended', 'Missed'}

# Tipos de pagamentos válidos
VALID_PAYMENT_TYPES = {'PerSession', 'MonthlyPackage'}

# ================================================================
# FUNÇÕES
# ================================================================

def load_raw(path: Path = RAW_PATH) -> pd.DataFrame:
    """
    Lê o arquivo CSV bruto sem reazkuzar transformações.

    Raises:
        FileNotFoundError: Caso o arquivo não seja encontrado.

    Returns:
        pd.DataFrame: DataFrame contendo dados brutos de atendimentos.
    """
    
    if not path.exists():
        raise FileNotFoundError(f'Arquivo não encontrado: {path}')
    
    df = pd.read_csv(path)
    logger.info(f'CSV lido: {len(df)} linhas | {len(df.columns)} colunas.')
    return df

def validate_data(df: pd.DataFrame) -> None:
    """
    Valida se o CSV tem o formato esperado:
    
    Verifica:
    - Presença das colunas obrigatórias (EXPECTED_COLUMNS)
    - Valores válidos em appointments_status e payment_type (VALID_STATUS / PAYMENT_STATUS)

    Raises:
        ValueError: Caso o dataset não esteja conforme o padrão esperado.
    """
    # 1. Verificar colunas obrigatórias
    missing = EXPECTED_COLUMNS - set(df.columns)
    if missing:
        raise ValueError(f'Colunas faltando: {missing}')
    
    # 2. Verificar valores válidos em colunas categóricas
    invalid_status = set(df['appointment_status'].dropna().unique()) - VALID_STATUS
    if invalid_status:
        raise ValueError(f'appointment_status inválido: {invalid_status}')
        
    invalid_payment = set(df['payment_type'].dropna().unique()) - VALID_PAYMENT_TYPES
    if invalid_payment:
        raise ValueError(f'payment_type inválido: {invalid_payment}')
    
    # 3. Mensagem caso esteja conforme padrão.
    logger.info('Input data validado com sucesso.')    

# ================================================================
# FUNÇÃO PRINCIPAL
# ================================================================

def extract(path: Path = RAW_PATH) -> pd.DataFrame:
    """
    Extrai e valida os dados do CSV bruto.

     Returns:
        pd.DataFrame: DataFrame validado, pronto para transformação.
    """
    
    df = load_raw(path)
    validate_data(df)
    return df

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    df = extract()
    print(df.head())