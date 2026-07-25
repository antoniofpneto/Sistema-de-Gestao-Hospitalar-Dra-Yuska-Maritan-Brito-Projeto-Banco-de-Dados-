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

@app.route('/paciente/novo', methods=['POST'])
def novo_paciente():
    # 1. Captura dos dados do formulário HTML (atributos 'name' das tags <input>)
    nome = request.form.get('nome')
    cpf = request.form.get('cpf')
    data_nascimento = request.form.get('data_nascimento')
    telefone = request.form.get('telefone')
    
    # 2. Instanciamos o objeto Pessoa (nossa entidade "Pai")
    nova_pessoa = Pessoa(
        nome=nome, 
        cpf=cpf, 
        data_nascimento=data_nascimento, 
        telefone=telefone
    )
    db.session.add(nova_pessoa)
    
    # 3. Sincronização intermediária
    db.session.flush() 
    
    # 4. Instanciamos o objeto Paciente (entidade "Filha"), usando o ID recém-gerado
    novo_paciente = Paciente(id_pessoa=nova_pessoa.id_pessoa)
    db.session.add(novo_paciente)
    
    # 5. Efetivação atômica no banco de dados
    db.session.commit() 
    
    # 6. Redireciona o usuário de volta para a tabela principal
    return redirect(url_for('index'))

@app.route('/paciente/deletar/<int:id>', methods=['POST'])
def deletar_paciente(id):
    # Busca a pessoa pelo ID
    pessoa = Pessoa.query.get_or_404(id)
    
    # O SQLAlchemy deleta a Pessoa. 
    # Como definimos ON DELETE CASCADE no banco, o registro em Paciente será excluído automaticamente!
    db.session.delete(pessoa)
    db.session.commit()
    
    return redirect(url_for('index'))

@app.route('/paciente/editar/<int:id>', methods=['GET', 'POST'])
def editar_paciente(id):
    # Busca o paciente no banco
    paciente = Paciente.query.get_or_404(id)
    pessoa = paciente.pessoa

    if request.method == 'POST':
        # Se o usuário enviou o formulário com alterações, atualiza os objetos
        pessoa.nome = request.form.get('nome')
        pessoa.telefone = request.form.get('telefone')
        # ... atualize outros campos que desejar
        
        db.session.commit() # Salva as edições no banco
        return redirect(url_for('index'))

    # Se for GET, apenas renderiza uma página simples de edição 
    # (Você pode criar um editar_paciente.html depois similar ao cadastro)
    return f"""
    <form method="POST">
        Nome: <input type="text" name="nome" value="{pessoa.nome}"><br>
        Telefone: <input type="text" name="telefone" value="{pessoa.telefone}"><br>
        <button type="submit">Atualizar</button>
    </form>
    """

if __name__ == '__main__':
    with app.app_context():
        db.create_all() # Cria as tabelas caso não existam (útil para testes, mas no seu caso o script SQL já fez isso)
    app.run(debug=True)