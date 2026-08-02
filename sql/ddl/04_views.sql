-- Script SQL responsável por criar as views solicitadas para a etapa 2

-- View que retorna os pacientes internados atualmente
CREATE OR REPLACE VIEW vw_pacientes_internados AS
SELECT
    i.id_internacao,
    i.id_paciente,
    p.nome AS nome_paciente,
    i.id_unidade,
    u.nome AS nome_unidade,
    i.id_residente,
    resp.nome AS nome_residente,
    i.id_preceptor,
    prep.nome AS nome_preceptor,
    i.data_hora_entrada,
    i.data_hora_saida
FROM INTERNACAO i
JOIN PACIENTE pac ON pac.id_pessoa = i.id_paciente
JOIN PESSOA p ON p.id_pessoa = pac.id_pessoa
JOIN UNIDADE u ON u.id_unidade = i.id_unidade
JOIN RESIDENTE res ON res.id_profissional = i.id_residente
JOIN PESSOA resp ON resp.id_pessoa = res.id_profissional
JOIN PRECEPTOR prec ON prec.id_profissional = i.id_preceptor
JOIN PESSOA prep ON prep.id_pessoa = prec.id_profissional
WHERE i.data_hora_saida IS NULL;

-- View que retorna os residentes que ou não tem supervisor ou tem supervisor que não é um doutor
CREATE OR REPLACE VIEW vw_residentes_sem_supervisor AS
SELECT DISTINCT ON (e.id_residente)
    e.id_residente,
    resp.nome AS nome_residente,
    e.id_unidade,
    u.nome AS nome_unidade,
    e.id_preceptor,
    prep.nome AS nome_preceptor,
    prec.titulacao,
    CASE
        WHEN prec.titulacao <> 'Doutor' THEN 'Preceptor sem titulação de Doutor'
        ELSE 'Sem supervisão ativa' 
    END AS motivo
FROM ESCALA e
JOIN RESIDENTE res ON res.id_profissional = e.id_residente
JOIN PESSOA resp ON resp.id_pessoa = res.id_profissional
JOIN PRECEPTOR prec ON prec.id_profissional = e.id_preceptor
JOIN PESSOA prep ON prep.id_pessoa = prec.id_profissional
JOIN UNIDADE u ON u.id_unidade = e.id_unidade
WHERE prec.titulacao <> 'Doutor'
   OR NOT EXISTS (
        SELECT 1
        FROM HISTORICO_PAPEL hp
        WHERE hp.id_profissional = e.id_preceptor
          AND hp.papel = 'Preceptor'
          AND hp.data_inicio <= CURRENT_DATE
          AND (hp.data_fim IS NULL OR hp.data_fim >= CURRENT_DATE)
    );

-- View que retorna as estatísticas de atendimento, agrupados por mês e unidade
CREATE OR REPLACE VIEW vw_estatisticas_atendimentos_mensal AS
WITH estatisticas AS (
    SELECT
        DATE_TRUNC('month', a.data_hora)::DATE AS mes,
        a.id_unidade,
        COUNT(DISTINCT a.id_atendimento) AS total_atendimentos,
        ROUND(AVG(a.duracao_minutos)::NUMERIC, 2) AS media_duracao_minutos
    FROM ATENDIMENTO a
    GROUP BY DATE_TRUNC('month', a.data_hora)::DATE, a.id_unidade
),
procedimentos_por_mes_unidade AS (
    SELECT
        DATE_TRUNC('month', a.data_hora)::DATE AS mes,
        a.id_unidade,
        pr.id_procedimento,
        COUNT(*) AS qtd_procedimentos
    FROM ATENDIMENTO a
    JOIN PROCEDIMENTO_REALIZADO pr ON pr.id_atendimento = a.id_atendimento
    GROUP BY DATE_TRUNC('month', a.data_hora)::DATE, a.id_unidade, pr.id_procedimento
),
ranked_procedimentos AS (
    SELECT
        mes,
        id_unidade,
        id_procedimento,
        qtd_procedimentos,
        ROW_NUMBER() OVER (
            PARTITION BY mes, id_unidade
            ORDER BY qtd_procedimentos DESC, id_procedimento
        ) AS rn
    FROM procedimentos_por_mes_unidade
),
top_procedimentos AS (
    SELECT
        mes,
        id_unidade,
        JSONB_AGG(
            JSONB_BUILD_OBJECT(
                'procedimento', proc.nome,
                'qtd_vezes', ranked.qtd_procedimentos
            )
            ORDER BY ranked.qtd_procedimentos DESC, proc.nome
        ) AS procedimentos_mais_comuns
    FROM ranked_procedimentos ranked
    JOIN PROCEDIMENTO proc ON proc.id_procedimento = ranked.id_procedimento
    WHERE ranked.rn <= 3
    GROUP BY mes, id_unidade
)
SELECT
    e.mes,
    e.id_unidade,
    u.nome AS nome_unidade,
    e.total_atendimentos,
    e.media_duracao_minutos,
    tp.procedimentos_mais_comuns
FROM estatisticas e
JOIN UNIDADE u ON u.id_unidade = e.id_unidade
LEFT JOIN top_procedimentos tp
    ON tp.mes = e.mes
   AND tp.id_unidade = e.id_unidade
ORDER BY e.mes, e.id_unidade;
