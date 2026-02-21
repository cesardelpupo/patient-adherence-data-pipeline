# pipeline.py

import logging
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "src"))

from extract_data import extract
from transform_data import transform
from load_data import load, get_connection, run_sql_file

SQL_PATH = Path('sql')

# ================================================================
# LOGGING
# ================================================================

def setup_logging() -> logging.Logger:
    """
    Configura o sistema de logging do pipeline:
    - Cria a pasta de logs, caso não exista
    - Define o formato padrão de logs
    - Envia logs para console e arquivo
    - Gera arquivo com timestamp único

    Returns:
        logging.Logger: logger configurado para o pipeline.
    """
    Path("logs").mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_format = "%(asctime)s | %(levelname)-8s | %(message)s"
    
    logging.basicConfig(
        level = logging.INFO,
        format = log_format,
        handlers = [
            logging.StreamHandler(sys.stdout),
            logging.FileHandler(
                f'logs/pipeline_{timestamp}.log', encoding='utf-8'
            )
        ]
    )
    return logging.getLogger('pipeline')

# ================================================================
# EXECUTAR SQL (PÓS-STAGING)
# ================================================================

def run_sql_scripts(logger: logging.Logger) -> None:
    """
    Executa scripts SQL adicionais após a carga de staging:
    - Procura arquivos .sql na pasta /sql
    - Ignora arquivos que começam com '00_' (ex: staging)
    - Executa scripts em ordem alfabética
    - Aplica commit ao final.

    Raise:
        Exception: caso algum script SQL falhe
    """
    sql_files = sorted([f for f in SQL_PATH.glob('*.sql')
                        if not f.name.startswith('00_')
    ])

    if not sql_files:
        logger.info('Nenhum script SQL adicional encontrando em sql/')
        return
    
    from load_data import get_connection, run_sql_file
    conn = get_connection()
    
    try:
        for sql_file in sql_files:
            logger.info(f'Executando: {sql_file.name}')
            run_sql_file(conn, sql_file)
        conn.commit()
        logger.info(f'{len(sql_files)} script(s) SQL executado(s)')
    
    except Exception as e:
        conn.rollback()
        logger.error(f'Erro ao executar SQL: {e}')
        raise

    finally:
        conn.close()

# ================================================================
# PIPELINE
# ================================================================

def run():
    """
    Orquestra o pipeline completo de dados (ETL):
    
    Etapas:
    1. Extract -> leitura e validação do CSV
    2. Transform -> limpeza e criação de features
    3. Load -> carga na staging do SQlite
    4. SQL scripts -> criação de dimensões, fatos e views.
    
    Controla:
    - logging do processo
    - tempo de execução
    - tratamento de erros
    - encerramento seguro do pipeline
    
    Raises:
        SystemExit: encerra execução em caso de erro crítico.     
    """
    logger = setup_logging()
    start = datetime.now()
    
    logger.info("=" * 50)
    logger.info("APPOINTMENT ANALYTICS PIPELINE")
    logger.info("=" * 50)
    
    try:
        # EXTRACT
        logger.info("[1/4] EXTRACT")
        df_raw = extract()
        
        # TRANSFORM
        logger.info("[2/4] TRANSFORM")
        staging = transform(df_raw)
        
        # LOAD (staging apenas)
        logger.info("[3/4] LOAD -> staging_appointments")
        load(staging)
        
        # SQL SCRIPTS (dims, facts, rules, views)
        logger.info('[4/4] SQL SCRIPTS')
        run_sql_scripts(logger)
        
        # RESUMO
        elapsed = (datetime.now() - start).total_seconds()
        logger.info("=" * 50)
        logger.info(f'CONCLUÍDO em {elapsed:.2f}s')
        logger.info("=" * 50)
        
    except FileNotFoundError as e:
        logger.error(f'Arquivo não encontrado: {e}')
        sys.exit(1)
        
    except ValueError as e:
        logger.error(f'Erro de validação: {e}')
        sys.exit(1)
        
    except Exception as e:
        logger.error(f'Erro inesperado: {e}', exc_info=True)
        sys.exit(1)
        
if __name__ == "__main__":
    run()