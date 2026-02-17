# src/transform_data.py

import pandas as pd
import logging

logger = logging.getLogger(__name__)

# ================================================================
# LIMPEZA
# ================================================================

def clean(df: pd.DataFrame) -> pd.DataFrame:
    """
    Limpa o dataframe bruto
    
    Etapas:
    - Limpar e padronizar campos de string
    - Renomear colunas
    - Tratar valores nulos
    - Remover appointment_id duplicados
    - Converter a coluna appointment_date para datetime
    - Ordernar dataframe

    Returns:
        pd.DataFrame: dataframe limpo
    """
    df = df.copy()
    
    # 01. Strings manipulation (trim + capitalize)
    df['appointment_status'] = df['appointment_status'].str.strip()
    df['payment_type'] = df['payment_type'].str.strip()
    df['appointment_id'] = df['appointment_id'].str.strip().str.upper()
    df['patient_id'] = df['patient_id'].str.strip().str.upper()
    
    # 02. Renomear a coluna price para appointment_price
    df = df.rename(columns={'price': 'appointment_price'})
    
    #03. Remover nulos em appointment_price
    df['appointment_price'] = df['appointment_price'].fillna(0).astype(float)
        
    # 04. Remover valores duplicados em appointment_id
    before = len(df)
    df = df.drop_duplicates(subset=['appointment_id'])
    removed = before - len(df)
    if removed > 0:
        logger.warning(f'{removed} valores duplicados removidos.')
        
    # 05. Converter data (datetime)
    df['appointment_date'] = pd.to_datetime(df['appointment_date'], dayfirst=True)
    
    # 06. Ordernar dataFrame
    df = df.sort_values(['patient_id', 'appointment_date']).reset_index(drop=True)
    
    logger.info(f'Limpeza concluída: {len(df)} registros.')
    return df

# ================================================================
# FEATURES
# ================================================================

def features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Criar features para análise:
    
    Features adicionadas:
    - Flag de status (attended_flag, missing_flag)
    - Flag de tipo de pagamento (is_package)
    - Colunas temporais (year, month_num, month_name, month_date, weekday_num, weekday_name) 
    
    Returns:
        pd.DataFrame: dataframe enriquecido com novas features
    """
    df = df.copy()
    
    # 01. Flags de status
    # 1 = Attended | 0 = Missed
    df['attended_flag'] = (df['appointment_status'] == 'Attended').astype(int)
    
    # 1 = Missed | 0 = Attended
    df['missed_flag'] = (df['appointment_status'] == 'Missed').astype(int)
    
    # 02. Flag de tipo de pagamento
    # 1 = MonthlyPackage | 0 = PerSession 
    df['is_package'] = (df['payment_type'] == 'MonthlyPackage').astype(int)
    
    # 03. Colunas temporais
    df['date_id']      = df['appointment_date'].dt.strftime('%Y%m%d').astype(int)
    df['year']         = df['appointment_date'].dt.year
    df['month_num']    = df['appointment_date'].dt.month
    df['month_name']   = df['appointment_date'].dt.strftime('%B')
    df['month_date']   = df['appointment_date'].dt.strftime('%Y-%m')
    df['weekday_num']  = df['appointment_date'].dt.weekday + 1        # (1= Segunda, 7=Domingo)
    df['weekday_name'] = df['appointment_date'].dt.strftime('%A')     # ('Monday', 'Sunday')
    
    # 03. Data como string para SQLite
    # SQLite não tem tipo 'date' nativo
    df['appointment_date'] = df['appointment_date'].dt.strftime('%Y-%m-%d')
    
    logger.info(f'Enriquecimento com features concluído: {len(df.columns)}')
    return df

# ================================================================
# FUNÇÃO PRINCIPAL
# ================================================================

def transform(df_raw: pd.DataFrame) -> pd.DataFrame:
    """
    Limpa o dataframe bruto e adiciona novas features analíticas.

    Returns:
        pd.DataFrame: Dataset final, pronto para a carga.
    """
    
    df = clean(df_raw)
    df = features(df)  

    logger.info(f'Transformação concluída: '
                f'{len(df)} linhas | {len(df.columns)} colunas')
    return df

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    from extract_data import extract
    df_raw = extract()
    staging = transform(df_raw)
    print(staging.head())