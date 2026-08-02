import os
os.environ["PGCLIENTENCODING"] = "utf-8"

import threading
import time
from app import app
from models import db, Escala, Residente
import random

def simular_agendamento(nome_thread, id_residente, id_preceptor, id_unidade, dia, turno):
    with app.app_context():

        # Ambas a threads chegam aqui
        largada.wait()

        # Espera um tempo aleatorio entre 1 e 15 milisegundo para a thread 1 conseguir acordar
        time.sleep(random.uniform(0.001, 0.015))

        print(f"[{nome_thread}] Iniciando transação...")
        try:
            print(f"[{nome_thread}] Solicitando lock para o Residente {id_residente}...")
            
            # LOCK PESSIMISTA (O erro está ocorrendo nesta linha)
            residente = db.session.query(Residente).filter_by(id_profissional=id_residente).with_for_update().first()
            
            if not residente:
                print(f"[{nome_thread}] ERRO: Residente {id_residente} não existe no banco.")
                db.session.rollback()
                return

            print(f"[{nome_thread}] Lock adquirido! Nenhuma outra thread avança por agora.")
            
            time.sleep(3)

            # Verificação da regra de negócio
            escala_existente = db.session.query(Escala).filter_by(
                id_residente=id_residente,
                dia_semana=dia,
                turno=turno
            ).first()

            if escala_existente:
                print(f"[{nome_thread}] CONFLITO DETECTADO: Vaga já preenchida. Abortando transação.")
                db.session.rollback()
                return

            # Inserção
            nova_escala = Escala(
                id_unidade=id_unidade,
                id_residente=id_residente,
                id_preceptor=id_preceptor,
                dia_semana=dia,
                turno=turno
            )
            db.session.add(nova_escala)
            db.session.commit()
            print(f"[{nome_thread}] SUCESSO: Escala cadastrada e Lock liberado.")

        except Exception as e:
            db.session.rollback()
            # repr(e) exibe o erro exato do SQLAlchemy
            print(f"[{nome_thread}] ERRO REAL: {repr(e)}")

if __name__ == "__main__":
    print("--- Iniciando Simulação de Concorrência ---")
    
    # Variáveis de teste já ajustadas para IDs que agora existem no banco
    ID_RES = 6  
    ID_PRE = 11  
    ID_UNI = 1  
    DIA = 'Quinta' 
    TURNO = 'Noite'

    largada = threading.Barrier(2)

    with app.app_context():
        # Deleta a escala se ela já existir para a corrida ser justa
        db.session.query(Escala).filter_by(id_residente=6, dia_semana='Quinta', turno='Noite').delete()
        db.session.commit()

    t1 = threading.Thread(target=simular_agendamento, args=("Thread-1", ID_RES, ID_PRE, ID_UNI, DIA, TURNO))
    t2 = threading.Thread(target=simular_agendamento, args=("Thread-2", ID_RES, ID_PRE, ID_UNI, DIA, TURNO))

    t1.start()
    # time.sleep(0.5) # Retirando a espera
    t2.start()

    t1.join()
    t2.join()
    
    print("--- Simulação Finalizada ---")