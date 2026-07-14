-- =========================================================================
-- 3.2 LISTAR TODOS OS ATENDIMENTOS DE UM PACIENTE ESPECÍFICO
--     (ordenados por data)
-- =========================================================================
SELECT
    a.id_atendimento,
    pes_pac.nome            AS nome_paciente,
    a.data_hora,
    a.duracao_minutos,
    pes_res.nome            AS nome_residente,
    pes_prec.nome           AS nome_preceptor
FROM ATENDIMENTO a
JOIN PACIENTE      pac       ON pac.id_pessoa = a.id_paciente
JOIN PESSOA        pes_pac   ON pes_pac.id_pessoa = pac.id_pessoa
JOIN RESIDENTE     res       ON res.id_profissional = a.id_residente
JOIN PESSOA        pes_res   ON pes_res.id_pessoa = res.id_profissional
JOIN PRECEPTOR     prec      ON prec.id_profissional = a.id_preceptor
JOIN PESSOA        pes_prec  ON pes_prec.id_pessoa = prec.id_profissional
WHERE a.id_paciente = 1          -- <-- troque pelo id do paciente desejado
ORDER BY a.data_hora;