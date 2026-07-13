-- =========================================================================
-- 3.4 ATUALIZAR OS DADOS DE UM PACIENTE (convênio)
-- =========================================================================
-- Observação: o schema atual não possui coluna "endereço" em PACIENTE
-- (apenas num_convenio, alergias e grupo_sanguineo). O exemplo abaixo
-- atualiza o convênio; caso queira, o mesmo padrão serve para alergias
-- e grupo_sanguineo.

UPDATE PACIENTE
SET num_convenio = 'UNIMED-9999'
WHERE id_pessoa = 2;             -- <-- troque pelo id do paciente desejado

-- Exemplo alternativo: atualizando também as alergias registradas
-- UPDATE PACIENTE
-- SET alergias = 'Dipirona, Ibuprofeno'
-- WHERE id_pessoa = 2;