-- =========================================================================
-- 4.3 QUANTIDADE DE PLANTÕES ESCALADOS POR UNIDADE E RESIDENTE NO MÊS
--     (Considerando a modelagem de escala semanal, multiplicamos a
--      contagem de plantões fixos por 4 semanas)
-- =========================================================================
SELECT 
    u.nome                   AS nome_unidade,
    p.nome                   AS nome_residente,
    (COUNT(e.id_escala) * 4) AS qtd_plantoes_mes
FROM ESCALA e
JOIN UNIDADE u 
    ON e.id_unidade = u.id_unidade                   -- Traz o nome da unidade
JOIN RESIDENTE r 
    ON e.id_residente = r.id_profissional            -- Filtra os residentes da escala
JOIN PESSOA p 
    ON r.id_profissional = p.id_pessoa               -- Traz o nome do residente
GROUP BY 
    u.nome, 
    p.nome
ORDER BY 
    u.nome ASC,                                      -- Agrupa visualmente por unidade
    qtd_plantoes_mes DESC;                           -- Mostra quem dá mais plantões no topo