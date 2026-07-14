-- =========================================================================
-- 3.3 LISTAR OS PROCEDIMENTOS REALIZADOS EM UM ATENDIMENTO
--     (com nome do procedimento, quantidade e tempo real)
-- =========================================================================
SELECT
    pr.id_atendimento,
    proc.codigo               AS codigo_procedimento,
    proc.nome                 AS nome_procedimento,
    pr.quantidade,
    pr.tempo_real_minutos,
    proc.tempo_medio_minutos,
    pr.observacao,
    pr.faturado
FROM PROCEDIMENTO_REALIZADO pr
JOIN PROCEDIMENTO proc ON proc.id_procedimento = pr.id_procedimento
WHERE pr.id_atendimento = 1 <-- id do atendimento específico
ORDER BY proc.nome;