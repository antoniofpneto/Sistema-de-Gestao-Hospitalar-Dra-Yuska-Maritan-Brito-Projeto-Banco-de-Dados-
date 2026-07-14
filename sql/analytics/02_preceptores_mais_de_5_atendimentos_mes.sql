-- =========================================================================
-- 4.2 PRECEPTORES QUE SUPERVISIONARAM MAIS DE 5 ATENDIMENTOS NO MÊS
--     (filtra por mês/ano e exibe apenas preceptores com mais de 5 supervisões)
-- =========================================================================
SELECT 
    p.nome                  AS nome_preceptor,
    prec.titulacao          AS titulacao,
    COUNT(a.id_atendimento) AS total_supervisoes
FROM PESSOA p
JOIN PRECEPTOR prec 
    ON p.id_pessoa = prec.id_profissional             -- Garante que o profissional é um preceptor
JOIN ATENDIMENTO a 
    ON prec.id_profissional = a.id_preceptor          -- Cruza com a tabela de atendimentos
WHERE 
    EXTRACT(MONTH FROM a.data_hora) = 5             
    AND EXTRACT(YEAR FROM a.data_hora) = 2026         -- <-- Troque pelo ano desejado
GROUP BY 
    p.nome, 
    prec.titulacao
HAVING 
    COUNT(a.id_atendimento) > 5                       -- Regra: apenas quem supervisionou MAIS de 5
ORDER BY 
    total_supervisoes DESC;