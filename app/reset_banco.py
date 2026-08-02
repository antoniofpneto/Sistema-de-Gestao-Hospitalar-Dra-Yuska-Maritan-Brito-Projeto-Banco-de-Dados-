# reset_banco.py
import os
from sqlalchemy import text
from app import app, db


SCRIPTS_SQL = [
    "../sql/ddl/01_create_tables.sql",
    "../sql/ddl/02_stored_procedures.sql",
    "../sql/ddl/03_triggers.sql",
    "../sql/ddl/04_views.sql",
    "../sql/dml/01_dados_teste.sql"
]

def resetar_banco():
    with app.app_context():
        print("Iniciando limpeza profunda do banco de dados...")
        
        db.session.execute(text("DROP SCHEMA public CASCADE; CREATE SCHEMA public;"))
        db.session.commit()
        
        print("Banco esvaziado. Iniciando reconstrução...\n")
        
        for caminho_arquivo in SCRIPTS_SQL:
            if os.path.exists(caminho_arquivo):
                print(f"Executando: {caminho_arquivo}")
                with open(caminho_arquivo, 'r', encoding='utf-8') as file:
                    script_sql = file.read()
                    
                    
                    script_sql = script_sql.replace('BEGIN;', '').replace('COMMIT;', '')
                    
                    # Executa o script inteiro
                    db.session.execute(text(script_sql))
                    db.session.commit()
            else:
                print(f"ATENÇÃO: Arquivo não encontrado - {caminho_arquivo}")
                
        print("\nSucesso! O banco de dados foi resetado e populado com os dados da Etapa 1.")

if __name__ == '__main__':
    # Adicionamos uma confirmação de segurança para evitar acidentes
    confirmacao = input("TEM CERTEZA QUE DESEJA APAGAR E RESETAR O BANCO? (s/n): ")
    if confirmacao.lower() == 's':
        resetar_banco()
    else:
        print("Operação cancelada.")