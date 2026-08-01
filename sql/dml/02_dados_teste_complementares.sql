-- 02b. Dados de teste complementares — enriquecimento do banco de dados.
-- Este script NÃO substitui o 01_dados_teste.sql: ele ADICIONA registros novos
-- em cima dos que já existem, usando IDs que continuam a partir de onde a
-- sequência parou (por isso deve ser executado DEPOIS do 01_dados_teste.sql).
--
-- Objetivo: dar volume e variedade suficientes para que as consultas de
-- sql/analytics/*.sql produzam resultados ricos (rankings com diferenças
-- claras, meses com múltiplos preceptores acima e abaixo do limite de 5
-- atendimentos, pacientes com e sem procedimento de risco ALTO, plantões
-- espalhados por todas as unidades) e também popular tabelas que ainda
-- estavam vazias (INTERNACAO, HISTORICO_PAPEL) e as tabelas multivaloradas
-- criadas na normalização (ALERGIA_PACIENTE, ESPECIALIDADE_PROFISSIONAL).

--\c hospital_db;

BEGIN;

-- =========================================================================
-- 1. PESSOA — 18 novas pessoas (ids 16 a 33)
--    16-25: pacientes novos (total de pacientes passa de 5 para 15)
--    26-30: profissionais novos que serão residentes (total de residentes: 5 -> 10)
--    31-33: profissionais novos que serão preceptores (total de preceptores: 5 -> 8)
-- =========================================================================
INSERT INTO PESSOA (id_pessoa, nome, cpf, data_nascimento, is_flamengo, telefone) VALUES
(16, 'Roberto Carlos Ximenes',     '66677788899', '1955-12-01', FALSE, '83992223301'),
(17, 'Vanessa Lima Cordeiro',      '77788899900', '1999-05-14', TRUE,  '83992223302'),
(18, 'Marcelo Antunes Braga',      '88899900011', '1982-09-09', FALSE, '83992223303'),
(19, 'Priscila Farias Gadelha',    '99900011122', '1973-02-28', TRUE,  '83992223304'),
(20, 'Diego Henrique Cunha',       '00011122233', '2010-06-30', FALSE, '83992223305'),
(21, 'Gabriela Souto Ramalho',     '10112233445', '1988-04-17', TRUE,  '83992223306'),
(22, 'Otávio Machado Guedes',      '20223344556', '1960-08-22', FALSE, '83992223307'),
(23, 'Renata Belchior Pinto',      '30334455667', '1995-11-11', TRUE,  '83992223308'),
(24, 'Felipe Andrade Correia',     '40445566778', '2001-07-04', FALSE, '83992223309'),
(25, 'Isabela Nóbrega Castro',     '50556677889', '1979-03-23', TRUE,  '83992223310'),
(26, 'Yasmin Cavalcante Diniz',    '60667788990', '1997-01-19', TRUE,  '83999991101'),
(27, 'Pedro Henrique Bezerra',     '70778899001', '1996-10-05', FALSE, '83999991102'),
(28, 'Nathalia Souza Peixoto',     '80889900112', '1998-03-30', TRUE,  '83999991103'),
(29, 'Igor Wanderley Costa',       '90990011223', '1994-06-16', FALSE, '83999991104'),
(30, 'Clarice Monteiro Lyra',      '01001122334', '1999-12-08', TRUE,  '83999991105'),
(31, 'Fábio Chaves Trindade',      '11223344556', '1972-02-11', FALSE, '83999992201'),
(32, 'Mônica Barreto Aragão',      '22334455667', '1965-09-27', TRUE,  '83999992202'),
(33, 'Otacílio Rangel Bessa',      '33445566778', '1969-05-05', FALSE, '83999992203');

-- =========================================================================
-- 2. PACIENTE + ALERGIA_PACIENTE
-- =========================================================================
INSERT INTO PACIENTE (id_pessoa, num_convenio, grupo_sanguineo) VALUES
(16, NULL,            'A-'),
(17, 'HAPVIDA-2201',  'B+'),
(18, NULL,            'O+'),
(19, 'UNIMED-3345',   'AB-'),
(20, NULL,            'A+'),
(21, 'BRADESCO-0099', 'O-'),
(22, NULL,            'B+'),
(23, 'AMIL-4456',     'A+'),
(24, NULL,            'O+'),
(25, 'HAPVIDA-5567',  'AB+');

-- Alergias: incluímos aqui um segundo registro para o paciente 1, que já
-- tinha "Dipirona" no script anterior — isso demonstra na prática por que
-- ALERGIA_PACIENTE foi normalizada como tabela à parte (um paciente pode
-- ter mais de uma alergia, o que violaria 1FN se fosse coluna única).
INSERT INTO ALERGIA_PACIENTE (id_paciente, alergia) VALUES
(1,  'Sulfa'),
(16, 'Poeira'),
(17, 'Amendoim'),
(17, 'Frutos do Mar'),
(19, 'Iodo'),
(21, 'Penicilina'),
(23, 'Dipirona'),
(23, 'AAS');
-- Pacientes 18, 20, 22, 24 e 25 ficam propositalmente sem nenhuma alergia
-- registrada, para reforçar que a alergia é opcional (ausência de linhas
-- na tabela filha, e não um NULL numa coluna).

-- =========================================================================
-- 3. PROFISSIONAL + ESPECIALIDADE_PROFISSIONAL
-- =========================================================================
INSERT INTO PROFISSIONAL (id_pessoa, crm, data_admissao) VALUES
(26, 'CRM-PB 12034', '2024-01-15'),
(27, 'CRM-PB 12245', '2023-11-20'),
(28, 'CRM-PB 12456', '2024-03-05'),
(29, 'CRM-PB 12667', '2023-08-12'),
(30, 'CRM-PB 12878', '2024-02-01'),
(31, 'CRM-PB 05012', '1995-03-10'),
(32, 'CRM-PB 05223', '1998-07-22'),
(33, 'CRM-PB 05434', '2001-01-30');

-- Alguns profissionais recebem DUAS especialidades, demonstrando o
-- relacionamento N:N criado na normalização (inclusive um profissional
-- que já existia desde o script anterior, id 11, ganha uma segunda
-- especialidade aqui).
INSERT INTO ESPECIALIDADE_PROFISSIONAL (id_profissional, especialidade) VALUES
(11, 'Geriatria'),                     -- especialidade extra p/ profissional já existente
(26, 'Clinica Medica'),
(27, 'Cirurgia Geral'),
(27, 'Cirurgia Vascular'),             -- segunda especialidade
(28, 'Pediatria'),
(29, 'Ortopedia'),
(29, 'Medicina Esportiva'),            -- segunda especialidade
(30, 'Ginecologia e Obstetricia'),
(31, 'Cardiologia'),
(32, 'Neurologia'),
(33, 'Cirurgia Geral'),
(33, 'Cirurgia Cardiovascular');       -- segunda especialidade

-- =========================================================================
-- 4. RESIDENTE (ids 26 a 30) e PRECEPTOR (ids 31 a 33)
-- =========================================================================
INSERT INTO RESIDENTE (id_profissional, ano_residencia) VALUES
(26, 'R1'),
(27, 'R2'),
(28, 'R1'),
(29, 'R3'),
(30, 'R2');

INSERT INTO PRECEPTOR (id_profissional, titulacao) VALUES
(31, 'Mestre'),
(32, 'Doutor'),
(33, 'Livre-Docente');

-- =========================================================================
-- 5. UNIDADE — 2 unidades novas (ids 5 e 6), ampliando de 4 para 6 unidades
-- =========================================================================
INSERT INTO UNIDADE (id_unidade, nome, tipo, capacidade_leitos) VALUES
(5, 'Centro Cirurgico', 'Centro Cirurgico', 6),
(6, 'Maternidade',      'Maternidade',      20);

-- =========================================================================
-- 6. PROCEDIMENTO — 2 procedimentos novos (ids 9 e 10)
-- =========================================================================
INSERT INTO PROCEDIMENTO (id_procedimento, codigo, nome, tempo_medio_minutos, nivel_risco) VALUES
(9,  'PRC-009', 'Endoscopia Digestiva Alta', 30, 'MEDIO'),
(10, 'PRC-010', 'Cardioversao Eletrica',     20, 'ALTO');

-- =========================================================================
-- 7. ATENDIMENTO — 20 atendimentos novos (ids 17 a 36)
--
-- Distribuídos de propósito para enriquecer as 4 consultas analíticas:
--   - Residente 6 (Marcos) já tinha 8 atendimentos vindos do script
--     anterior e segue isolado na liderança do ranking (4.1).
--   - Em MAIO/2026 (mês fixado na consulta 4.2), agora existem QUATRO
--     preceptores com atendimentos: preceptor 11 (6, já existentes),
--     preceptor 12 (6 novos) e preceptor 31 (7 novos) ULTRAPASSAM o
--     limite de 5 e aparecem no relatório; o preceptor 13 (3 novos)
--     FICA DE FORA por não ultrapassar o limite — ou seja, a consulta
--     agora mostra tanto quem entra quanto quem fica de fora do corte.
-- =========================================================================
INSERT INTO ATENDIMENTO (id_atendimento, id_paciente, id_residente, id_preceptor, data_hora, duracao_minutos) VALUES
(17, 1,  7,  12, '2026-05-02 08:00:00', 25),
(18, 1,  7,  12, '2026-05-04 09:00:00', 30),
(19, 2,  8,  12, '2026-05-06 10:00:00', 20),
(20, 2,  8,  12, '2026-05-08 11:00:00', 35),
(21, 16, 9,  12, '2026-05-10 08:30:00', 40),
(22, 16, 9,  12, '2026-05-12 09:30:00', 25),
(23, 3,  10, 13, '2026-05-03 08:00:00', 30),
(24, 17, 10, 13, '2026-05-14 09:00:00', 45),
(25, 18, 10, 13, '2026-05-16 10:00:00', 20),
(26, 19, 26, 31, '2026-05-05 08:00:00', 30),
(27, 20, 26, 31, '2026-05-07 09:00:00', 25),
(28, 21, 27, 31, '2026-05-09 10:00:00', 40),
(29, 22, 27, 31, '2026-05-11 11:00:00', 35),
(30, 23, 28, 31, '2026-05-13 08:30:00', 20),
(31, 24, 28, 31, '2026-05-15 09:30:00', 45),
(32, 25, 29, 31, '2026-05-17 10:30:00', 30),
(33, 4,  30, 32, '2026-06-10 08:00:00', 25),
(34, 5,  30, 32, '2026-06-12 09:00:00', 30),
(35, 16, 29, 33, '2026-07-01 08:00:00', 50),
(36, 17, 26, 33, '2026-07-03 09:00:00', 40);

-- =========================================================================
-- 8. PROCEDIMENTO_REALIZADO — 17 registros novos
--
-- Dá cobertura de procedimento a boa parte dos atendimentos novos, com
-- nível de risco variado. Resultado esperado na consulta 4.4 (pacientes
-- sem procedimento ALTO): pacientes 3, 16, 17, 19 e 23 ficam de FORA da
-- lista (têm ALTO); os demais pacientes novos (18, 20, 21, 22, 24, 25) e
-- os antigos (1, 2, 4, 5) continuam aparecendo na lista.
-- =========================================================================
INSERT INTO PROCEDIMENTO_REALIZADO (id_atendimento, id_procedimento, quantidade, tempo_real_minutos, observacao, faturado) VALUES
(17, 2,  1, 20, NULL,                                          TRUE),
(19, 7,  1, 15, NULL,                                          TRUE),
(21, 5,  1, 22, 'Procedimento de alto risco - paciente 16',    FALSE),
(23, 1,  1, 18, NULL,                                          TRUE),
(24, 4,  1, 28, 'Curativo pós-cirúrgico',                      TRUE),
(25, 1,  1, 19, NULL,                                          TRUE),
(26, 10, 1, 20, 'Procedimento cardíaco de alto risco',         FALSE),
(27, 2,  1, 8,  NULL,                                          TRUE),
(28, 9,  1, 32, NULL,                                          TRUE),
(29, 7,  1, 13, NULL,                                          TRUE),
(30, 6,  1, 42, 'Drenagem realizada com sucesso',               FALSE),
(31, 4,  1, 27, NULL,                                          TRUE),
(32, 8,  1, 33, 'Biópsia de rotina',                            FALSE),
(33, 2,  1, 9,  NULL,                                          TRUE),
(34, 7,  1, 14, NULL,                                          TRUE),
(35, 3,  1, 16, NULL,                                          TRUE),
(36, 5,  1, 24, 'Intubação emergencial',                        FALSE);

-- =========================================================================
-- 9. ESCALA — 15 plantões novos, distribuídos pelas 6 unidades
--    (a consulta 4.3 conta todas as linhas de ESCALA, então isso alimenta
--    diretamente o relatório de plantões por unidade e residente)
-- =========================================================================
INSERT INTO ESCALA (id_unidade, dia_semana, turno, id_residente, id_preceptor) VALUES
(1, 'Terca',   'Manha', 7,  12),
(1, 'Quinta',  'Tarde', 8,  13),
(2, 'Segunda', 'Noite', 9,  12),
(2, 'Quarta',  'Manha', 10, 13),
(2, 'Sexta',   'Tarde', 6,  11),
(3, 'Segunda', 'Tarde', 26, 31),
(3, 'Terca',   'Noite', 27, 31),
(3, 'Sabado',  'Manha', 28, 32),
(4, 'Domingo', 'Manha', 29, 32),
(4, 'Quinta',  'Noite', 30, 33),
(5, 'Sexta',   'Manha', 26, 31),
(5, 'Sabado',  'Tarde', 27, 31),
(6, 'Domingo', 'Tarde', 28, 33),
(6, 'Quarta',  'Noite', 29, 32),
(1, 'Sabado',  'Noite', 30, 33);

-- =========================================================================
-- 10. INTERNACAO — 6 internações novas (tabela ainda não tinha dados)
--     Mistura de pacientes já internados (data_hora_saida NULL) e já
--     recebeu alta (data_hora_saida preenchida), em unidades diferentes.
-- =========================================================================
INSERT INTO INTERNACAO (id_paciente, id_unidade, id_residente, id_preceptor, data_hora_entrada, data_hora_saida) VALUES
(1,  2, 6,  11, '2026-06-01 07:00:00', '2026-06-05 10:00:00'), -- já teve alta
(3,  1, 8,  13, '2026-06-02 09:00:00', NULL),                   -- internado no momento
(16, 3, 9,  12, '2026-05-10 08:00:00', '2026-05-11 08:00:00'), -- já teve alta
(19, 2, 26, 31, '2026-05-05 08:00:00', NULL),                   -- internado no momento
(21, 6, 27, 31, '2026-05-09 10:00:00', '2026-05-12 10:00:00'), -- já teve alta
(23, 5, 28, 31, '2026-05-13 08:30:00', NULL);                   -- internado no momento

-- =========================================================================
-- 11. HISTORICO_PAPEL — 9 registros (tabela ainda não tinha dados)
--
-- Ilustra a regra do enunciado: "um profissional pode atuar como
-- preceptor em um período e como residente em outro". Os três preceptores
-- mais antigos (11, 12, 31) têm um registro fechado como Residente no
-- passado (data_fim preenchida) seguido de um registro aberto como
-- Preceptor (data_fim NULL = papel atual). Alguns residentes atuais
-- também recebem seu registro de papel em aberto.
-- =========================================================================
INSERT INTO HISTORICO_PAPEL (id_profissional, papel, data_inicio, data_fim) VALUES
(11, 'Residente', '1999-03-01', '2004-03-01'),
(11, 'Preceptor', '2005-04-12', NULL),
(12, 'Residente', '1995-02-01', '2000-08-01'),
(12, 'Preceptor', '2000-09-01', NULL),
(31, 'Residente', '1998-03-01', '2003-02-28'),
(31, 'Preceptor', '2003-03-01', NULL),
(8,  'Residente', '2023-01-10', NULL),
(27, 'Residente', '2023-11-20', NULL),
(9,  'Residente', '2022-08-20', NULL);

COMMIT;

-- =========================================================================
-- Sincroniza as sequences das colunas SERIAL onde inserimos IDs manuais
-- (PESSOA, UNIDADE, ATENDIMENTO e PROCEDIMENTO). ESCALA, INTERNACAO e
-- HISTORICO_PAPEL usaram DEFAULT/auto-incremento, então já ficam em dia.
-- =========================================================================
SELECT setval(pg_get_serial_sequence('PESSOA', 'id_pessoa'), (SELECT MAX(id_pessoa) FROM PESSOA));
SELECT setval(pg_get_serial_sequence('UNIDADE', 'id_unidade'), (SELECT MAX(id_unidade) FROM UNIDADE));
SELECT setval(pg_get_serial_sequence('ATENDIMENTO', 'id_atendimento'), (SELECT MAX(id_atendimento) FROM ATENDIMENTO));
SELECT setval(pg_get_serial_sequence('PROCEDIMENTO', 'id_procedimento'), (SELECT MAX(id_procedimento) FROM PROCEDIMENTO));