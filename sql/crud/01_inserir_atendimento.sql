-- =========================================================================
-- 3.1 INSERIR UM NOVO ATENDIMENTO
--     (verificando se paciente, residente e preceptor existem)
-- =========================================================================

INSERT INTO ATENDIMENTO (id_paciente, id_residente, id_preceptor, data_hora, duracao_minutos)
SELECT 3, 8, 13, '2026-07-10 09:00:00', 30
WHERE 
    EXISTS (SELECT 1 FROM PACIENTE WHERE id_pessoa = 3) AND
    EXISTS (SELECT 1 FROM RESIDENTE WHERE id_profissional = 8) AND
    EXISTS (SELECT 1 FROM PRECEPTOR WHERE id_profissional = 13);