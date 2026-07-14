--\c hospital_db;

-- =========================================================================
-- 3.1 INSERIR UM NOVO ATENDIMENTO
--     (verificando se paciente, residente e preceptor existem)
-- =========================================================================
-- Usamos um bloco anônimo DO $$ ... $$ do PostgreSQL. Ele roda a lógica
-- procedural (IF/RAISE) uma única vez, sem criar uma função permanente
-- no banco — por isso ainda é "SQL puro" no sentido do enunciado, e não
-- uma stored procedure (que só é pedida na Etapa 2).
--
-- Se qualquer um dos três IDs não existir, o bloco inteiro é abortado
-- com RAISE EXCEPTION e nada é inserido (comportamento transacional
-- padrão do PostgreSQL: um erro dentro do DO desfaz a instrução).

DO $$
DECLARE
    v_id_paciente   INT := 3;                        -- Fernanda Costa Rocha
    v_id_residente  INT := 8;                        -- Rafael Augusto Torres
    v_id_preceptor  INT := 13;                       -- Simone Cavalcanti Barros
    v_data_hora     TIMESTAMP := '2026-07-10 09:00:00';
    v_duracao       INT := 30;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PACIENTE WHERE id_pessoa = v_id_paciente) THEN
        RAISE EXCEPTION 'Paciente com id % não encontrado.', v_id_paciente;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM RESIDENTE WHERE id_profissional = v_id_residente) THEN
        RAISE EXCEPTION 'Residente com id % não encontrado.', v_id_residente;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM PRECEPTOR WHERE id_profissional = v_id_preceptor) THEN
        RAISE EXCEPTION 'Preceptor com id % não encontrado.', v_id_preceptor;
    END IF;

    INSERT INTO ATENDIMENTO (id_paciente, id_residente, id_preceptor, data_hora, duracao_minutos)
    VALUES (v_id_paciente, v_id_residente, v_id_preceptor, v_data_hora, v_duracao);

    RAISE NOTICE 'Atendimento inserido com sucesso para o paciente %.', v_id_paciente;
END $$;

-- Observação: mesmo sem essas verificações explícitas, as FOREIGN KEYs
-- definidas no DDL (fk_atendimento_paciente, fk_atendimento_residente,
-- fk_atendimento_preceptor) já impediriam a inserção com IDs inexistentes,
-- retornando um erro de violação de chave estrangeira. A verificação acima
-- só antecipa esse erro com uma mensagem mais clara para quem for operar o sistema.