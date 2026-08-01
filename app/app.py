# app.py
import os
from flask import Flask, render_template, request, redirect, url_for
from models import db, Pessoa, Paciente, Preceptor, Residente, Atendimento, ProcedimentoRealizado, Unidade
from dotenv import load_dotenv, find_dotenv
from sqlalchemy import func
from datetime import date, datetime

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

# app.py

# ... (criação do app)

# Função que formata o CPF
def format_cpf(cpf):
    if cpf and len(cpf) == 11:
        return f"{cpf[:3]}.{cpf[3:6]}.{cpf[6:9]}-{cpf[9:]}"
    return cpf

# Função que formata o Telefone
def format_telefone(telefone):
    if telefone and len(telefone) == 11:
        return f"({telefone[:2]}) {telefone[2:7]}-{telefone[7:]}"
    return telefone

# registra as funções como filtros no Jinja2
app.jinja_env.filters['cpf'] = format_cpf
app.jinja_env.filters['telefone'] = format_telefone

@app.route('/')
def dashboard():
    # Buscamos o primeiro registro de cada entidade para montar os links da apresentação dinamicamente
    primeiro_paciente = Paciente.query.first()
    primeiro_residente = Residente.query.first()
    primeiro_atendimento = Atendimento.query.first()
    
    # Prevenção: se o banco estiver vazio, não quebra a interface
    id_pac = primeiro_paciente.id_pessoa if primeiro_paciente else 0
    id_res = primeiro_residente.id_profissional if primeiro_residente else 0
    id_atend = primeiro_atendimento.id_atendimento if primeiro_atendimento else 0
    
    return render_template('dashboard.html', id_pac=id_pac, id_res=id_res, id_atend=id_atend)


@app.route('/paciente/deletar/<int:id>', methods=['POST'])
def deletar_paciente(id):
    # Busca a pessoa pelo ID
    pessoa = Pessoa.query.get_or_404(id)
    
    # O SQLAlchemy deleta a Pessoa. 
    # Como definimos ON DELETE CASCADE no banco, o registro em Paciente será excluído automaticamente!
    db.session.delete(pessoa)
    db.session.commit()
    
    return redirect(url_for('listar_pacientes'))

@app.route('/paciente/editar/<int:id>', methods=['GET', 'POST'])
def editar_paciente(id):
    # Busca o paciente no banco
    paciente = Paciente.query.get_or_404(id)
    pessoa = paciente.pessoa

    if request.method == 'POST':
        # Se o usuário enviou o formulário com alterações, atualiza os objetos
        pessoa.nome = request.form.get('nome')
        pessoa.cpf = request.form.get('cpf')
        pessoa.telefone = request.form.get('telefone')

        # Converte a string da data para o tipo Date do Python
        data_nasc_str = request.form.get('data_nascimento')
        if data_nasc_str:
            paciente.pessoa.data_nascimento = datetime.strptime(data_nasc_str, '%Y-%m-%d').date()

        # Boolean para o checkbox do Flamengo
        paciente.pessoa.is_flamengo = True if request.form.get('is_flamengo') else False

        # Atualiza os dados da tabela PACIENTE
        paciente.num_convenio = request.form.get('num_convenio') or None
        paciente.grupo_sanguineo = request.form.get('grupo_sanguineo')

        # Persiste no banco de dados com segurança transacional
        db.session.commit()
        
        db.session.commit() # Salva as edições no banco

        return redirect(url_for('detalhe_paciente', id_pessoa=id))

    return render_template('paciente_editar.html', paciente=paciente)

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



# A partir daqui foram implementadas as rotas para as consultas estabelecidas na Etapa I

# Consulta 01 - Inserir novo atendimento
@app.route('/atendimento/novo', methods=['POST'])
def inserir_atendimento():
    # Recebemos os IDs garantidos pelas tags <select> do HTML
    id_paciente = request.form.get('id_paciente')
    id_residente = request.form.get('id_residente')
    id_preceptor = request.form.get('id_preceptor')
    id_unidade = request.form.get('id_unidade')
    
    data_hora_str = request.form.get('data_hora')
    duracao_minutos = request.form.get('duracao_minutos')

    # Validação básica
    if not (id_paciente and id_residente and id_preceptor and id_unidade and data_hora_str and duracao_minutos):
        return "Erro: Preencha todos os campos.", 400

    try:
        data_hora = datetime.strptime(data_hora_str, '%Y-%m-%dT%H:%M')
        
        # Criação do objeto usando o ORM
        novo_atend = Atendimento(
            id_paciente=id_paciente,
            id_residente=id_residente,
            id_preceptor=id_preceptor,
            id_unidade=id_unidade,
            data_hora=data_hora,
            duracao_minutos=duracao_minutos
        )
        
        db.session.add(novo_atend)
        db.session.commit()
        return redirect(url_for('listar_atendimentos'))
        
    except Exception as e:
        db.session.rollback()
        return f"Erro de validação do ORM ou Banco de Dados: {str(e)}", 400

@app.route('/atendimentos')
def listar_atendimentos():
    # Busca todos os atendimentos ordenados do mais recente para o mais antigo
    atendimentos = Atendimento.query.order_by(Atendimento.data_hora.desc()).all()
    
    # Busca os dados para popular os selects do Modal
    pacientes = Paciente.query.all()
    residentes = Residente.query.all()
    preceptores = Preceptor.query.all()
    unidades = Unidade.query.all()
    
    return render_template('atendimentos.html', 
                           atendimentos=atendimentos,
                           pacientes=pacientes,
                           residentes=residentes,
                           preceptores=preceptores,
                           unidades=unidades)


# Consulta 02 - Listar todos os atendimentos de um paciente específico
@app.route('/paciente/<int:id_pessoa>/atendimentos')
def atendimentos_por_paciente(id_pessoa):
    # Uso do lazy loading / filter
    atendimentos = Atendimento.query\
        .filter_by(id_paciente=id_pessoa)\
        .order_by(Atendimento.data_hora.desc())\
        .all()
        
    return render_template('lista_atendimentos.html', atendimentos=atendimentos)

# Consulta 03 - Listar os procedimentos que foram realizados em um atendimento
@app.route('/atendimento/<int:id_atendimento>/procedimentos')
def procedimentos_do_atendimento(id_atendimento):
    # Busca os procedimentos filtrando pelo ID do atendimento
    procedimentos_realizados = ProcedimentoRealizado.query\
        .filter_by(id_atendimento=id_atendimento)\
        .all()
    
    # Graças ao relationship 'procedimento_rel', podemos acessar o nome do procedimento
    # ex no HTML: {{ proc.procedimento_rel.nome }}, {{ proc.quantidade }}, {{ proc.tempo_real_minutos }}
    return render_template('lista_procedimentos.html', procedimentos=procedimentos_realizados)


# Consulta 04 - Atualizar os dados de um paciente
@app.route('/paciente/atualizar_convenio/<int:id_pessoa>', methods=['POST'])
def atualizar_convenio_paciente(id_pessoa):
    paciente = Paciente.query.get_or_404(id_pessoa)
    
    # Atualiza o dado diretamente no objeto Python
    paciente.num_convenio = request.form.get('num_convenio')
    
    # Apenas o commit é necessário (O ORM percebe a alteração e faz o UPDATE sozinho)
    db.session.commit()
    return redirect(url_for('detalhe_paciente', id_pessoa=id_pessoa))


# Consulta 05 - Remover um procedimento realizado
@app.route('/procedimento_realizado/remover/<int:id_atendimento>/<int:id_procedimento>', methods=['POST'])
def remover_procedimento_realizado(id_atendimento, id_procedimento):
    # Busca pela PK Composta (tupla)
    proc_realizado = ProcedimentoRealizado.query.get_or_404((id_atendimento, id_procedimento))
    
    # Validação da regra de negócio (só remove se não houver faturamento associado)
    if proc_realizado.faturado:
        return "Acesso Negado: Não é possível remover um procedimento já faturado.", 403
        
    db.session.delete(proc_realizado)
    db.session.commit()
    return redirect(url_for('procedimentos_do_atendimento', id_atendimento=id_atendimento))


# Consulta 06 - Calcula o tempo médio de duração dos atendimentos por
@app.route('/residente/<int:id_residente>/media_atendimentos')
def media_duracao_residente(id_residente):
    # Equivalente a: SELECT AVG(duracao_minutos) FROM atendimento WHERE id_residente = X
    media = db.session.query(func.avg(Atendimento.duracao_minutos))\
        .filter_by(id_residente=id_residente)\
        .scalar() # scalar() pega o valor numérico direto do resultado
        
    # Arredondando para 2 casas decimais, ou 0 se não houver atendimentos
    media_formatada = round(media, 2) if media else 0
    return f"O tempo médio de atendimento deste residente é de {media_formatada} minutos."


@app.route('/atendimento/<int:id_atendimento>')
def detalhe_atendimento(id_atendimento):
    # Busca o atendimento.
    atendimento = Atendimento.query.get_or_404(id_atendimento)
    return render_template('atendimento_detalhe.html', atendimento=atendimento)


@app.route('/atendimento/<int:id_atendimento>/procedimento/<int:id_procedimento>/deletar', methods=['POST'])
def deletar_procedimento_realizado(id_atendimento, id_procedimento):
    # Busca o registro na tabela associativa pela chave primária composta
    pr = ProcedimentoRealizado.query.get_or_404((id_atendimento, id_procedimento))
    
    # REGRA DE NEGÓCIO DA APLICAÇÃO: Bloqueia exclusão de itens já cobrados
    if pr.faturado:
        return "Erro de Regra de Negócio: Procedimentos faturados (já enviados para cobrança) não podem ser excluídos do sistema.", 403
    
    try:
        db.session.delete(pr)
        db.session.commit()
        return redirect(url_for('detalhe_atendimento', id_atendimento=id_atendimento))
    except Exception as e:
        db.session.rollback()
        return f"Erro ao remover o procedimento: {str(e)}", 400


if __name__ == '__main__':
    with app.app_context():
        db.create_all() # Cria as tabelas caso não existam (útil para testes, mas no seu caso o script SQL já fez isso)
    app.run(debug=True)