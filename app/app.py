# app.py
import os
from flask import Flask, render_template, request, redirect, url_for
from models import db, Pessoa, Paciente
from dotenv import load_dotenv

# carrregar as variáveis de ambiente para a memória
load_dotenv()

app = Flask(__name__)

# Puxa os dados da memória de forma segura
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')
db_host = os.getenv('DB_HOST')
db_port = os.getenv('DB_PORT')
db_name = os.getenv('DB_NAME')


# Monta a URL de conexão usando as variáveis (f-string do Python)
app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

@app.route('/')
def index():
    # Consulta básica com ORM: listar todos os pacientes com seus dados de Pessoa
    pacientes = Paciente.query.join(Pessoa).all()
    return render_template('index.html', pacientes=pacientes)

@app.route('/cadastrar', methods=['POST'])
def cadastrar_paciente():
    nome = request.form.get('nome')
    cpf = request.form.get('cpf')
    data_nascimento = request.form.get('data_nascimento')
    
    # Criando os objetos Python (o SQLAlchemy fará o INSERT)
    nova_pessoa = Pessoa(nome=nome, cpf=cpf, data_nascimento=data_nascimento)
    db.session.add(nova_pessoa)
    db.session.commit() # Salvando a pessoa primeiro para gerar o id_pessoa
    
    novo_paciente = Paciente(id_pessoa=nova_pessoa.id_pessoa)
    db.session.add(novo_paciente)
    db.session.commit() # Confirmando a transação
    
    return redirect('/')

if __name__ == '__main__':
    with app.app_context():
        db.create_all() # Cria as tabelas caso não existam (útil para testes, mas no seu caso o script SQL já fez isso)
    app.run(debug=True)