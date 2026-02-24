# src/load_data.py

import sqlite3
import pandas as pd
from pathlib import Path
import logging

logger = logging.getLogger(__name__)

# ================================================================
# CONFIG 
# ================================================================

DB_PATH = Path('data/appointments_analytics.db')
SQL_PATH = Path('sql')

# ================================================================
# FUNÇÕES
# ================================================================

def get_connection(db_path: Path = DB_PATH) -> sqlite3.Connection:
    """
    Criar conexão com o banco de dados SQLite3

    - Garante que as pasta do banco de dados exista
    - Abre conexão com o banco de dados
    - Habilita o suporte a Foreign keys

    Returns:
        sqlite3.Connection: Conexão ativa com o banco de dados
    """
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA foreign_keys = ON")
    logger.info(f'Conectado: {db_path}')
    return conn

def run_sql_file(conn: sqlite3.Connection, sql_file: Path) -> None:
    """
    Executa script do arquivo .sql no banco de dados. 
    
    Lê o arquivo SQL e executa todos os comandos usando executescript().

    Raises:
        FileNotFoundError: Se o arquivo não existir
        ValueError: Se o arquivo não for em formato .sql
    """
    sql_file = Path(sql_file)
    
    if not sql_file.exists():
        raise FileNotFoundError(f'SQL não encontrado: {sql_file}')
    
    if sql_file.suffix != ".sql":
        raise ValueError(
            f'Arquivo precisa ser .sql\n'
            f'Recebido: {sql_file}\n'
            f'Tipo: {type(sql_file)}\n'
            f'Suffix: {sql_file.suffix!r}'
        )
     
    sql = sql_file.read_text(encoding='utf-8')
    conn.executescript(sql)
    logger.info(f'Executado: {sql_file.name}')

def load_staging(conn: sqlite3.Connection, df: pd.DataFrame, if_exists: str = 'replace') -> None:
    """
    Carrega o dataframe na tabela staging_appointments.
    
    - Limpa a tabela staging
    - Insere os registros do dataframe no SQLite3
    """
    cursor = conn.cursor()
    
    # 1. Busca colunas da tabela existente
    cursor.execute(
        """
        SELECT name FROM pragma_table_info('staging_appointments')
        """
    )
    existing_cols = [row[0] for row in cursor.fetchall()]
    
    # 2. Compara com colunas do DataFrame
    df_cols = list(df.columns)
    
    # 3. Se diferentes ou tabela não existe → recria
    if not existing_cols: 
        logger.info('Tabela staging não existe. Criando...')
        run_sql_file(conn, SQL_PATH / '00_stg_appointments.sql')
        
    elif set(df_cols) != set(existing_cols):
        logger.info(f'Schema da staging mudou. Recriando tabela...')
        conn.execute('DROP TABLE IF EXISTS staging_appointments')
        conn.commit()
        run_sql_file(conn, SQL_PATH / '00_drop_all.sql')
    
    # 4. Limpa dados antigos
    conn.execute("DELETE FROM staging_appointments")
    conn.commit()
    
    # 5. Insere dados novos
    df.to_sql(
        name        = 'staging_appointments',
        con         = conn,
        if_exists   = 'append',
        index       = False
        )
    logger.info(f'Staging carregada: {len(df)} registros.')
    
def verify(conn: sqlite3.Connection) -> None:
    """
    Executa verificações de validação na tabela staging.
    
    Exibe as seguintes estatísticas:
    - Quantidade de registros
    - Total de attended / missed
    - Pacientes únicos
    - Tipos de pagamentos únicos
    - Intervalo de datas
    """
    cursor = conn.cursor()
    cursor.execute("""
        SELECT
            COUNT(*)                        AS total,
            SUM(attended_flag)              AS attended,
            SUM(missed_flag)                AS missed,             
            COUNT(DISTINCT patient_id)      AS patients,
            COUNT(DISTINCT payment_type)    AS payment_types,
            MIN(appointment_date)           AS first_date,
            MAX(appointment_date)           AS last_date
        FROM staging_appointments
""")
    row = cursor.fetchone()
    labels = ['Total', 'Attended', 'Missed','Patients','Payments Types','First Date','Last Date']
    print("\n ===== STAGING SUMMARY =====")
    if row:
        for label, value in zip(labels, row):
            print(f' {label:<15} {value}')
    else:
        print('Tabela vazia!')
        
# ================================================================
# FUNÇÃO PRINCIPAL
# ================================================================
        
def load(df: pd.DataFrame, db_path: Path = DB_PATH) -> None:
    """
    Executa todo o processo de carga no SQLite3
    
    Etapas:
    - Abre conexão com o bando de dados
    - Executa scrpit para criar estrutura via SQL
    - Carrega dados na stating
    - Validação dos dados carregados.
    - Confirmar mudanças (commit)
    
    Raise:
        Exception: reverte a transação em caso de falha.    
    """
    conn = get_connection(db_path)
    
    try:
        # 01. Cria estrutura via SQL
        run_sql_file(conn, SQL_PATH / '00_drop_all.sql')
        
        # 02. Carga dos dados
        load_staging(conn, df)
        
        # 03. Verificação
        verify(conn)
        
        conn.commit()
        logger.info('Load concluído')
    
    except Exception as e:
        conn.rollback()
        logger.error(f'Erro no load, rollback executado: {e}')
        raise
    
    finally:
        conn.close()
        
if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    verify_only = get_connection()
    verify(verify_only)
    verify_only.close()