-- 02. Script de inserção de dados de teste para o sistema de gestão hospitalar.
-- Requisito Etapa 1 (item 2): mínimo de 5 pacientes, 5 residentes, 5 preceptores,

BEGIN;

-- =========================================================
-- 1. PESSOA
-- Pessoas 1-5  -> PACIENTES
-- Pessoas 6-10 -> PROFISSIONAIS / RESIDENTES
-- Pessoas 11-15 -> PROFISSIONAIS / PRECEPTORES
-- =========================================================
INSERT INTO PESSOA (id_pessoa, nome, cpf, data_nascimento, is_flamengo, telefone) VALUES
(1,  'Ana Beatriz Souza Lima',      '12345678901', '1985-03-12', TRUE,  '83991234501'),
(2,  'Carlos Eduardo Nunes',        '23456789012', '1990-07-22', FALSE, '83991234502'),
(3,  'Fernanda Costa Rocha',        '34567890123', '1978-11-05', TRUE,  '83991234503'),
(4,  'Bruno Henrique Alves',        '45678901234', '2000-01-30', FALSE, '83991234504'),
(5,  'Juliana Pereira Dias',        '56789012345', '1965-09-18', TRUE,  '83991234505'),
(6,  'Marcos Vinicius Silva',       '67890123456', '1996-04-10', FALSE, '83998887701'),
(7,  'Larissa Mendes Farias',       '78901234567', '1995-06-25', TRUE,  '83998887702'),
(8,  'Rafael Augusto Torres',      '89012345678', '1994-12-02', FALSE, '83998887703'),
(9,  'Camila Andrade Souza',        '90123456789', '1997-02-14', TRUE,  '83998887704'),
(10, 'Thiago Barbosa Lima',         '01234567890', '1993-08-08', FALSE, '83998887705'),
(11, 'Patricia Gomes Melo',         '11122233344', '1975-05-19', TRUE,  '83997776601'),
(12, 'Eduardo Ramos Vieira',        '22233344455', '1970-10-01', FALSE, '83997776602'),
(13, 'Simone Cavalcanti Barros',    '33344455566', '1980-03-27', FALSE, '83997776603'),
(14, 'Andre Luiz Ferreira',         '44455566677', '1968-07-14', TRUE,  '83997776604'),
(15, 'Beatriz Nogueira Sa',         '55566677788', '1982-01-09', FALSE, '83997776605');

-- =========================================================
-- 2. PACIENTE (subtipo de PESSOA, ids 1 a 5)
-- =========================================================
INSERT INTO PACIENTE (id_pessoa, num_convenio, grupo_sanguineo) VALUES
(1, 'UNIMED-0001', 'O+'),
(2, NULL,          'A+'),
(3, 'BRADESCO-0045', 'B-'),
(4, NULL,          'AB+'),
(5, 'AMIL-1123',   'O-');

INSERT INTO alergia_paciente (id_paciente, alergia) VALUES
(1, 'Dipirona'),
(3, 'Penicilina'),
(5, 'Latex');

-- =========================================================
-- 3. PROFISSIONAL (subtipo de PESSOA, ids 6 a 15)
-- =========================================================
INSERT INTO PROFISSIONAL (id_pessoa, crm, data_admissao) VALUES
(6,  'CRM-PB 10234', '2022-02-01'),
(7,  'CRM-PB 10567', '2021-03-15'),
(8,  'CRM-PB 10789', '2023-01-10'),
(9,  'CRM-PB 11023', '2022-08-20'),
(10, 'CRM-PB 11245', '2023-06-05'),
(11, 'CRM-PB 08123', '2005-04-12'),
(12, 'CRM-PB 07456', '2000-09-01'),
(13, 'CRM-PB 09011', '2010-11-23'),
(14, 'CRM-PB 06789', '1998-06-17'),
(15, 'CRM-PB 09345', '2012-02-28');

INSERT INTO especialidade_profissional (id_profissional, especialidade) VALUES
(6,  'Clinica Medica'),
(7,  'Pediatria'),
(8,  'Cirurgia Geral'),
(9,  'Ginecologia e Obstetricia'),
(10, 'Ortopedia'),
(11, 'Clinica Médica'),
(12, 'Cirurgia Geral'),
(13, 'Pediatria'),
(14, 'Ortopedia'),
(15, 'Ginecologia e Obstetricia');

-- =========================================================
-- 4. RESIDENTE (subtipo de PROFISSIONAL, ids 6 a 10)
-- =========================================================
INSERT INTO RESIDENTE (id_profissional, ano_residencia) VALUES
(6,  'R2'),
(7,  'R1'),
(8,  'R3'),
(9,  'R1'),
(10, 'R2');

-- =========================================================
-- 5. PRECEPTOR (subtipo de PROFISSIONAL, ids 11 a 15)
-- =========================================================
INSERT INTO PRECEPTOR (id_profissional, titulacao) VALUES
(11, 'Doutor'),
(12, 'Mestre'),
(13, 'Livre-Docente'),
(14, 'Especialista'),
(15, 'Doutor');

-- =========================================================
-- 6. UNIDADE (mínimo 3, incluímos 4 para refletir o enunciado)
-- =========================================================
INSERT INTO UNIDADE (id_unidade, nome, tipo, capacity_leitos) VALUES
(1, 'Enfermaria Geral',      'Enfermaria',     40),
(2, 'UTI Adulto',            'UTI',            10),
(3, 'Pronto-Socorro Central','Pronto-Socorro', 15),
(4, 'Ambulatorio Central',   'Ambulatorio',    0);

-- =========================================================
-- 7. ATENDIMENTO (10 atendimentos)
-- =========================================================
INSERT INTO ATENDIMENTO (id_atendimento, id_paciente, id_residente, id_preceptor, data_hora, duracao_minutos) VALUES
(1,  1, 6,  11, '2026-06-01 08:30:00', 30),
(2,  2, 7,  12, '2026-06-01 09:15:00', 20),
(3,  3, 8,  13, '2026-06-02 10:00:00', 45),
(4,  4, 9,  14, '2026-06-02 11:30:00', 25),
(5,  5, 10, 15, '2026-06-03 14:00:00', 60),
(6,  1, 7,  11, '2026-06-03 15:20:00', 15),
(7,  2, 8,  12, '2026-06-04 08:00:00', 40),
(8,  3, 9,  13, '2026-06-04 09:45:00', 35),
(9,  4, 10, 14, '2026-06-05 13:10:00', 50),
(10, 5, 6,  15, '2026-06-05 16:00:00', 20);

-- =========================================================
-- 8. PROCEDIMENTO (catálogo de procedimentos)
-- =========================================================
INSERT INTO PROCEDIMENTO (id_procedimento, codigo, nome, tempo_medio_minutos, nivel_risco) VALUES
(1, 'PRC-001', 'Sutura Simples',              20, 'BAIXO'),
(2, 'PRC-002', 'Coleta de Sangue',            10, 'BAIXO'),
(3, 'PRC-003', 'Aplicaçao de Medicaçao IV',   15, 'BAIXO'),
(4, 'PRC-004', 'Curativo Complexo',           30, 'MEDIO'),
(5, 'PRC-005', 'Intubaçao Orotraqueal',       25, 'ALTO'),
(6, 'PRC-006', 'Drenagem Toracica',           40, 'ALTO'),
(7, 'PRC-007', 'Raio-X Simples',              15, 'BAIXO'),
(8, 'PRC-008', 'Biopsia',                     35, 'MEDIO');

-- =========================================================
-- 9. PROCEDIMENTO_REALIZADO (10 registros, PK composta
--    id_atendimento + id_procedimento)
-- =========================================================
INSERT INTO PROCEDIMENTO_REALIZADO (id_atendimento, id_procedimento, quantidade, tempo_real_minutos, observacao, faturado) VALUES
(1,  1, 1, 22, 'Sem intercorrencias',                       TRUE),
(2,  2, 1, 8,  NULL,                                        TRUE),
(3,  5, 1, 28, 'Paciente estavel durante o procedimento',  FALSE),
(4,  3, 2, 18, NULL,                                        TRUE),
(5,  6, 1, 45, 'Procedimento de alta complexidade',        FALSE),
(6,  7, 1, 12, NULL,                                        TRUE),
(7,  4, 1, 33, 'Curativo trocado',                          TRUE),
(8,  2, 1, 9,  NULL,                                        TRUE),
(9,  8, 1, 40, 'Amostra enviada para laboratorio',         FALSE),
(10, 1, 1, 18, NULL,                                        TRUE);

-- =========================================================
-- Sincroniza as sequences das colunas SERIAL, já que os IDs
-- foram inseridos manualmente (evita conflito em INSERTs futuros
-- que usem DEFAULT/nextval).
-- =========================================================
SELECT setval(pg_get_serial_sequence('PESSOA', 'id_pessoa'), (SELECT MAX(id_pessoa) FROM PESSOA));
SELECT setval(pg_get_serial_sequence('UNIDADE', 'id_unidade'), (SELECT MAX(id_unidade) FROM UNIDADE));
SELECT setval(pg_get_serial_sequence('ATENDIMENTO', 'id_atendimento'), (SELECT MAX(id_atendimento) FROM ATENDIMENTO));
SELECT setval(pg_get_serial_sequence('PROCEDIMENTO', 'id_procedimento'), (SELECT MAX(id_procedimento) FROM PROCEDIMENTO));

-- =========================================================================
-- DADOS EXTRAS PARA VALIDAR AS CONSULTAS ANALÍTICAS 
-- =========================================================================

-- 1. Casos para a Consulta 4.2 (Preceptores com > 5 atendimentos no mês 05/2026)
-- Inserindo 6 atendimentos no mesmo mês para o mesmo Preceptor e Residente
INSERT INTO ATENDIMENTO (data_hora, duracao_minutos, id_paciente, id_residente, id_preceptor) 
VALUES
('2026-05-01 08:00:00', 30, (SELECT id_pessoa FROM PACIENTE LIMIT 1), (SELECT id_profissional FROM RESIDENTE LIMIT 1), (SELECT id_profissional FROM PRECEPTOR LIMIT 1)),
('2026-05-05 09:30:00', 45, (SELECT id_pessoa FROM PACIENTE LIMIT 1), (SELECT id_profissional FROM RESIDENTE LIMIT 1), (SELECT id_profissional FROM PRECEPTOR LIMIT 1)),
('2026-05-10 10:15:00', 20, (SELECT id_pessoa FROM PACIENTE LIMIT 1), (SELECT id_profissional FROM RESIDENTE LIMIT 1), (SELECT id_profissional FROM PRECEPTOR LIMIT 1)),
('2026-05-15 14:00:00', 60, (SELECT id_pessoa FROM PACIENTE LIMIT 1), (SELECT id_profissional FROM RESIDENTE LIMIT 1), (SELECT id_profissional FROM PRECEPTOR LIMIT 1)),
('2026-05-20 15:30:00', 15, (SELECT id_pessoa FROM PACIENTE LIMIT 1), (SELECT id_profissional FROM RESIDENTE LIMIT 1), (SELECT id_profissional FROM PRECEPTOR LIMIT 1)),
('2026-05-25 11:00:00', 40, (SELECT id_pessoa FROM PACIENTE LIMIT 1), (SELECT id_profissional FROM RESIDENTE LIMIT 1), (SELECT id_profissional FROM PRECEPTOR LIMIT 1));


-- 2. Casos para a Consulta 4.3 (Plantões por Unidade e Residente)
-- Inserindo escalas fixas semanais para os residentes
INSERT INTO ESCALA (id_unidade, id_residente, id_preceptor, dia_semana, turno) 
VALUES
((SELECT id_unidade FROM UNIDADE LIMIT 1), (SELECT id_profissional FROM RESIDENTE LIMIT 1), (SELECT id_profissional FROM PRECEPTOR LIMIT 1), 'Segunda', 'Manha'),
((SELECT id_unidade FROM UNIDADE LIMIT 1), (SELECT id_profissional FROM RESIDENTE LIMIT 1), (SELECT id_profissional FROM PRECEPTOR LIMIT 1), 'Quarta', 'Tarde'),
((SELECT id_unidade FROM UNIDADE LIMIT 1), (SELECT id_profissional FROM RESIDENTE OFFSET 1 LIMIT 1), (SELECT id_profissional FROM PRECEPTOR LIMIT 1), 'Sexta', 'Noite');
COMMIT;