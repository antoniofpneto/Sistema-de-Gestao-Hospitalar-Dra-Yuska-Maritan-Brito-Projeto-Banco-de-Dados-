-- 01. Script para criar as tabelas do banco de dados do sistema de gestão hospitalar.

-- Criação das tabelas:

-- Criação da tabela entidade PESSOA
CREATE TABLE PESSOA (
    -- Atributos:
    id_pessoa SERIAL PRIMARY KEY, -- Utilizando serial para permiter o incremento do id de maneira automatica
    nome VARCHAR(150) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE, -- CPF como uma chave candidata
    data_nascimento DATE NOT NULL,
    is_flamengo BOOLEAN NOT NULL DEFAULT FALSE,
    telefone VARCHAR(20) NOT NULL,
    --Restrições:
    CONSTRAINT chk_cpf_formato CHECK (LENGTH(cpf) = 11) -- Restrição do tamanho do CPF
);

-- Criação da tabela para entidade PACIENTE, subtipo de PESSOA
CREATE TABLE PACIENTE (
    -- Atributos:
    id_pessoa INT PRIMARY KEY,
    num_convenio VARCHAR(50), -- Nulo caso seja SUS
    grupo_sanguineo VARCHAR(3),
    -- Restrições:
    CONSTRAINT fk_paciente_pessoa FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_grupo_sanguineo CHECK (grupo_sanguineo IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
);

-- Criação da tabela para associar alergias a pacientes
CREATE TABLE ALERGIA_PACIENTE (
    id_paciente INT NOT NULL,
    alergia VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_paciente, alergia),
    CONSTRAINT fk_alergia_paciente FOREIGN KEY (id_paciente) REFERENCES PACIENTE(id_pessoa)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Criação da tabela para entidade PROFISSIONAL, especialização de PESSOA
CREATE TABLE PROFISSIONAL (
    -- Atributos:
    id_pessoa INT PRIMARY KEY,
    crm VARCHAR(20) NOT NULL UNIQUE,
    data_admissao DATE NOT NULL,
    -- Restrições:
    CONSTRAINT fk_profissional_pessoa FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Criação da tabela para associar especialidades a profissionais
CREATE TABLE ESPECIALIDADE_PROFISSIONAL (
    id_profissional INT NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_profissional, especialidade),
    CONSTRAINT fk_especialidade_profissional FOREIGN KEY (id_profissional) REFERENCES PROFISSIONAL(id_pessoa)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Criação da tabela para entidade PRECEPTOR, subclasse de PROFISSIONAL
CREATE TABLE PRECEPTOR (
    -- Atributos:
    id_profissional INT PRIMARY KEY,
    titulacao VARCHAR(50) NOT NULL,
    -- Restrições:
    CONSTRAINT fk_preceptor_profissional FOREIGN KEY (id_profissional) REFERENCES PROFISSIONAL(id_pessoa) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_titulacao CHECK (titulacao IN ('Especialista', 'Mestre', 'Doutor', 'Livre-Docente'))
);

-- Criação da tabela para entidade RESIDENTE, advinda de PROFISSIONAL
CREATE TABLE RESIDENTE (
    -- Atributos:
    id_profissional INT PRIMARY KEY,
    ano_residencia CHAR(2) NOT NULL,
    -- Restrições:
    CONSTRAINT fk_residente_profissional FOREIGN KEY (id_profissional) REFERENCES PROFISSIONAL(id_pessoa) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_ano_residencia CHECK (ano_residencia IN ('R1', 'R2', 'R3'))
);

-- Criação da tabela para entidade UNIDADE
CREATE TABLE UNIDADE (
    -- Atributos:
    id_unidade SERIAL PRIMARY KEY, -- Mesma coisa que foi explicada anteriormente na tabela PESSOA
    nome VARCHAR(100) NOT NULL UNIQUE,
    tipo VARCHAR(50) NOT NULL,
    capacity_leitos INT NOT NULL DEFAULT 0,
    -- Restrições:
    CONSTRAINT chk_capacity CHECK (capacity_leitos >= 0)
);

-- Criação da tabela para entidade ATENDIMENTO
CREATE TABLE ATENDIMENTO (
    -- Atributos:
    id_atendimento SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL, -- Representa a relação com a tabela PACIENTE, paciente recebe atendimento
    id_residente INT NOT NULL, -- Representa a relação com a tabela RESIDENTE, residente realiza o atendimento
    id_preceptor INT NOT NULL, -- Representa a relação com a tabela PRECEPTOR, preceptor supervisiona o atendimento
    data_hora TIMESTAMP NOT NULL,
    duracao_minutos INT NOT NULL,
    -- Restrições:
    CONSTRAINT fk_atendimento_paciente FOREIGN KEY (id_paciente) REFERENCES PACIENTE(id_pessoa)
        ON UPDATE CASCADE,
    CONSTRAINT fk_atendimento_residente FOREIGN KEY (id_residente) REFERENCES RESIDENTE(id_profissional)
        ON UPDATE CASCADE,
    CONSTRAINT fk_atendimento_preceptor FOREIGN KEY (id_preceptor) REFERENCES PRECEPTOR(id_profissional)
        ON UPDATE CASCADE,
    CONSTRAINT chk_duracao CHECK (duracao_minutos > 0)
);

-- Criação da tabela para entidade PROCEDIMENTO
CREATE TABLE PROCEDIMENTO (
    -- Atributos:
    id_procedimento SERIAL PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nome VARCHAR(150) NOT NULL,
    tempo_medio_minutos INT NOT NULL,
    nivel_risco VARCHAR(10) NOT NULL DEFAULT 'BAIXO',
    -- Restrições:
    CONSTRAINT chk_tempo_medio CHECK (tempo_medio_minutos > 0),
    CONSTRAINT chk_nivel_risco CHECK (nivel_risco IN ('BAIXO', 'MEDIO', 'ALTO'))
);

-- Criação da tabela para entidade PROCEDIMENTO_REALIZADO, dependente de ATENDIMENTO e PROCEDIMENTO
CREATE TABLE PROCEDIMENTO_REALIZADO (
    -- Atributos:
    id_atendimento INT NOT NULL, -- Da tabela ATENDIMENTO
    id_procedimento INT NOT NULL, -- Da tabela PROCEDIMENTO
    quantidade INT NOT NULL DEFAULT 1,
    tempo_real_minutos INT NOT NULL,
    observacao TEXT,
    faturado BOOLEAN NOT NULL DEFAULT FALSE,
    -- Restrições:
    PRIMARY KEY (id_atendimento, id_procedimento),
    CONSTRAINT fk_proc_realizado_atendimento FOREIGN KEY (id_atendimento) REFERENCES ATENDIMENTO(id_atendimento) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_proc_realizado_procedimento FOREIGN KEY (id_procedimento) REFERENCES PROCEDIMENTO(id_procedimento) 
        ON UPDATE CASCADE,
    CONSTRAINT chk_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_tempo_real CHECK (tempo_real_minutos > 0)
);

-- Criação da tabela para entidade ESCALA
CREATE TABLE ESCALA (
    -- Atributos:
    id_escala SERIAL PRIMARY KEY,
    id_unidade INT NOT NULL,
    id_residente INT NOT NULL,
    id_preceptor INT NOT NULL,
    dia_semana VARCHAR(15) NOT NULL,
    turno VARCHAR(15) NOT NULL,
    -- Restrições:
    CONSTRAINT fk_escala_unidade FOREIGN KEY (id_unidade) REFERENCES UNIDADE(id_unidade) ON UPDATE CASCADE,
    CONSTRAINT fk_escala_residente FOREIGN KEY (id_residente) REFERENCES RESIDENTE(id_profissional) ON UPDATE CASCADE,
    CONSTRAINT fk_escala_preceptor FOREIGN KEY (id_preceptor) REFERENCES PRECEPTOR(id_profissional) ON UPDATE CASCADE,
    CONSTRAINT chk_dia_semana CHECK (dia_semana IN ('Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo')),
    CONSTRAINT chk_turno CHECK (turno IN ('Manhã', 'Tarde', 'Noite')),
    CONSTRAINT uq_escala_residente UNIQUE (id_unidade, dia_semana, turno, id_residente) -- Sem turno duplicado
);

-- Criação da tabela para entidade INTERNACAO
CREATE TABLE INTERNACAO (
    -- Atributos:
    id_internacao SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_unidade INT NOT NULL,
    id_residente INT NOT NULL,
    id_preceptor INT NOT NULL,
    data_hora_entrada TIMESTAMP NOT NULL,
    data_hora_saida TIMESTAMP, -- Nulo enquanto o paciente estiver internado
    -- Restrições:
    CONSTRAINT fk_internacao_paciente FOREIGN KEY (id_paciente) REFERENCES PACIENTE(id_pessoa) ON UPDATE CASCADE,
    CONSTRAINT fk_internacao_unidade FOREIGN KEY (id_unidade) REFERENCES UNIDADE(id_unidade) ON UPDATE CASCADE,
    CONSTRAINT fk_internacao_residente FOREIGN KEY (id_residente) REFERENCES RESIDENTE(id_profissional) ON UPDATE CASCADE,
    CONSTRAINT fk_internacao_preceptor FOREIGN KEY (id_preceptor) REFERENCES PRECEPTOR(id_profissional) ON UPDATE CASCADE,
    CONSTRAINT chk_datas_internacao CHECK (data_hora_saida IS NULL OR data_hora_saida >= data_hora_entrada)
);

-- Criação da tabela para entidade HISTORICO_PAPEL
CREATE TABLE HISTORICO_PAPEL (
    -- Atributos:
    id_historico_papel SERIAL PRIMARY KEY,
    id_profissional INT NOT NULL,
    papel VARCHAR(30) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE, -- Pode ser nulo se for o papel atual
    -- Restrições:
    CONSTRAINT fk_historico_profissional FOREIGN KEY (id_profissional) REFERENCES PROFISSIONAL(id_pessoa)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_papel CHECK (papel IN ('Residente', 'Preceptor')),
    CONSTRAINT chk_datas_historico CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);



