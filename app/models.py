# models.py
from flask_sqlalchemy import SQLAlchemy
from datetime import date

db = SQLAlchemy()


# HIERARQUIA DE PESSOAS E PROFISSIONAIS
class Pessoa(db.Model):
    __tablename__ = 'pessoa'
    
    id_pessoa = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(150), nullable=False)
    cpf = db.Column(db.String(11), unique=True, nullable=False)
    data_nascimento = db.Column(db.Date, nullable=False)
    is_flamengo = db.Column(db.Boolean, nullable=False, default=False)
    telefone = db.Column(db.String(20), nullable=False)

    paciente = db.relationship('Paciente', backref='pessoa', uselist=False)
    profissional = db.relationship('Profissional', backref='pessoa', uselist=False)


class Paciente(db.Model):
    __tablename__ = 'paciente'
    
    id_pessoa = db.Column(db.Integer, db.ForeignKey('pessoa.id_pessoa', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    num_convenio = db.Column(db.String(50))
    grupo_sanguineo = db.Column(db.String(3))
    
    # Relacionamentos
    atendimentos = db.relationship('Atendimento', backref='paciente_rel')
    internacoes = db.relationship('Internacao', backref='paciente_rel')
    alergias = db.relationship('AlergiaPaciente', backref='paciente_rel', cascade="all, delete-orphan")


class AlergiaPaciente(db.Model):
    __tablename__ = 'alergia_paciente'
    
    id_paciente = db.Column(db.Integer, db.ForeignKey('paciente.id_pessoa', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    alergia = db.Column(db.String(100), primary_key=True)


class Profissional(db.Model):
    __tablename__ = 'profissional'
    
    id_pessoa = db.Column(db.Integer, db.ForeignKey('pessoa.id_pessoa', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    crm = db.Column(db.String(20), unique=True, nullable=False)
    data_admissao = db.Column(db.Date, nullable=False)

    # Relacionamentos
    preceptor = db.relationship('Preceptor', backref='profissional_rel', uselist=False)
    residente = db.relationship('Residente', backref='profissional_rel', uselist=False)
    especialidades = db.relationship('EspecialidadeProfissional', backref='profissional_rel', cascade="all, delete-orphan")
    historico = db.relationship('HistoricoPapel', backref='profissional_rel')


class EspecialidadeProfissional(db.Model):
    __tablename__ = 'especialidade_profissional'
    
    id_profissional = db.Column(db.Integer, db.ForeignKey('profissional.id_pessoa', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    especialidade = db.Column(db.String(100), primary_key=True)


class HistoricoPapel(db.Model):
    __tablename__ = 'historico_papel'
    
    id_historico_papel = db.Column(db.Integer, primary_key=True)
    id_profissional = db.Column(db.Integer, db.ForeignKey('profissional.id_pessoa', ondelete='CASCADE', onupdate='CASCADE'), nullable=False)
    papel = db.Column(db.String(30), nullable=False)
    data_inicio = db.Column(db.Date, nullable=False)
    data_fim = db.Column(db.Date)


class Preceptor(db.Model):
    __tablename__ = 'preceptor'
    
    id_profissional = db.Column(db.Integer, db.ForeignKey('profissional.id_pessoa', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    titulacao = db.Column(db.String(50), nullable=False)

    atendimentos = db.relationship('Atendimento', backref='preceptor_rel')
    escalas = db.relationship('Escala', backref='preceptor_rel')
    internacoes = db.relationship('Internacao', backref='preceptor_rel')


class Residente(db.Model):
    __tablename__ = 'residente'
    
    id_profissional = db.Column(db.Integer, db.ForeignKey('profissional.id_pessoa', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    ano_residencia = db.Column(db.String(2), nullable=False)

    atendimentos = db.relationship('Atendimento', backref='residente_rel')
    escalas = db.relationship('Escala', backref='residente_rel')
    internacoes = db.relationship('Internacao', backref='residente_rel')



# ESTRUTURA HOSPITALAR E ATENDIMENTO
class Unidade(db.Model):
    __tablename__ = 'unidade'
    
    id_unidade = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(100), unique=True, nullable=False)
    tipo = db.Column(db.String(50), nullable=False)
    capacidade_leitos = db.Column(db.Integer, nullable=False, default=0)

    escalas = db.relationship('Escala', backref='unidade_rel')
    internacoes = db.relationship('Internacao', backref='unidade_rel')


class Atendimento(db.Model):
    __tablename__ = 'atendimento'
    
    id_atendimento = db.Column(db.Integer, primary_key=True)
    id_paciente = db.Column(db.Integer, db.ForeignKey('paciente.id_pessoa', onupdate='CASCADE'), nullable=False)
    id_residente = db.Column(db.Integer, db.ForeignKey('residente.id_profissional', onupdate='CASCADE'), nullable=False)
    id_preceptor = db.Column(db.Integer, db.ForeignKey('preceptor.id_profissional', onupdate='CASCADE'), nullable=False)
    data_hora = db.Column(db.DateTime, nullable=False)
    duracao_minutos = db.Column(db.Integer, nullable=False)

    procedimentos_realizados = db.relationship('ProcedimentoRealizado', backref='atendimento_rel')


class Internacao(db.Model):
    __tablename__ = 'internacao'
    
    id_internacao = db.Column(db.Integer, primary_key=True)
    id_paciente = db.Column(db.Integer, db.ForeignKey('paciente.id_pessoa', onupdate='CASCADE'), nullable=False)
    id_unidade = db.Column(db.Integer, db.ForeignKey('unidade.id_unidade', onupdate='CASCADE'), nullable=False)
    id_residente = db.Column(db.Integer, db.ForeignKey('residente.id_profissional', onupdate='CASCADE'), nullable=False)
    id_preceptor = db.Column(db.Integer, db.ForeignKey('preceptor.id_profissional', onupdate='CASCADE'), nullable=False)
    data_hora_entrada = db.Column(db.DateTime, nullable=False)
    data_hora_saida = db.Column(db.DateTime)


# PROCEDIMENTOS
class Procedimento(db.Model):
    __tablename__ = 'procedimento'
    
    id_procedimento = db.Column(db.Integer, primary_key=True)
    codigo = db.Column(db.String(20), unique=True, nullable=False)
    nome = db.Column(db.String(150), nullable=False)
    tempo_medio_minutos = db.Column(db.Integer, nullable=False)
    nivel_risco = db.Column(db.String(10), nullable=False, default='BAIXO')

    realizacoes = db.relationship('ProcedimentoRealizado', backref='procedimento_rel')


class ProcedimentoRealizado(db.Model):
    __tablename__ = 'procedimento_realizado'
    
    id_atendimento = db.Column(db.Integer, db.ForeignKey('atendimento.id_atendimento', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    id_procedimento = db.Column(db.Integer, db.ForeignKey('procedimento.id_procedimento', onupdate='CASCADE'), primary_key=True)
    
    quantidade = db.Column(db.Integer, nullable=False, default=1)
    tempo_real_minutos = db.Column(db.Integer, nullable=False)
    observacao = db.Column(db.Text)
    faturado = db.Column(db.Boolean, nullable=False, default=False)


# ESCALAS
class Escala(db.Model):
    __tablename__ = 'escala'
    
    id_escala = db.Column(db.Integer, primary_key=True)
    id_unidade = db.Column(db.Integer, db.ForeignKey('unidade.id_unidade', onupdate='CASCADE'), nullable=False)
    id_residente = db.Column(db.Integer, db.ForeignKey('residente.id_profissional', onupdate='CASCADE'), nullable=False)
    id_preceptor = db.Column(db.Integer, db.ForeignKey('preceptor.id_profissional', onupdate='CASCADE'), nullable=False)
    dia_semana = db.Column(db.String(15), nullable=False)
    turno = db.Column(db.String(15), nullable=False)

    __table_args__ = (
        db.UniqueConstraint('id_unidade', 'dia_semana', 'turno', 'id_residente', name='uq_escala_residente'),
    )