-- =========================================================================
-- 4.1 RANKING DOS RESIDENTES POR NÚMERO DE ATENDIMENTOS REALIZADOS
--     (mostrar nome e total, ordenado do maior para o menor)
-- =========================================================================
SELECT 
    p.nome AS nome_residente,
    COUNT(a.id_atendimento) AS total_atendimentos
FROM PESSOA p
JOIN RESIDENTE r 
    ON p.id_pessoa = r.id_profissional       -- Garante que a pessoa é um residente
LEFT JOIN ATENDIMENTO a 
    ON r.id_profissional = a.id_residente    -- LEFT JOIN garante que residentes com 0 atendimentos também apareçam
GROUP BY 
    p.nome, 
    r.id_profissional
ORDER BY 
    total_atendimentos DESC;