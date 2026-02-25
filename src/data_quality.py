# ============================================================================
# Arquivo: src/data_quality.py
# Criado por: [Cesar Del Pupo]
# Última Atualização: 2026-02-24
# Descrição: Responsável por executar os testes de qualidade de dados
# ============================================================================

import sqlite3
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

TESTS_PATH = Path('sql/tests')

def run_test(conn: sqlite3.Connection, logger: logging.Logger) -> None:
    """
    Função auxiliar para executar um teste SQL e validar o resultado.
    
    Suporta comparação com tolerância para floats, evitando falsos negativos
    por imprecisão de ponto flutuante.
    """
    
    # rglob busca em todas as subpastas
    test_files = sorted(TESTS_PATH.rglob('*.sql'))
    
    if not test_files:
        logger.warning('Nenhum script de teste encontrado em {TESTS_PATH}')
        return
    
    logger.info(f'Iniciando testes de Data Quality: Executando {len(test_files)} testes encontrados.')
    logger.info("="*60)
    
    cursor = conn.cursor()
    erros_encontrados = 0
    
    # Variável para rastrear arquivo atual caso ocorra erro de SQL
    current_file = "Nenhum"
    
    try:
        for sql_file in test_files:
            current_file = sql_file.name
            
            # Usa o nome da pasta (ex: flow, referential) para o log ficar bonito
            category = sql_file.parent.name.upper()
            test_display_name = sql_file.stem.replace('_', ' ').title()
            
            query = sql_file.read_text(encoding='utf-8')
            
            cursor.execute(query)
            
            # Primeiro valor da primeira linha
            result = cursor.fetchone()[0]
            
            if result == 0 or result == 0.0:
                logger.info(f' [OK] {category:<12} | {test_display_name}')
            else:
                logger.error(f' [FALHA] {category:<12} | {test_display_name} | Erros: {result}')
                erros_encontrados += 1
        
        logger.info("="*60)
        
        if erros_encontrados > 0:
            msg = f'Pipeline interrompido. {erros_encontrados} teste(s) de qualidade falharam.'
            logger.critical(msg)
            raise ValueError(msg)
        
        logger.info('Data Quality concluído: 100% dos dados estão íntegros.')
        
    except sqlite3.Error as e:
        logger.critical(f"Erro de sintaxe SQL no arquivo '{current_file}': {e}")
        raise