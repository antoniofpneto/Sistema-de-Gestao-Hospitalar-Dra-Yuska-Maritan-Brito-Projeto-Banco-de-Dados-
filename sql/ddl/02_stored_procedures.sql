-- Script SQL responsável por criar as procedures e funções do banco de dados, realizado na etapa 02

-- Procedure para registrar um atendimento completo, recebendo dados do atendimento e uma lista de procedimento em json
CREATE OR REPLACE PROCEDURE sp_registrar_atendimento_completo(
    IN p_id_paciente INT,
    IN p_id_residente INT,
    IN p_id_preceptor INT,
    IN p_data_hora TIMESTAMP,
    IN p_duracao_minutos INT,
    IN p_procedimentos JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_atendimento INT;
    v_proc JSONB;
BEGIN
    IF p_duracao_minutos <= 0 THEN
        RAISE EXCEPTION 'duracao_minutos deve ser maior que zero';
    END IF;

    INSERT INTO ATENDIMENTO (
        id_paciente,
        id_residente,
        id_preceptor,
        data_hora,
        duracao_minutos
    )
    VALUES (
        p_id_paciente,
        p_id_residente,
        p_id_preceptor,
        p_data_hora,
        p_duracao_minutos
    )
    RETURNING id_atendimento INTO v_id_atendimento;

    -- Para cada procedimento que aconteceu no atendimento, insere na tabela PROCEDIMENTO_REALIZADO
    FOR v_proc IN
        SELECT * FROM jsonb_array_elements(COALESCE(p_procedimentos, '[]'::jsonb))
    LOOP
        INSERT INTO PROCEDIMENTO_REALIZADO (
            id_atendimento,
            id_procedimento,
            quantidade,
            tempo_real_minutos,
            observacao,
            faturado,
            data_hora_inicio
        )
        VALUES (
            v_id_atendimento,
            (v_proc->>'id_procedimento')::INT,
            COALESCE((v_proc->>'quantidade')::INT, 1),
            (v_proc->>'tempo_real_minutos')::INT,
            v_proc->>'observacao',
            COALESCE((v_proc->>'faturado')::BOOLEAN, FALSE),
            CASE
                WHEN v_proc->>'data_hora_inicio' IS NULL OR v_proc->>'data_hora_inicio' = '' THEN
                    p_data_hora
                ELSE
                    (v_proc->>'data_hora_inicio')::TIMESTAMP
            END
        );
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Falha ao registrar atendimento completo: %', SQLERRM;
END;
$$;

-- Função para calcular o tempo médio entre a chegada do paciente e o início do primeiro procedimento realizado, agrupando por unidade
CREATE OR REPLACE FUNCTION sp_calcular_tempo_medio_espera()
RETURNS TABLE (
    id_unidade INT,
    nome_unidade VARCHAR,
    tempo_medio_espera_minutos NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_unidade,
        u.nome,
        ROUND(AVG(
            EXTRACT(EPOCH FROM (proc.inicio_primeiro_procedimento - a.data_hora)) / 60
        )::NUMERIC, 2) AS tempo_medio_espera_minutos
    FROM ATENDIMENTO a
    JOIN (
        SELECT
            id_atendimento,
            MIN(data_hora_inicio) AS inicio_primeiro_procedimento
        FROM PROCEDIMENTO_REALIZADO
        WHERE data_hora_inicio IS NOT NULL
        GROUP BY id_atendimento
    ) proc ON proc.id_atendimento = a.id_atendimento
    JOIN UNIDADE u ON u.id_unidade = a.id_unidade
    GROUP BY a.id_unidade, u.nome;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_reajustar_escala(
    IN p_id_residente INT,
    IN p_dia_origem VARCHAR,
    IN p_turno_origem VARCHAR,
    IN p_dia_destino VARCHAR,
    IN p_turno_destino VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    IF p_dia_origem = p_dia_destino AND p_turno_origem = p_turno_destino THEN
        RAISE EXCEPTION 'Origem e destino não podem ser iguais';
    END IF;

    FOR r IN
        SELECT id_escala, id_unidade
        FROM ESCALA
        WHERE id_residente = p_id_residente
          AND dia_semana = p_dia_origem
          AND turno = p_turno_origem
    LOOP
        IF EXISTS (
            SELECT 1
            FROM ESCALA
            WHERE id_unidade = r.id_unidade
              AND id_residente = p_id_residente
              AND dia_semana = p_dia_destino
              AND turno = p_turno_destino
              AND id_escala <> r.id_escala
        ) THEN
            RAISE EXCEPTION 'Conflito de escala para o residente % na unidade %', p_id_residente, r.id_unidade;
        END IF;

        UPDATE ESCALA
        SET dia_semana = p_dia_destino,
            turno = p_turno_destino
        WHERE id_escala = r.id_escala;
    END LOOP;
END;
$$;


