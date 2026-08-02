-- Script SQL responsável por criar as procedures e funções do banco de dados, realizado na etapa 02

-- Procedure para registrar um atendimento completo, recebendo dados do atendimento e uma lista de procedimento em json
CREATE OR REPLACE PROCEDURE sp_registrar_atendimento_completo(
    IN p_id_paciente INT,
    IN p_id_residente INT,
    IN p_id_preceptor INT,
    IN p_id_unidade INT,
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
        id_unidade,
        data_hora,
        duracao_minutos
    )
    VALUES (
        p_id_paciente,
        p_id_residente,
        p_id_preceptor,
        p_id_unidade,
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
CREATE OR REPLACE PROCEDURE sp_calcular_tempo_medio_espera(INOUT p_resultado REFCURSOR)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_resultado FOR
    SELECT
        u.id_unidade,
        u.nome AS nome_unidade,
        COALESCE(
            ROUND(AVG(
                EXTRACT(EPOCH FROM (proc.inicio_primeiro_procedimento - a.data_hora)) / 60
            )::NUMERIC, 2), 
            0
        ) AS tempo_medio_espera_minutos
    FROM UNIDADE u
    LEFT JOIN ATENDIMENTO a ON u.id_unidade = a.id_unidade
    LEFT JOIN (
        SELECT
            id_atendimento,
            MIN(data_hora_inicio) AS inicio_primeiro_procedimento
        FROM PROCEDIMENTO_REALIZADO
        WHERE data_hora_inicio IS NOT NULL
        GROUP BY id_atendimento
    ) proc ON proc.id_atendimento = a.id_atendimento
    GROUP BY u.id_unidade, u.nome
    ORDER BY u.id_unidade;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_reajustar_escala(
    IN p_id_residente INT,
    IN p_id_unidade_origem INT,
    IN p_dia_origem VARCHAR,
    IN p_turno_origem VARCHAR,
    IN p_id_unidade_destino INT,
    IN p_dia_destino VARCHAR,
    IN p_turno_destino VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
    v_linhas_afetadas INT := 0;
BEGIN
    -- Evita transação nula
    IF p_id_unidade_origem = p_id_unidade_destino AND p_dia_origem = p_dia_destino AND p_turno_origem = p_turno_destino THEN
        RAISE EXCEPTION 'A origem e o destino selecionados são idênticos.';
    END IF;

    FOR r IN
        SELECT id_escala
        FROM ESCALA
        WHERE id_residente = p_id_residente
          AND id_unidade = p_id_unidade_origem
          AND dia_semana = p_dia_origem
          AND turno = p_turno_origem
    LOOP
        v_linhas_afetadas := v_linhas_afetadas + 1;

        UPDATE ESCALA
        SET id_unidade = p_id_unidade_destino,
            dia_semana = p_dia_destino,
            turno = p_turno_destino
        WHERE id_escala = r.id_escala;
    END LOOP;

    IF v_linhas_afetadas = 0 THEN
        RAISE EXCEPTION 'Nenhuma escala encontrada na origem (Unidade %, %, %).', p_id_unidade_origem, p_dia_origem, p_turno_origem;
    END IF;
END;
$$;

-- Função do trigger de verificação de sobreposição de escala
CREATE OR REPLACE FUNCTION trg_check_sobreposicao_escala_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ESCALA
        WHERE id_residente = NEW.id_residente
          AND dia_semana = NEW.dia_semana
          AND turno = NEW.turno
          AND id_unidade <> NEW.id_unidade
          AND (TG_OP = 'INSERT' OR id_escala <> NEW.id_escala)
    ) THEN
        RAISE EXCEPTION 'Residente % já está escalado no mesmo dia/turno em outra unidade', NEW.id_residente;
    END IF;

    RETURN NEW;
END;
$$;

-- Função do trigger de auditoria de atendimento
CREATE OR REPLACE FUNCTION trg_audita_atendimento_fn()
RETURNS TRIGGER AS $$
DECLARE
    v_antigo JSONB := NULL;
    v_novo JSONB := NULL;
BEGIN
    -- Monta o objeto JSON formatado para os dados ANTIGOS (usado em UPDATE e DELETE)
    IF (TG_OP = 'DELETE' OR TG_OP = 'UPDATE') THEN
        v_antigo := jsonb_build_object(
            'Data e Hora', OLD.data_hora,
            'Duração (Min)', OLD.duracao_minutos,
            'Unidade', (SELECT nome FROM UNIDADE WHERE id_unidade = OLD.id_unidade),
            'Paciente', (SELECT nome FROM PESSOA WHERE id_pessoa = OLD.id_paciente),
            'Residente', (SELECT nome FROM PESSOA WHERE id_pessoa = OLD.id_residente),
            'Preceptor', (SELECT nome FROM PESSOA WHERE id_pessoa = OLD.id_preceptor)
        );
    END IF;

    -- Monta o objeto JSON formatado para os dados NOVOS (usado em INSERT e UPDATE)
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        v_novo := jsonb_build_object(
            'Data e Hora', NEW.data_hora,
            'Duração (Min)', NEW.duracao_minutos,
            'Unidade', (SELECT nome FROM UNIDADE WHERE id_unidade = NEW.id_unidade),
            'Paciente', (SELECT nome FROM PESSOA WHERE id_pessoa = NEW.id_paciente),
            'Residente', (SELECT nome FROM PESSOA WHERE id_pessoa = NEW.id_residente),
            'Preceptor', (SELECT nome FROM PESSOA WHERE id_pessoa = NEW.id_preceptor)
        );
    END IF;

    -- Executa a inserção na tabela de Auditoria dependendo da operação
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO AUDITORIA_ATENDIMENTO (id_atendimento, operacao, usuario, dados_antigos, dados_novos)
        VALUES (OLD.id_atendimento, 'Exclusao', current_user, v_antigo, NULL);
        RETURN OLD;
        
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO AUDITORIA_ATENDIMENTO (id_atendimento, operacao, usuario, dados_antigos, dados_novos)
        VALUES (NEW.id_atendimento, 'Atualizacao', current_user, v_antigo, v_novo);
        RETURN NEW;
        
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO AUDITORIA_ATENDIMENTO (id_atendimento, operacao, usuario, dados_antigos, dados_novos)
        VALUES (NEW.id_atendimento, 'Insercao', current_user, NULL, v_novo);
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Função do trigger de atualização de média de procedimentos
CREATE OR REPLACE FUNCTION trg_atualiza_media_procedimentos_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_media INT;
BEGIN
    SELECT ROUND(AVG(tempo_real_minutos)::numeric)::INT
    INTO v_media
    FROM PROCEDIMENTO_REALIZADO
    WHERE id_procedimento = NEW.id_procedimento;

    UPDATE PROCEDIMENTO
    SET tempo_medio_minutos = v_media
    WHERE id_procedimento = NEW.id_procedimento;

    RETURN NULL;
END;
$$;