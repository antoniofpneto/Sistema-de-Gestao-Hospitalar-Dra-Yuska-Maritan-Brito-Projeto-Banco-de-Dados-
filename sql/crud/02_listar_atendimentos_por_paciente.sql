-- =========================================================================
-- 3.2 LISTAR TODOS OS ATENDIMENTOS DE UM PACIENTE ESPECÍFICO
--     (ordenados por data)
-- =========================================================================
SELECT
    pes_pac.nome            AS nome_paciente,
    a.id_atendimento,
    a.data_hora,
    a.duracao_minutos,
    pes_res.nome            AS nome_residente,
    pes_prec.nome           AS nome_preceptor
FROM PESSOA pes_pac

JOIN PACIENTE pac           ON pac.id_pessoa = pes_pac.id_pessoa

LEFT JOIN ATENDIMENTO a     ON a.id_paciente = pac.id_pessoa

LEFT JOIN RESIDENTE res     ON res.id_profissional = a.id_residente
LEFT JOIN PESSOA pes_res    ON pes_res.id_pessoa = res.id_profissional

LEFT JOIN PRECEPTOR prec    ON prec.id_profissional = a.id_preceptor
LEFT JOIN PESSOA pes_prec   ON pes_prec.id_pessoa = prec.id_profissional

WHERE pes_pac.id_pessoa = 1  -- ID do paciente buscado
ORDER BY a.data_hora;