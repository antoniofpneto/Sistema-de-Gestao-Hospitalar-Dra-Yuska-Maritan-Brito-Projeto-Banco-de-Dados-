# app.py
import os
from flask import Flask, render_template, request, redirect, url_for
from models import db, Pessoa, Paciente
from dotenv import load_dotenv, find_dotenv
from sqlalchemy import func

# carrregar as variáveis de ambiente para a memória
load_dotenv(find_dotenv())

os.environ["PGCLIENTENCODING"] = "utf-8" #[cite: 3]

app = Flask(__name__)

# Puxa os dados da memória de forma segura
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')
db_host = os.getenv('DB_HOST')
db_port = os.getenv('DB_PORT')
db_name = os.getenv('DB_NAME')

# Monta a URL de conexão usando as variáveis (f-string do Python)
app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}?client_encoding=utf8&options=-c%20lc_messages=C' #[cite: 3]
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

@app.route('/')
def dashboard():
    return render_template('dashboard.html')


@app.route('/paciente/deletar/<int:id>', methods=['POST'])
def deletar_paciente(id):
    # Busca a pessoa pelo ID
    pessoa = Pessoa.query.get_or_404(id)
    
    # O SQLAlchemy deleta a Pessoa. 
    # Como definimos ON DELETE CASCADE no banco, o registro em Paciente será excluído automaticamente!
    db.session.delete(pessoa)
    db.session.commit()
    
    return redirect(url_for('dashboard'))

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
        return redirect(url_for('dashboard'))

    # Se for GET, apenas renderiza uma página simples de edição 
    # (Você pode criar um editar_paciente.html depois similar ao cadastro)
    return f"""
    <form method="POST">
        Nome: <input type="text" name="nome" value="{pessoa.nome}"><br>
        Telefone: <input type="text" name="telefone" value="{pessoa.telefone}"><br>
        <button type="submit">Atualizar</button>
    </form>
    """

@app.route('/paciente/novo', methods=['POST'])
def novo_paciente():
    # 1. Captura de todos os campos gerais da Pessoa
    nome = request.form.get('nome')
    cpf = request.form.get('cpf')
    data_nascimento = request.form.get('data_nascimento')
    telefone = request.form.get('telefone')
    
    # 2. Tratamento específico para o checkbox booleano
    # Se vier algo no formulário, é True. Se vier None (desmarcado), é False.
    is_flamengo_form = request.form.get('is_flamengo')
    is_flamengo = True if is_flamengo_form else False
    
    # 3. Captura dos campos específicos do Paciente
    num_convenio = request.form.get('num_convenio')
    grupo_sanguineo = request.form.get('grupo_sanguineo')
    
    # 4. Instancia e salva a entidade "Pai" (Pessoa) com todos os campos
    nova_pessoa = Pessoa(
        nome=nome, 
        cpf=cpf, 
        data_nascimento=data_nascimento, 
        telefone=telefone,
        is_flamengo=is_flamengo
    )
    db.session.add(nova_pessoa)
    db.session.flush() # Sincroniza para gerar o id_pessoa no banco
    
    # 5. Instancia e salva a entidade "Filha" (Paciente) com os campos médicos
    novo_paciente = Paciente(
        id_pessoa=nova_pessoa.id_pessoa,
        num_convenio=num_convenio,
        grupo_sanguineo=grupo_sanguineo
    )
    db.session.add(novo_paciente)
    
    # 6. Efetivação atômica da transação
    db.session.commit() 
    
    # 7. Redireciona de volta para a lista de pacientes
    return redirect(url_for('listar_pacientes'))
    
@app.route('/pacientes')
def listar_pacientes():
    # Busca todos os pacientes no banco
    pacientes = Paciente.query.all()
    return render_template('pacientes.html', pacientes=pacientes)

@app.route('/paciente/<int:id_pessoa>')
def detalhe_paciente(id_pessoa):
    # Busca o paciente específico pelo ID; se não achar, retorna erro 404
    paciente = Paciente.query.get_or_404(id_pessoa)
    return render_template('paciente_detalhe.html', paciente=paciente)

if __name__ == '__main__':
    with app.app_context():
        db.create_all() # Cria as tabelas caso não existam (útil para testes, mas no seu caso o script SQL já fez isso)
    app.run(debug=True)



# A partir daqui foram implementadas as rotas para as consultas estabelecidas na Etapa I

@app.route('/atendimento/novo', methods=['POST'])
def inserir_atendimento():
    id_paciente = request.form.get('id_paciente')
    id_residente = request.form.get('id_residente')
    id_preceptor = request.form.get('id_preceptor')
    
    # 1. Verifica se paciente, residente e preceptor existem usando o ORM
    paciente = Paciente.query.get(id_paciente)
    residente = Residente.query.get(id_residente)
    preceptor = Preceptor.query.get(id_preceptor)
    
    if not (paciente and residente and preceptor):
        return "Erro: Paciente, Residente ou Preceptor não encontrados no sistema.", 404
        
    # 2. Insere o atendimento
    novo_atendimento = Atendimento(
        id_paciente=id_paciente,
        id_residente=id_residente,
        id_preceptor=id_preceptor,
        data_hora=request.form.get('data_hora'),
        duracao_minutos=request.form.get('duracao_minutos')
    )
    db.session.add(novo_atendimento)
    db.session.commit()
    return redirect(url_for('listar_pacientes')) # Ou para a rota de atendimentos