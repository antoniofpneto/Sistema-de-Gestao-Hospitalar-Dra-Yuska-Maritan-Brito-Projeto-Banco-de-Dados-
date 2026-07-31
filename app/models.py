# models.py
from flask_sqlalchemy import SQLAlchemy
from datetime import date, datetime

db = SQLAlchemy()


# HIERARQUIA DE PESSOAS E PROFISSIONAIS
class Pessoa(db.Model):
    __tablename__ = 'pessoa'
    
    id_pessoa = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(150), nullable=False)
    cpf = db.Column(db.String(11), unique=True, nullable=False) # CPF como uma chave candidata
    data_nascimento = db.Column(db.Date, nullable=False)
    is_flamengo = db.Column(db.Boolean, nullable=False, default=False)
    telefone = db.Column(db.String(20), nullable=False)

    paciente = db.relationship('Paciente', backref='pessoa', uselist=False, cascade="all, delete-orphan")
    profissional = db.relationship('Profissional', backref='pessoa', uselist=False, cascade="all, delete-orphan")

    # restrição de tamanho do CPF
    __table_args__ = (
        db.CheckConstraint('LENGTH(cpf) = 11', name='chk_cpf_formato'),
    )

class Paciente(db.Model):
    __tablename__ = 'paciente'
    
    id_pessoa = db.Column(db.Integer, db.ForeignKey('pessoa.id_pessoa', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    num_convenio = db.Column(db.String(50))
    grupo_sanguineo = db.Column(db.String(3))
    
    # Relacionamentos
    atendimentos = db.relationship('Atendimento', backref='paciente_rel')
    internacoes = db.relationship('Internacao', backref='paciente_rel')
    alergias = db.relationship('AlergiaPaciente', backref='paciente_rel', cascade="all, delete-orphan")

    # restrição do tipo sanguíneo
    __table_args__ = (
        db.CheckConstraint(
            "grupo_sanguineo IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')", 
            name='chk_grupo_sanguineo'
        ),
    )

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

    # Restrições de papel e validade das datas
    __table_args__ = (
        db.CheckConstraint("papel IN ('Residente', 'Preceptor')", name='chk_papel'),
        db.CheckConstraint("data_fim IS NULL OR data_fim >= data_inicio", name='chk_datas_historico'),
    )

class Preceptor(db.Model):
    __tablename__ = 'preceptor'
    
    id_profissional = db.Column(db.Integer, db.ForeignKey('profissional.id_pessoa', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    titulacao = db.Column(db.String(50), nullable=False)

    atendimentos = db.relationship('Atendimento', backref='preceptor_rel')
    escalas = db.relationship('Escala', backref='preceptor_rel')
    internacoes = db.relationship('Internacao', backref='preceptor_rel')

    __table_args__ = (
        db.CheckConstraint("titulacao IN ('Especialista', 'Mestre', 'Doutor', 'Livre-Docente')", name='chk_titulacao'),
    )


class Residente(db.Model):
    __tablename__ = 'residente'
    
    id_profissional = db.Column(db.Integer, db.ForeignKey('profissional.id_pessoa', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    ano_residencia = db.Column(db.String(2), nullable=False)

    atendimentos = db.relationship('Atendimento', backref='residente_rel')
    escalas = db.relationship('Escala', backref='residente_rel')
    internacoes = db.relationship('Internacao', backref='residente_rel')

    __table_args__ = (
        db.CheckConstraint("ano_residencia IN ('R1', 'R2', 'R3')", name = 'chk_ano_residencia'),
    )



# ESTRUTURA HOSPITALAR E ATENDIMENTO
class Unidade(db.Model):
    __tablename__ = 'unidade'
    
    id_unidade = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(100), unique=True, nullable=False)
    tipo = db.Column(db.String(50), nullable=False)
    capacidade_leitos = db.Column(db.Integer, nullable=False, default=0)

    escalas = db.relationship('Escala', backref='unidade_rel')
    internacoes = db.relationship('Internacao', backref='unidade_rel')

    __table_args__ = (
        db.CheckConstraint("capacidade_leitos >= 0", name = 'chk_capacity'),
    )


class Atendimento(db.Model):
    __tablename__ = 'atendimento'
    
    id_atendimento = db.Column(db.Integer, primary_key=True)
    id_paciente = db.Column(db.Integer, db.ForeignKey('paciente.id_pessoa', onupdate='CASCADE'), nullable=False)
    id_residente = db.Column(db.Integer, db.ForeignKey('residente.id_profissional', onupdate='CASCADE'), nullable=False)
    id_preceptor = db.Column(db.Integer, db.ForeignKey('preceptor.id_profissional', onupdate='CASCADE'), nullable=False)
    id_unidade = db.Column(db.Integer, db.ForeignKey('unidade.id_unidade', onupdate='CASCADE'), nullable=False)
    data_hora = db.Column(db.DateTime, nullable=False)
    duracao_minutos = db.Column(db.Integer, nullable=False)

    procedimentos_realizados = db.relationship('ProcedimentoRealizado', backref='atendimento_rel')

    __table_args__ = (
        db.CheckConstraint("duracao_minutos > 0", name = 'chk_duracao'),
    )

# AUDITORIA DE ATENDIMENTOS
class AuditoriaAtendimento(db.Model):
    __tablename__ = 'auditoria_atendimento'
    
    id_auditoria = db.Column(db.Integer, primary_key=True)
    id_atendimento = db.Column(db.Integer, db.ForeignKey('atendimento.id_atendimento', onupdate='CASCADE'), nullable=False)
    data_hora = db.Column(db.TIMESTAMP, nullable=False, default=db.func.current_timestamp())
    usuario = db.Column(db.String(50), nullable=False)
    operacao = db.Column(db.String(20), nullable=False)  # Inserção, atualização ou exclusão
    dados_antigos = db.Column(db.JSON)
    dados_novos = db.Column(db.JSON)

    __table_args__ = (
        db.CheckConstraint("operacao IN ('Insercao', 'Atualizacao', 'Exclusao')", name='chk_operacao'),
    )


class Internacao(db.Model):
    __tablename__ = 'internacao'
    
    id_internacao = db.Column(db.Integer, primary_key=True)
    id_paciente = db.Column(db.Integer, db.ForeignKey('paciente.id_pessoa', onupdate='CASCADE'), nullable=False)
    id_unidade = db.Column(db.Integer, db.ForeignKey('unidade.id_unidade', onupdate='CASCADE'), nullable=False)
    id_residente = db.Column(db.Integer, db.ForeignKey('residente.id_profissional', onupdate='CASCADE'), nullable=False)
    id_preceptor = db.Column(db.Integer, db.ForeignKey('preceptor.id_profissional', onupdate='CASCADE'), nullable=False)
    data_hora_entrada = db.Column(db.DateTime, nullable=False)
    data_hora_saida = db.Column(db.DateTime)

    __table_args__ = (
        db.CheckConstraint("data_hora_saida IS NULL OR data_hora_saida >= data_hora_entrada", name = 'chk_datas_internacao'),
    )


# PROCEDIMENTOS
class Procedimento(db.Model):
    __tablename__ = 'procedimento'
    
    id_procedimento = db.Column(db.Integer, primary_key=True)
    codigo = db.Column(db.String(20), unique=True, nullable=False)
    nome = db.Column(db.String(150), nullable=False)
    tempo_medio_minutos = db.Column(db.Integer, nullable=False)
    nivel_risco = db.Column(db.String(10), nullable=False, default='BAIXO')

    realizacoes = db.relationship('ProcedimentoRealizado', backref='procedimento_rel')

    __table_args__ = (
        db.CheckConstraint("tempo_medio_minutos > 0", name = 'chk_tempo_medio'),
        db.CheckConstraint("nivel_risco IN ('BAIXO', 'MEDIO', 'ALTO')", name = 'chk_nivel_risco'),
    )

class ProcedimentoRealizado(db.Model):
    __tablename__ = 'procedimento_realizado'
    
    id_atendimento = db.Column(db.Integer, db.ForeignKey('atendimento.id_atendimento', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    id_procedimento = db.Column(db.Integer, db.ForeignKey('procedimento.id_procedimento', onupdate='CASCADE'), primary_key=True)
    
    quantidade = db.Column(db.Integer, nullable=False, default=1)
    tempo_real_minutos = db.Column(db.Integer, nullable=False)
    data_hora_inicio = db.Column(db.DateTime)
    observacao = db.Column(db.Text)
    faturado = db.Column(db.Boolean, nullable=False, default=False)

    __table_args__ = (
        db.CheckConstraint("quantidade > 0", name = 'chk_quantidade'),
        db.CheckConstraint("tempo_real_minutos > 0", name = 'chk_tempo_real'),
    )


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
        db.CheckConstraint("dia_semana IN ('Segunda', 'Terca', 'Quarta', 'Quinta', 'Sexta', 'Sabado', 'Domingo')", name = 'chk_dia_semana'),
        db.CheckConstraint("turno IN ('Manha', 'Tarde', 'Noite')", name = 'chk_turno'),
        db.UniqueConstraint('id_unidade', 'dia_semana', 'turno', 'id_residente', name='uq_escala_residente'),
    )


