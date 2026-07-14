-- =========================================================================
-- 3.6 CALCULAR O TEMPO MÉDIO DE DURAÇÃO DOS ATENDIMENTOS POR RESIDENTE
-- =========================================================================
-- LEFT JOIN garante que residentes sem nenhum atendimento ainda apareçam
-- na listagem (com total 0 e média NULL), em vez de serem omitidos.

SELECT
    pes.nome                                AS nome_residente,
    res.ano_residencia,
    COUNT(a.id_atendimento)                 AS total_atendimentos,
    ROUND(AVG(a.duracao_minutos)::NUMERIC, 2) AS duracao_media_minutos
FROM RESIDENTE res
JOIN PESSOA pes            ON pes.id_pessoa = res.id_profissional
LEFT JOIN ATENDIMENTO a    ON a.id_residente = res.id_profissional
GROUP BY pes.nome, res.ano_residencia
ORDER BY duracao_media_minutos DESC NULLS LAST;